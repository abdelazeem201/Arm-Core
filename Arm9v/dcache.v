`timescale 1ns/10ps
`include "pardef"
/*****************************************************************************
$RCSfile: dcache.v,v $
$Revision: 1.15 $
$Author: kohlere $
$Date: 2000/05/04 16:31:08 $
$State: Exp $


Description:  D-Cache Controller Unit for the ARM Microprocessor.  The
		cache is line addressable, so data writes use a read-
		modify-write protocol.

	Notes:	DMAS	11 => double word
			10 => word
			01 => halfword
			00 => byte

                DnWr    0  => data memory write
                        1  => data memory read

		Tag = D,V,tag

*****************************************************************************/

module dcache (nGCLK, nRESET, DA, DD, dmiss, DnMREQ, DMAS, DnWR,
		MMD, mmd_valid, istall, dwb, dmiss_addr, 
		drive_mmd, doublehold, BIGEND, initializing,
		swic, swic_data, DABORT, decomp,
		flush);

/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/
input   [31:0]  DA;             //Instruction Address Bus
input   [31:0]  swic_data;      //SWIC Word to Store
input	[1:0]	DMAS;		//Data Memory Access Size
input		nGCLK;		//Global Clock
input		nRESET;		//Global Reset
input		DnMREQ;		//Not Instruction Memory Request
input		DnWR;		//Data Not Write, Read
input		DABORT;		//Data Access Abort
input		BIGEND;		//Endianness of Main Memory
input		mmd_valid;	//MMD is Valid, Increment Counter
input		drive_mmd;	//Bus Granted via MMU
input		istall;		//ICache Miss
input           swic;           //SWIC Requested
input		decomp;		//Decompressor Running
input		flush;		//Flush a line from Cache

inout	[63:0]	DD;		//Data Data Bus
inout	[31:0]	MMD;		//Main Memory Data Bus

output	[31:0]	dmiss_addr;	//Miss Addr to MMU
output		doublehold;	//Hold for One Cycle
output		dmiss;		//Instruction Cache Miss
output		dwb;		//Data Write Back Required
output		initializing;	//Initializing Tags

/*------------------------------------------------------------------------
        Signal Declarations
------------------------------------------------------------------------*/
reg	[`DLS-1:0] next_line;		//Next Value for Buffer on Miss
reg     [`DLS-1:0] din_cache;           //Store Multiplexor
reg	[`DLS-1:0] comp_line;		//Compression Line Buffer
reg	[31:0]	lowword;		//Low Order Word of Double
reg	[63:0]	to_DD;			//Instruction Data Bus
reg	[63:0]	from_DD;		//Data Bus Latch
reg	[31:0]	to_MMD;			//Main Memory Data Bus
reg     [31:0]  swic_d;                 //Latched SWIC Data
reg     [31:2]  swic_a;                 //Latched SWIC Addr
reg	[`DTS-1:0] comp_tag;		//Compression Tag Buffer
reg	[`DTS-1:0] din_tag;		//Data to Write to Tag
reg	[`DPSH+1:0] page_sel;		//Page Select Bits (tag)
reg	[`DLSS-1:0] line_sel;		//Line Select Bits
reg	[`DLSS-1:0] comp_tag_line;	//Line Select Part of Tag
reg	[`DLSS-1:0] read_sel;		//Line Select Mux
reg	[`DLSS-1:0] line_wb;		//Line Address for WB
reg	[`DLSS-1:0] ls_mux;		//Mux Between Line and SWIC
reg	[7:0]	dc0;			//Cache Write Port Mux Byte 0
reg	[2:0]	word_sel;		//Word Select Bits
reg	[2:0]	word_cntr;		//Which word?
reg	[1:0]	byte_sel;		//Byte Select Bits
reg		disable_latch;		//Disable Latch for DD bus
reg		writecycle;		//Write Block Next Cycle
reg		access;			//Accessing DCache
reg		nMiss_active;		//Miss is Active (active_low)
reg		drive_DD;		//Drive DD this cycle
reg		drive_MMD;		//Drive MMD this cycle
reg		held;			//1Delay Taken
reg		init_on;		//Initialization In Progress
reg             swic_store;             //Store Enable for SWIC
reg		wb_done;		//Write Back Done	
reg		flush_now;		//Flush a Cache Line

wire	[255:0]	cache_line;		//Line Read from Cache
wire	[255:0]	dc_line;		//Read Port of D$
wire	[31:0]	MMD;			//Main Memory Data Bus
wire	[31:0]	dmiss_addr;		//Address of Miss
wire	[`DTS-1:0] tag_line;		//Data from Tag$
wire	[`DTS-1:0] dt_line;		//Read Port of Tag$
wire	[`DPSH+1:0] cache_tag;		//Cache Tag
wire		init_done;		//Initialization Complete
wire		doublehold;		//Hold for One Cycle
wire		swic_wb;		//SWIC requires a Write Back
wire		flush_wb;		//Flush requires a write back
wire		ls_and;			//And of All Line Select Bits
wire		wr_ena_c;		//Write Enable Cache
wire		wr_ena_t;		//Write Enable Tag
wire		wr_ena_cc;		//Write Enable Compression Cache
wire		wr_ena_ct;		//Write Enable Compression Tag
wire		initializing;		//Initializing Tag Ram
wire		dmiss;			//Cache Miss
wire            dwb;                    //Replacing Dirty Line
wire		dirty;			//Dirty
wire		line_miss;		//Line Miss

/*------------------------------------------------------------------------
        Memory Declarations
------------------------------------------------------------------------*/
ram2p xdcache (.nGCLK(nGCLK), .write_sel(ls_mux),
		.read_sel(read_sel), .write_port(din_cache),
		.read_port(dc_line), .wr_ena(wr_ena_c));

dtag xdtag (.nGCLK(nGCLK), .write_sel(ls_mux), .read_sel(read_sel),
                .write_port(din_tag), .read_port(dt_line), 
		.wr_ena(wr_ena_t));

/*------------------------------------------------------------------------
        Signal Assignments
------------------------------------------------------------------------*/
//Set up The Drivers for Cache/Tag Lines
assign cache_line = (decomp & ~swic_store) ? comp_line : {256{1'bz}};
assign cache_line = (~decomp | swic_store) ? dc_line : {256{1'bz}};  
assign tag_line = (~decomp | swic_store) ? dt_line : {`DTS{1'bz}};
assign tag_line = (decomp & ~swic_store) ? comp_tag : {`DTS{1'bz}};
assign dirty = tag_line[`DTS-1];

//This is the Miss Logic
assign cache_tag = tag_line[`DPSH+1:0];
assign line_miss = (access & (comp_tag_line != line_sel) & decomp);  
assign dmiss = (access & ((cache_tag != page_sel) | line_miss)  & ~swic_store)
		| swic_wb | flush_wb;
assign swic_wb = (swic_store & (cache_tag != page_sel) & dirty);
assign flush_wb = (flush_now & dirty);
assign dwb = (dmiss & dirty) | swic_wb | flush_wb;

//This is the Miss Address Control Logic
assign dmiss_addr = (dwb) ? {tag_line[`DPSH:0],line_wb,5'h00}
                          : {page_sel[`DPSH:0],line_wb,5'h00};

assign doublehold = (DMAS == `DOUB) & (word_sel == 3'h7) & access & ~held;
assign DD = (drive_DD) ? to_DD : {64{1'bz}};
assign MMD = (drive_MMD) ? to_MMD : {32{1'bz}};

//Check for All 1's, If so, may need to wrap around
//to line 0 for double word load/store
assign ls_and = (& line_sel);

//Assign the Cache Write Enable
//1) Normal Write
//2) While Loading Cache Lines from Memory
//3) During a SWIC operation
assign wr_ena_c = ((((writecycle & nMiss_active) | 
		     (mmd_valid)) & ~decomp) | swic_store);

assign wr_ena_cc = (((((writecycle & nMiss_active) |
		       (mmd_valid)) & decomp)) & ~swic_store);

//Assign the Tag Write Enable
//1) Normal Write
//2) When Line has been Loaded from Memory
//3) During a SWIC operation
//4) After a Dirty Line has been Copied to Memory
//5) During Initialization
assign wr_ena_t = ((((writecycle & nMiss_active) |
		     (word_cntr == 3'h7 & ~drive_MMD) | 
                     (wb_done) | 
		     (init_on)) & ~decomp) |
		     (swic_store));

assign wr_ena_ct = (((((writecycle & nMiss_active) |
                     (word_cntr == 3'h7 & ~drive_MMD) |
		     (wb_done) |
                     (init_on)) & decomp)) & ~swic_store & ~doublehold);

//Initialization Done when line select is All 1's
assign init_done = ls_and;
assign initializing = init_on & ~init_done;

/*------------------------------------------------------------------------
        Combinational Always Block
------------------------------------------------------------------------*/
//Mux Out the Proper Word to the I$ for SWIC   
always @(swic_store or swic_d or cache_line or swic_a or word_sel
		or next_line or from_DD or held or DMAS or nMiss_active
		or writecycle or BIGEND or byte_sel or lowword)
begin
  if (swic_store)
  begin
    case(swic_a[4:2]) //synopsys full_case parallel_case
      3'h0: din_cache = {cache_line[255:32],swic_d};
      3'h1: din_cache = {cache_line[255:64],swic_d,cache_line[31:0]};
      3'h2: din_cache = {cache_line[255:96],swic_d,cache_line[63:0]};
      3'h3: din_cache = {cache_line[255:128],swic_d,cache_line[95:0]};
      3'h4: din_cache = {cache_line[255:160],swic_d,cache_line[127:0]};
      3'h5: din_cache = {cache_line[255:192],swic_d,cache_line[159:0]};
      3'h6: din_cache = {cache_line[255:224],swic_d,cache_line[191:0]};
      3'h7: din_cache = {swic_d,cache_line[223:0]};
    endcase
  end
  else
  begin
    if (nMiss_active & writecycle)
    begin
      case (word_sel) //synopsys full_case parallel_case
	3'h0: 
         begin
 	  case (DMAS) //synopsys full_case parallel_case
            `DOUB: din_cache = (held) ? {cache_line[255:32],lowword}
                                      : {cache_line[255:64],from_DD};
	    `WORD: din_cache = {cache_line[255:32],from_DD[31:0]};
	    `HALF: 
	      begin
	       case ({BIGEND,byte_sel[1]})  //synopsys full_case parallel_case
	         2'b00, 2'b11:
		   din_cache = {cache_line[255:16],from_DD[15:0]};
		 2'b01, 2'b10:
		   din_cache = {cache_line[255:32],from_DD[31:16],cache_line[15:0]};
	       endcase
   	      end
	    `BYTE:
	      begin
	       case ({BIGEND,byte_sel})  //synopsys full_case parallel_case
                 3'b000,3'b111:
                   din_cache = {cache_line[255:8],from_DD[7:0]};
                 3'b001,3'b110:
                   din_cache = {cache_line[255:16],from_DD[15:8],cache_line[7:0]};
                 3'b010,3'b101:
                   din_cache = {cache_line[255:24],from_DD[23:16],cache_line[15:0]};
                 3'b011,3'b100:
                   din_cache = {cache_line[255:32],from_DD[31:24],cache_line[23:0]};
               endcase
	      end 
	  endcase
	 end
  
	3'h1:
	 begin
	  case (DMAS) //synopsys full_case parallel_case
            `DOUB: din_cache = {cache_line[255:96],from_DD,cache_line[31:0]}; 
            `WORD: din_cache = {cache_line[255:64],from_DD[31:0],cache_line[31:0]};
            `HALF:
              begin
                case ({BIGEND,byte_sel[1]})  //synopsys full_case parallel_case
                  2'b00, 2'b11:
                    din_cache = {cache_line[255:48],from_DD[15:0],cache_line[31:0]}; 
                  2'b01, 2'b10:
                    din_cache = {cache_line[255:64],from_DD[31:16],cache_line[47:0]};
                endcase
              end
            `BYTE:
              begin
                case ({BIGEND,byte_sel})  //synopsys full_case parallel_case
                  3'b000,3'b111:
                    din_cache = {cache_line[255:40],from_DD[7:0],cache_line[31:0]};
                  3'b001,3'b110:
                    din_cache = {cache_line[255:48],from_DD[15:8],cache_line[39:0]};
                  3'b010,3'b101:
                    din_cache = {cache_line[255:56],from_DD[23:16],cache_line[47:0]};
                  3'b011,3'b100:
                    din_cache = {cache_line[255:64],from_DD[31:24],cache_line[55:0]};
                endcase
              end  
          endcase
         end

        3'h2:
	 begin
          case (DMAS) //synopsys full_case parallel_case
            `DOUB: din_cache = {cache_line[255:128],from_DD,cache_line[63:0]};
            `WORD: din_cache = {cache_line[255:96],from_DD[31:0],cache_line[63:0]};
            `HALF:
              begin
                case ({BIGEND,byte_sel[1]})  //synopsys full_case parallel_case
                  2'b00, 2'b11:
                    din_cache = {cache_line[255:80],from_DD[15:0],cache_line[63:0]};
                  2'b01, 2'b10:
                    din_cache = {cache_line[255:96],from_DD[31:16],cache_line[79:0]};
                endcase
              end
            `BYTE:
              begin
                case ({BIGEND,byte_sel})  //synopsys full_case parallel_case
                  3'b000,3'b111:
                    din_cache = {cache_line[255:72],from_DD[7:0],cache_line[63:0]};
                  3'b001,3'b110:
                    din_cache = {cache_line[255:80],from_DD[15:8],cache_line[71:0]};
                  3'b010,3'b101:
                    din_cache = {cache_line[255:88],from_DD[23:16],cache_line[79:0]};
                  3'b011,3'b100:
                    din_cache = {cache_line[255:96],from_DD[31:24],cache_line[87:0]};
                endcase
              end
          endcase
         end
               
	3'h3:
         begin
          case (DMAS) //synopsys full_case parallel_case
            `DOUB: din_cache = {cache_line[255:160],from_DD,cache_line[95:0]};
            `WORD: din_cache = {cache_line[255:128],from_DD[31:0],cache_line[95:0]};
            `HALF: 
              begin
                case ({BIGEND,byte_sel[1]})  //synopsys full_case parallel_case
                  2'b00, 2'b11:
                    din_cache = {cache_line[255:112],from_DD[15:0],cache_line[95:0]};
                  2'b01, 2'b10:
                    din_cache = {cache_line[255:128],from_DD[31:16],cache_line[111:0]};
                endcase
              end
            `BYTE:
              begin
                case ({BIGEND,byte_sel})  //synopsys full_case parallel_case
                  3'b000,3'b111:
                    din_cache = {cache_line[255:104],from_DD[7:0],cache_line[95:0]};
                  3'b001,3'b110:
                    din_cache = {cache_line[255:112],from_DD[15:8],cache_line[103:0]};
                  3'b010,3'b101:
                    din_cache = {cache_line[255:120],from_DD[23:16],cache_line[111:0]};
                  3'b011,3'b100:
                    din_cache = {cache_line[255:128],from_DD[31:24],cache_line[119:0]};
                endcase
              end
          endcase
         end   

	3'h4:
	 begin
          case (DMAS) //synopsys full_case parallel_case
            `DOUB: din_cache = {cache_line[255:192],from_DD,cache_line[127:0]};
            `WORD: din_cache = {cache_line[255:160],from_DD[31:0],cache_line[127:0]};
            `HALF: 
              begin
                case ({BIGEND,byte_sel[1]})  //synopsys full_case parallel_case
                  2'b00, 2'b11:
                    din_cache = {cache_line[255:144],from_DD[15:0],cache_line[127:0]};
                  2'b01, 2'b10:
                    din_cache = {cache_line[255:160],from_DD[31:16],cache_line[143:0]};
                endcase
              end
            `BYTE:
              begin
                case ({BIGEND,byte_sel})  //synopsys full_case parallel_case
                  3'b000,3'b111:
                    din_cache = {cache_line[255:136],from_DD[7:0],cache_line[127:0]};
                  3'b001,3'b110:
                    din_cache = {cache_line[255:144],from_DD[15:8],cache_line[135:0]};
                  3'b010,3'b101:
                    din_cache = {cache_line[255:152],from_DD[23:16],cache_line[143:0]};
                  3'b011,3'b100:
                    din_cache = {cache_line[255:160],from_DD[31:24],cache_line[151:0]};
                endcase
              end  
          endcase
         end

	3'h5:
	 begin
	  case (DMAS) //synopsys full_case parallel_case
            `DOUB: din_cache = {cache_line[255:224],from_DD,cache_line[159:0]};
            `WORD: din_cache = {cache_line[255:192],from_DD[31:0],cache_line[159:0]};
            `HALF: 
              begin
                case ({BIGEND,byte_sel[1]})  //synopsys full_case parallel_case
                  2'b00, 2'b11:
                    din_cache = {cache_line[255:176],from_DD[15:0],cache_line[159:0]};
                  2'b01, 2'b10:
                    din_cache = {cache_line[255:192],from_DD[31:16],cache_line[175:0]};
                endcase
              end
            `BYTE:
              begin
                case ({BIGEND,byte_sel})  //synopsys full_case parallel_case
                  3'b000,3'b111:
                    din_cache = {cache_line[255:168],from_DD[7:0],cache_line[159:0]};
                  3'b001,3'b110:
                    din_cache = {cache_line[255:176],from_DD[15:8],cache_line[167:0]};
                  3'b010,3'b101:
                    din_cache = {cache_line[255:184],from_DD[23:16],cache_line[175:0]};
                  3'b011,3'b100:
                    din_cache = {cache_line[255:192],from_DD[31:24],cache_line[183:0]};
                endcase
              end  
          endcase
         end

        3'h6:
	 begin
          case (DMAS) //synopsys full_case parallel_case
            `DOUB: din_cache = {from_DD,cache_line[191:0]};
            `WORD: din_cache = {cache_line[255:224],from_DD[31:0],cache_line[191:0]};
            `HALF: 
              begin
                case ({BIGEND,byte_sel[1]})  //synopsys full_case parallel_case
                  2'b00, 2'b11:
                    din_cache = {cache_line[255:208],from_DD[15:0],cache_line[191:0]};
                  2'b01, 2'b10:
                    din_cache = {cache_line[255:224],from_DD[31:16],cache_line[207:0]};
                endcase
              end
            `BYTE:
              begin
                case ({BIGEND,byte_sel})  //synopsys full_case parallel_case
                  3'b000,3'b111:
                    din_cache = {cache_line[255:200],from_DD[7:0],cache_line[191:0]};
                  3'b001,3'b110:
                    din_cache = {cache_line[255:208],from_DD[15:8],cache_line[199:0]};
                  3'b010,3'b101:
                    din_cache = {cache_line[255:216],from_DD[23:16],cache_line[207:0]};
                  3'b011,3'b100:
                    din_cache = {cache_line[255:224],from_DD[31:24],cache_line[215:0]};
                endcase
              end
          endcase
         end

	3'h7:
         begin
	  case (DMAS) //synopsys full_case parallel_case
            `DOUB: din_cache = {from_DD[31:0],cache_line[223:0]};
	    `WORD: din_cache = {from_DD[31:0],cache_line[223:0]};
            `HALF:
              begin
                case ({BIGEND,byte_sel[1]})  //synopsys full_case parallel_case
                  2'b00, 2'b11:
                    din_cache = {cache_line[255:240],from_DD[15:0],cache_line[223:0]};
                  2'b01, 2'b10:
                    din_cache = {from_DD[31:16],cache_line[239:0]};
                endcase
              end
            `BYTE: 
              begin
                case ({BIGEND,byte_sel})  //synopsys full_case parallel_case   
                  3'b000,3'b111:
                    din_cache = {cache_line[255:232],from_DD[7:0],cache_line[223:0]}; 
                  3'b001,3'b110:
                    din_cache = {cache_line[255:240],from_DD[15:8],cache_line[231:0]};
                  3'b010,3'b101:
                    din_cache = {cache_line[255:248],from_DD[23:16],cache_line[239:0]};
                  3'b011,3'b100:
                    din_cache = {from_DD[31:24],cache_line[247:0]};
                endcase
              end
          endcase
         end
      endcase
    end	
    else
      din_cache = next_line;
  end
end

//Mux out the Proper Words to the Processor
always @(word_sel or cache_line or lowword or held)
  begin
    case (word_sel) //synopsys full_case parallel_case
      3'b000: to_DD = (held) ? {cache_line[31:0],lowword}
			     : cache_line[63:0];
      3'b001: to_DD = cache_line[95:32]; 
      3'b010: to_DD = cache_line[127:64];
      3'b011: to_DD = cache_line[159:96]; 
      3'b100: to_DD = cache_line[191:128];
      3'b101: to_DD = cache_line[223:160];
      3'b110: to_DD = cache_line[255:192];
      3'b111: to_DD = {32'h0, cache_line[255:224]};
    endcase
  end

//Mux out the Proper Word to Main Memory
always @(word_cntr or cache_line)
  begin
    case (word_cntr) //synopsys full_case parallel_case
      3'b000: to_MMD <= cache_line[31:0];
      3'b001: to_MMD <= cache_line[63:32];
      3'b010: to_MMD <= cache_line[95:64];
      3'b011: to_MMD <= cache_line[127:96];
      3'b100: to_MMD <= cache_line[159:128];
      3'b101: to_MMD <= cache_line[191:160];
      3'b110: to_MMD <= cache_line[223:192];
      3'b111: to_MMD <= cache_line[255:224];
    endcase
  end

//Determine what to put in the line buffer on a miss
always @(word_cntr or cache_line or MMD or mmd_valid or cache_line)
  begin
    if (mmd_valid)
      begin
        case (word_cntr) //synopsys full_case parallel_case
          3'h0: next_line = {cache_line[255:32], MMD};
          3'h1: next_line = {cache_line[255:64], MMD, cache_line[31:0]};
          3'h2: next_line = {cache_line[255:96], MMD, cache_line[63:0]};
          3'h3: next_line = {cache_line[255:128], MMD, cache_line[95:0]};
          3'h4: next_line = {cache_line[255:160], MMD, cache_line[127:0]};
          3'h5: next_line = {cache_line[255:192], MMD, cache_line[159:0]};
          3'h6: next_line = {cache_line[255:224], MMD, cache_line[191:0]};
          3'h7: next_line = {MMD, cache_line[223:0]};
        endcase
      end
    else
       next_line = cache_line;
  end

//Mux the Data into the Tag Cache
always @(tag_line or word_cntr or page_sel or drive_MMD 
		or wb_done or init_on or swic_store or swic_a)
  begin
    if (swic_store)
      din_tag = {2'b01, swic_a[31:`DPSL]};
    else
      begin
        if (init_on | wb_done)
          din_tag = {2'h0, page_sel[`DPSH-1:0]};

        else if (word_cntr == 3'h7 & ~drive_MMD)
          din_tag = {1'b0, page_sel};

        else
          din_tag = {2'h3, tag_line[`DPSH:0]};
      end
  end

//Figure out Which Line to Read
//1) If a double across the boundary, line_sel + 1
//2) During Stalls, read_sel loaded in line_sel
//3) Else DA Bus
always @(doublehold or line_sel or DA or istall or dmiss 
		or swic or swic_store or swic_a
		or flush or flush_wb)
  begin
    if (swic | swic_store | flush | flush_wb)
      read_sel <= (swic_store | flush_wb) ? swic_a[`DLSH:5] : DA[`DLSH:5];
    else if (doublehold & ~istall)
      read_sel <= line_sel + 1;
    else if (istall | dmiss)
      read_sel <= line_sel;
    else
      read_sel <= DA[`DLSH:5];
  end

always @(dwb or decomp or comp_tag_line or
                line_sel or read_sel or flush_wb)
  begin
    if (dwb & decomp)
      line_wb <= comp_tag_line;
    else if (flush_wb)
      line_wb <= read_sel;
    else
      line_wb <= line_sel;
  end

//Which Line Do we Access?
always @(swic_store or swic_a or line_sel or flush_wb)
  begin
    if (swic_store | flush_wb)
      ls_mux <= swic_a[`DLSH:5];
    else
      ls_mux <= line_sel;
  end

/*------------------------------------------------------------------------
        Sequential Always Block
------------------------------------------------------------------------*/
//synopsys async_set_reset nRESET
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      init_on <= 1'b1;
    else if (init_done)
      init_on <= 1'b0;
  end

//Reading Cache?
//synopsys async_set_reset nRESET
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      access <= #1 1'b0;
    else if (nMiss_active & ~istall & ~doublehold)
      access <= #1 ~DnMREQ & ~DABORT;
  end

//Writing Cache?
//synopsys async_set_reset nRESET
always @(posedge nGCLK or negedge nRESET)
  begin
   if (~nRESET)
     writecycle <= #1 1'b0;
   else if (nMiss_active & ~istall & ~doublehold)
     writecycle <= #1 ~DnMREQ & ~DnWR;
  end

//Latch the Busses for SWIC Instructions
//synopsys async_set_reset nRESET
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      begin
        swic_d <= 32'h0;
        swic_a <= 30'h0;
      end
    else if (swic | (flush & ~dmiss))
      begin
        swic_d <= swic_data;
        swic_a <= DA[31:2];
      end
  end

//Latch the SWIC signal
//synopsys async_set_reset nRESET
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      swic_store <= 1'b0;
    else if (~dmiss & ~doublehold)
      swic_store <= swic;
  end

//Latch the FLUSH signal
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      flush_now <= 1'b0;
    else if (~dmiss & ~doublehold)
      flush_now <= flush;
  end

//Watch out for DoubleLine Access
//synopsys async_set_reset nRESET
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      held <= #1 1'b0;
    else if (~istall)
      held <= #1 doublehold | (held & ~nMiss_active);
  end

//Data Bus Driver
//synopsys async_set_reset nRESET
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      drive_DD <= #1 1'b0;
    else if (nMiss_active & ~istall & ~doublehold)
      drive_DD <= #1 ~DnMREQ & DnWR;
  end

//Memory Bus Driver
//synopsys async_set_reset nRESET
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      drive_MMD <= #1 1'b0;
    else
      drive_MMD <= #1 drive_mmd;
  end

//Latch the Address Bits to Appropriate Regs
always @(posedge nGCLK)
  begin
    if (~DnMREQ & nMiss_active & ~istall)
      begin
	  byte_sel <= #1 DA[1:0];
      end
  end

//Latch the Address Bits to Appropriate Regs
//synopsys async_set_reset nRESET
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      begin
        line_sel <= 9'h0;
        word_sel <= 3'h0;
        page_sel <= 0;
      end
 
    else if (((~DnMREQ | doublehold) & nMiss_active & ~istall) | init_on)
      begin
        line_sel <= #1 (doublehold | init_on) ? (line_sel + 1)  
                                              : DA[`DLSH:5];
        word_sel <= #1 (doublehold) ? (word_sel + 1)
                                    : DA[4:2];
        page_sel <= #1 (doublehold) ? (page_sel + ls_and)
			            : {1'b1, DA[31:`DPSL]};
      end
  end

//Disable latch for DD bus
always @(istall or doublehold or nGCLK)
  begin
    if (~nGCLK)
      disable_latch <= istall | doublehold;
  end

//Latch the Data Bus
always @(nGCLK or DD or disable_latch or nMiss_active or from_DD)
  begin
    if (nGCLK)
      begin
        if (~disable_latch & nMiss_active)
          from_DD <= DD;
        else
          from_DD <= from_DD;
      end
  end

//Stall the Processor on a cache miss
//synopsys async_set_reset "nRESET"
always @(nGCLK or dmiss or nRESET)
  begin
    if (~nRESET)
      nMiss_active <= 1'b1;
    else if (~nGCLK)
      nMiss_active <= ~(dmiss & ~DABORT);
  end

//Cache Miss Word Count
//synopsys async_set_reset nRESET
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      word_cntr <= 3'h0;
    else if (~nMiss_active & ((mmd_valid & ~dwb) | (drive_MMD & dwb)))
      word_cntr <= word_cntr + 1;
    else
      word_cntr <= 3'h0;
  end

//synopsys async_set_reset nRESET
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      wb_done <= 1'b0;
    else
      wb_done <= ((word_cntr == 3'h6) & dwb);
  end

//Grab the low order word on a Double
//Word Access across Line Boundaries
//synopsys async_set_reset nRESET
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      lowword <= 32'h0000000;
    else if (doublehold)
      lowword <= (writecycle) ? from_DD[63:32] 
			      : next_line[255:224];
  end

//Create a Single Line Register for use in Data Decompression
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      comp_line <= {256{1'b0}};
    else if (wr_ena_cc)
      comp_line <= din_cache;
  end

//Create a Single Line Tag for use in Data Decompression
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      begin
        comp_tag <= {`DTS{1'b0}};
        comp_tag_line <= line_sel;
      end
    else if (wr_ena_ct)
      begin
        comp_tag <= din_tag;
        comp_tag_line <= line_sel;
      end
  end


endmodule
