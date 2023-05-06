// ARM Datapath Module
// Instantiates all other modules, to be used with ARM Controller
// Deanna Perry
// 4/3/00
// Updated by Matt Crum on 4/6/00 -- cleaned up parameter list and wire 
//                                   connections
// Updated by Amit Pandey 4/20/00 -- fixed the sign extender module
// Updated by Amit Pandey 4/30/00 -- added muxPreMar before ALU_Hold 
//                                   register to select A_Bus or Alu_result 
// Updated by J. Shin 8/30/00     -- removed memory from datapath

`timescale 1ns/100ps
`include "defines.v"
`include "accessories.v"
`include "sign_extend.v"
`include "shift_maker.v"
`include "barrel.v"
`include "booth.v"
`include "alu.v"
`include "wd_reg.v"
`include "addr_reg.v"
`include "regfile.v"
`include "SuperCPSR.v"
//`include "MemoryInterface.v"

module armdatapath(A_Addr_Sel,B_Addr_Sel,RF_Addr_Write_Sel,RF_Bus_Write_Sel,RF_PC_Write_Sel,
		   RF_Load_Write,RF_Load_Flags,RF_PSR_R_Sel,RF_PSR_W_Sel,RF_PSR_Read,
		   SC_Type,SC_Source,SZE_Sel,SZE_Ctrl,SAM_Ctrl,BS_Input_Sel,BS_Enable,BS_Cin,
		   AR_Bus_ALU_Sel,AR_Bus_Sel,WD_DBE,WD_Load,nOPC,nCPI,CPA,CPB,
		   ALU_A_Sel,Alu_Cntrl,Multiplier_Enable,Multiplier_Ready,ir2_bus,ir2_mult_bus,
		   ir1_zero,ir2_zero,ld_ir2_mult,nSTALL,BBus_Src,sysclk,nRESET,
		   nFIQ,nIRQ,ALU_Hold_Enable,ALU_Hold_Sel,Link_Sel,A_MAR,D);

// Input/Output declarations by module
   output [31:0] A_MAR;
   inout [31:0] D; 
   wire [31:0] 	 A_MAR; 
   wire [31:0] 	 D; 
   // Register File
   input 	 RF_Load_Write,RF_Load_Flags,B_Addr_Sel,RF_PSR_R_Sel,RF_PSR_W_Sel;
   input [1:0] 	 A_Addr_Sel;
   input [2:0]   RF_Bus_Write_Sel, RF_Addr_Write_Sel;
   input [3:0] 	 RF_PC_Write_Sel;
   input [4:0] 	 SC_Type;
   input [3:0] 	 SC_Source;
   output [31:0] RF_PSR_Read;

   wire          RF_Load_Write,RF_Load_Flags,B_Addr_Sel,RF_PSR_R_Sel,RF_PSR_W_Sel;
   wire [1:0]    A_Addr_Sel;
   wire [2:0]    RF_Addr_Write_Sel, RF_Bus_Write_Sel;
   wire [3:0]    RF_PC_Write_Sel;
   wire [4:0] 	 SC_Type;
   wire [3:0] 	 SC_Source;
   wire [31:0]    RF_PSR_Read;   

   wire [3:0] 	 RF_Addr_A,RF_Addr_B,RF_Addr_C,RF_Addr_Write; // internal connection
   wire [31:0]   RF_Bus_Write,RF_PC_Write; // internal connection
   wire [31:0]   A_Out,Reg_B_Out,B_Bus,C_Out,RF_PC_Read; // internal connection
   wire [31:0]   RF_PC_Minus4;
   wire [10:0] 	 RF_Flags_Write; // internal connection
   
   // Barrel Shifter
   input 	 BS_Enable,BS_Cin,SZE_Ctrl,BS_Input_Sel;
   input [1:0] 	 SZE_Sel,SAM_Ctrl;

   wire 	 BS_Enable,BS_Cin,SZE_Ctrl,BS_Input_Sel;
   wire [1:0] 	 SZE_Sel,SAM_Ctrl;
   
   wire [31:0] 	 BS_Input,SZE_Out,BS_Shift_Output; // internal connection
   wire [1:0]    BS_Shift_Type; // internal connection
   wire [4:0]    BS_Shift_Amt; // internal connection
   wire 	 BS_Cout; // internal connection
   
   // Address Register
   input [1:0]	 AR_Bus_Sel;
   input [1:0]   AR_Bus_ALU_Sel;
   input	 ALU_Hold_Enable;
   input 	 ALU_Hold_Sel;
   input 	 Link_Sel;

   

   wire  [1:0]	 AR_Bus_Sel;
   wire  [1:0]   AR_Bus_ALU_Sel;
   wire          ALU_Hold_Enable;
   wire		 ALU_Hold_Sel;
   wire		 Link_Sel;
  
   wire [31:0]   Alu_Hold_In; 
   

   //internal connection////////////////////////////////////////////////////////////// 
   wire [31:0] 	 AR_Bus_ALU,AR_Bus_PC,AR_Bus_PC_4,ALU_Hold; // internal connection
   //wire [31:0] 	 A_MAR; // internal connection
   //wire [31:0] 	 D; // internal connection
   wire 	 CPBOUNCEE; // internal connection
   wire [31:0] 	 ALU_A,ALU_Result; // internal connection
   wire          ALU_C; // internal connection
   wire [3:0] 	 ALU_Signals; // internal connection
   wire [31:0] 	 Multiplier_Result; // internal connection
   wire [31:0] 	 Multiplier_A,Multiplier_B; // internal connection
   wire [31:0]   bmuxin, ir1in; // internal connection
   wire          ir2_mult_zero; // internal connection
   ///////////////////////////////////////////////////////////////////////////////////
   
   // Write Data Register
   input 	 WD_DBE;
   input         WD_Load;

   wire 	 WD_DBE;
   wire          WD_Load;
   
   //wire [31:0] 	 D; // internal connection
 
   //Coprocessor
   input 	 CPA,CPB;
   output 	 nOPC,nCPI;
   
   wire 	 CPA,CPB;
   wire 	 nOPC,nCPI;
   //wire 	 CPBOUNCEE; // internal connection
   
   //Memory Interface
   //input 	 nMREQ,nRW;
   //input [1:0] 	 MAS;
   //output	 nWAIT;

   //wire 	 nMREQ,nRW;
   //wire [1:0] 	 MAS;
   //wire          nWAIT;   

   //ALU
   input  [1:0]	 ALU_A_Sel;
   input [4:0]  Alu_Cntrl;

   wire   [1:0]	 ALU_A_Sel;
   wire [4:0] 	 Alu_Cntrl;
   
   //wire [31:0] 	 ALU_A,ALU_Result; // internal connection
   //wire          ALU_C; // internal connection
   //wire [3:0] 	 ALU_Signals; // internal connection
   
   //Multiplier
   input 	 Multiplier_Enable;
   output 	 Multiplier_Ready;

   wire 	 Multiplier_Enable; 
   wire 	 Multiplier_Ready;

   //wire [31:0] 	 Multiplier_Result; // internal connection
   //wire [31:0] 	 Multiplier_A,Multiplier_B; // internal connection
   
   // Instruction Registers
   input 	 ir1_zero,ir2_zero,ld_ir2_mult;
   output [31:0] ir2_bus,ir2_mult_bus;

   wire 	 ir1_zero,ir2_zero,ld_ir2_mult;
   wire [31:0]   ir2_bus,ir2_mult_bus;

   wire [31:0]    ir1; // internal connection
   //wire [31:0]   bmuxin, ir1in; // internal connection
   //wire          ir2_mult_zero; // internal connection
  
   //General stuff
   input 	 sysclk;
   input 	 BBus_Src;
   input 	 nSTALL;
   input	 nRESET;
   input         nFIQ;
   input         nIRQ;
   
   wire 	 sysclk;
   wire 	 BBus_Src;
   wire 	 nSTALL;
   wire          nRESET;
   wire          nFIQ;
   wire          nIRQ;
   wire [31:0] 	 Link_Addr;  // specially offset pc value for BL
   

   // Barrel Shifter
   sign_extend se1(ir2_bus[11:0], ir2_mult_bus[7:0], ir2_bus[7:0],ir2_bus[23:0], SZE_Sel, SZE_Ctrl, SZE_Out);
   mux2 muxbs(B_Bus, SZE_Out, BS_Input_Sel, BS_Input);
   shift_maker sam1(ir2_bus, C_Out, SAM_Ctrl, BS_Shift_Amt, BS_Shift_Type);
   Barrel_Shifter bs1(BS_Enable, BS_Input, BS_Shift_Type, BS_Shift_Amt, BS_Cin, BS_Shift_Output, BS_Cout);

   // Multiplier
   Booth_multiplier mult1(Multiplier_Enable, A_Out, C_Out, Multiplier_Result, Multiplier_Ready, sysclk);

   // ALU
   mux4 muxalu(Multiplier_Result, A_Out, RF_PC_Read, C_Out, ALU_A_Sel, ALU_A);

`ifdef BUG2
   ALU_ARM7 alu1 (ALU_A, BS_Shift_Output, ALU_C, Alu_Cntrl, ALU_Signals, 
                  ALU_Result);
`else
   ALU_ARM7 alu1 (ALU_A, BS_Shift_Output, RF_PSR_Read[29], Alu_Cntrl, ALU_Signals, 
                  ALU_Result);
`endif

   // MMU
   //MemoryInterface mmu1(D, A_MAR, nMREQ, nRW, MAS, nWAIT, sysclk, nRESET);

   // WDR
   wd_reg wdr1(B_Bus, WD_DBE, WD_Load, D, sysclk);

   // FPU 
//   FPU fpu1(nOPC, nCPI, !nSTALL, D, CPA, CPB, CPBOUNCEE, sysclk, nRESET);

   // MAR
   plain_register alu_reg(sysclk, Alu_Hold_In, ALU_Hold, ALU_Hold_Enable);
   mux4 muxmar(ALU_Result, A_Out, ALU_Hold, 32'hzzzz, AR_Bus_ALU_Sel, AR_Bus_ALU);
   mux2 muxPreMar(ALU_Result, A_Out, ALU_Hold_Sel,Alu_Hold_In);

   //mux2 muxmar(ALU_Result, A_Out, AR_Bus_ALU_Sel, AR_Bus_ALU);
   addr_reg mar1(AR_Bus_ALU, RF_PC_Read, AR_Bus_PC_4, AR_Bus_Sel, A_MAR, sysclk);
   add4 add41(RF_PC_Read, AR_Bus_PC_4);
   sub4 sub41(RF_PC_Read, RF_PC_Minus4); 
   mux2 Link_mux (RF_PC_Minus4, RF_PC_Read, Link_Sel, Link_Addr);

   // RF
   mux84 muxaws(ir2_bus[19:16], ir2_mult_bus[19:16], ir2_bus[15:12], ir2_mult_bus[15:12], 4'b1110, 4'bzzzz, 4'bzzzz, 4'bzzzz, RF_Addr_Write_Sel, RF_Addr_Write);

   mux8 muxwbs(A_MAR, RF_PC_Read, ALU_Result, AR_Bus_PC_4, D,RF_PSR_Read,
               Link_Addr, 32'hzzzz, RF_Bus_Write_Sel, RF_Bus_Write);
   mux16 muxpcws(32'h0000, 32'h0004, 32'h0008, 32'h000C, 32'h001C, 32'h0018, RF_PC_Read, ALU_Result, AR_Bus_PC_4, 32'hzzzz, 32'hzzzz, 32'hzzzz, 32'hzzzz, 32'hzzzz, 32'hzzzz, 32'hzzzz, RF_PC_Write_Sel, RF_PC_Write);
   mux44 muxaas(ir2_bus[19:16], ir2_bus[3:0], ir2_mult_bus[19:16], 4'bzzzz, A_Addr_Sel, RF_Addr_A);
   mux24 muxbas(ir2_bus[15:12], ir2_bus[3:0], B_Addr_Sel, RF_Addr_B);
   Super_CPSR sc1(SC_Source, SC_Type, RF_PSR_Read, ALU_Result, ALU_Signals, BS_Cout, RF_Flags_Write);
   registerfile regfile1(RF_Addr_A, RF_Addr_B, ir2_bus[11:8], RF_Addr_Write, RF_Bus_Write, RF_Load_Write, RF_PC_Write, RF_Flags_Write, RF_Load_Flags, RF_PSR_R_Sel, RF_PSR_W_Sel, A_Out,Reg_B_Out, C_Out, RF_PC_Read, RF_PSR_Read, sysclk);

   // Instruction Registers
   decoder dopc(D, nOPC, ir1in, bmuxin);
   mux2 muxbbs(Reg_B_Out, bmuxin, BBus_Src, B_Bus);
   clearable_register ir1r(sysclk, ir1in, ir1, ir1_zero, nSTALL);
   clearable_register ir2r(sysclk, ir1, ir2_bus, ir2_zero, nSTALL);
   clearable_register ir2m(sysclk, ir2_bus, ir2_mult_bus, ir2_mult_zero, ld_ir2_mult);

   // PC+4
   // duplicate!  add4 pc_plus_4(RF_PC_Read, AR_Bus_PC_4);
   
endmodule // armdatapath
