`timescale 1ns/10ps
`include "pardef"
/*****************************************************************************
$RCSfile: id.v,v $
$Revision: 1.10 $
$Author: kohlere $
$Date: 2000/04/17 18:12:50 $
$State: Exp $

Description:  This is the Instruction Decode Stage.  It controls the
		reads of the Register File, as well as setting up some
		of the control signals.

*****************************************************************************/
module id(nGCLK, nWAIT, nRESET, id_enbar, inst, rf_a, rf_b,
		write_Rd_ex, Rd_ex, write_Rn_ex, Rn_ex,
		write_Rn_me, Rn_me, ex_result, me_result,
		base_ex, base_me, Rd_me, write_Rd_me, mode,
		index_a, index_b, op1, op2, alu_opcode, ldm, stm,
		condition, shift_amount, shift_type, ir_id, finished,
		second, need_2cycles, Rd_id, Rn_id, aux_data_id, 
		inst_type_id, s, load_use, second_nlu, mul_first, cop_id,
		double_id, cop_mem_id, hold_next_ex, pc_if, stop_id,
		cop_absent, exception, exc_code, exception_id, exc_code_id);

/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/

input	[31:0]	inst;			//Instruction from main memory 
input  	[31:0]	rf_a;			//A data from RF
input  	[31:0]	rf_b;			//B data from RF
input  	[31:0]	ex_result;		//Result of EX Stage
input  	[31:0]	me_result;		//Result of ME Stage
input  	[31:0]	base_ex;		//Result2 of EX Stage
input  	[31:0]	base_me;		//Result2 of ME Stage
input	[31:0]	pc_if;			//PC 
input  	[4:0]	Rd_ex;			//Rd in EX Stage
input  	[4:0]	Rn_ex;			//Rn in EX Stage
input  	[4:0]	Rd_me;			//Rd in ME Stage
input  	[4:0]	Rn_me;			//Rn in ME Stage
input  	[4:0]	mode;			//Mode of Processor
input	[1:0]	exc_code;		//Exception Code
input		nGCLK;			//clock signal
input		nRESET;			//reset signal
input		nWAIT;			//clock enable signal
input		exception;		//Take the Exception 
input		id_enbar;		//ID stage enable (active low)
input		write_Rd_ex;		//Ex_result going to be written?
input		write_Rn_ex;		//Base_ex going to be written?
input		write_Rd_me;		//Me_result going to be written?
input		write_Rn_me;		//Base_me going to be written?
input		cop_absent;		//Coprocessor is Absent
input		hold_next_ex;		//Ex is Stalling

output 	[31:0] 	op1;			//First Operand
output 	[31:0] 	op2;			//Second Operand
output 	[31:0] 	aux_data_id;		//Auxillary Data Operand
output 	[7:0]  	shift_amount;		//Shift Amount
output 	[4:0]  	index_a;		//Address A for RF
output 	[4:0]  	index_b;		//Address B for RF
output 	[4:0]  	Rd_id;			//First Destination
output 	[4:0]  	Rn_id;			//Second Destination
output 	[3:0]  	alu_opcode;		//ALU Opcode
output 	[3:0]  	condition;		//Condition
output 	[3:0]  	inst_type_id;		//4-Bit Instruction Code
output 	[2:0]  	shift_type;		//Shift Type  
output 	[6:4]  	ir_id;			//Bits 6:4 of IR
output        	need_2cycles;		//Signal that three Regs Required
output	      	second;			//Signal in Second Cycle
output	      	second_nlu;		//2nd Cycle, not due to Load Use
output	      	load_use;		//Load-Use Interlock Necessary
output	      	ldm;			//Inst is LDM to interlock.v
output	      	stm;			//Inst is STM to interlock.v
output	      	finished;		//Inst is finished to interlock.v
output        	s;			//S bit of Instruction
output	      	double_id;		//64-bit Memory access
output	      	mul_first;		//First cycle of LDM/STM
output	      	cop_mem_id;		//Coprocessor Inst. req. Memory
output	      	cop_id;			//Coprocessor Inst Present
output          exception_id;           //Exception to EX Stage
output		stop_id;		//Stop Execution
output  [1:0]   exc_code_id;            //Exception Code to EX Stage

/*------------------------------------------------------------------------
        Variable Declarations
------------------------------------------------------------------------*/

//Declare Outputs of Multiplexers and Registers
reg  [31:0] ir;				//Instruction Register
reg  [31:0] op1;			//Operand 1
reg  [31:0] op2;			//Operand 2
reg  [31:0] aux_data_id;		//Auxillary Data Operand
reg  [31:0] imm_32;			//Imm 2B Shifted
reg  [31:0] forwarded_op1;		//Data to Forward to Op1
reg  [31:0] forwarded_op2;		//Data to Forward to Op2
reg  [15:0] reg_mask_a;			//Intermediate Reg Mask
reg  [15:0] next_reg_mask;		//Next Register Mask
reg  [7:0]  imm_8;			//Imm Shfit Amount
reg  [7:0]  shift_amount;		//Shift Amount
reg  [4:0]  mode_user_a;		//Mode mux btwn Current/User
reg  [4:0]  mode_user_b;		//Mode mux btwn Current/User
reg  [4:0]  mode_user_Rn;		//Mode mux btwn Current/User/Und
reg  [3:0]  addr_a;			//Address A for RF
reg  [3:0]  addr_b;			//Address B for RF
reg  [3:0]  map_Rn;			//Base Register to Mapper
reg  [3:0]  map_Rd;			//Dest Register to Mapper
reg  [3:0]  inst_type;                  //Inst Code
reg  [3:0]  inst_type_id;		//Inst Code/Exception
reg  [2:0]  shift_type;			//Shift Type Control Signals
reg  [1:0]  exc_code_id;                //Exception Code to be taken
reg         exception_id;               //Exception to be taken
reg         second;			//2nd Cycle of RF reads
reg	    ldm_stm;			//One Bit Reg indicating LDM/STM
reg	    ldr_ex;			//Prev Inst was LDRW/H
reg	    ldm_ex;			//Prev Inst was LDM

//Declare Outputs of Combinational Logic
wire [15:0] mask_a_n;			//Anding Mask (inverted)
wire [15:0] mask_b_n;			//Anding Mask (inverted)
wire [15:0] reg_mask_b;			//One Bit removed 
wire [15:0] reg_mask_c;			//Two Bits removed
wire [4:0]  index_a;			//5-bit RF A index
wire [4:0]  index_b;			//5-bit RF B index
wire [4:0]  Rd_id;                      //Mapped Rd 
wire [4:0]  Rn_id;                      //Mapped Rn 
reg  [3:0]  mreg_a;			//Multiple Instruction Reg A
reg  [3:0]  mreg_b;			//Multiple Instruction Reg B
wire [3:0]  alu_opcode;			//Opcode to ALU
wire [3:0]  condition;			//Condition of Execution
wire [3:0]  Rd;				//Rd from Instruction
wire [3:0]  Rn;				//Rn from Instruction
wire [3:0]  Rm;				//Rm from Instruction
wire [3:0]  Rs;				//Rs from Instruction
wire [6:4]  ir_id;			//Bits 6-5 of IR
wire        double_id;			//64-bit Data Access
wire	    no_lu_on_op1;		//No Load-Use match for Op1
wire	    no_lu_on_op2;		//No Load-Use match on Op2
wire 	    need_2cycles;		//Inst Requires 2 Cycles
wire        branch;			//Instruction is a Branch
wire        multiply;			//Instruction is a MUL/MULL
wire	    alu;			//Instruction is an ALU
wire	    swap;			//Instruction is a SWAP
wire        ldrhi;			//Inst is LDRH/SH/SB & imm offset  
wire	    ldrh;			//Inst is LDRH/SH/SB
wire	    ldri;			//Inst is LDR with Imm Offset
wire	    ldrw;			//Inst is a LDRW
wire	    strhi;			//Inst is STRH & imm offset
wire	    strh;			//Inst is STRH
wire	    strw;			//Inst is STRW
wire	    stri;			//Inst is STRH/STR with imm Offset
wire	    ldm;			//Inst is LDM
wire	    stm;			//Inst is STM
wire	    str;			//Inst is STR/STRH
wire	    swi;			//Inst is SWI
wire	    msr;			//Inst is MSR
wire	    und;			//Inst is Undefined
wire        s;				//S bit of Instruction
wire	    forward_op1;		//Forward op1?
wire	    forward_op2;		//Forward op2?
wire	    forward_aux;		//Forward Aux Data Value
wire	    forward_sh_amt;		//Forward the data to Shift Amount
wire	    op2_is_imm;			//Op2 Immediate Value?
wire	    alu_3_reg;			//Shifted by Register Value
wire	    load_use;			//Load Use Interlock Necessary
wire	    load_use_Rn;		//Load Use to Rn
wire	    load_use_Rd;		//Load Use to Rd
wire	    second_nlu;			//2nd Cycle, not due to Load Use
wire	    swap_noforward;		//If Rd=Rm of Swap, don't forward
wire	    mul_first;			//LDM/STM in first cycle
wire 	    finished;			//This signals the end of LDM/STM
wire	    cop_id;			//Coprocessor Instruction
wire	    cop_mem_id;			//Coprocessor Inst using Memory
wire        stop_id;                    //Stop Execution (BL to Self)

/*------------------------------------------------------------------------
        Component Instantiations
------------------------------------------------------------------------*/

// Instantiate mapreg
// This will map Op1
mapreg	xmap_1 (.reg_field(addr_a), .mode(mode_user_a), .reg_addr(index_a));

// Instantiate mapreg
// This will map Op2
mapreg  xmap_2 (.reg_field(addr_b), .mode(mode_user_b), .reg_addr(index_b));

// Instantiate mapreg
// This will map Rn
mapreg  xmap_3 (.reg_field(map_Rn), .mode(mode_user_Rn), .reg_addr(Rn_id));

// Instantiate mapreg
// This will map Rd
mapreg  xmap_4 (.reg_field(map_Rd), .mode(mode_user_b), .reg_addr(Rd_id));

//Decoders for LDM/STM commands
decode xdec1 (.in(mreg_a), .out(mask_a_n));
decode xdec2 (.in(mreg_b), .out(mask_b_n));

/*------------------------------------------------------------------------
        Combinational Logic
------------------------------------------------------------------------*/

assign multiply		= ((inst_type==`MUL)||(inst_type==`MULL));
assign str		= ((inst_type==`STRW)||(inst_type==`STRH));
assign alu		= (inst_type == `ALU);
assign strh		= (inst_type == `STRH);
assign strw 		= (inst_type == `STRW);
assign swi		= (inst_type == `SWI);
assign branch 		= (inst_type == `BR);
assign swap 		= (inst_type == `SWAP);
assign msr 		= (inst_type == `MSR);
assign ldm 		= (inst_type == `LDM);
assign ldrw		= (inst_type == `LDRW);
assign stm 		= (inst_type == `STM);
assign cop_id		= (ir[27:26] == 2'h3) && (ir[25:24] != 2'h3);
assign und		= (inst_type == `UND) | ((inst_type == `COP) && (cop_absent==1'b1));
assign ldrh		= (inst_type == `LDRH);
assign swap_noforward 	= (swap && (Rd == Rm));
assign condition        = ir[31:28];
assign alu_opcode 	= ir[24:21];
assign Rn               = ir[19:16];
assign Rd 		= ir[15:12];
assign Rs               = ir[11:8];
assign Rm 		= ir[3:0];
assign s 		= ir[20];
assign ir_id 		= ir[6:4];
assign finished         = !(| reg_mask_c);
assign reg_mask_b	= reg_mask_a & ~mask_a_n;
assign reg_mask_c 	= reg_mask_b & ~mask_b_n;
assign double_id        = ldm_stm & (| reg_mask_b);
assign stop_id          = ir == 32'hebfffffe;   

//Indicates a Coprocessor Instruction using Memory
assign cop_mem_id = (ir[27:25] == 3'h6) & !und;

//Indicates an LDRH with an Immediate Offset
assign ldrhi = ((inst_type == `LDRH) & (ir[22]));

//Indicates an LDR with an Immediate Offset
assign ldri = ((inst_type == `LDRW) & (!ir[25]));

//Indicates a STRH with an Immediate offset
assign strhi = ((inst_type == `STRH) & (ir[22]));

//Indicates that 3 Registers may be required, if this is indeed an
//ALU type instruction.
assign alu_3_reg = (!ir[25] & ir[4]);

//Indicates that an LDM/STM is present in its first cycle
assign mul_first = (ldm | stm) & !ldm_stm;

//Indicates that an STR/STRH with Imm Offset
assign stri = ((inst_type == `STRH) & (ir[22])) ||
	      ((inst_type == `STRW) & (!ir[25]));

//Indicates that this is the 2nd Cycle of the current instruction,
//however, the extra cycle was not caused by a Load-Use interlock.
//This is important for the EX stage, because it behaves differently
//on the 2nd cycle of instructions that require two cycles, such as 
//Stores or ALU w/ 3 registers.
assign second_nlu = second & need_2cycles;

//Certain instructions shouldn't have a Load Use penalty (loads)
//Op1 is the base for LDM (that's the only load that can issue a lu for op1)
assign no_lu_on_op1 = (ldm & !mul_first) | ldrw | ldrh;
assign no_lu_on_op2 = ldm;

//Check for the Load-Use condition.  This occurs when the previous
//instruction is a load and the current instruction uses the value
//that is being loaded.
assign load_use_Rd = ((ldr_ex | ldm_ex) & (
			(write_Rd_ex & (Rd_ex == index_a) & !no_lu_on_op1) |
                    	(write_Rd_ex & (Rd_ex == index_b) & !no_lu_on_op2
                                 & !branch & !(op2_is_imm & !stri))));

assign load_use_Rn = (ldm_ex & (
			(write_Rn_ex & (Rn_ex == index_a) & !no_lu_on_op1) |
                    	(write_Rn_ex & (Rn_ex == index_b) & !no_lu_on_op2
                                 & !branch & !op2_is_imm)));

assign load_use = load_use_Rn | load_use_Rd;

//Set up the Need Cycle Signal
//Need extra Cycle for MLA, MLAL,STR/H with register offset, SWAP, & ALU
//instructions that have a register specified shift amount.
assign need_2cycles = ((strh & (!ir[22]))   |			//STRH 
		       (strw & (ir[25]))    |			//STRW
		       (swap) 		    |			//SWAP
		       (alu & alu_3_reg)    | 			//ALU
		       (multiply & ir[21])); 			//MLA/L 

//Determine whether Op2 is Reg or Imm Value
assign op2_is_imm = (swap | (alu & ir[25]) | ldri | stri |
                     ldrhi | (msr & ir[25]) | cop_mem_id | 
		     (und | swi) | mul_first);

//Forward Data to Op1 if there is a unfinished write to op1 reg.
assign forward_op1 = ((write_Rd_ex && (Rd_ex == index_a))||
		      (write_Rn_ex && (Rn_ex == index_a))||
		      (write_Rd_me && (Rd_me == index_a))||
		      (write_Rn_me && (Rn_me == index_a))) ? 1'b1 : 1'b0;

//Forward Data to Op2 if there is an unfinished write to op2 reg.
//Don't forward if Op2 is an Immediate Value  
assign forward_op2 = 
	(((write_Rd_ex && (Rd_ex == index_b))||
	  (write_Rn_ex && (Rn_ex == index_b))||
	  (write_Rd_me && (Rd_me == index_b))|| 
	  (write_Rn_me && (Rn_me == index_b))) && !op2_is_imm) ? 1'b1 : 1'b0;

//Forward Data to Aux if there is an unfinished write to aux_data reg.
//For Swap instructions with Rd=Rm, have to make sure that the
//loaded data into Rd is not forwarded into Rm.
assign forward_aux =
        (((write_Rd_ex && (Rd_ex == index_b)) && (!swap_noforward) ||
          (write_Rn_ex && (Rn_ex == index_b))||
          (write_Rd_me && (Rd_me == index_b))||
          (write_Rn_me && (Rn_me == index_b)))) ? 1'b1 : 1'b0;


//Forward Data to the shift amount mux if unfinished write to 
//Shift Register.
assign forward_sh_amt = (second_nlu && (inst_type == `ALU) &&
		((write_Rd_ex && (Rd_ex == index_a)) ||
		 (write_Rn_ex && (Rn_ex == index_a)) ||
		 (write_Rd_me && (Rd_me == index_a)) ||
		 (write_Rn_me && (Rn_me == index_a))));

/*------------------------------------------------------------------------
        Sequential Always Blocks
------------------------------------------------------------------------*/

//This block controls the IR
always @(posedge nGCLK or negedge nRESET)
  begin
    if (!nRESET)
      ir <= 32'h00000000;
    else if (nWAIT)
      begin
        if (!id_enbar)
          ir <= inst;
      end
  end

//This block controls the Exception Bit
always @(posedge nGCLK or negedge nRESET)     
  begin
    if (~nRESET)
      exception_id <= 1'b0;
    else if (nWAIT)
      begin
        if (~id_enbar)
          exception_id <= exception;
      end
  end

//This block controls the Exception Code Bits
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      exc_code_id <= 2'h0;
    else if (nWAIT)
      begin
        if (~id_enbar)
          exc_code_id <= exc_code;
      end
  end

//This block controls the second bit
//If id_enbar is not high, then a new instruction
//will be loaded into the IR and thus, will not
//be starting the 2nd cycle of past instruction
always @(posedge nGCLK or negedge nRESET)
  begin
    if (!nRESET)
      second <= 1'b0;
    else if (nWAIT)
      begin
	if (((need_2cycles & !load_use) | 
	     (load_use & !need_2cycles)) & 
	    id_enbar & !hold_next_ex)
	  second <= ~second;
	else
	  second <= 1'b0;
      end
  end

//These next two blocks control the flip-flops that
//make up the Register Mask used in LDM/STM instructions.
//When AND'd together, these represent the registers left
//to transfer.
always @(ldm_stm or ir or next_reg_mask)
    begin
	if (!ldm_stm)
	    reg_mask_a <= ir[15:0];
	else
	    reg_mask_a <= next_reg_mask;
    end	

always @(posedge nGCLK or negedge nRESET)
    begin
	if (!nRESET)
	    ldm_stm <= 1'b0;
	else if (nWAIT)
	    ldm_stm <= (ldm || stm) && id_enbar && !hold_next_ex;
    end

//Remember whether last inst was a load
always @(posedge nGCLK or negedge nRESET)
    begin
	if (!nRESET)
	    ldr_ex <= 1'b0;
	else if (nWAIT)
	    ldr_ex <= ldrh | ldrw;
    end

always @(posedge nGCLK or negedge nRESET)
    begin
	if (!nRESET)
	    ldm_ex <= 1'b0;
	else if (nWAIT)
	    ldm_ex <= ldm;
    end

/*------------------------------------------------------------------------
        Combinational Always Blocks
------------------------------------------------------------------------*/

//Mux the inst_code/Exception
always @(inst_type or und)
    begin
	if (und)
	    inst_type_id = `UND;
	else
	    inst_type_id = inst_type;
    end

//Mux the mode bits into the mapreg module
//For some LDM/STM need to transfer USER regs
always @(ir or ldm or stm or ldm_stm or mode)
    begin
	if (!ldm_stm & ((!ir[15] & ir[22] & ldm) || (ir[22] & stm)))
	    mode_user_a <= 5'b10000;
	else
	    mode_user_a <= mode;
    end

//Mux the mode bits into the mapreg module
//For some LDM/STM need to transfer USER regs
always @(ir or ldm or stm or mode) 
    begin
	if ((!ir[15] && ir[22] && ldm) || (ir[22] && stm))
            mode_user_b <= 5'b10000;
        else
            mode_user_b <= mode;
    end

//Mux the mode bits into the mapreg module
//For some LDM/STM need to transfer USER regs
//For exceptions, need to get correct link reg
always @(mode_user_a or und or swi or exception_id or exc_code_id)
    begin
	if (exception_id)
	  begin
	    case (exc_code_id)	//synopsys full_case parallel_case

	      2'b00, 2'b11: mode_user_Rn = 5'b10111; 	//D/I Abort
	      2'b01: mode_user_Rn = 5'b10001;		//FIQ
	      2'b10: mode_user_Rn = 5'b10010;		//IRQ

	    endcase
	  end

	else if (und)			//Und Mode
	    mode_user_Rn = 5'b11011;
	else if (swi)			//SVC MOde
	    mode_user_Rn = 5'b10011;
	else
	    mode_user_Rn = mode_user_a;
    end

//Calculate the number of multiples of 4 which will
//be added or subtracted to from Rn to form the new
//base value for LDM/STM instructions.
integer i;
integer count;
always @(ldm or stm or ir)
    begin
      count = 0;
	if (ldm | stm)
	  begin
	    for (i = 0; i <= 15; i = i+1) 
	      begin
	          count = count + ir[i];	
              end

	  end
    end

//Set up a Priority Encoder to find
//Next LDM/STM Register in transfer
always @(reg_mask_a)
  begin
    casex (reg_mask_a) //synopsys parallel_case
      16'b0000000000000000: mreg_a = 4'h0;
      16'b???????????????1: mreg_a = 4'h0;
      16'b??????????????10: mreg_a = 4'h1;
      16'b?????????????100: mreg_a = 4'h2;
      16'b????????????1000: mreg_a = 4'h3;
      16'b???????????10000: mreg_a = 4'h4;
      16'b??????????100000: mreg_a = 4'h5;
      16'b?????????1000000: mreg_a = 4'h6;
      16'b????????10000000: mreg_a = 4'h7;
      16'b???????100000000: mreg_a = 4'h8;
      16'b??????1000000000: mreg_a = 4'h9;
      16'b?????10000000000: mreg_a = 4'hA;
      16'b????100000000000: mreg_a = 4'hB;
      16'b???1000000000000: mreg_a = 4'hC;
      16'b??10000000000000: mreg_a = 4'hD;
      16'b?100000000000000: mreg_a = 4'hE;
      16'b1000000000000000: mreg_a = 4'hF;
    endcase

    casex (reg_mask_a) //synopsys parallel_case
      16'b0000000000000000,
      16'b0000000000000001,
      16'b0000000000000010,
      16'b0000000000000100,
      16'b0000000000001000,
      16'b0000000000010000,
      16'b0000000000100000,
      16'b0000000001000000,
      16'b0000000010000000,
      16'b0000000100000000,
      16'b0000001000000000,
      16'b0000010000000000,
      16'b0000100000000000,
      16'b0001000000000000,
      16'b0010000000000000,
      16'b0100000000000000,
      16'b1000000000000000: mreg_b = 4'h0;
      16'b??????????????11: mreg_b = 4'h1;
      16'b?????????????101, 
      16'b?????????????110: mreg_b = 4'h2;
      16'b????????????1001,
      16'b????????????1010,
      16'b????????????1100: mreg_b = 4'h3;
      16'b???????????10001,
      16'b???????????10010,
      16'b???????????10100,
      16'b???????????11000: mreg_b = 4'h4;
      16'b??????????100001,
      16'b??????????100010,
      16'b??????????100100,
      16'b??????????101000,
      16'b??????????110000: mreg_b = 4'h5;
      16'b?????????1000001,
      16'b?????????1000010,
      16'b?????????1000100,              
      16'b?????????1001000,
      16'b?????????1010000,
      16'b?????????1100000: mreg_b = 4'h6;
      16'b????????10000001,
      16'b????????10000010,
      16'b????????10000100,
      16'b????????10001000,
      16'b????????10010000,
      16'b????????10100000,
      16'b????????11000000: mreg_b = 4'h7;
      16'b???????100000001,
      16'b???????100000010,
      16'b???????100000100,
      16'b???????100001000,
      16'b???????100010000,
      16'b???????100100000,
      16'b???????101000000,
      16'b???????110000000: mreg_b = 4'h8;
      16'b??????1000000001,
      16'b??????1000000010,
      16'b??????1000000100,
      16'b??????1000001000,
      16'b??????1000010000,
      16'b??????1000100000,
      16'b??????1001000000,
      16'b??????1010000000,
      16'b??????1100000000: mreg_b = 4'h9;
      16'b?????10000000001,
      16'b?????10000000010,
      16'b?????10000000100,
      16'b?????10000001000,
      16'b?????10000010000,
      16'b?????10000100000,
      16'b?????10001000000,
      16'b?????10010000000,
      16'b?????10100000000,
      16'b?????11000000000: mreg_b = 4'hA;
      16'b????100000000001,
      16'b????100000000010,
      16'b????100000000100,
      16'b????100000001000,
      16'b????100000010000,
      16'b????100000100000,
      16'b????100001000000,
      16'b????100010000000,
      16'b????100100000000,
      16'b????101000000000,
      16'b????110000000000: mreg_b = 4'hB;
      16'b???1000000000001,
      16'b???1000000000010,
      16'b???1000000000100,
      16'b???1000000001000,
      16'b???1000000010000,
      16'b???1000000100000,
      16'b???1000001000000,
      16'b???1000010000000,
      16'b???1000100000000,
      16'b???1001000000000,
      16'b???1010000000000,
      16'b???1100000000000: mreg_b = 4'hC;
      16'b??10000000000001,
      16'b??10000000000010,
      16'b??10000000000100,
      16'b??10000000001000,
      16'b??10000000010000,
      16'b??10000000100000,
      16'b??10000001000000,
      16'b??10000010000000,
      16'b??10000100000000,
      16'b??10001000000000,
      16'b??10010000000000,
      16'b??10100000000000,
      16'b??11000000000000: mreg_b = 4'hD;
      16'b?100000000000001,
      16'b?100000000000010,
      16'b?100000000000100,
      16'b?100000000001000,
      16'b?100000000010000,
      16'b?100000000100000,
      16'b?100000001000000,
      16'b?100000010000000,
      16'b?100000100000000,
      16'b?100001000000000,
      16'b?100010000000000,
      16'b?100100000000000,
      16'b?101000000000000,
      16'b?110000000000000: mreg_b = 4'hE;
      16'b1000000000000001,
      16'b1000000000000010,
      16'b1000000000000100,
      16'b1000000000001000,
      16'b1000000000010000,
      16'b1000000000100000,
      16'b1000000001000000,
      16'b1000000010000000,
      16'b1000000100000000,
      16'b1000001000000000,
      16'b1000010000000000,
      16'b1000100000000000,
      16'b1001000000000000,
      16'b1010000000000000,
      16'b1100000000000000: mreg_b = 4'hF;
  endcase
end

//Mux and Latch the next reg mask value
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
    begin
	if (!nRESET)
	  next_reg_mask <= 16'h0000;
	else if (nWAIT)
	  next_reg_mask <= (mul_first) ? reg_mask_b : reg_mask_c;
    end
	
//Read Operand 1
//For LDM/STM in 2+ cycle, addr_a = next transfer
//For 1st Multiply want Rs
//All others want Rn
always @(second_nlu or multiply or Rn or Rs or ldm_stm or mreg_b or
		mul_first)
    begin
        if (ldm_stm)
            addr_a = mreg_b;
        else if (!(second_nlu ^ multiply) | mul_first)
            addr_a = Rn;
        else
            addr_a = Rs;
    end

//Read Operand 2
//For LDM/STM want next transfer
//For most other want Rm
//For 2nd of multiply or 1st store want Rd
always @(second_nlu or Rm or Rd or mreg_a or stri or
                ldm or stm or cop_id or swap)
    begin
        if (ldm | stm)
            addr_b = mreg_a;
        else if (!cop_id & ((!second_nlu & !stri) |
                                     (second_nlu && swap)))
            addr_b = Rm;
        else
            addr_b = Rd;
    end     

//Set the Base Register
//For LDM/STM comes from transfer list
//For exception/branch want R14
//for rest, want Rn
always @(Rn or ldm_stm or mreg_b or branch or und or swi or exception_id)
    begin
	if (ldm_stm)
	    map_Rn = mreg_b;
	else if (branch | und | swi | exception_id)
	    map_Rn = 4'hE;
	else
	    map_Rn = Rn;
    end

//Set the Dest Register
//IF 1st LDM/STM, want first transfer
//if 2+ LDM/STM want next transfer
//if branch/exception, want PC
//All others, Rd
always @(ldm or stm or mreg_a or branch or und or Rd or swi) 
    begin
	if (ldm | stm)
	    map_Rd = mreg_a;
	else if (branch | und | swi)
	    map_Rd = 4'hF;
	else
	    map_Rd = Rd;
    end	   
 
//Create the 32-Bit Immediate Value used as Op2
//All cases should be mutually exclusive.
//For Undefined, should do this like the nRESET and modify PC directly
always @(ir or ldrhi or strhi or Rs or Rm or swap or count
		or stm or ldm or und or swi)
    begin
	casex ({(und | swi), ldm,stm,ir[27:25],ldrhi,strhi,swap}) //synopsys parallel_case full_case

	    //Undefined Instruciton
	    9'b1????????: imm_32 = {28'h0000000, swi, und, 2'h0};

	    //LDM or STM Instruction
	    9'b010??????,
            9'b001??????: imm_32 = (count << 2);

	    //LDRW or STRW with Immediate Offset	
	    9'b0??010???: imm_32 = {20'h00000,ir[11:0]};

	    //LDRH or STRH with Immediate Offset
	    9'b0?????10?,
	    9'b0?????01?: imm_32 = {24'h000000,Rs,Rm};
	
	    //SWAP Instruction
	    9'b0???????1: imm_32 = 32'h00000000;
	
	    //Immediate Rotates
	    default: imm_32 = {24'h000000,ir[7:0]};
	endcase
    end

//Create the 8-bit Immediate Value used as Shift Amount
always @(ir or Rs or branch or ldrh or cop_mem_id
		or ldm or stm or stri or ldri or strh)
    begin
	if (ir[27:25] == 3'h1) 		//ALU with Rotated Immediate or
	    imm_8 = {3'h0, Rs, 1'h0};   //MSR with Rotated Immediate
	else if (branch || ldrh || stri || ldri || ldm || stm || strh)
	    imm_8 = 8'h00;
	else if (cop_mem_id)
	    imm_8 = 8'h2;
	else				
	    imm_8 = {2'h0,ir[11:7]};
    end

//Mux the Forwarding Data for Op1
//Priority is Important Here!!!
always @(write_Rd_ex or Rd_ex or index_a or write_Rn_ex
		or Rn_ex or write_Rd_me or Rd_me or base_ex 
		or write_Rn_me or Rn_me or ex_result
		or me_result or base_me)
    begin
	if ((write_Rd_ex) && (index_a == Rd_ex))
	    forwarded_op1 = ex_result;
	else if ((write_Rn_ex) && (index_a == Rn_ex))
	    forwarded_op1 = base_ex;
	else if ((write_Rd_me) && (index_a == Rd_me))
	    forwarded_op1 = me_result;
	else
	    forwarded_op1 = base_me;
    end

//Mux the Forwarding Data for Op2
//Priority is important here!!!
always @(write_Rd_ex or Rd_ex or index_b or write_Rn_ex
                or Rn_ex or write_Rd_me or Rd_me or base_ex
                or write_Rn_me or Rn_me or ex_result
                or me_result or base_me)
    begin
	if ((write_Rd_ex) && (index_b == Rd_ex))
            forwarded_op2 = ex_result;
        else if ((write_Rn_ex) && (index_b == Rn_ex))
	    forwarded_op2 = base_ex;
        else if ((write_Rd_me) && (index_b == Rd_me))
            forwarded_op2 = me_result;
        else                                              
            forwarded_op2 = base_me;
    end     

//Set Op1
always @(rf_a or forward_op1 or forwarded_op1 or pc_if or branch 
		or und or swi or exception_id)
    begin
	if (branch | und | swi | exception_id) //Op1 is PC
	    op1 = pc_if;
 	else if (forward_op1)		//Op1 from Unwritten Result
	    op1 = forwarded_op1;
	else 				//Op1 is Rn/Rs
	    op1 = rf_a;
    end

//Set Op2
always @(branch or ir or forward_op2 or forwarded_op2 or index_b 
		or imm_32 or op2_is_imm or rf_b)
    begin
	if (branch)	 		//Op2 is Branch Offset
	    op2 = {{6{ir[23]}},ir[23:0],2'b00};
	else if (forward_op2)		//Op2 from Unwritten result
	    op2 = forwarded_op2;	
        else if (op2_is_imm)            //Op2 is Imm Value
            op2 = imm_32;
	else				//Op2 is Rm/Rd
	    op2 = rf_b;
    end

//Set up the Auxillary Data Operand
always @(forward_aux or rf_b or forwarded_op2)
    begin
	if (forward_aux)
	    aux_data_id = forwarded_op2;
	else
	    aux_data_id = rf_b;
    end

//Set the Shift Amount
always @(rf_a or second_nlu or imm_8 or forwarded_op1 or forward_sh_amt 
		or str)
    begin
	if (forward_sh_amt)
	    shift_amount = forwarded_op1[7:0];
	else if (second_nlu & !str)
	    shift_amount = rf_a[7:0];
	else
	    shift_amount = imm_8;
    end

/*Set the Shift Type.
	shift_type[1:0]		2'b00: LSL
				2'b01: LSR
				2'b10: ASR
				2'b11: ROR
   	shift_type[2]		1'b1:  ALU Shift Reg by Imm
                        	1'b0:  All Other Shifts
*/
always @(ir or msr or ldm or stm or cop_mem_id or und)
    begin
	if (ldm || stm || cop_mem_id || und)
	    shift_type = 3'h0;
	else if (ir[27:26] == 2'h1)
            shift_type = {1'b0,ir[6:5]};
	else if (!ir[25] & !msr) 
	    shift_type = {~ir[4],ir[6:5]};
	else
	    shift_type = 3'h3;
    end

//Decode the Instruction Type
always @(ir or Rd)
    begin
	case(ir[27:20]) //synopsys full_case parallel_case
	    8'h00: begin
			if (ir[11:4] == 8'h0B)
				inst_type = `STRH;
		   	else if (ir[7:4] == 4'h9)
				inst_type = `MUL;
		   	else
				inst_type = `ALU;
		    end

	    8'h01: begin
                        if (ir[7:4] == 4'h9)
                            inst_type = `MUL;
                        else if ((ir[11:4] & 8'hF9) == 8'h09)
                            inst_type = `LDRH;
                        else
                            inst_type = `ALU;
                   end  

            8'h02: begin
                        if (ir[11:4] == 8'h0B)
                            inst_type = `STRH;
                        else if (ir[7:4] == 4'h9)
                            inst_type = `MUL;
                        else
                            inst_type = `ALU;
                   end  

            8'h03: begin
                        if (ir[7:4] == 4'h9)
                            inst_type = `MUL;
                        else if ((ir[11:4] & 8'hF9) == 8'h09)
                            inst_type = `LDRH;
                        else
                            inst_type = `ALU;
                   end  

            8'h04: begin
                        if (ir[7:4] == 4'hB)
                            inst_type = `STRH;
                        else
                            inst_type = `ALU;   
                   end

            8'h05: begin
                        if ((ir[11:4] & 8'h09) == 8'h09)
                            inst_type = `LDRH;  
                        else
                            inst_type = `ALU;
                   end  
                        
            8'h06: begin
                        if (ir[7:4] == 4'hB)
                            inst_type = `STRH;
                        else
                            inst_type = `ALU;
                   end  
                        
            8'h07: begin
                        if ((ir[11:4] & 8'h09) == 8'h09)
                            inst_type = `LDRH;
                        else
                            inst_type = `ALU;
                   end  
                        
            8'h08: begin
                        if (ir[11:4] == 8'h0B)
                            inst_type = `STRH;
                        else if (ir[7:4] == 4'h9)
                            inst_type = `MULL;
                        else
                            inst_type = `ALU;
                   end  
                        
            8'h09: begin
                        if (ir[7:4] == 4'h9)
                            inst_type = `MULL;
                        else if ((ir[11:4] & 8'hF9) == 8'h09)
                            inst_type = `LDRH;
                        else 
                            inst_type = `ALU; 
                   end
                
            8'h0A: begin
                        if (ir[11:4] == 8'h0B)
                            inst_type = `STRH;
                        else if (ir[7:4] == 4'h9)
                            inst_type = `MULL;
                        else
                            inst_type = `ALU;
                   end
                        
            8'h0B: begin
                        if (ir[7:4] == 4'h9)
                            inst_type = `MULL;
                        else if ((ir[11:4] & 8'hF9) == 8'h09)
                            inst_type = `LDRH;
                        else
                            inst_type = `ALU;
                   end
                        
            8'h0C: begin
                        if (ir[7:4] == 4'hB)
                            inst_type = `STRH;
                        else if (ir[7:4] == 4'h9)
                            inst_type = `MULL;
                        else
                            inst_type = `ALU;
                    end
                        
            8'h0D: begin
                        if (ir[7:4] == 4'h9)
                            inst_type = `MULL;
                        else if ((ir[11:4] & 8'h09) == 8'h09)
                            inst_type = `LDRH;
                        else
                            inst_type = `ALU;
                    end
                        
            8'h0E: begin
                        if (ir[7:4] == 4'hB)
                            inst_type = `STRH;
                        else if (ir[7:4] == 4'h9)
                             inst_type = `MULL;   
                        else
                            inst_type = `ALU;
                    end
                        
            8'h0F: begin
                        if (ir[7:4] == 4'h9)
                            inst_type = `MULL;
                        else if ((ir[11:4] & 8'h09) == 8'h09)
                            inst_type = `LDRH;
                        else
                            inst_type = `ALU;
                    end
                        
            8'h10: begin
                        if (ir[11:4] == 8'h0B)
                            inst_type = `STRH;
                        else if (ir[11:4] == 8'h09)
                            inst_type = `SWAP;
                        else if ((ir[11:0] == 8'h00) & (ir[21:16] == 6'h0F))
                            inst_type = `MRS;
                        else
                            inst_type = `ALU;
                    end
                       
            8'h11: begin 
                        if ((ir[11:4] & 8'hF9) == 8'h09)
                            inst_type = `LDRH;
                        else
                            inst_type = `ALU;
                    end
                        
            8'h12: begin
                        if (ir[11:4] == 8'h0B)
                            inst_type = `STRH;
                        else if ((Rd == 4'hF) && (ir[18:17] == 2'b00))
                            inst_type = `MSR;
                        else
                            inst_type = `ALU;
                    end
                        
            8'h13: begin
                        if ((ir[11:4] & 8'hF9) == 8'h09)
                            inst_type = `LDRH;
                        else
                            inst_type = `ALU;
                    end
                        
                
            8'h14: begin   
                        if (ir[7:4] == 4'hB)
                            inst_type = `STRH;
                        else if (ir[11:4] == 8'h09)
                            inst_type = `SWAP;
                        else if ((ir[11:4] == 8'h00) && (ir[21:16] == 6'h0F))
                            inst_type = `MRS; 
                        else
                            inst_type = `ALU;
                    end
                        
            8'h15: begin 
                        if ((ir[11:4] & 8'h09) == 8'h09)
                            inst_type = `LDRH;
                        else
                            inst_type = `ALU;
                    end
                        
            8'h16: begin
                        if (ir[7:4] == 4'hB)
                            inst_type = `STRH;
                        else if ((Rd == 4'hF) && (ir[18:17] == 2'b00))
                            inst_type = `MSR;
                        else
                            inst_type = `ALU;
                    end
                        
            8'h17: begin
                        if ((ir[11:4] & 8'h09) == 8'h09)
                            inst_type = `LDRH;
                        else
                            inst_type = `ALU;
                    end
                        
            8'h18: begin
                        if (ir[11:4] == 8'h0B)
                            inst_type = `STRH;
                        else
                            inst_type = `ALU;
                    end  
                        
            8'h19: begin
                        if ((ir[11:4] & 8'hF9) == 8'h09)
                            inst_type = `LDRH;
                        else
                            inst_type = `ALU;
                    end  
                        
            8'h1A: begin
                        if (ir[11:4] == 8'h0B)
                            inst_type = `STRH;
                        else
                            inst_type = `ALU;
                    end  
                        
            8'h1B: begin
                        if ((ir[11:4] & 8'hF9) == 8'h09)
                            inst_type = `LDRH;
                        else
                            inst_type = `ALU;
                    end  
                        
            8'h1C: begin
                        if (ir[7:4] == 4'hB)
                            inst_type = `STRH;
                        else
                            inst_type = `ALU;
                    end  
                        
            8'h1D: begin
                        if ((ir[11:4] & 8'h09) == 8'h09)
                            inst_type = `LDRH;
                        else
                            inst_type = `ALU;
                    end  
                        
            8'h1E: begin
                        if (ir[7:4] == 4'hB)
                            inst_type = `STRH;
                        else
                            inst_type = `ALU;
                    end  
                        
            8'h1F: begin
                        if ((ir[11:4] & 8'h09) == 8'h09)
                            inst_type = `LDRH;
                        else
                            inst_type = `ALU;
                    end  
                        
            8'h20: inst_type = `ALU;                          
            8'h21: inst_type = `ALU;                          
            8'h22: inst_type = `ALU;
            8'h23: inst_type = `ALU;
            8'h24: inst_type = `ALU;                            
            8'h25: inst_type = `ALU;                
            8'h26: inst_type = `ALU;                
            8'h27: inst_type = `ALU;                
            8'h28: inst_type = `ALU;
            8'h29: inst_type = `ALU;
            8'h2A: inst_type = `ALU;
            8'h2B: inst_type = `ALU;
            8'h2C: inst_type = `ALU;
            8'h2D: inst_type = `ALU;
            8'h2E: inst_type = `ALU;
            8'h2F: inst_type = `ALU;
            8'h30: inst_type = `ALU;
            8'h31: inst_type = `ALU;
                
            8'h32: begin
                        if ((Rd == 4'hF)&&(ir[18:17] == 2'b0))
                            inst_type = `MSR;
                        else   
                            inst_type = `ALU;
                    end
                
            8'h33: inst_type = `ALU;                
            8'h34: inst_type = `ALU;
            8'h35: inst_type = `ALU;
                
            8'h36: begin
                        if ((Rd == 4'hF)&&(ir[18:17] == 2'b0))
                            inst_type = `MSR;
                        else
                            inst_type = `ALU;
                    end
                    
            8'h37: inst_type = `ALU;                    
            8'h38: inst_type = `ALU;
            8'h39: inst_type = `ALU;                
            8'h3A: inst_type = `ALU;
            8'h3B: inst_type = `ALU;
            8'h3C: inst_type = `ALU;
            8'h3D: inst_type = `ALU;
            8'h3E: inst_type = `ALU;
            8'h3F: inst_type = `ALU;
            8'h40: inst_type = `STRW;
            8'h41: inst_type = `LDRW;
            8'h42: inst_type = `STRW;
            8'h43: inst_type = `LDRW;
            8'h44: inst_type = `STRW;
            8'h45: inst_type = `LDRW;
            8'h46: inst_type = `STRW;
            8'h47: inst_type = `LDRW;
            8'h48: inst_type = `STRW;
            8'h49: inst_type = `LDRW;
            8'h4A: inst_type = `STRW;
            8'h4B: inst_type = `LDRW;
            8'h4C: inst_type = `STRW;
            8'h4D: inst_type = `LDRW;
            8'h4E: inst_type = `STRW;
            8'h4F: inst_type = `LDRW;
            8'h50: inst_type = `STRW;
            8'h51: inst_type = `LDRW;
            8'h52: inst_type = `STRW;
            8'h53: inst_type = `LDRW;
            8'h54: inst_type = `STRW;
            8'h55: inst_type = `LDRW;
            8'h56: inst_type = `STRW;
            8'h57: inst_type = `LDRW;                
            8'h58: inst_type = `STRW;                
            8'h59: inst_type = `LDRW;                
            8'h5A: inst_type = `STRW;                
            8'h5B: inst_type = `LDRW;                
            8'h5C: inst_type = `STRW;                
            8'h5D: inst_type = `LDRW;                
            8'h5E: inst_type = `STRW;                
            8'h5F: inst_type = `LDRW;
                
            8'h60: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `STRW;   
                   end
        
            8'h61: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `LDRW;   
                   end
                
            8'h62: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `STRW;
                   end
                
            8'h63: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `LDRW;
                   end
                    
            8'h64: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `STRW;
                   end
                    
            8'h65: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `LDRW;
                   end
                    
            8'h66: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `STRW;
                   end
                    
            8'h67: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `LDRW;
                   end
                    
            8'h68: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `STRW;
                   end
                    
            8'h69: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `LDRW;
                   end
                    
            8'h6A: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `STRW;
                   end
                    
            8'h6B: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `LDRW;
                   end
                    
            8'h6C: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `STRW;
                   end
                    
            8'h6D: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `LDRW;
                   end
                    
            8'h6E: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `STRW;
                   end
                    
            8'h6F: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `LDRW;
                   end
                    
            8'h70: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `STRW;
                   end
                    
            8'h71: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `LDRW;
                   end
                   
            8'h72: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `STRW;
                   end
                    
            8'h73: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `LDRW;
                   end
                    
            8'h74: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `STRW;
                   end
                    
            8'h75: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `LDRW;
                   end
                    
            8'h76: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `STRW;
                   end
                    
            8'h77: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `LDRW;
                   end
                    
            8'h78: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `STRW;
                   end
                    
            8'h79: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `LDRW;
                   end
                    
            8'h7A: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `STRW;
                   end
                    
            8'h7B: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `LDRW;
                   end
                    
            8'h7C: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `STRW;
                   end
                    
            8'h7D: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `LDRW;
                   end
                    
            8'h7E: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `STRW;
                   end
                    
            8'h7F: begin
                    if (ir[4] == 1'b1)
                        inst_type = `UND;
                    else
                        inst_type = `LDRW;
                   end
                    
            8'h80: inst_type = `STM;                        
            8'h81: inst_type = `LDM;                        
            8'h82: inst_type = `STM;                    
            8'h83: inst_type = `LDM;                        
            8'h84: inst_type = `STM;                        
            8'h85: inst_type = `LDM;                
            8'h86: inst_type = `STM;                
            8'h87: inst_type = `LDM;                
            8'h88: inst_type = `STM;        
            8'h89: inst_type = `LDM;                
            8'h8A: inst_type = `STM;                
            8'h8B: inst_type = `LDM;                
            8'h8C: inst_type = `STM;                
            8'h8D: inst_type = `LDM;
            8'h8E: inst_type = `STM;                
            8'h8F: inst_type = `LDM;                
            8'h90: inst_type = `STM;                
            8'h91: inst_type = `LDM;                
            8'h92: inst_type = `STM;
            8'h93: inst_type = `LDM;
            8'h94: inst_type = `STM;
            8'h95: inst_type = `LDM;                
            8'h96: inst_type = `STM;                
            8'h97: inst_type = `LDM;                
            8'h98: inst_type = `STM;                
            8'h99: inst_type = `LDM;        
            8'h9A: inst_type = `STM;                
            8'h9B: inst_type = `LDM;                
            8'h9C: inst_type = `STM;                
            8'h9D: inst_type = `LDM;                
            8'h9E: inst_type = `STM;
            8'h9F: inst_type = `LDM;
                
            8'hA0, 8'hA1, 8'hA2, 8'hA3,
            8'hA4, 8'hA5, 8'hA6, 8'hA7: inst_type = `BR;  
                
            8'hA8, 8'hA9, 8'hAA, 8'hAB,
            8'hAC, 8'hAD, 8'hAE, 8'hAF: inst_type = `BR;

            8'hB0, 8'hB1, 8'hB2, 8'hB3,
            8'hB4, 8'hB5, 8'hB6, 8'hB7: inst_type = `BR;
                
            8'hB8, 8'hB9, 8'hBA, 8'hBB,
            8'hBC, 8'hBD, 8'hBE, 8'hBF: inst_type = `BR;
        
            8'hC0, 8'hC1, 8'hC2, 8'hC3,
            8'hC4, 8'hC5, 8'hC6, 8'hC7,
            8'hC8, 8'hC9, 8'hCA, 8'hCB,
            8'hCC, 8'hCD, 8'hCE, 8'hCF,
            8'hD0, 8'hD1, 8'hD2, 8'hD3,
            8'hD4, 8'hD5, 8'hD6, 8'hD7,
            8'hD8, 8'hD9, 8'hDA, 8'hDB,
            8'hDC, 8'hDD, 8'hDE, 8'hDF,
            8'hE0, 8'hE1, 8'hE2, 8'hE3,
            8'hE4, 8'hE5, 8'hE6, 8'hE7,
            8'hE8, 8'hE9, 8'hEA, 8'hEB,
            8'hEC, 8'hED, 8'hEE, 8'hEF: inst_type = `COP;
                
            8'hF0, 8'hF1, 8'hF2, 8'hF3,
            8'hF4, 8'hF5, 8'hF6, 8'hF7,
            8'hF8, 8'hF9, 8'hFA, 8'hFB,
            8'hFC, 8'hFD, 8'hFE, 8'hFF: inst_type = `SWI;
        endcase
    end

endmodule
