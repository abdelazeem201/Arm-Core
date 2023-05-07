`timescale 1ns/10ps
`include "pardef"
/*****************************************************************************
$RCSfile: interlock.v,v $
$Revision: 1.5 $
$Author: kohlere $
$Date: 2000/04/13 21:55:18 $
$State: Exp $

Description:  This contains the control logic which interlocks the 
		pipeline for these reasons:

	1) Mispredicted Branch
	2) Database result -> PC
	3) Load destination -> PC
	4) Swap Instruction
	5) Load-Use Register
	6) 3 Registers reads required in Instruction
	-7) LDM/STM instructions

*****************************************************************************/

module interlock(nGCLK, nRESET, nWAIT, need_2cycles, second, load_use,
			ldm, stm, finished, if_enbar, id_enbar, ex_enbar,
			pc_mod_ex, me_enbar, wb_enbar, mispredicted,
			fill_state, cop_id, CHSD, CHSE, cop_absent, Rn_ex,
			Rd_ex, write_Pc_Rn_ex, write_Pc_Rd_ex,
			reset_write_Rn_me, reset_write_Rd_me,
			hold_next_ex, load_pc, dabort, prediction_stall,
			misp_rec, load_pc_ex, ptaken_ex);

/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/

input	[4:0]	Rd_ex;			//Destination Reg in EX Stage
input	[4:0]	Rn_ex;			//Base Reg in EX stage
input	[1:0]	CHSD;			//Coprocessor Hndshk from Decode
input	[1:0]	CHSE;			//Coprocessor Hndshk from Execute
input		nGCLK;			//Clock Signal
input		nWAIT;			//Clock Enable
input		nRESET;			//Reset Signal
input		dabort;			//Data Abort Taken
input		need_2cycles;		//3 Reg Reads Required
input		second;			//2nd Cycle or Reg Reads indicator
input		load_use;		//Load-Use Interlock Necessary
input		ldm;			//Inst is LDM in ID stage
input		stm;			//Inst is STM in ID stage
input		finished;		//Inst (LDM/STM) is finished
input		mispredicted;		//Mispredicted a branch
input		misp_rec;		//Mispredicted but recoverable
input		cop_id;			//Coprocessor Inst in ID stage
input		pc_mod_ex;		//One of Last two inst mod pc
input		write_Pc_Rd_ex;		//Write to PC by Rd possible
input		write_Pc_Rn_ex;		//Write to PC by Rn possible
input		hold_next_ex;		//Hold Next Instruction for Ex
input		load_pc_ex;		//Load PC Inst in EX Stage
input		load_pc;		//Load PC from Memory
input		prediction_stall;	//Prediction Bubble

output	[2:0]	fill_state;		//State of Machine
output		cop_absent;		//No Coprocessor Present
output		if_enbar;		//Enable to IF stage
output		id_enbar;		//Enable to ID stage
output		ex_enbar;		//Enable to EX stage
output		me_enbar;		//Enable to ME stage
output		wb_enbar;		//Enable to WB stage
output		reset_write_Rn_me;	//Reset write signal
output		reset_write_Rd_me;	//Reset write signal
output		ptaken_ex;		//Pred bubble into->Ex Stage

/*------------------------------------------------------------------------
        Variable Declarations
------------------------------------------------------------------------*/
//FSM Declarations
reg 	[2:0]	fill_state;		//State of Machine wrt pipeline
reg	[2:0]	next_fill_state;	//Next State of Mach. wrt pipeline
reg	[1:0]	cop_cyc_count;		//Coprocessor Cycle Count
reg	[1:0] 	next_cyc_count;		//Next Coprocessor Cycle Count

//Outputs from Multiplexers
reg       	if_enbar;               //Enable to IF stage (active low)
reg            	id_enbar;               //Enable to ID stage (active low)
reg            	ex_enbar;               //Enable to EX stage (active low)
reg            	me_enbar;               //Enable to ME stage (active low)
reg            	wb_enbar;               //Enable to WB stage (active low)
reg	        latched_reset;		//Catch the Reset Signal
reg		delayed_reset;		//Delayed Reset Signal

//Outputs from Latches and Registers
reg	[1:0]	latched_chs;		//Latched Coprocessor Hndshk
reg		dabort_1;		//One Behind DABORT
reg		start_count;		//Start the Coprocessor Counter
reg		load_pc_latch;		//Latch the load_pc_signal
reg		ptaken_ex;		//Stall The EX stage
reg		third_plus;		//ID in 3+ Cycle
	
//Outputs from Combinational Logic
wire		pc_modified;		//An Instruction Modified PC
reg		nRefill;		//Signals Refill pipeline
wire		cop_stall;		//Coprocessor Signals Stall Pipe
wire 		cop_absent;		//Take Undefined Inst Trap
wire		cop_go;			//Multiple Cycles Required
wire		cop_count;		//Enable the Counter
wire		cop_not_first;		//Coprocessor Inst Not in 1st Cyc
wire		reset_write_Rd_me;	//Reset Write Signal
wire		reset_write_Rn_me;	//Reset Write Signal
wire		no_interlock_if;	//Refilling
wire		no_interlock_id;	//Refilling

/*------------------------------------------------------------------------
         Basic Assignments
------------------------------------------------------------------------*/
//This signal is one when a write is scheduled for the PC.
assign pc_modified = (((write_Pc_Rn_ex) && (Rn_ex == 5'h0F)) ||
		      ((write_Pc_Rd_ex) && (Rd_ex == 5'h0F)));

//assign refill = (!nRESET || pc_touched || load_pc);

//Coprocessor in 2+ cycle of exectution
assign cop_not_first = (cop_cyc_count != `NO_COUNT);

//Enable to the Coprocessor Cycle Counter
assign cop_count = cop_id & id_enbar & !pc_mod_ex;

//Coprocessor is Absent, take Undefined Instruction Trap
assign cop_absent = (latched_chs == `ABSENT) && !pc_mod_ex;

//Coprocessor is Working on something Else
assign cop_stall = (latched_chs == `WAIT) & !pc_mod_ex;

//Coprocessor is Working on requested operation
assign cop_go = (latched_chs == `GO) && !pc_mod_ex;

//Reset the Write to PC Signal
assign reset_write_Rd_me = ((((fill_state == `SECOND_FILL) & ~nRefill) &
				(Rd_ex == 5'h0F) & !load_pc_ex) | 
				dabort |
				mispredicted);

//Reset the Write to PC Signal
assign reset_write_Rn_me = ((((fill_state == `FIRST_FILL) & ~nRefill) &
				(Rn_ex == 5'h0F) & !load_pc_ex) | 
				dabort |
				mispredicted);

//Set a signal which indicates that neither the IF nor ID 
//stages should be interlocked.  When the pipeline is refilling,
//the instructions being squashed could send phony signals.
//Also, if in First Mispredict, 1st Inst should be loaded to ID next cycle
//The 'no_interlock' signal indicates that these should be ignored.

assign no_interlock_if = mispredicted | pc_modified | 
			load_pc_latch | load_pc | dabort |
			(fill_state == `FIRST_MISPREDICT) |
			(fill_state == `SECOND_FILL & nRefill);

assign no_interlock_id = misp_rec | 
			(fill_state == `FIRST_MISPREDICT) |
			((fill_state == `SECOND_FILL & nRefill) & 
				~prediction_stall) | 
			(dabort);

/*------------------------------------------------------------------------
         Combinational Always Blocks (Multiplexers)
------------------------------------------------------------------------*/
//The enable signals could/should be done with combinational logic
//only, but in order for things to function properly, I need them
//to be either 0 or 1, never X.

//The IF stage can be stalled due to:
//1) 2-Cycles for RF Reads (only 2cycles)
//2) Load-Use Interlock
//3) LDM/STM > 1word
//4) Coprocessor Not Ready/Busy
//4) Multi-Cycle Multiplication
always @(no_interlock_if or second or need_2cycles or load_use or
		ldm or stm or finished or cop_stall or cop_go or
		hold_next_ex or fill_state or ptaken_ex or third_plus)
    begin
	if (!no_interlock_if & (
				(!second & !third_plus & 
					(need_2cycles | load_use))    | 
				((ldm | stm) & !finished)	      |
				(cop_stall | cop_go)		      |
				(hold_next_ex & 
				  (fill_state != `FIRST_MISPREDICT))
			       ))
	    if_enbar = 1'b1;
	else 
	    if_enbar = 1'b0;
    end

//The ID stage can be stalled due to:
//1) Same as IF
//2) Load to PC from Memory (1 extra delay seen here)
//3) Reset asserted
always @(no_interlock_id or if_enbar or load_pc or prediction_stall 
		or latched_reset or fill_state or mispredicted or nRefill)
    begin
	if (~no_interlock_id & (
				(if_enbar)		|
				(load_pc) 		|
				(!latched_reset)	|
				(prediction_stall)	|
//Adding mispredicted because unless recoverable is set,
//shouldn't be loading next instruction into ID
				(mispredicted)		|
				(fill_state == `SECOND_FILL & ~nRefill)		
			       ))
	    id_enbar <= #1 1'b1;
	else
	    id_enbar <= #1 1'b0;
    end

//The EX stage be stalled due to:
//1) Multi-Cycle Multiplication
//2) Coprocessor Not Ready/Busy
//The EX can be squashed due to:
//1) Mispredicted Branch Instruction
//2) Pipeline is being Refilled
always @(fill_state or hold_next_ex or mispredicted or cop_stall or
		cop_not_first or ptaken_ex or nRefill or dabort)
    begin
	if ((fill_state == `FIRST_FILL)			|
	    (fill_state == `SECOND_FILL)		|
	    (hold_next_ex & ((fill_state != `SECOND_FILL)|
	        (fill_state == `SECOND_FILL & ~nRefill)) &
		(fill_state != `FIRST_MISPREDICT)) 	|
	    (mispredicted)				|
	    (ptaken_ex)					|
	    (fill_state == `FIRST_MISPREDICT)		|
            (dabort)				        |
	    (cop_stall & cop_not_first))
	    ex_enbar <= #1 1'b1;
	else
	    ex_enbar <= #1 1'b0;
    end

//The ME stage can be squashed due to:
//1) Pipeline is being refilled 
//2) Mispredicted Branch Instruction
//3) Data Abort
always @(fill_state or mispredicted or dabort or nRefill or dabort_1)
    begin
	if ((fill_state == `SECOND_FILL & nRefill)|
	    (fill_state == `THIRD_FILL)		|
	    (mispredicted)			|
	    (dabort | dabort_1)			|
	    (fill_state == `FIRST_MISPREDICT)	|
	    (fill_state == `SECOND_MISPREDICT))
		me_enbar = 1'b1;
	else
		me_enbar = 1'b0;
    end

//The WB stage can be squashed if:
//1) Load PC from Memory
//2) Pipeline is being refilled
//3) Data Abort
always @(load_pc_latch or fill_state or dabort or dabort_1)
    begin
	if ((load_pc_latch)||
	    (fill_state == `THIRD_FILL)		|
	    (fill_state == `FIRST_MISPREDICT)	|
	    (fill_state == `SECOND_MISPREDICT)	|
	    (fill_state == `THIRD_MISPREDICT)	|
	    (dabort | dabort_1))
		wb_enbar = 1'b1;
	else
		wb_enbar = 1'b0;
    end

/*------------------------------------------------------------------------
         Sequential Always Blocks (Latches)
------------------------------------------------------------------------*/
//synopsys async_set_reset "nRESET"
always @(negedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      nRefill <= 1'b0;
    else if (nWAIT)
      nRefill <= ~(pc_modified | load_pc | ~delayed_reset) | mispredicted;
  end

//Latch the Coprocessor Handshake signals.  If its the first
//cycle of the coprocessor inst, should be latching CHSD, else CHSE
//synopsys async_set_reset "nRESET"
always @(negedge nGCLK or negedge nRESET)
  begin
    if (!nRESET)
      latched_chs <= 2'h3;		//Last
    else if (nWAIT)
      begin
	if ((~if_enbar & ~cop_not_first) | (cop_not_first))
	  latched_chs <= (cop_not_first) ? CHSE : CHSD;
      end
  end

//Create a Latch that will Start the Coprocessor Counter
//synopsys async_set_reset "nRESET"
always @(nGCLK or cop_count or cop_not_first or nRESET or nWAIT or start_count)
    begin
	if (~nRESET)
	    start_count <= 1'b0;
	else if (~nGCLK)
          begin
            if (nWAIT)
	      start_count <= cop_count & !cop_not_first;
	    else
	      start_count <= start_count;
          end
    end   

//Create a FF that will Remember that the PC was loaded from
//Memory...thus requiring an extra bubble in the pipeline.
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
    begin
	if (!nRESET)
	    load_pc_latch <= 1'b0;
	else if (nWAIT)
	    load_pc_latch <= load_pc;
    end

//This block normally catches a bubble due to a prediction
//and keeps the bubble from fouling up the Ex Stage
//Added in the if_enbar so that if id and if are waiting (for LDM/STM)
//ex_enbar doesn't go high until after the ID bubble is present.
//synopsys async_set_reset "nRESET"
//Added in the fill_state because can predict a branch while pipe is
//refilling, in which case, ex_enbar may be high, so still need to
//capture the stall.
//Added in pt & ps & if_en so that if ptaken_ex is still high, you 
//can still stall the next cycle (this may happen in an every-other
//patter with prediction stalls) dO24.18713
wire ptaken_disable = ~(~ex_enbar | (fill_state == `SECOND_FILL & nRefill) |
                (ptaken_ex & prediction_stall & ~if_enbar));
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin 
    if (~nRESET)
      ptaken_ex <= 1'b0;
    else if (nWAIT)
      begin
        if (~ptaken_disable)
          ptaken_ex <= prediction_stall & ~if_enbar;
        else if (~hold_next_ex)
          ptaken_ex <= 1'b0;
      end
  end

//This block determines that a two-cycle inst is being stalled for
//some other reason, than its the first
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      third_plus <= 1'b0;      
    else if (nWAIT)
      third_plus <= (need_2cycles & second & id_enbar) |
		    (need_2cycles & third_plus & id_enbar);
  end

/*------------------------------------------------------------------------
         FSM Next State Logic
------------------------------------------------------------------------*/

//Fill FSM
always @(fill_state or mispredicted or misp_rec)
    begin 
	case (fill_state) //synopsys full_case parallel_case
	    `IDLE: begin
		    if (misp_rec) 
			next_fill_state = `SECOND_MISPREDICT;
		    else if (mispredicted)
			next_fill_state = `FIRST_MISPREDICT;
		    else 
			next_fill_state = `IDLE;
		  end

	    `FIRST_FILL: next_fill_state = `SECOND_FILL;
	    `SECOND_FILL: next_fill_state = `THIRD_FILL;
	    `THIRD_FILL: next_fill_state = `IDLE;
	    `FOURTH_FILL: next_fill_state = `IDLE;
	    `FIRST_MISPREDICT: next_fill_state = `SECOND_MISPREDICT;
	    `SECOND_MISPREDICT: next_fill_state = `THIRD_MISPREDICT;
	    `THIRD_MISPREDICT: begin
                                if (misp_rec)
                                  next_fill_state = `SECOND_MISPREDICT;
                                else if (mispredicted)
                                  next_fill_state = `FIRST_MISPREDICT;
                                else
                                  next_fill_state = `IDLE;
                              end
	    
	endcase
    end

//Coprocessor Cycle Count Next State Logic
always @(cop_cyc_count or cop_count)
    begin
	case (cop_cyc_count) //synopsys full_case parallel_case
	    `NO_COUNT: next_cyc_count = `NO_COUNT;

	    `SECOND_CYCLE: 
		   next_cyc_count = (cop_count) ? `THIRD_CYCLE
						: `NO_COUNT; 

	    `THIRD_CYCLE:
                   next_cyc_count = (cop_count) ? `FOURTH_PLUS_CYCLE 
						: `NO_COUNT;
	    `FOURTH_PLUS_CYCLE:
		   next_cyc_count = (cop_count) ? `FOURTH_PLUS_CYCLE
						: `NO_COUNT;
	endcase
    end


/*------------------------------------------------------------------------
         FSM Registers
------------------------------------------------------------------------*/

//Fill FSM
wire nFillReset = nRefill;

//synopsys async_set_reset "nFillReset"
always @(negedge nFillReset or posedge nGCLK)
  begin
    if (~nFillReset)
      fill_state <= `SECOND_FILL;
    else if (nWAIT)
      begin
	if (!load_pc)
	  fill_state <= next_fill_state;
      end
  end

//Count FSM
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (!nRESET)
      cop_cyc_count <= `NO_COUNT;
    else if (nWAIT)
      begin
	if (~id_enbar)
	  begin
	    if (start_count)
	      cop_cyc_count <= `SECOND_CYCLE;
	    else
	      cop_cyc_count <= next_cyc_count;
	  end
      end
  end

//This block captures the nRESET signal
//synopsys async_set_reset "nRESET"
always @(negedge nRESET or posedge nGCLK)
    begin
      if (!nRESET)
          latched_reset <= 1'b0;  
      else if (nWAIT)
          latched_reset <= 1'b1;
    end

always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      delayed_reset <= 1'b0;
    else if (nWAIT)
      delayed_reset <= latched_reset;
  end

//This block catures the dabort signal
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
    begin
	if (!nRESET)
	    dabort_1 <= 1'b0;
	else if (nWAIT)
	    dabort_1 <= dabort;
    end

endmodule
