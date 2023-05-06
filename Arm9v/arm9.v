`timescale 1ns/10ps

/*****************************************************************************
$RCSfile: arm9.v,v $
$Revision: 1.13 $
$Author: kohlere $
$Date: 2000/05/04 16:31:09 $
$State: Exp $

Description: This is a behavioral, 5-stage Pipeline design of an ARM9
		micorprocessor. 

*****************************************************************************/

module arm9 (GCLK, nRESET, nWAIT, nFIQ, nIRQ, ISYNC, STOP,
		MMnWR, MMD_In, MMD_Out, MMA, MM_New_Line, MM_CE);

/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/

input 		GCLK;		//Clock Signal
input 		nRESET;		//Reset Signal
input		nFIQ;		//Fast Interrupt Request (active low)
input		nIRQ;		//Normal Interrupt Request (active low)
input		ISYNC;		//Synchronous nFIQ, nIRQ when low
input   [31:0]  MMD_In;         //Main Memory Input Bus

//inout [31:0]  MMD;            //Main Memory Data Bus

output  [31:0]  MMD_Out;        //Main Memory Output Bus
output	[31:0]	MMA;		//Main Memory Address Bus
output		MMnWR;		//Main Memory Not Write, Read
output		nWAIT;		//External Clock Enable
output          MM_CE;          //Main Memory Enable
output          MM_New_Line;    //Main Memory Start New Access
output		STOP;

/*------------------------------------------------------------------------
        Variable/Signal Declarations
------------------------------------------------------------------------*/
wire	[31:0]	inst_count;

reg     [63:0]  pre_data_bus;  
wire	[31:0]	rf_a;
wire	[31:0]	rf_b;
reg     [31:0]  addr_bus;   
reg     [31:0]  data_bus;   
reg	[1:0]	DMAS;

wire    [63:0]  data_bus_me;
wire	[95:0]	ID;
wire	[31:0]	inst_if;
wire	[31:0] 	IA;
wire	[31:0]	imiss_addr;
wire	[31:0]	dmiss_addr;
wire	[31:0]	write_a;
wire	[31:0]	write_b;
wire	[31:0]	pc_if;
wire	[31:0]	op1_id;
wire	[31:0]	op2_id;
wire	[31:0] 	aux_data_id;	
wire	[31:0]	ex_result;
wire	[31:0]	store_addr;
reg	[31:0]	addr_bus_me;
wire	[31:0]	me_result;
wire	[31:0]  addr_me;
wire	[31:0]  base_ex;	
wire	[31:0]  base_me;
wire	[31:0]	cop_data_ex;
wire	[31:0]	MMA;
wire	[31:0]	MMD;
wire	[31:0]	count;
wire	[31:0]	cyc_count;
wire	[31:0]	swic_data;
wire	[7:0]	shift_amount_id;
wire	[4:0]	mode;
wire	[4:0]	index_a;
wire	[4:0]	index_b;
wire	[4:0]	Rd_id;
wire	[4:0]	Rn_id;
wire	[4:0]	Rd_ex;
wire	[4:0]	Rn_ex;
wire	[4:0]	Rd_me;
wire	[4:0]	Rn_me;
wire	[4:0]	w_addr_a;
wire	[4:0]	w_addr_b;
wire    [3:0]   alu_opcode_id;
wire    [3:0]   condition_id; 
wire	[3:0]	inst_type_ex;
wire	[3:0]	inst_type_id;
wire	[3:0]	flags_ex;
wire	[2:0]	shift_type_id;
wire	[6:4]	ir_id;
wire	[1:0]	exc_code;
wire	[1:0]	CHSD, CHSE;
wire		PASS;
wire		LATECANCEL = 1'b0;
wire		IABORT;
wire		DABORT;
wire		nWAIT;
wire		MM_New_Line;
wire		MM_CE;
wire		InMREQ;
wire		DnMREQ;
wire		DnWR;
wire		iswic;
wire		dswic;
wire		dwb;
wire		dmiss;
wire		imiss;
wire		doublehold;
wire		fiq_disable;
wire		irq_disable;
wire		rfw_ena_a;
wire		newline;
wire		rfw_ena_b;
wire		second_id;
wire		second_nlu_id;
wire		need_2cycles_id;
wire		load_use_id;		
wire		useMini;
wire		load_pc_ex;
wire		cop_mem_ld;
wire		cop_mem_st;
wire		ldm_id;
wire		stm_id;
wire		mcr_ex;
wire		prediction_stall;
wire		ptaken_ex;
wire		finished_id;
wire		double_id;
wire		double_ex;
wire		double_me;
wire		exception_to_id;
wire		pc_touched;
wire		mispredicted_if;
wire		misp_rec;
wire		s;
wire		mul_first_id;
wire		second_ex;
wire		write_Rd_ex;
wire		write_Rn_ex;
wire		unsigned_byte_ex;
wire		signed_byte_ex;
wire		unsigned_hw_ex;
wire		signed_hw_ex;
wire		write_Rd_me;
wire		dc_init;
wire		ic_init;
wire		write_Rn_me;
wire		write_Rd_wb;
wire		write_Rn_wb;
wire		mem_rd_wr;
wire		mem_ena;
wire		ic_read_mmd;
wire		dc_read_mmd;
wire		drive_mmd;
wire		byte;
wire		halfword;
wire            if_enbar;
wire            id_enbar;
wire            ex_enbar; 
wire            me_enbar;   
wire            wb_enbar;
wire		cop_mem_id;
wire		cop_id;	
wire		cop_absent_int;
wire		pc_mod_ex;
wire		write_Pc_Rn_ex;
wire		write_Pc_Rd_ex;
wire		reset_write_Rd_me;
wire		reset_write_Rn_me;
wire		hold_next_ex;
wire		load_pc_me;
wire            inst_finished;
wire		istall;
reg		nreset;
wire		decomp;
wire		dflush;	
wire		pt;
wire		put;
wire		eval;
wire		stop_me;
wire		STOP = stop_me;

/*------------------------------------------------------------------------
        Component Instantiations
------------------------------------------------------------------------*/
//Latch the reset  signal in case its shorter than one cycle
always @(posedge GCLK or negedge nRESET)
  begin
    if (~nRESET)
      nreset <= 1'b0;
    else if (nWAIT)
      nreset <= nRESET;
  end

always @(double_me or halfword or byte)
  begin
	if (double_me)
	  DMAS = 2'h3;
	else if (halfword)
	  DMAS = 2'h1;
	else if (byte)
	  DMAS = 2'h0;
	else
	  DMAS = 2'h2;
  end

control xcontrol (.nGCLK(GCLK), .nWAIT(nWAIT),
		.nRESET(nreset), .DABORT(DABORT),
		.IABORT(IABORT), .nFIQ(nFIQ), .nIRQ(nIRQ),
                .ISYNC(ISYNC), .CHSD(CHSD), .CHSE(CHSE), .ID(ID), .IA(IA),
		.irq_disable(irq_disable), .fiq_disable(fiq_disable),
                .flags_ex(flags_ex), .load_pc_me(load_pc_me),
		.exception_to_id(exception_to_id), .pc_touched(pc_touched),
		.pc(pc_if), .inst_if(inst_if), .misp_rec(misp_rec),
                .mispredicted_if(mispredicted_if), .me_result(me_result),
		.base_me(base_me), .ex_result(ex_result),
                .Rd_ex(Rd_ex), .Rd_me(Rd_me), .InMREQ(InMREQ),
		.Rn_me(Rn_me), .hold_next_ex(hold_next_ex), 
                .load_pc_ex(load_pc_ex), .exc_code(exc_code),
		.newline(newline), .Rn_ex(Rn_ex), .ptaken_ex(ptaken_ex),
		.need_2cycles_id(need_2cycles_id), .pt(pt), .put(put),
                .second_id(second_id), .load_use_id(load_use_id),
		.ldm_id(ldm_id), .stm_id(stm_id), .if_enbar(if_enbar),
		.finished_id(finished_id), .id_enbar(id_enbar),
		.ex_enbar(ex_enbar), .pc_mod_ex(pc_mod_ex),
		.me_enbar(me_enbar), .wb_enbar(wb_enbar), .cop_id(cop_id),
                .cop_absent_int(cop_absent_int),
		.write_Pc_Rn_ex(write_Pc_Rn_ex),
		.write_Pc_Rd_ex(write_Pc_Rd_ex), .eval(eval),
                .reset_write_Rn_me(reset_write_Rn_me),
		.reset_write_Rd_me(reset_write_Rd_me));

/* Comment out first two for non-structural code. */
pipe	xpipe	(.nGCLK(GCLK), .nWAIT(nWAIT),
                .nRESET(nreset), .id_enbar(id_enbar), .ex_enbar(ex_enbar),
		.me_enbar(me_enbar), .inst_if(inst_if), .rf_a(rf_a),
		.rf_b(rf_b), .index_a(index_a), .index_b(index_b),
		.finished_id(finished_id), .second_id(second_id),
		.need_2cycles_id(need_2cycles_id), .exception_to_id(exception_to_id),
		.exc_code(exc_code), .hold_next_ex(hold_next_ex),
		.write_Pc_Rn_ex(write_Pc_Rn_ex), .DnWR(DnWR),
		.write_Pc_Rd_ex(write_Pc_Rd_ex), .DnMREQ(DnMREQ),
		.PASS(PASS), .ldm_id(ldm_id), .stm_id(stm_id),
		.load_use_id(load_use_id), .cop_id(cop_id),
		.pc_mod_ex(pc_mod_ex), .Rn_ex(Rn_ex), .Rd_ex(Rd_ex),
		.load_pc_ex(load_pc_ex), .store_addr(store_addr),
                .ex_result(ex_result), .stop_me(stop_me),
		.flags_ex(flags_ex), .Rn_me(Rn_me), .Rd_me(Rd_me), 
		.base_me(base_me), .me_result(me_result),
		.write_Rd_ex(write_Rd_ex), .load_pc_me(load_pc_me), 
		.data_bus(data_bus_me), .mode(mode),
		.reset_write_Rd_me(reset_write_Rd_me),
		.reset_write_Rn_me(reset_write_Rn_me),
		.double_me(double_me), .byte_me(byte),
		.halfword_me(halfword), .store_ex(store_ex),
		.pc_if(pc_if), .cop_absent_int(cop_absent_int),
                .mispredicted_if(mispredicted_if),
		.irq_disable(irq_disable),
		.fiq_disable(fiq_disable), .BIGEND(BIGEND),
		.write_Rd_me(write_Rd_me), .write_Rn_me(write_Rn_me));

wire wena_a = write_Rd_me & ~wb_enbar;
wire wena_b = write_Rn_me & ~wb_enbar;

//Comment Out First Line for Checker 
regfile xrf	(.nRESET(nreset),
                .nGCLK(GCLK), .pc_if(pc_if), .nWAIT(nWAIT),
		.index_a(index_a), .index_b(index_b), 
		.write_a(me_result), .write_b(base_me),
		.wena_a(wena_a), .wena_b(wena_b), .w_addr_a(Rd_me),
		.w_addr_b(Rn_me), .port_a(rf_a), .port_b(rf_b));

mmu	xmmu 	(.nRESET(nreset), .nWAIT(nWAIT), .CHSD(CHSD), .CHSE(CHSE),
		.id_enbar(id_enbar), .BIGEND(BIGEND), .inst_if(inst_if),
		.LATECANCEL(LATECANCEL), .PASS(PASS), .IABORT(IABORT),
		.DABORT(DABORT), .MMA(MMA), .MMnWR(MMnWR),
		.nGCLK(GCLK), .dwb(dwb), .drive_mmd(drive_mmd),
		.ex_enbar(ex_enbar), .imiss(imiss), .dmiss(dmiss),
		.imiss_addr(imiss_addr), .dmiss_addr(dmiss_addr),
		.ic_read_mmd(ic_read_mmd), .dc_read_mmd(dc_read_mmd),
		.DD(data_bus_me), .doublehold(doublehold), .IA(IA),
		.InMREQ(InMREQ), .useMini(useMini), .iswic(iswic),
		.swic_data(swic_data), .dswic(dswic), .me_enbar(me_enbar),
		.dc_init(dc_init), .ic_init(ic_init), .istall(istall),
		.DA(store_addr), .DnMREQ(DnMREQ), .mode(mode), .dflush(dflush),
                .MM_CE(MM_CE), .MM_New_Line(MM_New_Line), .decomp(decomp),
		.mispredicted(mispredicted_if), .misp_rec(misp_rec),
                .pc_touched(pc_touched), .hold_next_ex(hold_next_ex),
                .ptaken_ex(ptaken_ex), .pt(pt), .put(put), .eval(eval),
                .if_enbar(if_enbar), .stop_me(stop_me));

icache	xicache1 (.nGCLK(GCLK), .nRESET(nreset), .IA(IA), .DABORT(DABORT),
		  .ID(ID), .imiss(imiss), .InMREQ(InMREQ | ~nreset), 
		  .MMD(MMD), .imiss_addr(imiss_addr),
		  .mmd_valid(ic_read_mmd), .newline(newline),
		  .dmiss(dmiss), .doublehold(doublehold),
		  .IABORT(IABORT), .useMini(useMini),
		  .swic(iswic), .swic_data(swic_data), 
		  .swic_addr(store_addr[31:2]), .initializing(ic_init));
//modified the swic_addr from swic_addr to DA...now address coming from ARM

dcache  xdcache1 (.nGCLK(GCLK), .nRESET(nreset), .DA(store_addr),
                  .DD(data_bus_me), .dmiss(dmiss), .DnMREQ(DnMREQ),
                  .MMD(MMD), .dmiss_addr(dmiss_addr), .DMAS(DMAS),
                  .mmd_valid(dc_read_mmd), .dwb(dwb), .DABORT(DABORT),
		  .drive_mmd(drive_mmd), .DnWR(DnWR), .decomp(decomp),
		  .BIGEND(BIGEND), .istall(istall), .swic(dswic),
		  .swic_data(swic_data),
		  .doublehold(doublehold), .initializing(dc_init),
		  .flush(dflush));

assign MMD = (MMnWR) ? MMD_In : 32'hzzzzzzzz;
assign MMD_Out = (~MMnWR) ? MMD : 32'h00000000;

endmodule
