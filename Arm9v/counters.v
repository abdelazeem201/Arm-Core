`timescale 1ns/10ps
/*****************************************************************************
$RCSfile: counters.v,v $
$Revision: 1.8 $
$Author: kohlere $
$Date: 2000/05/11 01:07:57 $
$State: Exp $
$Source: /home/lefurgy/tmp/ISC-repository/isc/hardware/ARM10/behavioral/pipelined/fpga2/counters.v,v $

Description:  This block keeps track of instruction count, when
		instructions are done, how many cycles have passed, etc...

*****************************************************************************/
module counters (nGCLK, nRESET, nWAIT, mispredicted,
			if_enbar, misp_rec, pc_touched, id_enbar,
			ex_enbar, me_enbar, hold_next_ex, ptaken_ex,
			pt, put, count, finished, cyc_count, eval,
			imiss, dmiss, InMREQ, DnMREQ, go, 
			imiss_count, dmiss_count, IABORT, DABORT,
			iaccesses, daccesses, predicted, pcorrect,
			spec_iabort, spec_dabort, time_count);

/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/

input		nGCLK;		//Core Clock Signal
input           nRESET;         //Reset Signal
input		nWAIT;		//Clock Enable Signal
input		InMREQ;		//Inst Access Request
input		DnMREQ;		//Data Access Request
input		IABORT;		//Compressed Instruction Miss
input		DABORT;		//Compressed Data Miss
input		if_enbar;	//Enable to IF Stage
input		id_enbar;	//Enable to ID Stage
input		ex_enbar;	//Enable to EX Stage
input		me_enbar;	//Enable to ME Stage
input		imiss;		//Instruction Cache Miss
input		dmiss;		//Data Cache Miss
input		go;		//Cache Miss Being Serviced
input		pt;		//Predicting Taken
input		put;		//Predicting Untaken
input		eval;		//Evaluating a Prediction
input		mispredicted;	//Mispredicted a Branch
input		misp_rec;	//Mispredicted but have next Inst
input		pc_touched;	//Taken Branch in EX stage
input		hold_next_ex;	//Mult in EX and working
input		ptaken_ex;	//Prediction Stall for EX

output	[31:0]	count;		//Instruction Count
output	[31:0]	cyc_count;	//Core Cycles
output	[31:0]	time_count;	//All Clock Cycles
output	[31:0]	imiss_count;	//Number of I$ Misses
output	[31:0]	dmiss_count;	//Number of D$ Misses
output	[31:0]	iaccesses;	//Instruction Cache Accesses
output	[31:0]	daccesses;	//Data Cache Accesses
output	[31:0]	predicted;	//Number of Predicted Branches
output	[31:0]	pcorrect;	//Number of Correctly Predicted Branches
output	[31:0]	spec_iabort;	//Number of Speculative IABORTS
output	[31:0]	spec_dabort;	//Number of Speculative DABORTS
output		finished;	//Instruciton Finished

/*------------------------------------------------------------------------
        Variable/Signal Declarations
------------------------------------------------------------------------*/
reg     [31:0]  counter;	//Count of current Instruction
reg	[31:0]	cyc_count;	//ECLK cycles
reg	[31:0]	time_count;	//Timer (Counts all Clock Cycles)
reg	[31:0]	pcorrect;	//Branches Predicted Correctly
reg	[31:0]	predicted;	//Predicted Branches
reg	[31:0]	imiss_count;	//Number of I$ Misses
reg	[31:0]	dmiss_count;	//Number of D$ Misses
reg	[31:0]	iaccesses;	//Number of I$ Accesses
reg	[31:0]	daccesses;	//Number of D$ Accesses
reg	[31:0] 	spec_dabort;	//Number of Spec. DABORTS
reg	[31:0]	spec_iabort;	//Number of Spec. IABORTS
reg     	id_valid;	//Instruction in ID Stage
reg     	ex_valid;	//Instruction in EX Stage
reg		me_valid;	//Instruction in ME Stage
reg		wb_valid;	//Instruction in WB Stage
reg		wb_waiting;	//Inst in WB Stage, waiting to Complete
reg		pre_clr;	//Prediction Clear
reg		pre_me;		//Predicted Br In ME Stage
reg		finished;	//Instruction Complete
reg	    	id_invalid;	//Reset id_valid
reg 	   	me_invalid;	//Reset me_valid

wire    	wb_reset;	//Reset wb_waiting

/*------------------------------------------------------------------------
        Combinational Always Blocks
------------------------------------------------------------------------*/

assign count = counter;

//This logic block watches for the completion of instructions 
//in the wb stage.  Completion is detected when the following
//instruction reaches the ME stage.  
always @(wb_waiting or me_valid or nGCLK or nWAIT)
  begin
    if (nGCLK)
      begin
        if (nWAIT)
          begin
            if (wb_waiting & me_valid)
              finished <= #2 1'b1;
          end
      end
    else 
      finished <= #2 1'b0;
  end

/*------------------------------------------------------------------------
        Sequential Always Blocks 
------------------------------------------------------------------------*/
//Create a Program Timer
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      time_count <= 32'h0;
    else
      time_count <= time_count + 1;
  end

//Count the total number of cycles, after memory stalls
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      cyc_count <= 32'h0;
    else if (nWAIT)
      cyc_count <= cyc_count + 1;
  end

//Count the number of Misses to each Cache
//May have to change this if ?miss isn't
//stable until after the nGCLK clock edge
always @(negedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      begin
        imiss_count <= 32'h00000000;
        dmiss_count <= 32'h00000000;
      end
    else if (~go)
      begin
        imiss_count <= imiss_count + imiss;
	dmiss_count <= dmiss_count + dmiss;
      end
  end

//Count Number of Speculate IABORTS
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      spec_iabort <= {32{1'b0}};
    else if (nWAIT)
      begin 
	if (~id_enbar)
          spec_iabort <= spec_iabort + IABORT;
      end
  end

//Count the Number of Speculative DABORTS
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      spec_dabort <= {32{1'b0}};
    else if (nWAIT)
      spec_dabort <= spec_dabort + DABORT;
  end

//Count the number of I$/D$ Accesses
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      begin
        iaccesses <= 32'h00000000;
        daccesses <= 32'h00000000;
      end
    else if (nWAIT)
      begin
	if (~InMREQ)
	  iaccesses <= iaccesses + 1;
	if (~DnMREQ)
          daccesses <= daccesses + 1;
      end
  end

//Count the number of correctly predicted branches
wire inc_correct = eval & ~mispredicted;

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      pcorrect <= 32'h0;
    else if (nWAIT)
      begin  
        if (inc_correct)
          pcorrect <= pcorrect + 1;  
      end   
  end

//Count the number of incorrectly predicted branches
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      predicted <= 32'h0;
    else if (nWAIT)
      begin
       if (eval)
         predicted <= predicted + 1;
      end
  end

/*	-- Follow Predictions  --

  Follow the results of branch prediction through the pipeline.  
  If the prediction makes it past the ex stage, add an extra 1 to 
  the instruction counter.

  Notes: 1) Need to use synchronous reset, other than nRESET
         2) Predicted Branch makes it into ME stage when:
		a) there is a predicted branch in EX, ME is enabled
		   and there's no active misprediction
	 3) Ensure that pre_ME does not get set on mispredicted
	    branches by adding mispredicted to the enable.
*/		

wire en_pre_me = ~me_enbar | mispredicted;
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      pre_me <= 1'b0;
    else if (nWAIT)
      begin
        if (en_pre_me) 
          pre_me <= eval & ~mispredicted;
        else
          pre_me <= 1'b0;
      end
  end  


/*      -- Follow Instruction in the Pipeline  --

  It is necessary to track the number of instructions that complete.
  This information is used by the verification environment to check
  the state of the machine versus a golden brick.  To do so, there
  is a bit for each stage of the pipeline from ID - WB which indicates
  that a valid instruction is occupying the stage.  When the bit
  for the WB stage is high, this indicates that an instruction is
  present, but not finished.  Completion is indicated by an additional
  bit of logic.

  Notes: 1) The id_invalid signal resets the id_valid if some previous
            instruction has modified the PC, and there is no 
            misprediction.  It is important to insure that there is no
            misprediction because a mispredicted branch is detected
            at the same time the first incorrect instruction would
            signal a modification to the pc.  Thus, mispredicted is
            higher priority.
         2) Id_valid is set when Id is enabled, unless there is a
            multiplication holding up progress.  If a prediction 
            occured in the middle of a mult requiring 3+ registers,
            the id stage is allowed to load the next instruction, 
            so the valid bit must be enabled in this case.
         3) Ex_valid is set when Id_valid was high last cycle 
            unless there is a multiplication in ex or a branch
            misprediction is detected.  If there is a multiplication
            asserting hold_next_ex, then ex has already been set
            on entrance, so it must be cleared while the mult is 
            occupying the stage or it will cause extra counts.
            On a misprediction, the ID stage was definitely invalid,
            so rather than asynchronously clearing ID, we insure
            ex_valid is cleared on the next cycle.  This eliminates
            glitch worries on the misprediction logic.
         4) Me_valid generally follows the ex_valid signal.  Exceptions:
		a) On a misprediction, want to make it look like
		   the branch was in the ex stage, so we set me_valid
		   on the following cycle
         5) The reset for me_valid is anded with GCLK to ensure
            glitches in the first half-cycle dont incorrectly cause
            a reset.  Probably could fix this to be synchronous reset.
         6) Wb_valid follows me_valid exactly.

*/

always @(nGCLK or nWAIT or pc_touched or mispredicted or nRESET)
  begin
    if (~nGCLK)
      begin
        if (nWAIT)
          id_invalid <= ((pc_touched & ~mispredicted) | ~nRESET);
      end
  end

//assign id_invalid = ((pc_touched & ~mispredicted) | ~nRESET) & (nGCLK & nWAIT);

wire en_idvalid = ~hold_next_ex | (hold_next_ex & ptaken_ex);
//synopsys async_set_reset "id_invalid"
always @(posedge nGCLK or posedge id_invalid)
  begin
    if (id_invalid)
        id_valid <= 1'b0;
    else if (nWAIT)
      begin
        if (en_idvalid)
          id_valid <= ~id_enbar;
      end
  end

//Mux a 1 or 0 in depending on Mispredicted
always @(mispredicted)
  begin
    if (mispredicted)
      pre_clr = 1'b1;
    else
      pre_clr = 1'b0;
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      ex_valid <= 1'b0;
    else if (nWAIT)
      ex_valid <= id_valid & ~hold_next_ex & ~pre_clr;
  end

always @(nGCLK or nWAIT or nRESET or mispredicted or hold_next_ex)
  begin
    if (~nGCLK)
      begin
        if (nWAIT)
          me_invalid <= (mispredicted & hold_next_ex) | ~nRESET;
      end
  end

//assign me_invalid = (mispredicted & hold_next_ex & (nGCLK & nWAIT)) | ~nRESET;
//synopsys async_set_reset "me_invalid"
always @(posedge nGCLK or posedge me_invalid)
  begin
    if (me_invalid)
      me_valid <= 1'b0;
    else if (nWAIT)
      me_valid <= ex_valid | pre_clr;
  end 	  

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      wb_valid <= 1'b0;
    else if (nWAIT)
      wb_valid <= me_valid;
  end

//synopsys async_set_reset "nRESET"
//if branch is there to be added in chthJ18.141116
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      counter <= 32'h00000000;
    else if (nWAIT)
      begin
        if (me_valid | pre_me) 
          counter <= counter + pre_me + me_valid;
      end
  end

//assign async_set_reset "wb_reset"
assign wb_reset = finished | ~nRESET;
always @(negedge nGCLK or posedge wb_reset)
  begin
    if (wb_reset)
      wb_waiting <= 1'b0;
    else if (nWAIT)
      wb_waiting <= me_valid | wb_waiting;
  end

endmodule
