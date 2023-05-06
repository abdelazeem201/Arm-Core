// File to test the arm controller 

// Created Amit Pandey 04/04/2000

// Controller tested on this by  
// Jon Moeller, Daryl K., Matt Crum
// 04/05/2000

// Updated the instantiation and added test for SWP instruction
// Amit Pandey & Vince Leung 04/09/2000

// Test for multicycle instructions - Amit 4/12/00

//////////////////////////////////////////////////////////////////////////

`include "armcontroller.v"
`timescale 1ns/100ps

// CLOCK MODULE ///////////////////////////////////////////////////////////////

module c1(clk);
   parameter TIME_LIMIT = 20000;
   output    clk;
   reg       clk;

   initial
      clk = 0;

   always
      #50 clk = ~clk;


   always @(posedge clk)
      if ($time > TIME_LIMIT) #70 $stop;
endmodule // c1

// TOP MODULE ///////////////////////////////////////////////////////////////

module top;
   
   wire 	       B_Addr_Sel;
   wire [2:0] 	 RF_Addr_Write_Sel, RF_Bus_Write_Sel;
   wire [1:0] 	 A_Addr_Sel;
   wire [3:0] 	 RF_PC_Write_Sel;
   wire 	 RF_Load_Write,RF_Load_Flags,RF_PSR_R_Sel,RF_PSR_W_Sel;
   reg [31:0] 	 RF_PSR_Read;

   // Zero/Sign Extender
   wire [1:0] 	 SZE_Sel;
   wire 		 SZE_Ctrl;
   
   // Barrel Shifter
   wire [1:0] 	 SAM_Ctrl;
   wire 	 BS_Input_Sel;	 
   wire 	 BS_Enable;
      
   // Address Register
   wire [1:0] 	 AR_Bus_ALU_Sel;
   wire [1:0] 	 AR_Bus_Sel;
   
   // Write Data Register
   wire 	 WD_DBE;
   wire 	 WD_Load;
      
   //Coprocessor
   wire 	 nOPC,nCPI;
   reg 		 CPA,CPB;
   
   //Memory Interface
   
   wire 	 nMREQ;
   wire 	 nRW;
   wire [1:0] 	 MAS;
   reg 		 nWAIT;
   
   //ALU
   wire [1:0] 	 Alu_A_Sel;
   wire [4:0] 	 Alu_Cntrl;
   
   //Multiplier
   wire 	 Multiplier_Enable;
   reg 		 Multiplier_Ready;
   
   //general
   reg [31:0] 	 ir2_bus, ir2_mult_bus;
   wire 	 ir1_zero, ir2_zero, ld_ir2_mult, nSTALL, BBUS_Src;   
   reg 		 cont,nRESET;
     	 
   reg 		     ABORT;
   reg 		     nFIQ;
   reg 		     nIRQ;
   wire ALU_Hold_Enable;
   wire ALU_Hold_Sel; // 1 := select A_Bus 0 := sel Alu_Result
  
   wire [4:0] 	     SC_Type;
   wire [3:0] 	     SC_Source;
   
   // internal state 
   wire [`NUM_STATE_BITS-1:0] present_state;
   wire 		      halt,sysclk;       
   
   c1 #100000 clock(sysclk);
   
   
   armcontroller arm_test(A_Addr_Sel,B_Addr_Sel,RF_Addr_Write_Sel,RF_Bus_Write_Sel,RF_PC_Write_Sel,
		     RF_Load_Write,RF_Load_Flags,RF_PSR_R_Sel,RF_PSR_W_Sel,RF_PSR_Read,
		     SC_Type,SC_Source,SZE_Sel,SZE_Ctrl,SAM_Ctrl,BS_Input_Sel,BS_Enable,BS_Cin,
		     AR_Bus_ALU_Sel,AR_Bus_Sel,WD_DBE,WD_Load,nOPC,nCPI,CPA,CPB,nMREQ,nRW,MAS,nWAIT,
                     Alu_A_Sel,Alu_Cntrl,Multiplier_Enable,Multiplier_Ready,ir2_bus,ir2_mult_bus,
		     ir1_zero,ir2_zero,ld_ir2_mult,nSTALL,BBUS_Src,sysclk,nRESET,ABORT,
		     nFIQ,nIRQ,ALU_Hold_Enable,ALU_Hold_Sel);

   initial
      begin
	 $stop;
	 
	 cont = 0;
	 #10;
	 cont =1;
	 
	  nWAIT = 1;
	 ir2_bus = 32'he6910002; 	
	 ir2_mult_bus = 32'he6910002;
	 	 
	 // TEST FOR SWP INSTRUCTION
	 
	 //ir2_bus = 32'he1054096;
	 //ir2_mult_bus = 32'he1054096;
	 
	 
	 
	 // 32'he2801102; //ADD R1<- R0 + Immediate(2)
	 // 32'he0801102; //ADD R1 <- R0 + R2(shift field = 0x10 (logical left by 2)
	 
	 
	 #1000 $stop;
	 
   
         // checking for multicycle instruction (LDR/STR etc)
	 
	 #249 	nWAIT = 0;
	 #500 nWAIT = 	1;
	 $stop;
         $finish; 
      end	
   
   // DISPLAY SIGNALS AS THEY CHANGE 
   always @(posedge sysclk)
      begin
	 $display("------------------------------");	 
	 $display("Time=%d",$time);
      end // always @ (posedge sysclk) 
   

always @(A_Addr_Sel)
$display("A_Addr_Sel=%h -------%d",A_Addr_Sel,$time); 
  
always @(B_Addr_Sel)
$display("B_Addr_Sel=%h -------%d",B_Addr_Sel,$time); 
  
always @(RF_Addr_Write_Sel)
$display("RF_Addr_Write_Sel=%h -------%d",RF_Addr_Write_Sel,$time); 
  
always @(RF_Bus_Write_Sel)
$display("RF_Bus_Write_Sel=%h -------%d",RF_Bus_Write_Sel,$time); 
  
always @(RF_PC_Write_Sel)
$display("RF_PC_Write_Sel=%h -------%d",RF_PC_Write_Sel,$time); 
  
always @(RF_Load_Write)
$display("RF_Load_Write=%h -------%d",RF_Load_Write,$time); 
  
always @(RF_Load_Flags)
$display("RF_Load_Flags=%h -------%d",RF_Load_Flags,$time); 
  
always @(RF_PSR_R_Sel)
$display("RF_PSR_R_Sel=%h -------%d",RF_PSR_R_Sel,$time); 
  
always @(RF_PSR_W_Sel)
$display("RF_PSR_W_Sel=%h -------%d",RF_PSR_W_Sel,$time); 
  
always @(RF_PSR_Read)
$display("RF_PSR_Read=%h -------%d",RF_PSR_Read,$time); 
  
always @(SC_Type)
$display("SC_Type=%h -------%d",SC_Type,$time); 
  
always @(SC_Source)
$display("SC_Source=%h -------%d",SC_Source,$time); 
  
always @(SZE_Sel)
$display("SZE_Sel=%h -------%d",SZE_Sel,$time); 
  
always @(SZE_Ctrl)
$display("SZE_Ctrl=%h -------%d",SZE_Ctrl,$time); 
  
always @(SAM_Ctrl)
$display("SAM_Ctrl=%h -------%d",SAM_Ctrl,$time); 
  
always @(BS_Input_Sel)
$display("BS_Input_Sel=%h -------%d",BS_Input_Sel,$time); 
  
always @(BS_Enable)
$display("BS_Enable=%h -------%d",BS_Enable,$time); 
  
always @(BS_Cin)
$display("BS_Cin=%h -------%d",BS_Cin,$time); 
  
always @(AR_Bus_ALU_Sel)
$display("AR_Bus_ALU_Sel=%h -------%d",AR_Bus_ALU_Sel,$time); 
  
always @(AR_Bus_Sel)
$display("AR_Bus_Sel=%h -------%d",AR_Bus_Sel,$time); 
  
always @(WD_DBE)
$display("WD_DBE=%h -------%d",WD_DBE,$time); 

   always @(WD_Load)
      $display("WD_Load=%h -------%d",WD_Load,$time); 

   always @(nOPC)
      $display("nOPC=%h -------%d",nOPC,$time); 
  
always @(nCPI)
$display("nCPI=%h -------%d",nCPI,$time); 
  
always @(CPA)
$display("CPA=%h -------%d",CPA,$time); 
  
always @(CPB)
$display("CPB=%h -------%d",CPB,$time); 
  
always @(nMREQ)
$display("nMREQ=%h -------%d",nMREQ,$time); 
  
always @(nRW)
$display("nRW=%h -------%d",nRW,$time); 
  
always @(MAS)
$display("MAS=%h -------%d",MAS,$time); 
  
always @(nWAIT)
$display("nWAIT=%h -------%d",nWAIT,$time); 
  
always @(Alu_A_Sel)
$display("Alu_A_Sel=%h -------%d",Alu_A_Sel,$time); 
  
always @(Alu_Cntrl)
$display("Alu_Cntrl=%h -------%d",Alu_Cntrl,$time); 
  
always @(Multiplier_Enable)
$display("Multiplier_Enable=%h -------%d",Multiplier_Enable,$time); 
  
always @(Multiplier_Ready)
$display("Multiplier_Ready=%h -------%d",Multiplier_Ready,$time); 
  
always @(ir2_bus)
$display("ir2_bus=%h -------%d",ir2_bus,$time); 
  
always @(ir2_mult_bus)
$display("ir2_mult_bus=%h -------%d",ir2_mult_bus,$time); 
  
always @(ir1_zero)
$display("ir1_zero=%h -------%d",ir1_zero,$time); 
  
always @(ir2_zero)
$display("ir2_zero=%h -------%d",ir2_zero,$time); 
  
always @(ld_ir2_mult)
$display("ld_ir2_mult=%h -------%d",ld_ir2_mult,$time); 
  
always @(nSTALL)
$display("nSTALL=%h -------%d",nSTALL,$time); 
  
always @(BBUS_Src)
$display("BBUS_Src=%h -------%d",BBUS_Src,$time); 
  
always @(sysclk)
$display("sysclk=%h -------%d",sysclk,$time); 
  
always @(nRESET)
$display("nRESET=%h -------%d",nRESET,$time); 
  
always @(ABORT)
$display("ABORT=%h -------%d",ABORT,$time); 
  
always @(nFIQ)
$display("nFIQ=%h -------%d",nFIQ,$time); 
  
always @(nIRQ)
$display("nIRQ=%h -------%d",nIRQ,$time); 


   // A TASK TO PRINT ALL SIGNALS   THIS DOESNOT HAVE ALL SIGNALS !!!
   task print_all_signals;
      begin
      $display("A_Addr_Sel=%h                B_Addr_Sel=%h",A_Addr_Sel,B_Addr_Sel);
      $display("RF_Addr_Write_Sel=%h                RF_Bus_Write_Sel=%h",RF_Addr_Write_Sel,RF_Bus_Write_Sel);
      $display("RF_PC_Write_Sel=%h          RF_Load_Write=%h",RF_PC_Write_Sel,RF_Load_Write);
      $display("RF_Load_Flags=%h            RF_PSR_R_Sel=%h",RF_Load_Flags,RF_PSR_R_Sel);
      $display("RF_PSR_W_Sel=%h             RF_PSR_Read=%h",RF_PSR_W_Sel,RF_PSR_Read);
      $display("SZE_Sel=%h          SZE_Ctrl=%h",SZE_Sel,SZE_Ctrl);
      $display("SAM_Ctrl=%h         BS_Input_Sel=%h",SAM_Ctrl,BS_Input_Sel);
      $display("BS_Enable=%h                AR_Bus_ALU_Sel=%h",BS_Enable,AR_Bus_ALU_Sel);
      $display("AR_Bus_Sel=%h               WD_DBE=%h",AR_Bus_Sel,WD_DBE);
      $display("nOPC=%h             nCPI=%h",nOPC,nCPI);
      $display("CPA=%h              CPB=%h",CPA,CPB);
      $display("nMREQ=%h            nRW=%h",nMREQ,nRW);
      $display("MAS=%h              nWAIT=%h",MAS,nWAIT);
      $display("Alu_A_Sel=%h                Alu_Cntrl=%h",Alu_A_Sel,Alu_Cntrl);
      $display("Multiplier_Enable=%h                Multiplier_Ready=%h",Multiplier_Enable,Multiplier_Ready);
      $display("ir2_bus=%h          ir2_mult_bus=%h",ir2_bus,ir2_mult_bus);
      $display("ir1_zero=%h         ir2_zero=%h",ir1_zero,ir2_zero);
      $display("ld_ir2_mult=%h              nSTALL=%h",ld_ir2_mult,nSTALL);
      $display("BBUS_Src=%h         cont=%h",BBUS_Src,cont);
      $display("nRESET=%h           sysclk=%h",nRESET,sysclk);
      $display("halt=%h            ",halt);
      end
   endtask

  
endmodule // top
