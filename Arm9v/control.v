`timescale 1ns/10ps
module control(nGCLK, nWAIT,
		nRESET, DABORT, IABORT, nFIQ, nIRQ,
		ISYNC, CHSD, CHSE, ID, IA, irq_disable, fiq_disable,
		flags_ex, load_pc_me, exception_to_id,  
		pc, inst_if, mispredicted_if, me_result, base_me, ex_result,
		Rd_ex, Rd_me, InMREQ, Rn_me, hold_next_ex, 
		load_pc_ex, exc_code, newline, Rn_ex, need_2cycles_id,
		second_id, load_use_id, ldm_id, stm_id, finished_id,
		id_enbar, ex_enbar, pc_mod_ex, me_enbar, wb_enbar, cop_id,
		cop_absent_int, write_Pc_Rn_ex, write_Pc_Rd_ex,
		reset_write_Rn_me, reset_write_Rd_me, eval, pt, put, ptaken_ex,
		misp_rec, pc_touched, if_enbar);

input		nGCLK;
input		nWAIT;
input		nRESET;
input		DABORT;
input 		IABORT;
input		nFIQ;
input		nIRQ;
input		ISYNC;
input	[1:0]	CHSD;
input	[1:0]	CHSE;
input	[95:0]	ID;
input		irq_disable;
input		fiq_disable;
input	[3:0]	flags_ex;
input		load_pc_me;
input		load_pc_ex;
input	[31:0]	base_me;
input	[31:0]	me_result;
input	[31:0]	ex_result;
input	[4:0]	Rd_me;
input	[4:0]	Rn_me;
input	[4:0]	Rd_ex;
input	[4:0]	Rn_ex;
input		hold_next_ex;
input		need_2cycles_id;
input		second_id;
input		load_use_id;
input		ldm_id;
input		stm_id;
input		finished_id;
input		pc_mod_ex;
input		cop_id;
input		write_Pc_Rn_ex;
input		write_Pc_Rd_ex;

output	[31:0]	IA;
output	[31:0]	pc;
output	[31:0]	inst_if;
output		exception_to_id;
output	[1:0]	exc_code;
output		newline;
output		mispredicted_if;
output		InMREQ;
output		if_enbar;
output		id_enbar;
output		ex_enbar;
output		me_enbar;
output		wb_enbar;
output		cop_absent_int;
output		reset_write_Rn_me;
output		reset_write_Rd_me;
output		eval;
output		pt;
output		put;
output		ptaken_ex;
output		misp_rec;
output		pc_touched;

/* Synchronize the Interrupts if Necessary */
reg s_nFIQ, s_nFIQ_0, s_nFIQ_1;
reg s_nIRQ, s_nIRQ_0, s_nIRQ_1;
reg dabort_taken, iabort_taken;
wire dabort, iabort;
        
always @(posedge nGCLK)
  begin
    if (nWAIT)
      begin
        dabort_taken <= DABORT;
        iabort_taken <= IABORT && (exc_code == 2'h3) && exception_to_id;
        s_nFIQ_1 <= (nFIQ | fiq_disable);
        s_nIRQ_1 <= (nIRQ | irq_disable);
        s_nFIQ_0 <= s_nFIQ_1;
        s_nIRQ_0 <= s_nIRQ_1;
        s_nFIQ <= ISYNC ? (nFIQ | fiq_disable) : (s_nFIQ_0);
        s_nIRQ <= ISYNC ? (nIRQ | irq_disable) : (s_nIRQ_0);
      end
  end

assign iabort = IABORT & !iabort_taken;
assign dabort = DABORT & !dabort_taken;

wire 		if_enbar;
wire		id_enbar;
wire		ex_enbar;
wire		me_enbar;
wire		wb_enbar;
wire	[31:0]	pc;
wire	[31:0]	inst_if;
wire	[2:0]	fill_state;
wire		mispredicted_if;
wire	[31:0]	IA;
wire		pt;
wire		put;
wire		prediction_stall;
wire		exception_to_id;
wire	[1:0]	exc_code;
wire		misp_rec;
wire		InMREQ;
wire		newline;
wire		eval;
wire		pc_touched;
wire		cop_absent_int;
wire		reset_write_Rd_me;
wire		reset_write_Rn_me;
wire		ptaken_ex;

ifetch  xifetch (.nGCLK(nGCLK), .nWAIT(nWAIT),
                .nRESET(nRESET), .if_enbar(if_enbar),
                .pc(pc), .inst_bus(ID), .flags(flags_ex),
                .inst_if(inst_if), .fill_state(fill_state),
                .mispredicted(mispredicted_if), .inst_addr(IA),
                .pt(pt), .put(put), .prediction_stall(prediction_stall),
                .Rn_me(Rn_me), .Rd_me(Rd_me), .load_pc_ex(load_pc_ex),
                .write_Rd_ex(write_Pc_Rd_ex), .me_result(me_result),
                .base_me(base_me), .hold_next_ex(hold_next_ex),
                .load_pc(load_pc_me), .dabort(dabort), .iabort(iabort),
                .s_nFIQ(s_nFIQ), .s_nIRQ(s_nIRQ), 
		.exception_to_id(exception_to_id),
                .exc_code(exc_code), .Rd_ex(Rd_ex), .ex_result(ex_result),
                .misp_rec(misp_rec), .InMREQ(InMREQ), .newline(newline),
                .eval(eval), .pc_touched(pc_touched));

interlock xinterlock (.nGCLK(nGCLK), .nRESET(nRESET), .nWAIT(nWAIT),
                .need_2cycles(need_2cycles_id),
		.hold_next_ex(hold_next_ex),
                .second(second_id), .if_enbar(if_enbar),
		.load_pc(load_pc_me), .finished(finished_id),
		.fill_state(fill_state), .id_enbar(id_enbar),
		.ldm(ldm_id), .stm(stm_id), 
                .ex_enbar(ex_enbar), .me_enbar(me_enbar),
                .load_use(load_use_id), .wb_enbar(wb_enbar),
                .mispredicted(mispredicted_if), .cop_id(cop_id),
                .CHSD(CHSD), .CHSE(CHSE), .cop_absent(cop_absent_int),
                .pc_mod_ex(pc_mod_ex), .Rn_ex(Rn_ex), .Rd_ex(Rd_ex),
                .write_Pc_Rn_ex(write_Pc_Rn_ex),
                .write_Pc_Rd_ex(write_Pc_Rd_ex),
                .reset_write_Rd_me(reset_write_Rd_me), .dabort(dabort),
                .reset_write_Rn_me(reset_write_Rn_me),
		.misp_rec(misp_rec), .prediction_stall(prediction_stall),
                .load_pc_ex(load_pc_ex), .ptaken_ex(ptaken_ex));

endmodule
