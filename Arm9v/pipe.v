`timescale 1ns/10ps
module pipe (nGCLK, nWAIT, 
		nRESET, id_enbar, ex_enbar, me_enbar, inst_if, rf_a, rf_b,
		index_a, index_b, finished_id, second_id, need_2cycles_id,
		exception_to_id, exc_code, hold_next_ex, write_Pc_Rn_ex,
		write_Pc_Rd_ex, DnMREQ, PASS, ldm_id, stm_id, load_use_id,
		cop_id, pc_mod_ex, Rn_ex, Rd_ex, load_pc_ex, store_addr,
		mode, ex_result, flags_ex, Rn_me, Rd_me, base_me,
		me_result, write_Rd_ex, load_pc_me, data_bus,
	        reset_write_Rd_me, reset_write_Rn_me, double_me,
		byte_me, halfword_me, store_ex, pc_if, cop_absent_int,
		mispredicted_if, irq_disable, fiq_disable, BIGEND,
		write_Rd_me, write_Rn_me, DnWR, stop_me);

input 		nGCLK;
input		nWAIT;
input		nRESET;
input		id_enbar;
input		ex_enbar;
input		me_enbar;
input	[31:0]	pc_if;
input	[31:0]	inst_if;
input	[31:0]	rf_a;
input	[31:0]	rf_b;
input		exception_to_id;
input	[1:0]	exc_code;
input		reset_write_Rd_me;
input		reset_write_Rn_me;
input		cop_absent_int;
input		mispredicted_if;
input		BIGEND;

inout	[63:0]	data_bus;

output	[4:0]	index_a;
output	[4:0]	index_b;
output	[4:0]	mode;
output		finished_id;
output		second_id;
output		need_2cycles_id;
output		hold_next_ex;
output		write_Pc_Rn_ex;
output		write_Pc_Rd_ex;
output		DnMREQ;
output		DnWR;
output		PASS;
output		ldm_id;
output		stm_id;
output		load_use_id;
output		cop_id;
output		pc_mod_ex;
output	[4:0]	Rn_ex;
output	[4:0]	Rd_ex;
output		load_pc_ex;
output	[31:0]	store_addr;
output	[31:0]	ex_result;
output	[3:0]	flags_ex;
output	[4:0]	Rn_me;
output	[4:0]	Rd_me;
output	[31:0]	base_me;
output	[31:0]	me_result;
output		load_pc_me;
output		write_Rd_ex;
output		double_me;
output		byte_me;
output		halfword_me;
output		store_ex;
output		irq_disable;
output		fiq_disable;
output		write_Rd_me;
output		write_Rn_me;
output		stop_me;

wire    [63:0]  data_bus;
wire    [31:0]  op1_id; 
wire    [31:0]  op2_id;
wire    [31:0]  aux_data_id;
wire    [31:0]  ex_result;
wire    [31:0]  store_addr;
wire    [31:0]  me_result;
wire    [31:0]  base_ex;   
wire    [31:0]  base_me;
wire	[31:0]	addr_me;
wire    [7:0]   shift_amount_id;
wire    [4:0]   mode_ex;
wire	[4:0]   mode=mode_ex;
wire    [4:0]   index_a;
wire    [4:0]   index_b;
wire    [4:0]   Rd_id;  
wire    [4:0]   Rn_id; 
wire    [4:0]   Rd_ex;
wire    [4:0]   Rn_ex;
wire    [4:0]   Rd_me;
wire    [4:0]   Rn_me;
wire    [3:0]   alu_opcode_id;
wire    [3:0]   condition_id;
wire    [3:0]   inst_type_ex;
wire    [3:0]   inst_type_id;
wire    [3:0]   flags_ex;
wire    [2:0]   shift_type_id;
wire    [6:4]   ir_id;
wire    [1:0]   exc_code;
wire	[1:0]	exc_code_id;
wire            PASS;
wire            DnMREQ; 
wire		DnWR;
wire		exception;
wire            second_id;
wire            second_nlu_id;
wire            need_2cycles_id;
wire            load_use_id;
wire            load_pc_ex;
wire            cop_mem_ld;
wire            cop_mem_st;
wire            ldm_id;
wire            stm_id;
wire		stop_id;
wire		stop_ex;
wire		stop_me;
wire            mcr_ex;
wire            finished_id;
wire            double_id; 
wire            double_ex;
wire            double_me;
wire            s_id;
wire            mul_first_id;
wire            second_ex;
wire            write_Rd_ex;
wire            write_Rn_ex;
wire            unsigned_byte_ex;
wire            signed_byte_ex;
wire            unsigned_hw_ex;
wire            signed_hw_ex;
wire            write_Rd_me;
wire            write_Rn_me;
wire            mem_rd_wr;
wire            mem_ena;
wire            cop_mem_id;
wire            cop_id;
wire            pc_mod_ex;
wire            write_Pc_Rn_ex;
wire            write_Pc_Rd_ex;
wire            hold_next_ex;
wire            load_pc_me;
wire		irq_disable;
wire		fiq_disable;
wire		exception_id;

id xid ( .nGCLK(nGCLK), .nWAIT(nWAIT), .nRESET(nRESET), .id_enbar(id_enbar),
.inst(inst_if), .rf_a(rf_a), .rf_b(rf_b), .write_Rd_ex(write_Rd_ex),
.Rd_ex(Rd_ex), .write_Rn_ex(write_Rn_ex), .Rn_ex(Rn_ex),
.write_Rn_me(write_Rn_me), .Rn_me(Rn_me), .ex_result(ex_result),
.me_result(me_result), .base_ex(base_ex), .base_me(base_me),
.Rd_me(Rd_me), .write_Rd_me(write_Rd_me), .mode(mode_ex), .index_a(index_a),
.index_b(index_b), .op1(op1_id), .op2(op2_id), .alu_opcode(alu_opcode_id), 
.ldm(ldm_id), .stm(stm_id), .condition(condition_id),
.shift_amount(shift_amount_id), .shift_type(shift_type_id), .ir_id(ir_id),
.finished(finished_id), .second(second_id), .stop_id(stop_id),
.need_2cycles(need_2cycles_id), .exception_id(exception_id), .exc_code_id(exc_code_id),
.Rd_id(Rd_id), .Rn_id(Rn_id), .aux_data_id(aux_data_id),
.inst_type_id(inst_type_id), .s(s_id), .load_use(load_use_id),
.second_nlu(second_nlu_id), .mul_first(mul_first_id), .cop_id(cop_id),
.double_id(double_id), .cop_mem_id(cop_mem_id),
.hold_next_ex(hold_next_ex), .pc_if(pc_if), .cop_absent(cop_absent_int),
.exception(exception_to_id), .exc_code(exc_code));

/* Comment out 1st for Checker */
ex xex (	.nRESET(nRESET),
                .nGCLK(nGCLK), .nWAIT(nWAIT),
                .ex_enbar(ex_enbar),
                .op1_in(op1_id), .op2_in(op2_id), .pc_mod_ex(pc_mod_ex),
                .alu_opcode_in(alu_opcode_id), .double_me(double_me),
                .mul_first_id(mul_first_id), .double_id(double_id),
                .condition_in(condition_id), .aux_data_id(aux_data_id),
                .shift_amount_in(shift_amount_id), .cpsr_flags(flags_ex),
                .shift_type_in(shift_type_id), .Rd_id(Rd_id),
                .Rn_id(Rn_id), .id_second(second_nlu_id),
                .inst_type_in(inst_type_id), .s_id(s_id), .ir_id(ir_id),
                .ex_result(ex_result), .store_addr(store_addr),
                .Rd_ex(Rd_ex), .DnWR(DnWR), .stop_id(stop_id),
                .Rn_ex(Rn_ex), .second_ex(second_ex), .mode(mode_ex),
                .inst_type_ex(inst_type_ex), .write_Rd_ex(write_Rd_ex),
                .write_Rn_ex(write_Rn_ex), .stop_ex(stop_ex),
		.need_2cycles_id(need_2cycles_id),
                .unsigned_byte_ex(unsigned_byte_ex), .store_ex(store_ex),
                .signed_byte_ex(signed_byte_ex), .addr_me(addr_me),
                .unsigned_hw_ex(unsigned_hw_ex), .double_ex(double_ex),
                .signed_hw_ex(signed_hw_ex), .base_ex(base_ex),
                .cop_mem_id(cop_mem_id), .PASS(PASS),
                .mcr_ex(mcr_ex), .load_use_id(load_use_id),
                .hold_next_ex(hold_next_ex), .cop_mem_ld(cop_mem_ld),
                .mispredicted(mispredicted_if), .fiq_disable(fiq_disable),
                .irq_disable(irq_disable), .exception(exception_id),
                .exc_code(exc_code_id), .load_pc_ex(load_pc_ex),
                .cop_mem_st(cop_mem_st), .DnMREQ(DnMREQ),
                .write_Pc_Rn(write_Pc_Rn_ex),
                .write_Pc_Rd(write_Pc_Rd_ex));

me      xme     (.nGCLK(nGCLK), .nWAIT(nWAIT), .nRESET(nRESET),
		.me_enbar(me_enbar),
                .store_addr(store_addr), .ex_result(ex_result),
                .inst_type_ex(inst_type_ex), .Rd_ex(Rd_ex), .Rn_ex(Rn_ex),
                .write_Rd_ex(write_Rd_ex), .write_Rn_ex(write_Rn_ex),
                .second_ex(second_ex),
                .unsigned_byte_ex(unsigned_byte_ex), .base_ex(base_ex), 
                .signed_byte_ex(signed_byte_ex), .double_ex(double_ex),
                .unsigned_hw_ex(unsigned_hw_ex), .BIGEND(BIGEND),  
                .signed_hw_ex(signed_hw_ex),  
                .data_bus(data_bus), .mem_rd_wr(mem_rd_wr),
                .double_me(double_me), .halfword(halfword_me),
		.byte(byte_me), .stop_ex(stop_ex), .stop_me(stop_me),
                .me_result(me_result), .Rd_me(Rd_me), .base_me(base_me),
                .Rn_me(Rn_me), .write_Rd_me(write_Rd_me),
		.mem_ena(mem_ena),
                .addr_me(addr_me), .write_Rn_me(write_Rn_me),  
                .load_pc(load_pc_me), .mcr_ex(mcr_ex),
                .reset_write_Rd_me(reset_write_Rd_me),
                .reset_write_Rn_me(reset_write_Rn_me),
                .store_ex(store_ex), .cop_mem_st(cop_mem_st),
                .cop_mem_ld(cop_mem_ld));

endmodule

