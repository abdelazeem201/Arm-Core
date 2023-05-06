/////////////////////////////////////////////////////////////////
//  ARM7 TOP LEVEL v1.0,  6-23-2000                            //
//  ECE 371 EMR, Spring 2000                                   //
//  COMPONENT:  ARM7 top level                                 //
// ----------------------------------------------------------- //
//  Updated by J. Shin 8/30/00 -- removed memory from datapath //
/////////////////////////////////////////////////////////////////

`timescale 1ns/100ps
`include "armcontroller.v"
`include "armdatapath.v"

///////////////////////////
// Top arm7 Module       //
///////////////////////////
module arm7 (nOPC, nCPI, CPA, CPB, sysclk, nRESET, nFIQ, nIRQ, ABORT,
nMREQ, nRW, MAS, nWAIT, A_MAR, D);

   // Input/Output declarations
   output        nOPC, nCPI,nMREQ,nRW;
   output [1:0]  MAS; 
   output [31:0] A_MAR; 
   inout [31:0] D; 
   input         CPA, CPB;
   input         sysclk;
   input         nRESET;
   input         nFIQ;
   input         nIRQ;
   input         ABORT;
   input         nWAIT;
   

   wire          nOPC, nCPI,nREQ;
   wire [1:0] 	MAS;
   wire [31:0]  A_MAR; 
   wire [31:0]  D; 
   wire          CPA, CPB;
   wire          sysclk;
   wire          nRESET;           // Exception Signals
   wire          nFIQ;
   wire          nIRQ;
   wire          ABORT;
   wire		nMREQ;
   wire		nRW;
   wire		nWAIT;
   

   // Declare internal wires 
   // Register File
   wire	   	B_Addr_Sel;
   wire [2:0] 	RF_Addr_Write_Sel, RF_Bus_Write_Sel;
   wire [1:0] 	A_Addr_Sel;
   wire [3:0] 	RF_PC_Write_Sel;
   wire 	RF_Load_Write,RF_Load_Flags,RF_PSR_R_Sel,RF_PSR_W_Sel;
   wire [31:0] 	RF_PSR_Read;

   // Super CPSR
   wire [4:0]	SC_Type;
   wire [3:0]	SC_Source;

   // Zero/Sign Extender
   wire [1:0] 	SZE_Sel;
   wire		SZE_Ctrl;

   // Barrel Shifter
   wire [1:0] 	SAM_Ctrl;
   wire		BS_Input_Sel;	 
   wire		BS_Enable;
   wire		BS_Cin;

   // Address Register
   wire		ALU_Hold_Enable;
   wire [1:0] 	AR_Bus_Sel, AR_Bus_ALU_Sel;
   wire		ALU_Hold_Sel;
   wire		Link_Sel;

   // Write Data Register
   wire 	 WD_DBE;
   wire	 WD_Load;

   //Memory Interface
   //wire		nMREQ;
   //wire		nRW;
   //wire [1:0] 	MAS;
   //wire		nWAIT;

   //ALU
   wire [1:0] 	Alu_A_Sel;
   wire [4:0] 	Alu_Cntrl;

   //Multiplier
   wire 	 Multiplier_Enable;
   wire 	 Multiplier_Ready;

   //general
   wire [31:0] 	ir2_bus, ir2_mult_bus;
   wire		ir1_zero, ir2_zero, ld_ir2_mult, nSTALL, BBUS_Src;   

   //Instantiate the datapath
   armdatapath DUT_DATA(A_Addr_Sel,B_Addr_Sel,RF_Addr_Write_Sel,
		RF_Bus_Write_Sel,RF_PC_Write_Sel,RF_Load_Write,
		RF_Load_Flags,RF_PSR_R_Sel,RF_PSR_W_Sel,RF_PSR_Read,
		SC_Type,SC_Source,SZE_Sel,SZE_Ctrl,SAM_Ctrl,BS_Input_Sel,
		BS_Enable,BS_Cin,AR_Bus_ALU_Sel,AR_Bus_Sel,WD_DBE,WD_Load,nOPC,
		nCPI,CPA,CPB,Alu_A_Sel,Alu_Cntrl,
		Multiplier_Enable,Multiplier_Ready,ir2_bus,ir2_mult_bus,
		ir1_zero,ir2_zero,ld_ir2_mult,nSTALL,BBUS_Src,sysclk,
		nRESET,nFIQ,nIRQ,ALU_Hold_Enable,ALU_Hold_Sel,Link_Sel,A_MAR,D);

   //Instantiate the controller
   armcontroller DUT_CONTROL(A_Addr_Sel,B_Addr_Sel,RF_Addr_Write_Sel,
		RF_Bus_Write_Sel,RF_PC_Write_Sel,RF_Load_Write,
		RF_Load_Flags,RF_PSR_R_Sel,RF_PSR_W_Sel,RF_PSR_Read,
		SC_Type,SC_Source,SZE_Sel,SZE_Ctrl,SAM_Ctrl,BS_Input_Sel,
		BS_Enable,BS_Cin,AR_Bus_ALU_Sel,AR_Bus_Sel,WD_DBE,WD_Load,nOPC,
		nCPI,CPA,CPB,nMREQ,nRW,MAS,nWAIT,Alu_A_Sel,Alu_Cntrl,
		Multiplier_Enable,Multiplier_Ready,ir2_bus,ir2_mult_bus,
		ir1_zero,ir2_zero,ld_ir2_mult,nSTALL,BBUS_Src,sysclk,
		nRESET,ABORT,nFIQ,nIRQ,ALU_Hold_Enable,ALU_Hold_Sel,Link_Sel);
endmodule

