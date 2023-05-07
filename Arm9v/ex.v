`timescale 1ns/10ps
`include "pardef"
/*****************************************************************************
$RCSfile: ex.v,v $
$Revision: 1.6 $
$Author: kohlere $
$Date: 2000/04/17 18:12:48 $
$State: Exp $

Description:  This is the Execution Stage of the Pipeline.  It 
		contains the Shifter, ALU, and PSR's.  

Note:	In the earlier versions, I saved the RF address decode until the
	registers were accessed.  This was going to cause problems for
	instructions that had different modes when it came to writing and
	forwarding data.  Now that I decode the address in the ID stage, 
	any place where I was using Rn[0] as a bit of the instruction is
	wrong. However, due to the fortunate nature of my coding scheme,
	any register with and even address will always map to an even
	addressed register and vice versa, so the decoded register address
	bit 0 will be equal to the intruction register address bit 0.

*****************************************************************************/

module ex(nGCLK, nWAIT, nRESET, ex_enbar, op1_in, op2_in,
		alu_opcode_in, addr_me, condition_in, shift_amount_in,
		shift_type_in, ir_id, Rd_id, Rn_id, id_second,
		need_2cycles_id, inst_type_in, s_id, ex_result,
 		store_addr, Rd_ex, Rn_ex, second_ex,
		inst_type_ex, mode, signed_byte_ex, write_Rd_ex,
		write_Rn_ex, unsigned_byte_ex, aux_data_id, 
		unsigned_hw_ex, signed_hw_ex, base_ex, mul_first_id,
		double_id, double_ex, double_me, cpsr_flags, load_use_id,
		cop_mem_id, pc_mod_ex, hold_next_ex, mcr_ex, cop_mem_ld,
		store_ex, mispredicted, exc_code, load_pc_ex, cop_mem_st,
		fiq_disable, irq_disable, exception, write_Pc_Rn, 
		write_Pc_Rd, DnMREQ, PASS, DnWR, stop_id, stop_ex);

/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/

input	[31:0] 	op1_in;			//OP1 from ID stage
input	[31:0] 	op2_in;			//OP2 from ID stage
input	[31:0] 	aux_data_id;		//Auxillary Data from ID stage
input	[31:0] 	addr_me;		//Address from ME stage
input	[7:0]  	shift_amount_in;	//Shift by this amount
input	[4:0]  	Rd_id;			//First(Main) Destination Register
input	[4:0]  	Rn_id;			//Second Destination Register
input	[3:0]  	alu_opcode_in;		//Alu Opcode
input	[3:0]  	condition_in;		//Condition of Execution
input	[3:0]  	inst_type_in;		//Instruction Code
input	[2:0]  	shift_type_in;		//Shift Controls
input	[6:4]  	ir_id;			//Bits 6-5 of Ir
input	[1:0]	exc_code;		//Which Exception
input		nGCLK;			//clock signal
input		nWAIT;			//clock enable
input		nRESET;			//reset signal
input		exception;		//Take Exception
input		ex_enbar;		//EX stage enable (active low)
input		id_second;		//ID Stage in Second Cycle
input		need_2cycles_id;	//Need_2cycles For this instruction
input		load_use_id;		//Need_2cycles due to Load Use
input		s_id;			//S Bit of Instruction
input		mul_first_id;		//First Cycle of LDM/STM
input		double_id;		//64-bit Memory Access
input		double_me;		//Inc by 4 or 8?
input		cop_mem_id;		//Coprocessor requiring Memory
input		mispredicted;		//Mispredicted Branch
input		stop_id;		//Stop Execution

output 	[31:0] 	ex_result;		//Result of Execution
output 	[31:0] 	store_addr;		//Usually Address
output 	[31:0] 	base_ex;		//Base Address
output 	[4:0]  	mode;			//Current Processor Mode
output 	[4:0]  	Rd_ex;			//Latched Fisrt Destination Reg
output 	[4:0]  	Rn_ex;			//Latched Second Destination Reg
output 	[3:0]  	cpsr_flags;		//Flags from CPSR
output 	[3:0]  	inst_type_ex;		//Instruction Code
output		write_Pc_Rd;		//Inst May Write PC in Rd field
output		write_Pc_Rn;		//Inst May Write PC in Rn field
output		fiq_disable;		//FIQ's Disabled (CPSR[6])
output		irq_disable;		//IRQ's Disabled (CPSR[6])
output	      	second_ex;		//Second Cycle of Instruction
output		store_ex;		//Inst should Store in ME cycle
output		write_Rn_ex;		//Write Back Signal
output		write_Rd_ex;		//Write to Destination?
output		unsigned_byte_ex;	//Inst uses Unsigned bytes
output		signed_byte_ex;		//Inst uses Signed Bytes
output		unsigned_hw_ex;		//Inst uses Unsigned Halfwords  
output		signed_hw_ex;		//Inst uses Signed Halfwords
output		double_ex;		//64-bit Memory Access
output		pc_mod_ex;		//One of last two inst modified pc
output		load_pc_ex;		//Load to the PC
output		hold_next_ex;		//Ex Stage requires another cycle
output		mcr_ex;			//Ex Stage has MCR
output		cop_mem_ld;		//Coprocessor Performing a Load
output		cop_mem_st;		//Coprocessor Performing a Store
output		PASS;			//Coprocessor should execute
output		DnMREQ;			//Data Not Memory Request
output		DnWR;			//Data Not Write Read
output		stop_ex;		//Stop Execution

/*------------------------------------------------------------------------
        Variable Declarations
------------------------------------------------------------------------*/

//Declare Outputs of Combinational Logic
wire	[63:0]	mult_result;		//Output from Multiplier
wire    [63:0]  acc_op1;                //Mult Op1 to Add
wire    [63:0]  acc_op2;                //Mult Op2 to Add
wire    [63:0]  alu_op1;                //Op1 to ALU
wire    [63:0]  alu_op2;                //Op2 to ALU
wire	[31:0]	upper_mult;		//Output from Upper Adder
wire	[31:0]	alu_result;		//Output from ALU
wire	[31:0]	shifted_op2;		//Output from Shifter
wire	[31:0]	inc_add;		//Incremented Address
wire	[4:0]	mode;			//Processor Mode
wire	[3:0]	cpsr_flags;		//CPSR[31:28]
wire	[3:0]	alu_flags;		//Flags from ALU 
wire	[2:0]	spsr_index;		//SPSR Index
wire	[1:0]	mult_flags;		//Mult Flags (N,Z)
wire		fiq_disable;		//CPSR[6]
wire		irq_disable;		//CPSR[7]
wire		store_ex;		//Want to Store On next Cycle
wire		signed_byte_ex;		//Inst uses Signed Bytes
wire		unsigned_byte_ex;	//Inst uses Unsigned Bytes
wire		signed_hw_ex;		//Inst uses Signed Halfwords
wire		unsigned_hw_ex;		//Inst uses Unsigned Halfwords
wire		shift_c_out;		//Shifter Carry Output
wire		multiply;		//MUL/MULL inst
wire		mult_res;		//Multiplier Reset
wire		cop_mem_ld;		//Coprocessor going to Load
wire		cop_mem_st;		//Coprocessor going to Stall
wire		inst_exception;		//SWI or UND
wire		alu;			//ALU inst
wire		str;			//STRW/STRH inst
wire		ldr;			//LDRW/LDRH inst
wire		branch;			//BR/BL inst
wire		swap;			//Swap inst
wire		mrs;			//MRS inst
wire		und;			//Undefined Inst
wire		swi;			//SWI Inst
wire		msr;			//MSR inst
wire		mrc;			//MRC inst
wire		mcr_ex;			//MCR inst
wire		ldm;			//LDM inst
wire		stm;			//STM inst
wire		load;			//Inst is a Load
wire		load_pc_ex;		//Inst is a Load to the PC
wire		N;			//N Flag from CPSR
wire		Z;			//Z Flag from CPSR
wire		C;			//C Flag from CPSR
wire		V;			//V Flag from CPSR
wire		write_Rn_ex;		//Write Back Base?
wire		u;			//Inc/Dec
wire		write_Rd_ex;		//Write to Rd?
wire		write_Pc_Rn;		//Write to PC (Rn)
wire		write_Pc_Rd;		//Write to PC (Rd)
wire		r15_inlist;		//R15 in Transfer List
wire		rd_pc;			//Rd is the PC
wire		alu_no_wb;		//Alu Inst with No WB
wire		no_writes;		//No Write Back this Cycle
wire		link;			//Link on Branches?
wire		long;			//Long Multiply Required
wire		acc;			//Accumulate
wire		cdp;			//Coprocessor Data Operation
wire		mrcmcr;			//Coprocessor Register Transfer
wire		pc_mod_ex;		//One of Last 2 inst modified pc
wire		hold_next_ex;		//Disable Registers for Next Cycle
wire		ex_mod_pc;		//PC will be modified
wire		cpsr_disable;		//Write to CPSR?
wire		DnMREQ;			//Data Access next Cycle
wire		DnWR;			//Data Not Write Read

//Declare Outputs of Multiplexers and Registers
reg	[31:0]	ex_result;		//Final Muxed Result
reg	[31:0]	store_addr;		//Address to be stored/loaded
reg	[31:0]	aux_data_ex;		//Auxillary Data 
reg	[31:0]	CPSR;			//Current Program Status Reg.
reg	[31:0]	spsr_fiq;		//Saved Program Status Register
reg	[31:0]	spsr_svc;		//Saved Program Status Register
reg	[31:0]	spsr_abt;		//Saved Program Status Register
reg	[31:0]	spsr_irq;		//Saved Program Status Register
reg	[31:0]	spsr_und;		//Saved Program Status Register
reg	[31:0]	op1;			//First Operand Register
reg	[31:0]	op2;			//Second Operand Register
reg	[31:0]	psr;			//CPSR/SPSR for MRS Instructions
reg	[31:0]	next_cpsr;		//Next Value to load into CPSR
reg	[31:0]	next_spsr;		//Next Value to load into SPSR
reg	[31:0]	flg_all_spsr;		//Muxed value from Shifted_Op2
reg	[31:0]	current_spsr;		//Current SPSR
reg	[31:0]	base_ex;		//Base Value for Post-Indexed
reg	[31:0]	cpsr_const;		//Possible Next CPSR Constant Value
reg	[7:0]	increment;		//4/8 for LDM/STM's
reg	[31:0]	addr_2b_inc;		//Input Address to Incrementer
reg	[7:0]	shift_amount;		//Shift Amount Register 
reg	[4:0]	Rd_ex;			//First Destination Reg
reg	[4:0]	Rn_ex;			//Second Destination Reg
reg	[3:0]	inst_type_ex;		//Latched Instr. Code
reg	[3:0]	condition;		//Condition of Execution
reg	[3:0]	alu_opcode;		//Opcode from ID Stage
reg	[3:0]	opcode;			//Multiplexed Opcode (LD/ST)
reg	[3:0]	flags_from_alu;		//Flags From ALU/SHIFTER
reg	[3:0]	early_flags;		//Flags Available Early
reg	[2:0]	shift_type;		//Shift Control Register
reg	[2:0]	write_spsr_index;	//Indicates which SPSR to update
reg	[6:4]	ir_ex;			//IR bits 6-5
reg	[1:0]	exc_code_ex;		//Exception Code
reg		exception_ex;		//Exception
reg		was_disabled;		//Last Inst was squashed
reg		second_ex;		//Second Cycle of Instruction
reg		need_2cycles_ex;	//Need 2 cycles for Current inst
reg		load_use_ex;		//Need 2 cycles due to Load Use
reg		cond_failed_ex;		//Inst Does Not Meet Condition
reg		s;			//S-Bit of Instruction
reg		stop_ex;		//Stop Execution
reg		mul_first_ex;		//First Cycle of LDM/STM
reg		double_ex;		//64-bit Memory Access
reg		latched_nRESET;		//One cycle delayed
reg		cop_mem_ex;		//Cop. Inst requiring Memory
reg		me_mod_pc;		//PC to be modified by inst in ME
reg		ldc_stc;		//LDC/STC inst
reg		PASS;			//Cop. should Execute Inst.

/*------------------------------------------------------------------------
        Basic Assignments
------------------------------------------------------------------------*/

//Detect several types of instructions
assign swap 	= (inst_type_ex == `SWAP);
assign multiply = ((inst_type_ex == `MUL) || (inst_type_ex == `MULL));
assign mult_res = (cond_failed_ex | me_mod_pc | was_disabled 
			| load_use_ex | mispredicted | !nRESET);
assign alu_op1	= (multiply) ? acc_op1 : {32'h00000000,op1};
assign alu_op2 	= (multiply) ? acc_op2 : {32'h00000000,shifted_op2};
assign alu 	= (inst_type_ex == `ALU);
assign str 	= ((inst_type_ex == `STRW) || (inst_type_ex == `STRH));
assign ldr 	= ((inst_type_ex == `LDRW) || (inst_type_ex == `LDRH));
assign branch 	= (inst_type_ex == `BR);
assign mrs 	= (inst_type_ex == `MRS);
assign msr 	= (inst_type_ex == `MSR);
assign link 	= alu_opcode[3];
assign long 	= (inst_type_ex == `MULL);
assign ldm 	= (inst_type_ex == `LDM);
assign stm 	= (inst_type_ex == `STM);
assign acc 	= (alu_opcode[0]);
assign und	= (inst_type_ex == `UND);
assign swi	= (inst_type_ex == `SWI);
assign fiq_disable	= CPSR[6];
assign irq_disable	= CPSR[7];
assign cop_mem_ld	= cop_mem_ex & s;
assign cop_mem_st	= cop_mem_ex & ~s & ~alu_opcode[1];
assign inst_exception 	= und | swi;
assign mult_result 	= {upper_mult,alu_result};
assign pc_mod_ex	= me_mod_pc | 
			  (write_Pc_Rn && (Rn_ex == 5'h0F)) | 
			  (write_Pc_Rd && (Rd_ex == 5'h0F));
assign #1 cpsr_flags 	= CPSR[31:28];
assign N 		= CPSR[31];
assign Z 		= CPSR[30];
assign C 		= CPSR[29];
assign V 		= CPSR[28];
assign mult_flags[1] 	= (long) ? mult_result[63] : mult_result[31];
assign mult_flags[0]	= (long) ? (~(| mult_result[63:32]) & alu_flags[2])
				 : alu_flags[2];

//This will detect the CDP Instruction
assign cdp = ((inst_type_ex == `COP) && (!ir_ex[4]));

//This will detect an MRC or MCR
assign mrcmcr = ((inst_type_ex == `COP) && (ir_ex[4]));

//This will determine the MRC
assign mrc = mrcmcr & s;

//This will determine the MCR
assign mcr_ex = mrcmcr & ~s;

//This is the address incrementer...its a 32'bit adder.  Maybe better
//if the increment is just 4 bits?
assign inc_add = addr_2b_inc + {{24{increment[7]}},increment};

//The TEQ, TST, CMN, and CMP Instructions do not write back
//the results of the instruction to Rd
assign alu_no_wb = ((opcode == `TEQ) || (opcode == `TST) ||
		    (opcode == `CMN) || (opcode == `CMP));

//There is usually no need to write to Rd on the 1st
//Cycle of instructions requiring two cycles.
assign no_writes = (need_2cycles_ex & !second_ex & !swap) | (load_use_ex);

//Write the Base Back on Long Multiplies (mult_res[63:32) and 
//any ldr/str with write back bit set.  WB is implied on ldr/str with
//post index addressing.  Also write back the base (R14)
//on BL instructions.  No writeback for non-executed instructions.
//Also write back for LDC/STC with W-Bit set
// write_Rn_ex = (fail)' . (bl + (cop_mem_ex . w) + ((ldm + stm).mul_first) 
//			+ (ldm.double) + und + 
//		(nw' . (MULL + ((ldr + str).ao[0]))))
 
//Might not need to base writeback in exceptions *******
assign write_Rn_ex = exception_ex |
	(!cond_failed_ex & !was_disabled & !hold_next_ex &
	((branch & link) | (und) | (swi) | 
	(cop_mem_ex & alu_opcode[0]) | (ldm & double_ex) |
	(mul_first_ex & alu_opcode[0]) |
	(!no_writes & 
		((long) | 
		((ldr | str) & (alu_opcode[0] | !alu_opcode[3]))))));

//Write to PC where Rn = PC
//Ignore from multiplies, mrc (only updates flags), mrs, swap, bl, und, 
//swi, ldr, cop_mem (ldc, stc) 
//For above instruction, Rn should never be R15 (PC)
//This is only a signal that indicates that PC may be written,
//Rn must still be compared to PC
assign write_Pc_Rn = !cond_failed_ex & !was_disabled & (ldm & double_ex);

//Write to Rd if the condition passes and there is a branch, or
//on the 1st cycle of a swap or on the final cycle of a  
//mul/ldr/alu (wb specified) or on a mrc
//write_Rd_ex=(fail)'.(branch + und + mrc + mrs + ldm + (swap.sec')+
//		(nw'.(mul+ldr+(ALU.nowb'))))

assign write_Rd_ex = 
	(!cond_failed_ex & !was_disabled & !no_writes & !hold_next_ex &
		!exception_ex & (branch | mrc | mrs | ldm | und | 
		(swap & !second_ex) | multiply | ldr | swi | 
		(alu & !alu_no_wb)));

//Write to PC where Rd = Pc
//Ignore from multiplies, mrc (only updates flags), mrs, swap
//For above instruction, Rd should never be R15 (PC)
//This is only a signal that indicates that PC may be written,
//Rd must still be compared to PC
assign #1 write_Pc_Rd = !cond_failed_ex & !was_disabled & !no_writes 
			& !exception_ex & 
		(branch | ldm | und | ldr | swi | (alu & !alu_no_wb));

//Assign the Unsigned Bit for Long Multiplication
assign u = alu_opcode[2];

//Instructions using Unsigned Bytes are STRB, LDRB, SWPB
assign unsigned_byte_ex = (((inst_type_ex == `STRW)||
                            (inst_type_ex == `LDRW)||
                            (inst_type_ex == `SWAP)) &&
                            (alu_opcode[1]));

//Instructions using Signed Bytes are LDRSB
assign signed_byte_ex = ((inst_type_ex == `LDRH) && (ir_ex[6:5] == 2'b10));

//Instructions using Unsigned Halfwords are STRH, LDRH
assign unsigned_hw_ex = (((inst_type_ex == `STRH) ||
                          (inst_type_ex == `LDRH)) &&
                          (ir_ex[6:5] == 2'b01));

//Instructions using Signed Halfwords are LDRSH
assign signed_hw_ex = ((inst_type_ex == `LDRH) && (ir_ex[6:5] == 2'b11));

//Determine whether this instruction will modify the PC
assign ex_mod_pc = (((Rd_ex == 5'h0F) & write_Rd_ex) |
                    ((Rn_ex == 5'h0F) & write_Rn_ex)) & !me_mod_pc;

//Determine whether or not CPSR can be updated
assign cpsr_disable = ~((!was_disabled & !me_mod_pc & !load_use_ex &
		         !mispredicted & !cond_failed_ex & 
                         !(need_2cycles_ex & !second_ex)) | 
		         (!nRESET | exception_ex));

//this tells ME to drive the DD Bus
assign store_ex = (((str & !id_second) | 
		    (stm) |
		    (swap & second_ex)) & !load_use_ex &
			!cond_failed_ex & !me_mod_pc & !was_disabled);

//This tells the cache its a store/read
assign DnWR = ~(((str & !id_second) |
                    (stm) |
                    (swap & second_ex)
                    | (cop_mem_st)) & !load_use_ex &
                        !cond_failed_ex & !me_mod_pc & !was_disabled);

assign r15_inlist = ((Rd_ex == 5'h0F) | (Rn_ex == 5'h0F));
assign rd_pc	= (Rd_ex == 5'h0F);

assign load = ((inst_type_ex == `LDRW)||
               (inst_type_ex == `LDRH)||
               (ldm) || (swap && !second_ex)) ? 1'b1 : 1'b0;  

//Recognize a load to the PC
assign load_pc_ex = load & (((Rd_ex == 5'h0F) & write_Pc_Rd) |
                            ((Rn_ex == 5'h0F) & double_ex & write_Pc_Rn));  

//Determine whether or not inst access data in next cycle
assign DnMREQ = ~((inst_type_ex == `LDRW) |
		  (inst_type_ex == `LDRH) |
		  (inst_type_ex == `LDM)  |
		  (inst_type_ex == `SWAP) |
		  (store_ex == 1'b1) 	  |
		  (cop_mem_ld == 1'b1)	  |
		  (cop_mem_st == 1'b1));

/*------------------------------------------------------------------------
        Component Instantiations
------------------------------------------------------------------------*/

// instantiate alu
alu xalu (.op1(alu_op1), .shifted_op2(alu_op2), .control(opcode),
		.C(C), .result({upper_mult,alu_result}),
		.flags(alu_flags));

// instantiate shifter
shifter xshift (.op1(op2), .shift_amount(shift_amount), 
		.shift_type(shift_type), .C(C),
		.result(shifted_op2), .shift_c_out(shift_c_out));

// instantiate mult
mult xmult (.enable(multiply), .op1(op1), .op2(op2), .a(acc),
		.l(alu_opcode[2]), .u(alu_opcode[1]), .nWAIT(nWAIT),
		.nGCLK(nGCLK), .acc_op1(acc_op1), .acc_op2(acc_op2), 
		.hold_next(hold_next_ex), .reset(mult_res), 
		.sum({upper_mult,alu_result}));

// instantiate mapspsr
mapspsr	xmapspsr (.mode(CPSR[4:0]), .spsr_index(spsr_index));

/*------------------------------------------------------------------------
        Combinational Always Blocks
------------------------------------------------------------------------*/
//Mux the SPSR's to give current one
always @(spsr_index or CPSR or spsr_fiq or spsr_svc 
		or spsr_abt or spsr_irq or spsr_und)
    begin
	case (spsr_index)  //synopsys full_case parallel_case
                3'h0: current_spsr = spsr_fiq;
                3'h1: current_spsr = spsr_svc;
                3'h2: current_spsr = spsr_abt;
                3'h3: current_spsr = spsr_irq;
                3'h4: current_spsr = spsr_und;
		default: current_spsr = CPSR;
	endcase
    end


//Set up the cond_failed signal
always @(condition or C or Z or N or V)
    begin
	 case (condition) //synopsys full_case parallel_case
             `EQ: cond_failed_ex <= !(Z);
             `NE: cond_failed_ex <= !(~Z);
             `CS: cond_failed_ex <= !(C);
             `CC: cond_failed_ex <= !(~C);
             `MI: cond_failed_ex <= !(N);
             `PL: cond_failed_ex <= !(~N);
             `VS: cond_failed_ex <= !(V);
             `VC: cond_failed_ex <= !(~V);
             `HI: cond_failed_ex <= !(C & ~Z);
             `LS: cond_failed_ex <= !(~C | Z);
             `GE: cond_failed_ex <= !((N && V)||(~N && ~V));
             `LT: cond_failed_ex <= !((N && ~V)||(~N && V));
             `GT: cond_failed_ex <= !(~Z && ((N && V)||(~N && ~V)));
             `LE: cond_failed_ex <= !(Z || ((N && ~V)||(~N && V)));
             `AL: cond_failed_ex <= 1'b0;
	     `NV: cond_failed_ex <= 1'b1;
        endcase
    end

//Set up the signal which muxes out the current CPSR or the 
//next CPSR to the mode bits and sets up all but the flags of the
//next CPSR value
always @(CPSR or nRESET or inst_exception or swi or exc_code_ex 
	  or exception_ex)
    begin
	if (~nRESET)
	  cpsr_const[31:8] = 24'h0;
        else
	  cpsr_const[31:8] = {4'h0,CPSR[27:8]};

	if (~nRESET)
	    cpsr_const[7:0] = 8'b11010011;
	else 
	  begin
	     if (exception_ex)
		begin
		    case (exc_code_ex)	//synopsys full_case parallel_case
                        2'b00: cpsr_const[7:0] = {1'b1,CPSR[6],6'b010111};
                  	2'b01: cpsr_const[7:0] = {2'b11,6'b010001};
                  	2'b10: cpsr_const[7:0] = {1'b1,CPSR[6],6'b010010};
                  	2'b11: cpsr_const[7:0] = {1'b1,CPSR[6],6'b010111};
		    endcase
		end

	     else
		cpsr_const[7:0] = {1'b1,CPSR[6],2'b01,!swi,3'b011};
	  end
    end

always @(nRESET or exception_ex or inst_exception or cpsr_const
	  or msr or alu_opcode or Rn_ex or CPSR or shifted_op2
	  or ldm or r15_inlist or alu or rd_pc or s 
	  or current_spsr)
    begin
	if (~nRESET | exception_ex | inst_exception)
	    next_cpsr[27:0] = cpsr_const;
	
	else 
	  begin
	    case ({(msr & ~alu_opcode[1] & Rn_ex[0] & (CPSR[4:0] != `USR)),
		   ((ldm & r15_inlist & alu_opcode[1]) | (alu & rd_pc & s))}) //synopsys full_case parallel_case
		    2'b01: next_cpsr[27:0] = current_spsr[27:0];
		    2'b10: next_cpsr[27:0] = shifted_op2[27:0];
		  default: next_cpsr[27:0] = CPSR[27:0];
	    endcase
	  end
    end

//Set a signal that indicates the flags should not be modified
//wire no_flags = ~nRESET | und | cond_failed_ex | swi | exception_ex;
wire no_flags = ~nRESET | und | cond_failed_ex | swi;

//Determine which flags from ALU to use
always @(alu_opcode or alu_flags or shift_c_out or CPSR)
    begin
	case (alu_opcode)	//synopsys full_case parallel_case
	    `AND, `EOR, `TST, `TEQ,
	    `ORR, `MOV, `BIC, `MVN:
                     flags_from_alu = {alu_flags[3:2],shift_c_out,CPSR[28]};

	    default: flags_from_alu = alu_flags;
	endcase
    end

//Mux the Flags known early
always @(alu or s or rd_pc or ldm or alu_opcode or r15_inlist or alu
	  or msr or shifted_op2 or current_spsr or flags_from_alu
	  or CPSR)
    begin
	case ({(alu & s & !rd_pc), 
	       ((ldm & alu_opcode[1] & r15_inlist) | (alu & s & rd_pc)),
	       (msr & !alu_opcode[1])}) //synopsys full_case parallel_case

	    3'b001: early_flags = shifted_op2[31:28];

	    3'b010: early_flags = current_spsr[31:28];

	    3'b100: early_flags = flags_from_alu;

	   default: early_flags = CPSR[31:28];
	endcase
    end

//Mux the Flags to the D-Input to CPSR
always @(multiply or s or hold_next_ex or mult_flags 
	  or CPSR or early_flags 
	  or inst_exception or nRESET or cpsr_const)
    begin
        if (~nRESET | inst_exception)
            next_cpsr[31:28] = cpsr_const[31:28];
	else if (multiply & s & !hold_next_ex)
	    next_cpsr[31:28] = {mult_flags,CPSR[29:28]};
	else
	    next_cpsr[31:28] = early_flags;
    end

//Set up a Mux for modifying only the flags, or the
//entire SPSR using shifted_op2 as a source
always @(Rn_ex or shifted_op2 or current_spsr) 
    begin
	case (Rn_ex[0]) //synopsys full_case parallel_case
	    1'b0: flg_all_spsr <= {shifted_op2[31:28],current_spsr[27:0]};
	    1'b1: flg_all_spsr <= shifted_op2;
	endcase
    end

//Set up the next SPSR Value. Only Modified by MSR instructions
//or exceptions.
always @(CPSR or msr or nRESET or mode or alu_opcode or und
	    or current_spsr or cond_failed_ex or shifted_op2 
	    or spsr_index or latched_nRESET or flg_all_spsr 
	    or swi or exception_ex or exc_code_ex)
    begin
	if ((!nRESET & latched_nRESET) | swi)
	  begin
	    next_spsr <= CPSR;
	    write_spsr_index <= 3'h1;	//spsr_svc
	  end

	else if (exception_ex)
	  begin
	    case (exc_code_ex) //synopsys full_case parallel_case
		2'b00: begin
			next_spsr <= CPSR;
			write_spsr_index <= 3'h2;
		       end
		2'b01: begin
			next_spsr <= CPSR;
			write_spsr_index <= 3'h0;
		       end
		2'b10: begin
			next_spsr <= CPSR;
			write_spsr_index <= 3'h3;
		       end
		2'b11: begin
			next_spsr <= CPSR;
			write_spsr_index <= 3'h2;
		       end
	    endcase	
	  end

	else if (und)
	  begin
	    next_spsr <= CPSR;
	    write_spsr_index <= 3'h4;	//spsr_und
	  end

        else if (msr && (mode != `USR) && (mode != `SYS)    
                     && !cond_failed_ex && alu_opcode[1])
	  begin
	    next_spsr <= flg_all_spsr;
	    write_spsr_index <= spsr_index;
	  end

	else
	  begin
	    next_spsr <= current_spsr;
	    write_spsr_index <= spsr_index;
	  end
    end	
	
//Mux the SPSR/CPSR for MRS Instructions
//For MRS instructions ir[22]=0 for CPSR, ir[22]=1 for SPSR
//ir[22] = alu_opcode[1].
always @(CPSR or alu_opcode or current_spsr)
    begin
	if (!alu_opcode[1])			//Use CPSR
	    psr <= CPSR;
	else					//Use SPSR
	    psr <= current_spsr;		//If no SPSR, current_spsr
    end						//will be the CPSR

//Create the Increment
wire iabort = exception_ex & (exc_code_ex == 2'h3);
wire dabort = exception_ex & (exc_code_ex == 2'h0);
always @(mul_first_ex or double_me or alu_opcode or ldm or stm 
		or branch or cop_mem_ex or inst_exception 
		or op2 or iabort or dabort)
    begin
	casex ({(inst_exception | branch | iabort | dabort), (ldm | stm), 
		mul_first_ex, double_me, cop_mem_ex, 
		alu_opcode[3:2]}) //synopsys full_case parallel_case
	    //Must Decrement PC by 4 for exceptions/BL
	    7'b1??????: increment = {5'b11111,~dabort,2'h0};

	    //Must Increment Op1 by 4 for COP/Pre-Inc/Auto-Inc
	    7'b????1??,
	    7'b??1??11,
	    7'b?100???: increment = 8'h04;

	    //For LDM/STM Pre-Decrement, Just want Op2
	    //For LDM/STM Post-Decrement, Want Op2 + 4
            7'b??1??00, 
	    7'b??1??10: increment =~(op2[7:0])+{5'h00,~alu_opcode[3],2'h0} + 1;

	    //Must Increment addr by 8 for LDM/STM of two words
	    7'b?101???: increment = 8'h08;
	
	    default:    increment = 8'h00;
	endcase
    end

//Mux the address to be incremented
always @(op1 or mul_first_ex or branch or addr_me or und or swi or
		exception_ex)
    begin
	if (und | swi | branch | mul_first_ex | exception_ex)
	    addr_2b_inc = op1;
	else
	    addr_2b_inc = addr_me;
    end

//Mux the Mult/ALU results
always @(str or alu_result or op2 or mrs or psr or mcr_ex or 
		stm or aux_data_ex or swap or inst_exception)
    begin
	if ((stm) | str | swap)			//STORE
            ex_result = aux_data_ex;
	else if (inst_exception | mcr_ex)	//UND/SWI
            ex_result = op2;
        else if (mrs)				//MRS
            ex_result = psr;
        else					//ALU/MULT
            ex_result = alu_result;
    end

//Mux the Store Addr
always @(ldm or stm or branch or cop_mem_ex or ldc_stc or
		ex_enbar or inc_add or alu_result or op1 or alu_opcode)
    begin 
	if (ldm || stm || (cop_mem_ex & ldc_stc & !ex_enbar))
	    store_addr <= inc_add;       	//Auto-Inc'd Addr
	else if (alu_opcode[3])			//Pre Indexed
	    store_addr <= alu_result;
	else					//Post Indexed
	    store_addr <= op1;
    end

//Mux the Base Addr
always @(multiply or mult_result or stm or mul_first_ex or inst_exception
		or op1 or alu_result or inc_add or branch or exception_ex)
    begin
	if (branch | inst_exception | exception_ex)	//PC + 8 - 4
	    base_ex <= inc_add;
	else if (multiply)                   	//Upperhalf of MULL result
	    base_ex <= mult_result[63:32];
	else if (stm & !mul_first_ex)		//STM Data
	    base_ex <= op1;
	else					//Updated Base Value
	    base_ex <= alu_result;
    end

//Mux the opcode to the alu.  If LD/St instruction,
//Opcode becomes add or subtract, depending on the U bit.
//ADD=0100, SUB=0010, Opcode is 0100 for Branch since
//PC offset is 2sC
always @(ldr or str or alu_opcode or u or branch or ldm or stm
		or cop_mem_ex or swap or multiply)
    begin
	if (ldr | str | swap | ldm | stm | cop_mem_ex)
            opcode <= {1'b0,u,~u,1'b0};	//ADD/SUB
	else if (branch | multiply)
	    opcode <= 4'h4;	//ADD
	else
	    opcode <= alu_opcode;
    end

//Mux the outgoing mode of processor.  This is necessary because
//a mode change does not take place until the instruction enters the
//ME stage.  By this time, the previous instruction will have decoded
//and used the wrong set of registers.  Therefore, mode must be
//forwarded to the ID stage for instructions that change the mode.
assign mode = (~cpsr_disable) ? next_cpsr[4:0] : CPSR[4:0];
	 
/*------------------------------------------------------------------------
        Sequential Logic Blocks
------------------------------------------------------------------------*/	
//This block controls the was_disabled bit.  
//Its there because the CPSR and SPSR registers must
//be disabled for one cycle longer than the input registers
//of the ex stage
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
    begin
	if (~nRESET)
	    was_disabled <= 1'b0;
	else if (nWAIT)
	    was_disabled <= ex_enbar & ~hold_next_ex;
    end

//This block controls the Op1 latch
//If an instruction requires 2 cycles, OP1 is only
//latched on the second cycle if the inst is an MLA/MLAL
wire op_disable = ~(~ex_enbar & (~id_second | (multiply & acc)));
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      op1 <= 32'h00000000;
    else if (nWAIT)
      begin
	if (~op_disable)
          op1 <= op1_in;
      end
  end

//This block controls the Op2 latch
//If an instruction requires 2 cycles, OP2 is only
//latched on the second cycle if the inst is an MLA/MLAL
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
        op2 <= 32'h00000000;
    else if (nWAIT)
      begin
	if (~op_disable)
          op2 <= op2_in;
      end
  end

//This block controls the aux data latch
//If an instruction requires 2 cycles, Aux_data is only
//latched on the 2nd cylce if the inst is STR (Reg Offset) or Swap
wire aux_disable = ~(!ex_enbar & (!id_second | (swap | str)));
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      aux_data_ex <= 32'h00000000;
    else if (nWAIT)
      begin
        if (~aux_disable)
          aux_data_ex <= aux_data_id;
      end
  end

//This block controls the Condition latch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      condition <= 4'h0;
    else if (nWAIT)
      begin
        if (~ex_enbar)
          condition <= condition_in; 
      end
  end

//This block controls the second latch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      second_ex <= 1'h0;
    else if (nWAIT)
      begin
        if (~ex_enbar)
          second_ex <= id_second;
      end     
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      need_2cycles_ex <= 1'h0;
    else if (nWAIT)
      begin
        if (~ex_enbar)
          need_2cycles_ex <= need_2cycles_id;
      end
  end


//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      load_use_ex <= 1'h0;
    else if (nWAIT)
      begin
        if (~ex_enbar)
          load_use_ex <= load_use_id;
      end
  end

//This block controls the alu opcode latch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      alu_opcode <= 4'h0;
    else if (nWAIT)
      begin
        if (~ex_enbar)
          alu_opcode <= alu_opcode_in; 
      end
  end

//This block controls the shift amount latch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      shift_amount <= 8'h00;
    else if (nWAIT)
      begin       
        if (~ex_enbar)
          shift_amount <= shift_amount_in;
      end
  end
       
//This block controls the shift type latch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      shift_type <= 3'h0;
    else if (nWAIT)
      begin       
        if (~ex_enbar)
          shift_type <= shift_type_in;
      end
  end 

//This block controls the rdest_1 latch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      Rd_ex <= #1 5'h00;
    else if (nWAIT)
      begin
        if (~ex_enbar)
	  begin
	    if (inst_type_in == `MUL)
	      Rd_ex <= #1 Rn_id;
	    else
              Rd_ex <= #1 Rd_id;
	  end
      end
  end

//This block controls the rdest_2 latch 
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      Rn_ex <= 5'h0;
    else if (nWAIT)
      begin
        if (~ex_enbar)
	  begin
	    if (inst_type_in == `MUL)
	      Rn_ex <= Rd_id;
	    else
	      Rn_ex <= Rn_id;
	  end
      end
  end

//This block controls the multiply latch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (!nRESET)
      inst_type_ex <= 4'h0;
    else if (nWAIT)
      begin
        if (~ex_enbar)
          inst_type_ex <= inst_type_in;  
      end
  end

//This block controls the 's' latch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin   
    if (!nRESET)
      s <= 1'b0;
    else if (nWAIT)
      begin
        if (~ex_enbar)
          s <= s_id;
      end
  end

//This block controls the mul_first_ex latch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      mul_first_ex <= 1'b0;
    else if (nWAIT)
      begin
        if (~ex_enbar)
          mul_first_ex <= mul_first_id;
      end
  end

//This block controls the mul_first_ex latch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      double_ex <= 1'b0;
    else if (nWAIT)
      begin
        if (~ex_enbar)
          double_ex <= double_id;
      end
  end

//This block controls the 'ir_id' register
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      ir_ex[6:4] <= 3'b000;
    else if (nWAIT)
      begin
        if (~ex_enbar)
          ir_ex[6:4] <= ir_id[6:4];
      end
  end

//This block controls the cop_mem_ex register
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      cop_mem_ex <= 1'b0;
    else if (nWAIT)
      begin
        if (~ex_enbar)
          cop_mem_ex <= cop_mem_id;   
      end
  end

//This block controls the CPSR register
always @(posedge nGCLK)
  begin
    if (nWAIT)
      begin
        if (~cpsr_disable)
          CPSR <= next_cpsr;
      end
  end

//Create the SPSR's
wire spsr_fiq_disable = ~((write_spsr_index == 3'h0) && 
			  ((!ex_enbar & !was_disabled) | exception_ex));
always @(posedge nGCLK)
  begin
    if (nWAIT)
      begin
	if (~spsr_fiq_disable)
	  spsr_fiq <= next_spsr;
      end
  end

wire spsr_svc_disable = ~(((write_spsr_index == 3'h1) && ((!ex_enbar
                && !was_disabled) | exception_ex)) || (!nRESET));
always @(posedge nGCLK)
  begin
    if (nWAIT)
      begin
        if (~spsr_svc_disable)
          spsr_svc <= next_spsr;
      end
  end

wire spsr_abt_disable = ~((write_spsr_index == 3'h2) && 
			  ((!ex_enbar & !was_disabled) | exception_ex));

always @(posedge nGCLK)
  begin
    if (nWAIT)
      begin
        if (~spsr_abt_disable)
          spsr_abt <= next_spsr;
      end
  end

wire spsr_irq_disable = ~((write_spsr_index == 3'h3) && 
			  ((!ex_enbar & !was_disabled) | exception_ex));

always @(posedge nGCLK)
  begin
    if (nWAIT)
      begin
        if (~spsr_irq_disable)
          spsr_irq <= next_spsr;
      end
  end

wire spsr_und_disable = ~((write_spsr_index == 3'h4) &&
			  ((!ex_enbar & !was_disabled) | exception_ex));

always @(posedge nGCLK)
  begin
    if (nWAIT)
      begin
        if (~spsr_und_disable)
            spsr_und <= next_spsr;
      end
  end

//This block captures the nRESET so that some events
//only occur once during the reset cycle (i.e. spsr_svc = CPSR)
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or posedge nRESET)
    begin
	if (nRESET)
	    latched_nRESET <= 1'b1;
	else if (nWAIT)
	    latched_nRESET <= nRESET;
    end

//This block is a memory of the last two instructions
//and their effect on the pc
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
    begin
	if (~nRESET)
	    me_mod_pc <= 1'b0;
	else if (nWAIT)
	    me_mod_pc <= ex_mod_pc;
    end

//This block monitors the cop_mem_ex signal
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
    begin
        if (~nRESET)
	    ldc_stc <= 1'b0;
	else if (nWAIT)
	    ldc_stc <= cop_mem_ex & ex_enbar;
    end

//This block controls the PASS signal.  It is triggered
//during the 2nd phase of the clock (when its high)
//synopsys async_set_reset "nRESET"
always @(negedge nGCLK or negedge nRESET)
    begin
	if (~nRESET)
	    PASS <= 1'b0;
	else if (nWAIT)
	    PASS <= (cdp | mrcmcr) & !cond_failed_ex & 
			!me_mod_pc;
    end

//This ff latches the take exception signal
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      exception_ex <= 1'b0;
    else if (nWAIT)
      begin
        if (~ex_enbar)
          exception_ex <= exception;
      end
  end

//These 2 ff's latch the exception code
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      exc_code_ex <= 2'h0;
    else if (nWAIT)
      begin
	if (~ex_enbar)
	  exc_code_ex <= exc_code;
      end
  end

//This just latches the Stop Signal
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      stop_ex <= 1'b0;
    else if (nWAIT)
      begin
        if (~ex_enbar)
          stop_ex <= stop_id;
      end
  end

endmodule
