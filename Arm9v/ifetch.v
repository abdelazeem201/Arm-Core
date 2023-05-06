`timescale 1ns/10ps
`include "pardef"
/*****************************************************************************
$RCSfile: ifetch.v,v $
$Revision: 1.8 $
$Author: kohlere $
$Date: 2000/05/10 20:35:48 $
$State: Exp $
$Source: /home/lefurgy/tmp/ISC-repository/isc/hardware/ARM10/behavioral/pipelined/fpga2/ifetch.v,v $

Description: Currently, this is the first stage of the pipeline.  This
		stage handles the PC and fetches the next instruction.  It 
		also performs a simple branch prediction (BTFNT).

*****************************************************************************/

module ifetch(nGCLK, nWAIT, nRESET, dabort, iabort, if_enbar,
		inst_bus, flags, load_pc, s_nFIQ, s_nIRQ, exception_to_id,
		fill_state, pc, inst_if, inst_addr, eval,
		mispredicted, misp_rec, pt, put, me_result, base_me, 
		ex_result, Rd_ex, Rd_me, pc_touched, InMREQ,
		Rn_me, write_Rd_ex, hold_next_ex, load_pc_ex,
		exc_code, prediction_stall, newline);

/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/

input   [95:0]  inst_bus;		//Instruction Data
input	[31:0]	me_result;		//Rd Data in ME Stage
input	[31:0]	base_me;		//Base Data in ME Stage
input	[31:0]	ex_result;		//Result of Ex Stage
input	[4:0]	Rd_me;			//Rd in ME Stage
input	[4:0]	Rn_me;			//Rn in ME Stage
input	[4:0]	Rd_ex;			//Rd in EX Stage
input	[3:0]	flags;			//CPSR Flags
input	[2:0]	fill_state;		//Machine State
input		nGCLK;			//clock signal
input		nWAIT;			//clock enable
input        	nRESET;			//reset signal
input		iabort;			//Inst Abort
input		dabort;			//Data Abort
input		s_nFIQ;			//FIQ
input		s_nIRQ;			//IRQ
input         	if_enbar;		//PC enable (active low)
input		write_Rd_ex;		//Write Rd in ME Stage
input		hold_next_ex;		//EX is stalling
input		load_pc_ex;		//Load the PC from Memory next
input		load_pc;		//Load the PC from Memory

output 	[31:0] 	pc;			//Program Counter Value
output	[31:0]	inst_if;		//Instruction to ID stage
output	[31:0]	inst_addr;		//Instruction Address
output	[1:0]	exc_code;		//Which Exception
output		InMREQ;			//Instruction Fetch Requested
output		newline;		//New Cache Line Required
output		pc_touched;		//PC is being Modified by Pipe
output		exception_to_id;	//Take Exception
output		mispredicted;		//Mispredicted a branch
output		misp_rec;		//Recoverable Misprediction
output		prediction_stall;	//Need a Bubble for Prediction
output		pt;			//Predict Taken
output		put;			//Predict Untaken
output		eval;			//Predicted Br in Ex

/*------------------------------------------------------------------------
        Variable Declarations
------------------------------------------------------------------------*/
reg	[35:0]  pcstore;	//Value to Store in Saved_PC Reg	
reg     [36:0]  saved_pc0;      //Stored PC + BR Condition
reg     [36:0]  saved_pc1;      //Stored PC + BR Condition
reg	[36:0]	saved_pc2;	//Stored PC + BR Condition
reg	[31:0]	irstore;	//Instruction to Store
reg	[32:0]	saved_ir0;	//Saved Instruction
reg	[32:0]	saved_ir1;	//Saved Instruction
reg	[32:0]	saved_ir2;	//Saved Instruction
reg	[31:0]	pc_me;		//PC Value from ME
reg	[31:0]	inst_addr;	//Address Bus Latch
reg	[31:0]	inst_addr_in;	//Muxed PC
reg	[31:0]	pred_addr;	//Predicted Address
reg	[31:0]	pc;		//PC to ID stage
reg 	[31:0] 	pc_if;		//Program Counter Register
reg	[31:2]  pcp4;		//PC plus 4
reg 	[31:0] 	next_pc;	//Output from Multiplexer to D input of PC
reg	[31:0]	saved_pc;	//Muxed saved_pc value
reg	[31:0]	saved_ir;	//Muxed saved_ir value
reg	[31:0]	inst_if;	//Instruction to ID stage
reg	[31:0]	exc_vector;	//Exception Vector
reg	[31:0]	offset;		//Muxed between Branch/Dabort
reg	[31:5]	lastline;	//Last {Tag,Line} Number
reg	[4:0]	saved_cond;	//Muxed saved_cond value
reg	[4:2]	lastword;	//Last Word Number
reg	[1:0]	open_ptr;	//Pointer To Open Save Buffer
reg	[1:0]	eval_ptr;	//Pointer to Current Branch 
reg	[1:0]	next_open_ptr;	//Next State for Open Pointer
reg	[1:0]	next_eval_ptr;	//Next State for Eval Pointer
reg	[1:0]	exc_code;	//Exception Code
reg		was_iabort;	//Was Instruction Abort
reg		was_dabort;	//Wast Data Access Abort
reg		ps1;		//Prediction Stall Now
reg		updating_clb;	//Updating Cache Line Buffer
reg		recoverable;	//Stored the fall-through Instruction
reg	   	latched_reset;	//Captured Reset Signal
reg		wait1;		//Branch was Predicted, in IF stage now
reg		wait2;		//Branch was Predicted, in ID stage now
reg		eval;		//Predicted Branch in EX stage
reg		cond_false;	//Condition is false
reg		use_stall;	//Use a Bubble to Check Branch Pred

wire	[31:0]	inc_pc;		//Incremented PC
wire	[31:0]	branch_addr;	//Branch Address
wire	[31:0]	boff1;		//Branch Offset 1
wire	[31:0]	boff2;		//Branch Offset 2
wire	[31:0]	doff;		//Offset for Data Aborts (-4)
wire	[31:0]	iplus1;		//Next Instruction
wire	[31:0]	iplus2;		//Next Next Instruction
wire	[31:0]	iplus3;		//Next Next Next Instruction
wire    [31:0]  spci2;     	//PC to Store for Misprediction recovery
wire	[31:0]	spci1;		//PC to Store for Misprediction recovery
wire	[31:0]	pc_for_br;	//PC to add Offset To for Branches
wire	[31:2]	to_pcp4;	//Output of PC Incrementer
wire	[31:0]	pcp8;		//Output of PC + 8 Incrementer
wire	[29:0]	pc_plus;	//PC + 4
wire	[29:0]	pc_plus_off;	//PC + Offset
wire		InMREQ;		//Instruction Request (low)
wire		newline;	//Change Cache Lines
wire		fallthrough;	//This is the fallthrough instruction
wire		exception;	//Exception
wire		exception_to_id;//Exception
wire		exc_no_inc;	//Don't Increment PC
wire		ptaken1;  	//Predict Taken on iplus1
wire		ptaken2;	//Predict Taken on iplus2
wire		puntaken1;	//Predict Not Taken on iplus1
wire		pc_touched;	//PC modified by an instruction
wire		mispredicted;	//mispredicted a branch
wire		misp_rec;	//mispredicted, but recoverable
wire		clr_pred;	//Clear Any/All Predictions
wire		N;		//N Flag (negative)
wire		Z;		//Z Flag (zero)
wire		C;		//C Flag (carry)
wire		V;		//V Flag (overflow)

wire		pt = ptaken1 | ptaken2;
wire		put = puntaken1;

/*------------------------------------------------------------------------
        Basic Assignments
------------------------------------------------------------------------*/
//Break off Instructions
assign iplus1 = inst_bus[31:0];
assign iplus2 = inst_bus[63:32];
assign iplus3 = inst_bus[95:64];

//Assign the Inst Request Signal
assign InMREQ = if_enbar | ~latched_reset;

//Reset the Branch Prediction State Machine
assign clr_pred = (pc_touched | mispredicted | dabort | load_pc_ex |
			load_pc);

//This signal detects that FIQ and IRQ have been taken
assign exc_no_inc = exception & ((exc_code == 2'h1) | (exc_code == 2'h2));
assign exception = dabort |
		        ((iabort | !s_nFIQ | !s_nIRQ) 
			& !if_enbar & !mispredicted & !pc_touched
			& ~(wait1 | wait2 | eval));

assign exception_to_id = exception;

//This is the last PC fetch, incremented by '4'
//If there is a load to the PC, I don't want to 
//increment it until the next cycle
assign pc_plus = inst_addr[31:2] + 1;
assign inc_pc = {pc_plus,2'h0};

//Check for a mispredicted Branch
assign mispredicted = (cond_false & eval & saved_cond[4]) |
		      (!cond_false & eval & !saved_cond[4]);

//Check to see that an instruction modified the PC
assign pc_touched = ((Rd_ex == 5'h0F && write_Rd_ex == 1'b1) &
			~load_pc_ex);

//This is the branch offset.  Its sign exteded and shifted left two places.
//On Data Aborts, have to sub 4 from PC so that it will end up being PC+8
assign doff = 32'hFFFFFFF8;
assign boff1 = {{6{iplus1[23]}},iplus1[23:0],2'b00};
assign boff2 = {{6{iplus2[23]}},iplus2[23:0],2'b00};

//This performs the branch calculation.  Because the pc_if is only PC + 4,
//in relation to the instruction in the instruction buffer, an extra 4 must
//be added to compensate for the usual PC+8 condition.
assign to_pcp4 = (pc_if[31:2] + 1);
assign pc_for_br = (ptaken2) ? {to_pcp4,2'h0} : pc_if;
assign pc_plus_off = (pc_for_br[31:2] + offset[31:2] + 1);
assign branch_addr = {pc_plus_off,2'h0};

//Predict a Branch to be taken if:
//1) Its an Unconditional BR/BL
//2) Its a Branch Backward (loop?)
//Note that the extra conditions for p2
//are there to assure one-hot'edness 
//between ptaken1, ptaken2, puntaken1
assign ptaken1 = (((iplus1[31:24] == 8'hEA)	|	//Uncond Branch
		  (iplus1[27:23] == 5'h15))	&	//Branch Backwords
		  ~(updating_clb | 			//Reading New Line
		   (ps1 & ~updating_clb)));		//Br to Self
assign ptaken2 = (((iplus2[31:24] == 8'hEA)	|       //Uncond Branch
                   (iplus2[27:23] == 5'h15))	&	//Branch Backwords
		  ~(ptaken1 | puntaken1 |
			updating_clb));			//Reading New Line

//Predict a Branch to be not taken if:
//1) Its a Conditional Branch Forward
//If want to predict untaken on last word, no gain
//If try to predict while another prediction is in the IF stage,
//will have to eval 2 at once in order to insure an incorrect 
//instruction in EX doesn't modify state.  Just don't predict
//to save the hassle of checking two at a time.  chthJ8.4554
assign puntaken1 = (((iplus1[27:23] == 5'h14) 	&	//Branch Forwards
		     (iplus1[31:28] != 4'hE))	&	//!Uncond Branch
		    ~(updating_clb | 			//Reading New Line
		      lastword == 3'h7 |		//End of Line
		      wait1 | use_stall));		

//Watch the Cache Line, when it changes, stop predicting
assign newline = (lastline != inst_addr[31:5]);

//Create a Bubble for Predict Takens on Iplus1
assign prediction_stall = ptaken1;

//Determine whether we have stored the next instruction
//for a predicted branch.  If so, we can hide the prefetch
//operation and eliminate a bubble in the pipeline.
assign misp_rec = mispredicted & recoverable;

//Figure Out if we have the fall through instruction, 
//necessary to recover from mispredicted taken branches
assign fallthrough = (ptaken1 & (lastword != 3'h7)) |
		     (ptaken2 & (lastword != 3'h7) &
				(lastword != 3'h6));

//Mux the Values which will need to be saved for Branch prediction
assign pcp8 = {(pc_if[31:3] + 1),pc_if[2],2'b00};
assign spci2 = (ptaken2 & fallthrough) ? pcp8 : {to_pcp4,2'h0};
assign spci1 = (ptaken1 & fallthrough) ? {to_pcp4,2'h0} : pc_if;

//Assign each flag for later use.
assign N = flags[3];
assign Z = flags[2];
assign C = flags[1];
assign V = flags[0];

/*------------------------------------------------------------------------
        Sequential Always Blocks
------------------------------------------------------------------------*/	

//This block controls the operations of 
//the PC register
always @(posedge nGCLK)
    begin
      if (nWAIT)
        begin
          if (!if_enbar & !exc_no_inc)
            pc_if <= next_pc;
        end
    end

//This block follows the pc, only
//necessary when predicting early
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      pcp4 <= 30'h00000000;
    else if (nWAIT)
      begin
        if (~if_enbar & ~exc_no_inc)
          pcp4 <= to_pcp4;
      end
  end

//This latches the Inst Address Bus
always @(nGCLK or if_enbar or inst_addr_in or nWAIT or inst_addr)
    begin
      if (~nGCLK)
	begin
          if (nWAIT & ~if_enbar)
	    inst_addr <= inst_addr_in;
	  else
	    inst_addr <= inst_addr;
        end
    end	  

//This catches the previous {Tag,Line}
//synopsys async_set_reset "nRESET"
wire update_line = ~if_enbar & latched_reset;
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      lastline <= 27'h7FFFFFF;
    else if (nWAIT)
      begin
        if (update_line)
          lastline <= inst_addr[31:5];
      end
  end

//This catches the previous Word Number
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      lastword <= 3'h7;
    else if (nWAIT)
      begin
        if (~if_enbar)
          lastword <= inst_addr[4:2];
      end
  end

//This block latches the inst abort signal
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      was_iabort <= 1'b0;
    else if (nWAIT)
      begin
        if (~if_enbar)
          was_iabort <= iabort;
      end
  end

always@(negedge nRESET or posedge nGCLK)
  begin
    if (~nRESET)
      was_dabort <= 1'b0;
    else if (nWAIT)
      begin
        if (~if_enbar)
          was_dabort <= dabort;
      end
  end

//This block captures the nRESET signal
always @(negedge nRESET or posedge nGCLK)
    begin
      if (!nRESET)
	  latched_reset <= 1'b0;
      else if (nWAIT)
	  latched_reset <= 1'b1;
    end

//The next three flip-flops create a state machine which
//waits two cycles, and then indicates that the condition
//of a predicted branch must be evaluated.  Do not begin
//this procedure if either mispredicted or pc_touched is
//high because the branch prediction is not being used.
//These two cases have higher priority.
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (!nRESET)
      wait1 <= 1'h0;
    else if (nWAIT)
      begin
        if (!if_enbar)
          wait1 <= (ptaken2) & ~(clr_pred);
      end
    end

//putting in the hold_next & wait2 because if hold+next goes high
//while wait2 is high, its possible that if_enbar will be low, so
//don't want to reset in this case rodan.99-Aug-19.27461
//putting in this condition because don't want signal to last longer
//even if if_enbar is high...because pipe is advancing smaug-Aug20
//but pipe is not advancing if hold_next is high, so this must be 
//considered as well smaug-Sep3
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (!nRESET)
      wait2 <= 1'b0;
    else if (nWAIT)
      begin
        if (~if_enbar)
          wait2 <= (wait1 | ptaken1 | puntaken1 | (wait2 & hold_next_ex)) 
		& ~(clr_pred);
        else if (~hold_next_ex)
          wait2 <= 1'b0;
      end
  end

//This flip-flop records the fact that back2back predictions
//can only occur if there is a natural delay cycle to check the
//second prediction.  If so, then this ff will extend the eval 
//cycle to check the second branch.
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      use_stall <= 1'b0;
    else if (nWAIT)
      use_stall <= ((wait1 & ptaken1 & ~if_enbar) | (use_stall & wait2))
			& ~clr_pred;
  end


//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
    begin
	if (!nRESET)
	    eval <= 1'b0;
	else if (nWAIT)
	    eval <= (wait2 | use_stall) & ~(clr_pred | hold_next_ex);
    end

//This is a Pointer to the Next available set of Buffers
//to store saved branch information
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      open_ptr <= 2'h0;
    else if (nWAIT)
      begin
        if (!if_enbar | clr_pred)
          open_ptr <= next_open_ptr;
      end
  end

//This is a Pointer to the Pending Branch
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      eval_ptr <= 2'h0;
    else if (nWAIT)
      eval_ptr <= next_eval_ptr;
  end

//This block controls the storing of the pc's
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
    begin
	if (~nRESET)
	    saved_pc0 <= 37'h0000000000;
	else if (nWAIT)
          begin
	    if ((open_ptr == 2'h0))
	      begin
	        if (pt)
	          saved_pc0 <= {1'b1,pcstore};
	        else if (put)
	          saved_pc0 <= {1'b0,pcstore};
              end
          end
    end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
    begin 
        if (~nRESET)
            saved_pc1 <= 37'h0000000000;
        else if (nWAIT)
          begin
            if ((open_ptr == 2'h1))
              begin
                if (pt)
                  saved_pc1 <= {1'b1,pcstore};
                else if (put)
                  saved_pc1 <= {1'b0,pcstore};
              end
          end
    end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
    begin
        if (~nRESET)
            saved_pc2 <= 37'h0000000000;
        else if (nWAIT)
          begin
            if (open_ptr == 2'h2)
              begin
                if (pt)
                  saved_pc2 <= {1'b1,pcstore};
                else if (put)
                  saved_pc2 <= {1'b0,pcstore};
              end
          end  
    end
//synopsys async_set_reset "nRESET" 
always @(posedge nGCLK or negedge nRESET)
    begin
        if (~nRESET)
            saved_ir0 <= 33'h0;
        else if (nWAIT)
          begin
            if ((open_ptr == 2'h0))
              begin
                if (pt | put)
                  saved_ir0 <= {fallthrough,irstore};
              end
          end
    end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      saved_ir1 <= 33'h0;
    else if (nWAIT)
      begin
        if ((open_ptr == 2'h1))
          begin
            if (pt | put)
              saved_ir1 <= {fallthrough,irstore};
          end  
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      saved_ir2 <= 33'h0;
    else if (nWAIT)
      begin
        if ((open_ptr == 2'h2))
          begin
            if (pt | put)
              saved_ir2 <= {fallthrough,irstore};
          end
      end
  end

//Create a FF that will halt Branch Prediction while
//reading a new cache line into the line buffer
//Want to assume reading a new line on reset, so 
//reset is actually a set for this flip-flop
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      updating_clb <= 1'b1;
    else if (nWAIT)
      updating_clb <= newline | ~latched_reset;
  end

//This ff is used so that when a prediction stall is
//encountered, if on the next cycle, updating_clb is 
//high, then could be branch to self and want to 
//not predict a branch in this cycle.
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      ps1 <= 1'b0;
    else if (nWAIT)
      ps1 <= (prediction_stall & ~if_enbar) | (ps1 & prediction_stall & if_enbar);
  end   


/*------------------------------------------------------------------------
        Combinational Always Blocks
------------------------------------------------------------------------*/
//Mux the pc value to be sent to the ID stage
always @(dabort or pc_if or was_dabort or pcp4 or wait1 or was_iabort)
    begin
        if (wait1 | was_iabort | dabort | was_dabort)
            pc = {pcp4,2'h0};
        else
            pc = pc_if;
    end

//Mux in the proper Exception Vector
always @(latched_reset or dabort or iabort or s_nFIQ or s_nIRQ)
    begin
	if (!latched_reset)
	    exc_vector = 32'h00000000;
	else if (dabort)
	    exc_vector = 32'h00000010;
	else if (!s_nFIQ)
	    exc_vector = 32'h0000001C;
	else if (!s_nIRQ)
	    exc_vector = 32'h00000018;
	else if (iabort)
	    exc_vector = 32'h0000000C;
	else
	    exc_vector = 32'h00000000;
    end

//Create the Exception Code by Exception Priority
//DABORT = 00, FIQ = 01, IRQ = 10, IABORT = 11
always @(dabort or iabort or s_nFIQ or s_nIRQ)
    begin
	if (dabort)
	    exc_code = 2'h0;
	else if (!s_nFIQ)
	    exc_code = 2'h1;
	else if (!s_nIRQ)
	    exc_code = 2'h2;
	else 
	    exc_code = 2'h3;
    end

//Mux out the PC or the Saved_PC for Predicted BL's
//Combinational Multiplexer which sets up Data inputs
//to the PC
always @(inc_pc or latched_reset or load_pc or me_result)
//always @(inc_pc or nRESET or load_pc or me_result)
    begin
	if (~latched_reset)
	    	next_pc <= #1 32'h00000000;
        else if (load_pc)
	    	next_pc <= #1 me_result;
	else
		next_pc <= #1 inc_pc;
    end

//Mux the two possible PC's from ME
always @(Rd_me or me_result or base_me)
  begin
    if (Rd_me == 5'h0F)
      pc_me = me_result;
    else
      pc_me = base_me;
  end      

//Mux the two possible predicted addresses
always @(pt or branch_addr or to_pcp4)
  begin
    if (pt)
      pred_addr = branch_addr;
    else
      pred_addr = {to_pcp4,2'h0};
  end

//Mux the outgoing PC to memory
//Priority: Exception
//          Load to PC
//          Misprediction
//          Branch in Pipe
//          Prediction
always @(exception or exc_vector or load_pc or pc_me or mispredicted
		or saved_pc or pc_touched or ex_result or pt or put 
		or pred_addr or pc_if)
    begin
	if (exception)
	    inst_addr_in = exc_vector; 
	else if (load_pc)
	    inst_addr_in = pc_me;
        else if (mispredicted)
            inst_addr_in = saved_pc;
	else if (pc_touched)
	    inst_addr_in = ex_result;
	else if (pt | put)
            inst_addr_in = pred_addr;
	else
	    inst_addr_in = pc_if;
    end

//Mux the instruction data to the ID stage, It will
//be either the instruction bus, or a mov->R14 
always @(iplus1 or saved_ir or misp_rec or iplus2 or puntaken1)
    begin
	if (misp_rec)
	    inst_if = saved_ir;
	else if (puntaken1)
	    inst_if = iplus2;
	else
	    inst_if = iplus1;
    end

//Mux the three sets of conditions
always @(eval_ptr or saved_pc0 or saved_pc1 or saved_pc2)
  begin
    case (eval_ptr) //synopsys full_case parallel_case
      2'h2: saved_cond = saved_pc2[36:32];
      2'h1: saved_cond = saved_pc1[36:32];
   default: saved_cond = saved_pc0[36:32];
    endcase
  end

//Mux the three saved pc's
always @(eval_ptr or saved_pc0 or saved_pc1 or saved_pc2)
  begin
    case (eval_ptr) //synopsys full_case parallel_case
      2'h2: saved_pc = saved_pc2[31:0];
      2'h1: saved_pc = saved_pc1[31:0];
   default: saved_pc = saved_pc0[31:0];
    endcase
  end

always @(eval_ptr or saved_ir0 or saved_ir1 or saved_ir2)
  begin
    case (eval_ptr) //synopsys full_case parallel_case
      2'h2: saved_ir = saved_ir2[31:0];
      2'h1: saved_ir = saved_ir1[31:0];
   default: saved_ir = saved_ir0[31:0];
    endcase
  end

//Mux the Recoverable bit
always @(eval_ptr or saved_ir0 or saved_ir1 or saved_ir2)
  begin
    case (eval_ptr) //synopsys full_case parallel_case
      2'h2: recoverable = saved_ir2[32];
      2'h1: recoverable = saved_ir1[32];
   default: recoverable = saved_ir0[32];
    endcase
  end

//Check the Predicted Branch conditions
always @(saved_cond or N or Z or C or V)
    begin
	case (saved_cond[3:0])	//synopsys full_case parallel_case
             `EQ: cond_false = !(Z);
             `NE: cond_false = !(~Z);
             `CS: cond_false = !(C);
             `CC: cond_false = !(~C);
             `MI: cond_false = !(N);
             `PL: cond_false = !(~N);
             `VS: cond_false = !(V);
             `VC: cond_false = !(~V);
             `HI: cond_false = !(C & ~Z); 
             `LS: cond_false = !(~C | Z);
             `GE: cond_false = !((N && V)||(~N && ~V));
             `LT: cond_false = !((N && ~V)||(~N && V));
             `GT: cond_false = !(~Z && ((N && V)||(~N && ~V)));
             `LE: cond_false = !(Z || ((N && ~V)||(~N && V)));
             `AL: cond_false = 1'b0;
             `NV: cond_false = 1'b1;
        endcase
    end

//Mux the offset added to the PC, only used for Predicting Branches
//And storing the correct PC on Data Aborts
always @(ptaken2 or dabort or doff or boff1 or boff2)
  begin
    if (dabort)
      offset = doff;
    else if (ptaken2)
      offset = boff2;
    else
      offset = boff1;
  end

//Find the Next State for the Open Pointer
always @(pt or put or open_ptr or clr_pred)
  begin
    if (clr_pred)
      next_open_ptr = 2'h0;
    else
      begin
        case(open_ptr) //synopsys full_case parallel_case
          2'b00: next_open_ptr = (pt | put) ? 2'h1 : 2'h0;
          2'b01: next_open_ptr = (pt | put) ? 2'h2 : 2'h1;
	  2'b10: next_open_ptr = (pt | put) ? 2'h0 : 2'h2;
	  2'b11: next_open_ptr = 2'h0;
        endcase
      end
  end

//Find the Next State for the Eval Pointer
always @(eval_ptr or eval or clr_pred)
  begin
    if (clr_pred)
      next_eval_ptr = 2'h0;
    else
      begin
        case(eval_ptr) //synopsys full_case parallel_case
          2'b00: next_eval_ptr = eval ? 2'h1 : 2'h0;
          2'b01: next_eval_ptr = eval ? 2'h2 : 2'h1;
          2'b10: next_eval_ptr = eval ? 2'h0 : 2'h2;
          2'b11: next_eval_ptr = 2'h0;
        endcase
      end
  end

//Mux in the pcstore value.
//For PTaken, Want to Store PC/PC+4 (depends on where predicting from)
//For PUnTaken, Want to Store Branch Address
always @(ptaken1 or ptaken2 or puntaken1 or branch_addr 
		or spci2 or spci1 or iplus2 or iplus1)
  begin
    case ({ptaken1,ptaken2,puntaken1}) //synopsys parallel_case full_case
      //Predict Untaken on Iplus1
      3'h1: pcstore = {iplus1[31:28],branch_addr};

      //Predict Taken on Iplus2
      3'h2: pcstore = {iplus2[31:28],spci2};

      //Predict Taken on Iplus1
      3'h4: pcstore = {iplus1[31:28],spci1};

      //No Predictions Being Made
      default: pcstore = 36'h0;
    endcase
  end    

//Mux in the Proper Instruction to Store
//Want to Store the Next Instruction after Branch
always @(puntaken1 or ptaken1 or iplus2 or iplus3)
  begin
    if (puntaken1 | ptaken1)
      irstore = iplus2;
    else
      irstore = iplus3;
  end

/*======================================================================*/
endmodule       //ifetch
/*======================================================================*/

