`timescale 1ns/10ps
`include "pardef"
/*****************************************************************************
$RCSfile: me.v,v $
$Revision: 1.5 $
$Author: kohlere $
$Date: 2000/04/17 18:12:50 $
$State: Exp $

Description: This is the Memory Stage.  It controls all accesses to
		and from memory and passes on the results to the WB
		stage.

*****************************************************************************/

module me(nGCLK, nWAIT, nRESET, BIGEND, me_enbar, store_addr, ex_result, 
		inst_type_ex, Rd_ex, Rn_ex, write_Rd_ex, second_ex, 
		write_Rn_ex, unsigned_byte_ex, signed_byte_ex, base_ex,
		unsigned_hw_ex, signed_hw_ex, stop_ex, stop_me,
		data_bus, mem_rd_wr, me_result, Rd_me, Rn_me, write_Rd_me, 
		mem_ena, addr_me, write_Rn_me, base_me, double_ex,
		double_me, byte, halfword, load_pc, mcr_ex,
		reset_write_Rd_me, reset_write_Rn_me, store_ex,
		cop_mem_ld, cop_mem_st);

/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/

input 	[31:0]	store_addr;		//Address from Ex Stage
input	[31:0]	ex_result;		//Result from Ex Stage
input	[31:0]	base_ex;		//Base Address
input	[3:0]	inst_type_ex;		//Instruction Code
input	[4:0]	Rd_ex;			//1st Destination Reg
input	[4:0]	Rn_ex;			//2nd Destination Reg
input		nGCLK;			//Clock Signal
input		nRESET;			//Reset Signal
input		nWAIT;			//Clock Enable
input		BIGEND;			//Big Endian?
input		me_enbar;		//Memory Stage Enable
input		store_ex;		//Inst is a Store
input		write_Rd_ex;		//Conditions Failed?
input		second_ex;		//Second Cycle of Instruction
input		write_Rn_ex;		//Write Back Signal
input		unsigned_byte_ex;	//Inst uses Unsigned Bytes
input		signed_byte_ex;		//Inst uses Signed Bytes
input		unsigned_hw_ex;		//Inst uses Unsigned Halfwords
input		signed_hw_ex;		//Inst uses Signed Halfwords
input		double_ex;		//64-Bit Memory Access
input		mcr_ex;			//MCR Inst comin In
input		reset_write_Rd_me;	//Reset the write Signal
input		reset_write_Rn_me;	//Reset the write Signal
input		cop_mem_ld;		//Coprocessor Loading
input		cop_mem_st;		//Coprocessor Storing
input		stop_ex;		//Stop Execution

inout	[63:0]  data_bus;		//Data Bus To Memory

output	[31:0]  me_result;		//Data to pass to WB Stage
output	[31:0]  addr_me;		//Output for Storing Base
output	[31:0]	base_me;		//Base Value to Write Back
output	[4:0]	Rd_me;			//1st Destination Reg
output	[4:0]	Rn_me;			//2nd Destination Reg
output 		write_Rd_me;		//Latched Condition Failed?
output		mem_rd_wr;		//Memory Read/Write
output		mem_ena;		//Memory Access Required
output		write_Rn_me;		//Write Back?
output		double_me;		//64-Bit Memory Access
output		byte;			//8-Bit Memory Access
output		halfword;		//16-Bit Memory Access
output		load_pc;		//Load to the PC
output		stop_me;		//Stop Execution

/*------------------------------------------------------------------------
        Variable Declarations
------------------------------------------------------------------------*/

//Declare Output of Multiplexers and Regiseters
reg 	[31:0]	data;			//Latched ex_result
reg	[31:0]	addr_me;		//Latched store_addr
reg	[31:0]  me_result;		//Muxed Result
reg	[31:0]	base_me;		//Output Base Value
reg	[31:0]  base;			//Base Value
reg	[3:0]	inst_type_me;		//Latched Inst Code
reg	[4:0]	Rd_me;			//Latched 1st Dest Reg
reg	[4:0]	Rn_me;			//Latched 2nd Dest Reg
reg		store_me;		//Store the Data
reg		write_Rd_me;		//Latched Cond Failed
reg		second_me;		//Latched 2nd Cycle of Inst
reg		write_Rn_me;		//Latched Write-Back
reg		unsigned_byte_me;	//Unsigned Bytes Used
reg		signed_byte_me;		//Signed Bytes Used
reg		unsigned_hw_me;		//Unsigned Halfwords Used
reg		signed_hw_me;		//Signed Halfwords Used
reg		double_me;		//64-Bit Memory Access
reg		mcr_me;			//MCR in here
reg		cop_ld_me;		//Cop Loading
reg		cop_st_me;		//Cop Storing
reg		stop_me;		//Stop Execution

//Declare Outputs of Combinational Logic & Tri-Stated Buses
wire    [63:0]  data_bus;               //Memory Data Bus
wire	[63:0]	loaded_data;		//Aligned Load Data
wire	[1:0]	lowbits;		//Low Address Bits
wire		load;			//Instruction is a LDRW/LDRH
wire	        swap;			//Instruction is a SWAP/B
wire		ldm;			//Instruction is a LDM
wire		mem_rd_wr;		//Read = 1, Write = 0
wire		mem_ena;		//Memory Enable
wire		byte;			//Byte Access
wire		halfword;		//Halfword Access
wire		cop;			//Coprocessor Instruciton
reg		load_pc;		//Load to the PC
wire		data_out_ena;		//Drive the Data Bus?

/*------------------------------------------------------------------------
        Component Instantiations
------------------------------------------------------------------------*/
// instantiate align
align	xalign	(.data({base,data}), .data_bus(data_bus), 
		.addr_low(lowbits), .loaded_data(loaded_data),
		.BIGEND(BIGEND), .out_ena(data_out_ena), 
		.unsigned_byte(unsigned_byte_me),
		.unsigned_hw(unsigned_hw_me),
		.signed_byte(signed_byte_me),
		.signed_hw(signed_hw_me)); 

/*------------------------------------------------------------------------
        Basic Assignments (Combinational Logic)
------------------------------------------------------------------------*/
assign byte = signed_byte_me || unsigned_byte_me;
assign halfword = signed_hw_me || unsigned_hw_me;
assign cop = (inst_type_me == `COP);
assign data_out_ena = store_me | mcr_me;
assign lowbits = (load | store_me) ? addr_me[1:0] : 2'h0;

//Load should be high whenever there is a load.  If the instruction
//is not executed, then the loaded value will not be written.  To reduce
//memory accesses, this logic could be changed, but for now is fine.
assign #1 load = ((inst_type_me == `LDRW)||
	       (inst_type_me == `LDRH)||
	       (ldm) || (swap && !second_me)) ? 1'b1 : 1'b0;

//Recognize a load to the PC
always @(Rd_me or write_Rd_me or Rn_me or double_me or write_Rn_me
		or load)
    begin
	  load_pc <= load & (((Rd_me == 5'h0F) & write_Rd_me) | 
			 ((Rn_me == 5'h0F) & double_me & write_Rn_me));
    end

//Detect swap instructions.
assign #1 swap = (inst_type_me == `SWAP);

//Detect LDM instructions
assign #1 ldm = (inst_type_me == `LDM);

//mem_rd_wr = 0 for stores.
assign mem_rd_wr = !(store_me | cop_st_me);

//Enable a memory access for any load or store.
assign mem_ena = (load | store_me | cop_ld_me | cop_st_me);

/*------------------------------------------------------------------------
        Combinational Always Block (Multiplexers)
------------------------------------------------------------------------*/	

//Set up the me_result
//For Load instructions, the data will be on the data bus.  
//For all other instructions, the data comes from the EX stage and
//will be in the data register.
always @(load or loaded_data or data or cop)
    begin
        if (load | cop) 
            me_result = loaded_data[31:0];
        else
            me_result = data;
    end

//Set up the base_me to the WB stage
always @(ldm or double_me or base or loaded_data)
    begin
	if (ldm && double_me)
	    base_me = loaded_data[63:32];
	else
	    base_me = base;
    end
/*------------------------------------------------------------------------
        Sequential Always Block (Registers)
------------------------------------------------------------------------*/
//This block controls the data latch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (!nRESET)
      data <= 32'h00000000;
    else if (nWAIT)
      begin
        if (!me_enbar)
          data <= #1 ex_result;
      end
  end

//This block controls the addr_me latch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (!nRESET)
      addr_me <= 32'h00000000;
    else if (nWAIT)
      begin
        if (!me_enbar)
          addr_me <= #1 store_addr;
      end
  end

//This block controls the base_me latch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (!nRESET)
      base <= 32'h00000000;
    else if (nWAIT)
      begin
        if (!me_enbar)
          base <= #1 base_ex;
      end
  end

//This block controls the inst_type_me latch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (!nRESET)
      inst_type_me <= 4'h0;
    else if (nWAIT)
      begin 
        if (!me_enbar)
          inst_type_me <= #2 inst_type_ex;
      end
  end

//This block controls the Rd_me latch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (!nRESET)
      Rd_me <= 5'h00;
    else if (nWAIT)
      begin
        if (!me_enbar)
          Rd_me <= #2 Rd_ex;
      end
  end

//This block controls the Rn_me latch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (!nRESET)
      Rn_me <= 5'h00;
    else if (nWAIT)
      begin       
        if (!me_enbar)
          Rn_me <= #2 Rn_ex;     
      end
  end

//This block controls the write_Rd_me latch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (!nRESET)
      write_Rd_me <= 1'h0;
    else if (nWAIT)
      begin
	if (!me_enbar | reset_write_Rd_me)
          write_Rd_me <= #2 write_Rd_ex & !reset_write_Rd_me;
      end
  end

//This block controls the second_me latch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (!nRESET)
      second_me <= 1'h0;
    else if (nWAIT)
      begin
        if (!me_enbar)
          second_me <= #2 second_ex;
      end
  end

//This block controls the w_me latch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (!nRESET)
      write_Rn_me <= 1'h0;
    else if (nWAIT)
      begin
        if (!me_enbar | reset_write_Rn_me)
          write_Rn_me <= #2 write_Rn_ex & !reset_write_Rn_me;
      end
  end

//This block controls the unsigned_byte_me latch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (!nRESET)
      unsigned_byte_me <= 1'h0;
    else if (nWAIT)
      begin
        if (!me_enbar)
            unsigned_byte_me <= #2 unsigned_byte_ex; 
      end
  end

//This block controls the signed_byte_me latch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (!nRESET)
      signed_byte_me <= 1'h0;
    else if (nWAIT)
      begin
        if (!me_enbar)
          signed_byte_me <= #2 signed_byte_ex;
      end
  end

//This block controls the unsigned_hw_me latch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (!nRESET)
      unsigned_hw_me <= 1'h0;
    else if (nWAIT)
      begin
        if (!me_enbar)
          unsigned_hw_me <= #2 unsigned_hw_ex;
      end
  end

//This block controls the signed_hw_me latch
always @(posedge nGCLK or negedge nRESET)
  begin
    if (!nRESET)
      signed_hw_me <= 1'h0;
    else if (nWAIT)
      begin
        if (!me_enbar)
          signed_hw_me <= #2 signed_hw_ex;
      end
  end

//This block controls the double_me latch
always @(posedge nGCLK or negedge nRESET)
  begin
    if (!nRESET)
      double_me <= 1'h0;
    else if (nWAIT)
      begin
        if (!me_enbar)
          double_me <= #2 double_ex;
      end
  end

//This block latches the store_ex signal
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      store_me <= 1'b0;
    else if (nWAIT)
      begin
	if (!me_enbar)
	  store_me <= #2 store_ex;
      end
  end

//This block latches the mcr_ex signal
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      mcr_me <= 1'b0;
    else if (nWAIT)
      begin
        if (!me_enbar)
          mcr_me <= mcr_ex;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      cop_ld_me <= 1'b0;
    else if (nWAIT)
      begin
        if (!me_enbar)
          cop_ld_me <= cop_mem_ld;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      cop_st_me <= 1'b0;
    else if (nWAIT)
      begin
        if (!me_enbar)
          cop_st_me <= cop_mem_st;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      stop_me <= 1'b0;
    else if (nWAIT)
      begin
        if (~me_enbar)
          stop_me <= stop_ex;
      end
  end

/*======================================================================*/
endmodule       //me
/*======================================================================*/

