/*****************************************************************************
$RCSfile: icache.v,v $
$Revision: 1.7 $
$Author: kohlere $
$Date: 2000/04/10 18:17:59 $
$State: Exp $

Description:  I-Cache Controller Unit for the ARM Microprocessor.  This
	provides the next 3 instruction to the ARM fetch unit.  When a 
	miss is triggered, it accepts the data from the MMD and a signal
	from MMU indicating the arrival of data.

	Notes: Tag = D,V,tag

*****************************************************************************/
`timescale 1ns/10ps
`include "pardef"
module icache (nGCLK, nRESET, IA, ID, InMREQ, MMD, mmd_valid, IABORT,
		dmiss, imiss_addr, imiss, doublehold, newline, DABORT,
		useMini, swic, swic_addr, swic_data, initializing);

/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/
input   [31:0]  IA;             //Instruction Address Bus
input	[31:0]	swic_data;	//SWIC Word to Store
input	[31:2]	swic_addr;	//SWIC Addr to Store
input		nGCLK;		//Global Clock
input		nRESET;		//Global Reset
input		InMREQ;		//Not Instruction Memory Request
input		IABORT;		//Instruction ABORT (no Miss)
input		DABORT;		//Data Access ABORT
input		mmd_valid;	//MMD is Valid, Increment Counter
input		dmiss;		//DCache Miss
input		doublehold;	//Hold Cycle for Double Load
input		newline;	//New Line Required
input		useMini;	//Use Small Lock-Down Cache
input		swic;		//SWIC Requested

input	[31:0]	MMD;		//Main Memory Data Bus

output	[95:0]	ID;		//Instruction Data Bus
output	[31:0]	imiss_addr;	//Miss Addr to MMU
output		imiss;		//Instruction Cache Miss
output		initializing;	//Initializing Tag Ram

/*------------------------------------------------------------------------
        Signal Declarations
------------------------------------------------------------------------*/
reg	[`ILS-1:0] next_line;		//Next Value for Buffer on Miss
reg	[`ILS-1:0] line_mux;		//Mux Between Cache Lines
reg	[`ILS-1:0] din_cache;		//Store Multiplexor
reg	[95:0]	ID;			//Instruction Data Bus
reg	[31:0]	swic_d;			//Latched SWIC Data
reg	[31:2]	swic_a;			//Latched SWIC Addr
reg	[`ITS-1:0] din_tag;		//Mux Between Tag and SWIC
reg	[`IPSH+1:0] page_sel;		//Page Select Bits (V,tag)
reg	[`ILSS-1:0] line_sel;		//Line Select Bits
reg	[2:0]	word_sel;		//Word Select Bits
reg	[2:0]	load_word;		//Which word?
reg		swic_store;		//Store Enable for SWIC
reg		nMiss_active;		//Miss is Active (active_low)
wire		imiss;			//Cache Miss
reg		init_on;		//Initialization in Progress
reg		access;			//Accessing Ram

wire	[`ILS-1:0] cache_line;		//Line In Cache (Read Port)
wire	[`ILS-1:0] miniline;		//Line in Cache (Read Port)
wire	[31:0]	imiss_addr;		//Address of Miss
wire	[`ITS-1:0] tag_line;		//Tag
wire	[`IPSH+1:0] cache_tag;		//Cache V,Tag
reg    [`ILSS-1:0] ls_mux;             //Mux Between Line and SWIC
wire	[3:0] 	inc_loadword;		//Incremented Line Select
wire		wr_ena_c;		//Write Enable to I$
wire		wr_ena_t;		//Write Enable to Tag$
wire		wrmini_ena;		//Write Enable to MiniCache
wire		initializing;		//Initializing Tag Ram
wire		init_done;		//Done

/*------------------------------------------------------------------------
        Memory Declarations
------------------------------------------------------------------------*/
ram1p xicache (.nGCLK(nGCLK), .write_sel(ls_mux),
		.read_sel(ls_mux), .write_port(din_cache),
		.read_port(cache_line), .wr_ena(wr_ena_c));

itag xitag (.nGCLK(nGCLK), .write_sel(ls_mux), .read_sel(ls_mux),
		.write_port(din_tag), .read_port(tag_line),
		.wr_ena(wr_ena_t));

//Now its a ROM 
miniram xmini (.read_sel(line_sel[3:0]), .read_port(miniline));

/*------------------------------------------------------------------------
        Signal Assignments
------------------------------------------------------------------------*/
assign cache_tag = tag_line[`IPSH+1:0];
assign imiss_addr = {page_sel[`IPSH:0],line_sel,5'h00};
assign wr_ena_c = ((mmd_valid) & ~useMini) | swic_store;
assign wr_ena_t = ((load_word == 3'h7) & ~useMini) | swic_store | init_on;
assign wrmini_ena = (load_word == 3'h7) & useMini;
assign init_done = (& line_sel);
assign initializing = init_on & !init_done;
assign imiss = ((cache_tag != page_sel) & ~useMini & ~init_on & ~DABORT);

/*------------------------------------------------------------------------
        Combinational Always Block
------------------------------------------------------------------------*/
//Mux out the Proper Words to the Processor
always @(word_sel or line_mux or IABORT or DABORT)
  begin
    if (IABORT | DABORT) //Move PC to Link Register
      ID <= #1 96'h0e1a0e00f;
    else
      begin
        case (word_sel) //synopsys full_case parallel_case
          3'b000: ID <= #1 line_mux[95:0];
          3'b001: ID <= #1 line_mux[127:32];
          3'b010: ID <= #1 line_mux[159:64];
          3'b011: ID <= #1 line_mux[191:96];
          3'b100: ID <= #1 line_mux[223:128];
          3'b101: ID <= #1 line_mux[255:160];
          3'b110: ID <= #1 {32'h0,line_mux[255:192]};
          3'b111: ID <= #1 {64'h0,line_mux[255:224]};
        endcase
      end
  end

//Mux Out the Proper Tag to Store
always @(swic_store or swic_a or tag_line or init_on or load_word
		or page_sel)
  begin
    if (swic_store)
      din_tag <= {2'b01, swic_a[31:`IPSL]};
    else
      begin
	if (init_on)
          din_tag <= 0;
	else if (load_word == 3'h7)
	  din_tag <= {1'b0, page_sel};
	else
	  din_tag <= tag_line;
      end
  end

//Mux Out the Proper Word to the I$ for SWIC
always @(next_line or swic_store or swic_d or cache_line or swic_a)
  begin
    if (swic_store)
      begin
        case(swic_a[4:2])
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
      din_cache = next_line;
  end

//Determine what to put in the line buffer on a miss
always @(load_word or line_mux or MMD)
  begin
    case (load_word) //synopsys full_case parallel_case
      3'h0: next_line = {line_mux[255:32], MMD};
      3'h1: next_line = {line_mux[255:64], MMD, line_mux[31:0]};
      3'h2: next_line = {line_mux[255:96], MMD, line_mux[63:0]};
      3'h3: next_line = {line_mux[255:128], MMD, line_mux[95:0]};
      3'h4: next_line = {line_mux[255:160], MMD, line_mux[127:0]};
      3'h5: next_line = {line_mux[255:192], MMD, line_mux[159:0]};
      3'h6: next_line = {line_mux[255:224], MMD, line_mux[191:0]};
      3'h7: next_line = {MMD, line_mux[223:0]};
    endcase
  end

//Use the MiniLine from the Lock Down Cache during
//Decompression Routine.
always @(useMini or cache_line or miniline)
  begin
    if (useMini)
      line_mux <= miniline;
    else
      line_mux <= cache_line;
  end

//Multiplex the Line Select to the Rams
//1) Swic Address during SWIC operation
//2) If writing and not swic_store, only on a cache miss
//3) Else the IA bus
always @(swic or swic_store or wr_ena_c or swic_a or line_sel or IA or wr_ena_t
		or dmiss or doublehold or swic_addr)
  begin
    if (swic | swic_store)
      ls_mux <= (swic_store) ? swic_a[`ILSH:5] : swic_addr[`ILSH:5];
    else if (wr_ena_c | wr_ena_t | dmiss | doublehold)
      ls_mux <= line_sel;
    else
      ls_mux <= IA[`ILSH:5];
  end

/*------------------------------------------------------------------------
        Sequential Always Block
------------------------------------------------------------------------*/
//Catch the reset and initialize the tag ram
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      init_on <= 1'b1;
    else if (init_done)
      init_on <= 1'b0;
  end

//Latch the Address Bits to Appropriate Regs
wire nNewread = ~(((~InMREQ & newline) | init_on) & nMiss_active & ~dmiss & ~doublehold);
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      begin
        page_sel <= 0;
        line_sel <= 9'h0;
      end
    else if (~nNewread | init_on | DABORT)
      begin
	page_sel <= #1 {1'b1, IA[31:`IPSL]};
	line_sel <= #1 (init_on) ? (line_sel + 1) : IA[`ILSH:5];
      end
  end

always @(posedge nGCLK)
  begin
    if ((~InMREQ & nMiss_active & ~dmiss & ~doublehold) | DABORT)
      begin
        word_sel <= #1 IA[4:2];
      end
  end

//Latch the Busses for SWIC Instructions
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      begin
        swic_d <= 32'h0;
        swic_a <= 32'h0;
      end
    else if (swic)
      begin
        swic_d <= swic_data;
        swic_a <= swic_addr;
      end
  end

//Latch the SWIC signal
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      swic_store <= 1'b0;
    else
      swic_store <= swic;
  end

//Stall the Processor on a cache miss
//synopsys async_set_reset "nRESET"
always @(nGCLK or imiss or nRESET or IABORT)
  begin
    if (!nRESET)
      nMiss_active <= #1 1'b1;
    else if (~nGCLK)
      nMiss_active <= #1 ~(imiss & ~IABORT);
  end

//Cache Miss Word Load Count
//synopsys async_set_reset "nRESET"
assign inc_loadword = load_word + 1;
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      load_word <= #1 3'h0;
    else if (~nMiss_active & mmd_valid)
      load_word <= #1 inc_loadword;
    else
      load_word <= #1 3'h0;
  end

endmodule
