`timescale 1ns/10ps
`include "pardef"
/*****************************************************************************
$RCSfile: mmu_new.v,v $
$Revision: 1.15 $
$Author: kohlere $
$Date: 2000/05/11 01:07:57 $
$State: Exp $
$Source: /home/lefurgy/tmp/ISC-repository/isc/hardware/ARM10/behavioral/pipelined/fpga2/mmu_new.v,v $

Description:  Memory Management Unit for the ARM Microprocessor.
	Notes:	DMAS 	11 => double word
			10 => word
			01 => halfword
			00 => byte

		CHSD/E	11 => last
			10 => absent
			01 => go
			00 => wait

		DnWr	0  => data memory write
			1  => data memory read

*****************************************************************************/

module mmu (nGCLK, nRESET,
		nWAIT, CHSD, CHSE, id_enbar, BIGEND, LATECANCEL, PASS,
		IABORT, DABORT, MMA, MMnWR, DnMREQ, dmiss, dwb, DD, doublehold,
		dmiss_addr, imiss_addr, imiss, inst_if, ex_enbar,
		ic_read_mmd, dc_read_mmd, drive_mmd, IA, InMREQ, DA,
		useMini, iswic, dswic, swic_data, dc_init, ic_init,
		istall, mode, MM_New_Line, MM_CE, me_enbar, decomp,
		dflush, mispredicted, misp_rec, pc_touched, hold_next_ex,
		ptaken_ex, pt, put, eval, if_enbar, stop_me);

/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/
input   [31:0]  imiss_addr;	//Instruction Address of Miss
input   [31:0]  dmiss_addr;     //Data Address of Miss
input	[31:0]	inst_if;	//Instr to ID stage
input	[31:0]	IA;		//Instruction Address Bus
input	[31:0]	DA;		//Data Address Bus
input	[4:0]	mode;		//Processor Mode
input		nGCLK;		//Global Clock
input		nRESET;		//Global Reset
input		LATECANCEL;	//Cancel Coprocessor Inst
input		PASS;		//Execute Coprocessor Inst (Cond Passed)
input		InMREQ;		//Instruction Requested
input		DnMREQ;		//Data Requested
input		if_enbar;	//Instruction Fetch Enable
input		id_enbar;	//Coprocessor Decode Enable
input		ex_enbar;	//Coprocessor Ex Enable
input		me_enbar;	//Coprocessor ME Enable 
input		imiss;		//Instruction Cache Miss
input		doublehold;	//Hold for One Cycle
input		dmiss;		//Data Cache Miss
input		dwb;		//Data Write Back Needed
input		dc_init;	//Data Cache Initing
input		ic_init;	//Inst Cache Initing
input           mispredicted;   //Mispredicted a Branch   
input           misp_rec;       //Have the IR Saved
input           pc_touched;     //PC Modified in EX
input           hold_next_ex;   //Multiply in EX
input           ptaken_ex;      //Predicted Taken
input           pt;             //Predicted Taken
input           put;            //Predicted Not Taken
input           eval;           //Evaluating a Branch
input		stop_me;	//Stop Execution

inout	[63:0]	DD;		//Data Data Bus

output	[31:0]	MMA;		//Main Memory Address Bus
output	[31:0]	swic_data;	//Data Word to Store in I$
output	[1:0]	CHSD;		//Coprocessor HandShake
output	[1:0]	CHSE;		//Coprocessor HandShake
output		nWAIT;		//Memory System Stall Signal
output		BIGEND;		//Give Processor Big/Little Endianess
output		DABORT;		//Data Abort
output		IABORT;		//Instruction Prefetch Abort
output		MMnWR;		//Not Main Memory Write, Read
output          MM_New_Line;    //Used for FPGA to Initiate New Transfer  
output          MM_CE;          //Enable for Buffer Ram
output		iswic;		//SWIC Signal to I$ Controller
output		dswic;		//SWIC Signal to D$ Controller
output		ic_read_mmd;	//To I-Cache Controller
output		dc_read_mmd;	//To D-Cache Controller
output		drive_mmd;	//Permission to Dcache Controller
output		useMini;	//Do Not Store Line in Cache
output		istall;		//ICache Stalling Processor
output		decomp;		//Decompressing
output          dflush;         //Flush a Line from Data Cache

/*------------------------------------------------------------------------
        Defines & Parameters
------------------------------------------------------------------------*/
parameter	LATENCY = 1;			//# of GCLK cycles
parameter	BW = 1;				//words/cycle
parameter	PENALTY = LATENCY + 8/BW;	//Total Miss Penalty

/*------------------------------------------------------------------------
        Signal Declarations
------------------------------------------------------------------------*/
reg	[31:0]	MMA;			//Main Memory Address Bus
reg	[31:6]  ia;			//Latched Instruction Addr
reg	[31:0]  da;			//Latched Data Addr
reg	[3:0]	count;			//Cycle Count for Miss
reg		swicInD;		//Swic, Hi=>I, Lo=>D
reg		nWAIT;			//Stall Signal to Processor
reg		MMnWR;			//Main Memory not Write Read
reg             MM_New_Line;            //Start New Transfer
reg             MM_CE;                  //Enable the Buffer
reg		srv_d;			//Serving DCache=1/Icache=0
reg		go;			//Servicing Miss
reg		dwb_1;			//DWB delayed by 1
reg             abort_id;               //ABORT now in ID
reg             abort_ex;               //ABORT now in EX
reg             abort_me;               //ABORT now in ME

wire	[63:0]	DD;			//Data Data Bus
wire	[31:0]	MMD;			//Main Memory Data Bus
wire	[31:0]	inst_count;		//Number of Completed Instructions
wire	[31:0]  cyc_count;		//Number of Pipeline Cycles
wire	[31:0]	time_count;		//Number of all Clock Cycles
wire	[31:0]	iaccesses;		//Number of I$ Accesses
wire	[31:0]	daccesses;		//Number of D$ Accesses
wire	[31:0]	imiss_count;		//Number of I$ Misses
wire	[31:0]	dmiss_count;		//Number of D$ Misses
wire	[31:0]	predicted;		//Number of Predicted Branches
wire	[31:0]	pcorrect;		//Number of Correctly Predicted Branches
wire	[31:0]	spec_iabort;		//Number of Speculative IABORTS
wire	[31:0]	spec_dabort;		//Number of Speculative DABORTS
wire	[3:0]	penalty;		//Cache Miss Penalty (cycles)
wire	[3:0]	latency;		//Main Memory Latency
wire	[3:0]	next_count;		//Next Count Value
wire		BIGEND;			//Endianness
wire		DABORT;			//Data Access Abort
wire		IABORT;			//Inst Access Abort
wire		drive_mmd;		//DCache Controller Drive MMD
wire		istall;			//ICache Needs to Stall Pipeline
wire		decomp;			//Decompressing

/*------------------------------------------------------------------------
        Component Instantiations
------------------------------------------------------------------------*/

counters xcounters (.nGCLK(nGCLK), .nWAIT(nWAIT), .IABORT(IABORT),
                        .nRESET(nRESET), .mispredicted(mispredicted),
                        .if_enbar(if_enbar), .misp_rec(misp_rec),
                        .pc_touched(pc_touched), .id_enbar(id_enbar),
                        .ex_enbar(ex_enbar), .me_enbar(me_enbar),
                        .hold_next_ex(hold_next_ex), .DABORT(DABORT),
                        .finished(inst_finished), .go(go),
                        .ptaken_ex(ptaken_ex), .pt(pt),
                        .put(put), .count(inst_count), .eval(eval),
                        .cyc_count(cyc_count), .imiss(imiss),
                        .dmiss(dmiss), .InMREQ(InMREQ), .DnMREQ(DnMREQ),
                        .imiss_count(imiss_count), .predicted(predicted),
                        .dmiss_count(dmiss_count), .pcorrect(pcorrect),
			.iaccesses(iaccesses), .daccesses(daccesses),
			.spec_iabort(spec_iabort), .spec_dabort(spec_dabort),
			.time_count(time_count));

/*------------------------------------------------------------------------
        Signal Assignments
------------------------------------------------------------------------*/
assign next_count = ((count == penalty) | (DABORT & ~abort_id)) 
		  ? 4'h0 : count + 1;
assign ic_read_mmd = (count > latency) & ~srv_d;
assign dc_read_mmd = (count > latency) & srv_d & MMnWR & ~dwb_1;
assign penalty = (~MMnWR) ? (4'h7 + latency) : PENALTY;
assign latency = LATENCY;
assign drive_mmd = (dwb & go & (count < 4'h8));
assign istall = imiss & ~nWAIT;

/*------------------------------------------------------------------------
        Sequential Always Block
------------------------------------------------------------------------*/
//Stall the Processor on a cache miss
//synopsys async_set_reset "nRESET"
always @(nGCLK or imiss or IABORT or dmiss or doublehold or nRESET or
		dc_init or ic_init or stop_me)
  begin
    if (~nRESET)
      nWAIT <= 1'b1;
    else if (~nGCLK)
      nWAIT <= ~((imiss & ~IABORT) | (dmiss & ~DABORT) | doublehold | 
			ic_init | dc_init | stop_me);
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      swicInD <= 1'b0;
    else if (IABORT)
      swicInD <= 1'b1;
    else if (DABORT)
      swicInD <= 1'b0;
  end

/*------------------------------------------------------------------------
        MMA Bus Controller
------------------------------------------------------------------------*/

//Cache Miss Cycle Counter
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      count <= #1 4'h0;
    else if (~nWAIT & go)
      count <= #1 next_count;
    else
      count <= #1 4'h0;
  end

//Want to Reset MMnWR after transferred
//8 words, thus the < 4'h7
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      MMnWR <= #1 1'b1;
    else
      MMnWR <= #1 ~(dwb & go & (count < 4'h8));
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      srv_d <= #1 1'b0;
    else
      srv_d <= #1 (dmiss & (count != penalty)) | dwb;
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      go <= #1 1'b0;
    else
      go <= #1 (dmiss & ~DABORT) | (imiss & ~IABORT);
  end

always @(srv_d or dmiss_addr or count or imiss_addr)
  begin
      MMA <= (srv_d) ? {dmiss_addr[31:5],count[2:0],2'h0}
                     : {imiss_addr[31:5],count[2:0],2'h0};
  end

always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      dwb_1 <= #1 1'b0;
    else
      dwb_1 <= #1 dwb;
  end

//Start a Memory to Buffer/Buffer to Memory Transfer
always @(go or count or dwb or MMnWR or imiss or dmiss)
  begin
    if ((go & (count == 4'h0) & MMnWR & ~dwb & (imiss | dmiss)) | 
	(go & (count == 4'h8) & dwb & dmiss))
      MM_New_Line <= 1'b1;
    else
      MM_New_Line <= 1'b0;
  end

//Enable the DPM Buffer
always @(negedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      MM_CE <= 1'b0;
    else
      MM_CE <= go;
  end

/*------------------------------------------------------------------------
        MMU Coprocessor Begins Here (CP #15)
------------------------------------------------------------------------*/

reg	[31:0]	mmu_ir_id;	//MMU ID Instruction Register
reg	[31:0]	op1_cid;	//Operand #1 (in ID)
reg	[31:0]	op1_cex;	//Operand #1 (in EX)
reg	[31:0]	op2_cid;	//Operand #2 (in ID)
reg	[31:0]	op2_cex;	//Operand #2 (in EX)
reg	[31:0]	res_cex;	//Muxed Result of EX Stage
reg     [31:0]  res_cme;        //Result (in ME)
reg	[31:0]	res_to_wb;	//Muxed Result in ME Stage
reg	[31:0]	cr1;		//Reg 1 -- Control Register
reg     [31:0]  cr2;            //Reg 2 --
reg     [31:0]  cr3;            //Reg 3 --
reg     [31:0]  cr4;            //Reg 4 --
reg     [31:0]  cr5;            //Reg 5 --
reg     [31:0]  cr6;            //Reg 6 --
reg     [31:0]  cr7;            //Reg 7 --
reg     [31:0]  cr8;            //Reg 8 --
reg     [31:0]  cr9;            //Reg 9 --
reg     [31:0]  cr10;           //Reg 10 --
reg     [31:0]  cr11;           //Reg 11 --
reg     [31:0]  cr12;           //Reg 12 --
reg     [31:0]  cr13;           //Reg 13 --
reg     [31:0]  cr14;           //Reg 14 --
reg     [31:0]  cr15;           //Reg 15 --
reg	[31:0]	rf_op1;		//Register Operand #1
reg	[31:0]	rf_op2;		//Register Operand #2
reg	[31:0]	perf_op1;	//Performance Counter Mux
reg	[3:0]	op2_index_cid;	//Op2 Index into Reg File
reg	[3:0]	op1_index_cex;	//Op1 Index in EX 
reg	[3:0]	CRd_cex;	//Destination Register Index
reg	[3:0]	CRd_cme;	//Destination Register Index
reg	[1:0]	CHSD;		//MMU ID Handshake Signal
reg	[1:0]	CHSE;		//MMU EX Handshake Signal
reg	[1:0]	next_chsd;	//Input to CHSD Latch
reg	[1:0]	next_chse;	//Input to CHSE Latch
reg		mem_op_cex;	//LDC/STC Operation (in EX)
reg		reg_op_cex;	//MRC/MCR Operation (in EX)
reg		data_op_cex;	//CDP Operation (in EX)
reg		drive_DD_cex;	//To ARM (in EX)
reg		load_use_cex;	//Load Use Bubble 
reg		swic_cex;	//SWIC in EX
reg             flush_cex;      //FLUSH in EX
reg		mem_op_cme;	//LDC/STC Operation (in ME)
reg		reg_op_cme;	//MRC/MCR Operation (in ME)
reg		data_op_cme;	//CDP Operation (in ME)
reg		drive_DD_cme;	//To ARM (in ME)

wire	[31:0]	to_DD;		//Data to DD;
wire	[31:0]	cr0;		//Cr0 -- ID Register (Read Only)
wire	[31:0]	swic_data;	//Swic Data to Store
wire	[3:0] 	CRn_cid;	//Cop Rn
wire    [3:0]   Rd_cid;         //ARM Rd
wire    [3:0]   CRm_cid;	//Cop Rm
wire	[3:0]	op1_index_cid;	//Op1 Index into Reg File
wire            cop15;          //Coprocessor 15 Selected
wire            N;              //N-Bit of Mem Inst.
wire            flush;          //Opcode for Flush Instr.  
wire		move_perf;	//Move the Performance Counters
wire		flush_cid;	//Flush in ID Stage
wire		must_wait_cid;	//ID Stage Blocked
wire		must_wait_cex;	//EX Stage Blocked
wire		load_use_op1;	//Load Use Interlock 
wire		mem_op_cid;	//LDC/STC Operation 
wire		reg_op_cid;	//MRC/MCR Operation
wire		data_op_cid;	//CDP Operation
wire		swic_cid;	//SWIC Inst
wire		swic_cme;	//SWIC Inst
wire		rfw_ena;	//Write to a Regsiter
wire		write_cr0;	//Write to Cr0
wire            write_cr1;      //Write to Cr1
wire            write_cr2;      //Write to Cr2
wire            write_cr3;      //Write to Cr3
wire            write_cr4;      //Write to Cr4
wire            write_cr5;      //Write to Cr5
wire            write_cr6;      //Write to Cr6
wire            write_cr7;      //Write to Cr7
wire            write_cr8;      //Write to Cr8
wire            write_cr9;      //Write to Cr9
wire            write_cr10;     //Write to Cr10
wire            write_cr11;     //Write to Cr11
wire            write_cr12;     //Write to Cr12
wire            write_cr13;     //Write to Cr13
wire            write_cr14;     //Write to Cr14
wire            write_cr15;     //Write to Cr15


/*------------------------------------------------------------------------
        MMU ID Stage
------------------------------------------------------------------------*/

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      mmu_ir_id <= 32'h0;
    else if (nWAIT)
      begin
        if (~id_enbar)
          mmu_ir_id <= inst_if;
      end
  end

//Grab the Operand Indexes
assign CRn_cid = mmu_ir_id[19:16];
assign Rd_cid = mmu_ir_id[15:12];
assign CRm_cid = mmu_ir_id[3:0];
assign op1_index_cid = (mem_op_cid) ? Rd_cid : CRn_cid;
assign cop15 = (mmu_ir_id[11:8] == 4'hf);
assign N = mmu_ir_id[22];

//Decode the three types of Coprocessor Operations
assign mem_op_cid = (mmu_ir_id[27:25] == 3'h6) & cop15;
assign reg_op_cid = (mmu_ir_id[27:24] == 4'hE) &
                        (mmu_ir_id[4]) & cop15;
assign data_op_cid = (mmu_ir_id[27:24] == 4'hE) &
                        (~mmu_ir_id[4]) & cop15;

/* Modifying the coding of a SWIC, its now a Cop Store with N Set */
assign swic_cid = (mem_op_cid & N) & useMini;

/* Creating a Flush Instruction from Standard CDP */
assign flush_cid = (mem_op_cid & N) & ~useMini;

/* Creating a Move of Performance Counters */
assign move_perf = reg_op_cid & (mmu_ir_id[23:21] == 3'h7);

//Mux the 1st Operand Index  
always @(CRm_cid or Rd_cid or mem_op_cid or swic_cid)
  begin
    if (mem_op_cid)
      op2_index_cid = Rd_cid;
    else
      op2_index_cid = CRm_cid;
  end   

//Figure Out when to Interlock the Pipelie
//1) ARM is Interlocked
//2) Load-Use Interlock
assign load_use_op1 = (((mem_op_cid & ~mmu_ir_id[20]) 	| 
			reg_op_cid 			|
                        data_op_cid) 			&
        ((CRd_cex == op1_index_cid) & ~drive_DD_cex & mem_op_cex));

assign must_wait_cid = id_enbar | load_use_op1;


//Figure out how to drive CHSD
always @(reg_op_cid or mem_op_cid or data_op_cid or must_wait_cid)
  begin
    case({reg_op_cid,mem_op_cid,data_op_cid}) //synopsys full_case parallel_case
      3'b001: next_chsd = (must_wait_cid) ? 2'b00 : 2'b11;
      3'b010: next_chsd = (must_wait_cid) ? 2'b00 : 2'b11;   
      3'b100: next_chsd = (must_wait_cid) ? 2'b00 : 2'b11;   
      3'b000: next_chsd = 2'b10;
    endcase
  end 

//Probably don't need latch...just assign to next_chsd
//Latch the CHSD Signal
//synopsys async_set_reset "nRESET"
always @(nGCLK or next_chsd or nRESET or CHSD or nWAIT)
  begin
    if (~nRESET)
      CHSD <= #1 2'b10;
    else if (nGCLK)
      begin
        if (nWAIT)
//        CHSD <= #1 next_chsd;
          CHSD <= 2'b11;
	else
	  CHSD <= #1 CHSD;
      end
  end

//Mux out Operand 1
always @(op1_index_cid or CRd_cme or rf_op1 or res_to_wb or
		move_perf or perf_op1)
  begin
    if (move_perf)
      op1_cid = perf_op1;
    else if (op1_index_cid == CRd_cme)
      op1_cid = res_to_wb;
    else
      op1_cid = rf_op1;
  end

always @(rf_op2)
  begin
    op2_cid = rf_op2;
  end

/*------------------------------------------------------------------------
        MMU Ex Stage
------------------------------------------------------------------------*/
//Set up the Pipeline Status/Decode Bits
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      begin
        mem_op_cex <= 1'b0;
        reg_op_cex <= 1'b0;
        data_op_cex <= 1'b0;
        drive_DD_cex <= 1'b0;
	swic_cex <= 1'b0;
        flush_cex <= 1'b0;
	op1_cex <= 32'h00000000;
	op2_cex <= 32'h00000000;
	CRd_cex <= 4'h0;
	op1_index_cex <= 4'h0;
      end
    else if (nWAIT)
      begin
        if (~ex_enbar)
          begin
            mem_op_cex <= mem_op_cid;
            reg_op_cex <= reg_op_cid;
            data_op_cex <= data_op_cid;
            drive_DD_cex <= (mmu_ir_id[20] & reg_op_cid) |
	    		    (~mmu_ir_id[20] & mem_op_cid);
	    swic_cex <= swic_cid;
            flush_cex <= flush_cid;
	    op1_cex <= op1_cid;
	    op2_cex <= op2_cid;
	    CRd_cex <= (reg_op_cid) ? CRn_cid : Rd_cid;
	    op1_index_cex <= op1_index_cid;
          end
      end
  end

/* Cop Instructions Only Executed it PASS is High */
/* Use me_enbar so that incorrect instructions (wrong branch path) */
/* Dont get executed */

assign iswic = swic_cex & swicInD & PASS & ~me_enbar;
assign dswic = swic_cex & ~swicInD & PASS & ~me_enbar;
assign dflush = flush_cex & PASS & ~me_enbar;
assign swic_data = res_cex;
assign decomp = useMini;

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      load_use_cex <= 1'b0;
    else if (nWAIT)
      load_use_cex <= load_use_op1;
  end

//Determine the Result
always @(reg_op_cex or data_op_cex or drive_DD_cex or op1_cex or
                op1_index_cex or CRd_cme or res_to_wb or mem_op_cex or
                rfw_ena or data_op_cex or flush_cex)
  begin
    if ((reg_op_cex & drive_DD_cex) | (mem_op_cex & drive_DD_cex) | (data_op_cex))
      begin
        if ((op1_index_cex == CRd_cme) & rfw_ena & ~flush_cex)  //forward operand?
	  res_cex = res_to_wb;
        else
         res_cex = op1_cex;
      end
    else
      res_cex = 32'h00000000;
  end

//Figure out how to drive CHSD
assign must_wait_cex = id_enbar & ~load_use_cex;

always @(reg_op_cex or mem_op_cex or data_op_cex or must_wait_cex)
  begin
    case({reg_op_cex,mem_op_cex,data_op_cex}) //synopsys full_case parallel_case
      3'b001: next_chse = (must_wait_cex) ? 2'b00 : 2'b11;
      3'b010: next_chse = (must_wait_cex) ? 2'b00 : 2'b11;
      3'b100: next_chse = (must_wait_cex) ? 2'b00 : 2'b11;
      3'b000: next_chse = 2'b10;
    endcase
  end

//Probably don't need latch...just assign to next_chsd
//Latch the CHSE Signal
//synopsys async_set_reset "nRESET"
always @(nGCLK or next_chse or nRESET or nWAIT or CHSE)
  begin
    if (~nRESET)
      CHSE <= #1 2'b10;
    else if (nGCLK)
      begin
        if (nWAIT)
          CHSE <= #1 next_chse;
	else
	  CHSE <= CHSE;
      end
  end


/*------------------------------------------------------------------------
        MMU ME Stage     
------------------------------------------------------------------------*/
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      begin
        mem_op_cme <= 1'b0;
        reg_op_cme <= 1'b0;
        data_op_cme <= 1'b0;
        drive_DD_cme <= 1'b0;
	CRd_cme <= 4'h0;
      end
    else if (nWAIT)
      begin
        if (~me_enbar)
          begin
            mem_op_cme <= mem_op_cex & PASS;
            reg_op_cme <= reg_op_cex & PASS;
            data_op_cme <= data_op_cex & PASS;
            drive_DD_cme <= drive_DD_cex & PASS;
	    CRd_cme <= CRd_cex;
	  end
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      res_cme <= 32'h0;
    else if (nWAIT)
      res_cme <= res_cex;
  end

//Set up the DD data_bus
assign to_DD = res_cme;
assign DD = (drive_DD_cme) ? {32'h0,to_DD} : 64'hzzzzzzzzzzzzzzzz;

//Setup of the Result of ME Stage
always @(reg_op_cme or drive_DD_cme or DD or mem_op_cme or data_op_cme or
		res_cme)
  begin
    case({reg_op_cme,mem_op_cme,data_op_cme}) //synopsys full_case parallel_case
      3'b001: res_to_wb = res_cme;
      3'b010: res_to_wb = DD;
      3'b100: res_to_wb = DD;
      3'b000: res_to_wb = res_cme;
    endcase
  end

/*------------------------------------------------------------------------
        MMU WB Stage
------------------------------------------------------------------------*/
/*------------------------------------------------------------------------
        MMU Register File & Operand Access
------------------------------------------------------------------------*/
//Set up the ID Register
assign cr0 = 32'hED019ED0;

// Set up the Control Register
//	31:17	16	15:13	12:0
//Cr1 = O's	IDRRE	CBRRE's	IZFRSBLDPWCAM

//M= MMU Enable
//A= Alignment Fault Enable
//C= Data Cache Enable 
//W= Write Buffer Enable
//P= 32-Bit Exceptions (sb1)
//D= 32-Bit Addresses (sb1)
//L= --
//B= Big Endian=1/Little Endian=0
//S= System Protection
//R= ROM Protection
//F= --
//Z= --
//I= Instruction Cache Enable
//IDRRE - Instruction Decompression Routine Region enable
//	16 - Enable IDRR - cr5 (1=enabled)
//CBRRE's, Compression Boundary Region Register enables
//	15 - Enable CBRR2 - cr4 (1=enabled)
//	14 - Enable CBRR1 - cr3 (1=enabled)
//	13 - Enable CBRR0 - cr2 (1=enabled)

assign rfw_ena = ((reg_op_cme & ~drive_DD_cme) | 
		  (mem_op_cme & ~drive_DD_cme)) & ~LATECANCEL;

assign write_cr1 = rfw_ena && (CRd_cme == 4'h1);
assign BIGEND = cr1[7];
wire idrre = cr1[16];
wire cbrr2e = cr1[15];
wire cbrr1e = cr1[14];
wire cbrr0e = cr1[13];
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      cr1 <= 32'h0;
    else if (nWAIT)
      begin
        if (write_cr1)
          cr1 <= res_to_wb;
      end
  end

assign write_cr2 = rfw_ena & (CRd_cme == 4'h2);
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      cr2 <= 32'h0;
    else if (nWAIT)
      begin
        if (write_cr2)
          cr2 <= res_to_wb;
      end
  end

assign write_cr3 = rfw_ena & (CRd_cme == 4'h3);
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      cr3 <= 32'h0;
    else if (nWAIT)
      begin
        if (write_cr3)
          cr3 <= res_to_wb;
      end
  end

assign write_cr4 = rfw_ena & (CRd_cme == 4'h4);
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      cr4 <= 32'h0;
    else if (nWAIT)
      begin
        if (write_cr4)
          cr4 <= res_to_wb;
      end
  end

assign write_cr5 = rfw_ena & (CRd_cme == 4'h5);
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      cr5 <= 32'h0;
    else if (nWAIT)
      begin
        if (write_cr5)
          cr5 <= res_to_wb;
      end
  end

assign write_cr6 = rfw_ena & (CRd_cme == 4'h6);
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      cr6 <= 32'h0;
    else if (nWAIT)
      begin
        if (write_cr6)
          cr6 <= res_to_wb;
      end
  end

assign write_cr7 = rfw_ena & (CRd_cme == 4'h7);
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      cr7 <= 32'h0;
    else if (nWAIT)
      begin
        if (write_cr7)
          cr7 <= res_to_wb;
      end
  end

assign write_cr8 = rfw_ena & (CRd_cme == 4'h8);
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      cr8 <= 32'h0;
    else if (nWAIT)
      begin
        if (write_cr8)
          cr8 <= res_to_wb;
      end
  end

assign write_cr9 = rfw_ena & (CRd_cme == 4'h9);
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      cr9 <= 32'h0;
    else if (nWAIT)
      begin
        if (write_cr9)
          cr9 <= res_to_wb;
      end
  end

assign write_cr10 = rfw_ena & (CRd_cme == 4'ha);
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      cr10 <= 32'h0;
    else if (nWAIT)
      begin
        if (write_cr10)
          cr10 <= res_to_wb;
      end
  end

assign write_cr11 = rfw_ena & (CRd_cme == 4'hb);
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      cr11 <= 32'h0;
    else if (nWAIT)
      begin
        if (write_cr11)
          cr11 <= res_to_wb;
      end
  end

assign write_cr12 = rfw_ena & (CRd_cme == 4'hc);
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      cr12 <= 32'h0;
    else if (nWAIT)
      begin
        if (write_cr12) 
          cr12 <= res_to_wb;
      end   
  end

assign write_cr13 = rfw_ena & (CRd_cme == 4'hd);
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      cr13 <= 32'h0;
    else if (nWAIT)
      begin
        if (write_cr13)
          cr13 <= res_to_wb;
      end
  end

assign write_cr14 = rfw_ena & (CRd_cme == 4'he);
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      cr14 <= 32'h0;
    else if (nWAIT)
      begin
        if (DABORT)
          cr14 <= da;
      end
  end

assign write_cr15 = rfw_ena & (CRd_cme == 4'hf);
//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      cr15 <= 32'h0;
    else if (nWAIT)
      begin
        if (DABORT)
          cr15 <= da;
      end
  end

//Read the Proper Operands
always @(cr0 or cr1 or cr2 or cr3 or cr4 or cr5 or cr6 or cr7 or cr8 or
	 cr9 or cr10 or cr11 or cr12 or cr13 or cr14 or cr15 or 
	 op1_index_cid)
  begin
    case (op1_index_cid) //synopsys full_case parallel_case
      4'h0: rf_op1 = cr0;
      4'h1: rf_op1 = cr1;
      4'h2: rf_op1 = cr2;
      4'h3: rf_op1 = cr3;
      4'h4: rf_op1 = cr4;
      4'h5: rf_op1 = cr5;
      4'h6: rf_op1 = cr6;
      4'h7: rf_op1 = cr7;
      4'h8: rf_op1 = cr8;
      4'h9: rf_op1 = cr9;
      4'ha: rf_op1 = cr10;
      4'hb: rf_op1 = cr11;
      4'hc: rf_op1 = cr12;
      4'hd: rf_op1 = cr13;
      4'he: rf_op1 = cr14;
      4'hf: rf_op1 = cr15;
    endcase
  end

always @(op1_index_cid or inst_count or cyc_count or imiss_count
                or dmiss_count or iaccesses or daccesses or time_count or
		predicted or pcorrect or spec_iabort or spec_dabort)
  begin
    case (op1_index_cid) //synopsys full_case parallel_case
      4'h0: perf_op1 = inst_count;
      4'h1: perf_op1 = cyc_count;
      4'h2: perf_op1 = imiss_count;
      4'h3: perf_op1 = dmiss_count;
      4'h4: perf_op1 = iaccesses;
      4'h5: perf_op1 = daccesses;
      4'h6: perf_op1 = predicted;
      4'h7: perf_op1 = pcorrect;
      4'h8: perf_op1 = spec_iabort;
      4'h9: perf_op1 = spec_dabort;
      4'hA: perf_op1 = time_count;
   default: perf_op1 = inst_count;
    endcase
  end



always @(cr0 or cr1 or cr2 or cr3 or cr4 or cr5 or cr6 or cr7 or cr8 or
         cr9 or cr10 or cr11 or cr12 or cr13 or cr14 or cr15 or 
	 op2_index_cid)
begin
    case (op2_index_cid) //synopsys full_case parallel_case
      4'h0: rf_op2 = cr0;
      4'h1: rf_op2 = cr1;
      4'h2: rf_op2 = cr2;
      4'h3: rf_op2 = cr3;
      4'h4: rf_op2 = cr4;
      4'h5: rf_op2 = cr5;
      4'h6: rf_op2 = cr6;
      4'h7: rf_op2 = cr7;
      4'h8: rf_op2 = cr8;
      4'h9: rf_op2 = cr9;
      4'ha: rf_op2 = cr10;
      4'hb: rf_op2 = cr11;
      4'hc: rf_op2 = cr12;
      4'hd: rf_op2 = cr13;
      4'he: rf_op2 = cr14;
      4'hf: rf_op2 = cr15;
    endcase
  end

/*------------------------------------------------------------------*/
/* Instruction Decompression Trigger Circuitry                      */
/*------------------------------------------------------------------*/

//Latch the Address Bus
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      ia <= 26'h0;
    else if (nWAIT)
      begin
        if (~InMREQ)
          ia <= IA[31:6];
      end
  end

always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      da <= 32'h0;
    else if (nWAIT)
      begin
        if (~DnMREQ)
          da <= DA[31:0];
      end
  end

/* First Compare the Top 21 Bits */
wire	[31:11]	inst_xor0;	//Bitwise XOR of Top 21 Bits
wire	[31:11]	inst_xor1;	//Bitwise XOR of Top 21 Bits
wire	[31:11] inst_xor2;	//Bitwise XOR of Top 21 Bits
wire	[31:11] data_xor0;	//Bitwise XOR or Top 21 DA Bits
wire    [31:11] data_xor1;      //Bitwise XOR or Top 21 DA Bits
wire    [31:11] data_xor2;      //Bitwise XOR or Top 21 DA Bits
wire	[31:11]	cbrtag0;	//Tag of Region 0
wire	[31:11] cbrtag1;	//Tag of Region 1
wire	[31:11]	cbrtag2;	//Tag of Region 2
wire	[31:6]  idrtag;		//Tag of Inst Decomp Routine 
wire	[31:11] abus;		//Address From IA Bus
wire	[31:11] dbus;		//Address from DA Bus
wire	[31:6]  addr_xor3;	//Bitwise XOR of Top 26 Bits

assign cbrtag0 = cr2[31:11];
assign cbrtag1 = cr3[31:11];
assign cbrtag2 = cr4[31:11];
assign idrtag = cr5[31:6];
assign abus = ia[31:11];
assign dbus = da[31:11];
assign inst_xor0 = (abus ^ cbrtag0);
assign inst_xor1 = (abus ^ cbrtag1);
assign inst_xor2 = (abus ^ cbrtag2);
assign data_xor0 = (dbus ^ cbrtag0);
assign data_xor1 = (dbus ^ cbrtag1);
assign data_xor2 = (dbus ^ cbrtag2);
assign addr_xor3 = (ia ^ idrtag);

/* Also Must Create the Size Masks */
/* Sizes Range from 2kB - 64MB in by powers of 2. */
/* 2kB = 0000, 4kB = 0001, 8kB = 0010, ... 64MB = 1111 */
/* 2kB check IA[31:11], 4kB check IA[31:12] ... 64MB check IA[31:26] */
reg	[31:11]	mask0;		//0 the Bits Comparing
reg	[31:11] mask1;		//0 the Bits Comparing
reg	[31:11] mask2;		//0 the Bits Comparing
reg	[31:6]	mask3;		//0 the Bist Comparing
wire	[3:0]	size0;		//Size of Region 0;
wire	[3:0]	size1;		//Size of Region 1;
wire	[3:0]	size2;		//Size of Region 2;
wire	[1:0]	size3;		//Size of Inst Decomp Routine

/* Split of the Sizes from the CBRR's */
assign size0 = cr2[3:0];
assign size1 = cr3[3:0];
assign size2 = cr4[3:0];
assign size3 = cr5[1:0];

/* Set up the Rest of each Mask */
always @(size0)
  begin
    case (size0) //synopsys full_case parallel_case
      4'h0: mask0[31:11] = 21'h000000;
      4'h1: mask0[31:11] = 21'h000001;
      4'h2: mask0[31:11] = 21'h000003;
      4'h3: mask0[31:11] = 21'h000007;
      4'h4: mask0[31:11] = 21'h00000F;
      4'h5: mask0[31:11] = 21'h00001F;
      4'h6: mask0[31:11] = 21'h00003F;
      4'h7: mask0[31:11] = 21'h00007F;
      4'h8: mask0[31:11] = 21'h0000FF;
      4'h9: mask0[31:11] = 21'h0001FF;
      4'hA: mask0[31:11] = 21'h0003FF;
      4'hB: mask0[31:11] = 21'h0007FF;
      4'hC: mask0[31:11] = 21'h000FFF;
      4'hD: mask0[31:11] = 21'h001FFF;
      4'hE: mask0[31:11] = 21'h003FFF;
      4'hF: mask0[31:11] = 21'h007FFF;
    endcase
  end

always @(size1)
  begin
    case (size1) //synopsys full_case parallel_case
      4'h0: mask1[31:11] = 21'h0000;
      4'h1: mask1[31:11] = 21'h0001;
      4'h2: mask1[31:11] = 21'h0003;
      4'h3: mask1[31:11] = 21'h0007;
      4'h4: mask1[31:11] = 21'h000F;
      4'h5: mask1[31:11] = 21'h001F;
      4'h6: mask1[31:11] = 21'h003F;
      4'h7: mask1[31:11] = 21'h007F;
      4'h8: mask1[31:11] = 21'h00FF;
      4'h9: mask1[31:11] = 21'h01FF;
      4'hA: mask1[31:11] = 21'h03FF;
      4'hB: mask1[31:11] = 21'h07FF;
      4'hC: mask1[31:11] = 21'h0FFF;
      4'hD: mask1[31:11] = 21'h1FFF;
      4'hE: mask1[31:11] = 21'h3FFF;
      4'hF: mask1[31:11] = 21'h7FFF;
    endcase
  end

always @(size2)
  begin
    case (size2) //synopsys full_case parallel_case
      4'h0: mask2[31:11] = 21'h0000;
      4'h1: mask2[31:11] = 21'h0001;
      4'h2: mask2[31:11] = 21'h0003;
      4'h3: mask2[31:11] = 21'h0007;
      4'h4: mask2[31:11] = 21'h000F;
      4'h5: mask2[31:11] = 21'h001F;
      4'h6: mask2[31:11] = 21'h003F;
      4'h7: mask2[31:11] = 21'h007F;
      4'h8: mask2[31:11] = 21'h00FF;
      4'h9: mask2[31:11] = 21'h01FF;
      4'hA: mask2[31:11] = 21'h03FF;
      4'hB: mask2[31:11] = 21'h07FF;
      4'hC: mask2[31:11] = 21'h0FFF;
      4'hD: mask2[31:11] = 21'h1FFF;
      4'hE: mask2[31:11] = 21'h3FFF;
      4'hF: mask2[31:11] = 21'h7FFF;
    endcase
  end

always @(size3)
  begin
    case (size3) //synopsys full_case parallel_case
      2'h0: mask3[31:6] = 26'h0000000;
      2'h1: mask3[31:6] = 26'h0000001;
      2'h2: mask3[31:6] = 26'h0000003;
      2'h3: mask3[31:6] = 26'h0000007;
    endcase
  end

/* XOR the AND'd address with the Mask and Or it     */
/* When nHit goes Low, there is a match              */
/* A match indicates an address in Compressed Region */
wire nHit0, nHit1, nHit2, nHit3, nHit4, nHit5, nHit6;
assign nHit0 = | (~mask0 & inst_xor0);
assign nHit1 = | (~mask1 & inst_xor1);
assign nHit2 = | (~mask2 & inst_xor2);
assign nHit3 = | (~mask3 & addr_xor3);
assign nHit4 = | (~mask0 & data_xor0);
assign nHit5 = | (~mask1 & data_xor1);
assign nHit6 = | (~mask2 & data_xor2);

/* Generate the Instruction Abort Interrupt */
assign IABORT = ((~nHit0 & cbrr0e & imiss) | 
		 (~nHit1 & cbrr1e & imiss) |
		 (~nHit2 & cbrr2e & imiss));

always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      abort_id <= 1'b0;
    else if (nWAIT)
      begin
        if (~id_enbar)
          abort_id <= (IABORT | DABORT);  
      end
  end

always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      abort_ex <= 1'b0;
    else if (nWAIT)
      begin
	if (~ex_enbar)
          abort_ex <= abort_id | (abort_ex & (mode == 5'b10111));
      end
  end
           
always @(posedge nGCLK or negedge nRESET)  
  begin
    if (~nRESET)
      abort_me <= 1'b0;
    else if (nWAIT)
      begin
        if (~me_enbar)
          abort_me <= abort_ex;
      end
  end

assign DABORT = ((~nHit4 & cbrr0e & dmiss & ~abort_me) |
                 (~nHit5 & cbrr1e & dmiss & ~abort_me) |
                 (~nHit6 & cbrr2e & dmiss & ~abort_me));
  
/* Generate Non-Cacheable Signal */
assign useMini = ~nHit3 & idrre;

endmodule
