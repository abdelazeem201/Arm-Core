//////////////////////////////////////////////////
//                                              //
// ARM Controller Mixed Model                   //        
// Revision History                             //             
// Version 1.0 - initial hack, 29 Mar 2000      //
//    Jon Moeller, Daryl Kowalski               //            
// Version 1.01 - included interfaces           //
//    Jon Moeller                               //
// Version 1.02 - revised LDR/STR,              //
//              - MUL, Data Proc. added         //
//              - removed @(posedge sysclks)    //
//    Jon Moeller & Matt Crum                   //
// Version 1.03 - revised DP,signal names       //
//              - setup all defines for muxes   //       
//              - debugged syntax errors        //
//    Jon Moeller & Matt Crum                   //
// Version 1.04 - tested dp instructions        //
//              - played with LDR/STR           //
//    Jon Moeller, Daryl K., Matt Crum          //
// Version 1.05 - added exception handling/SWI  //
//              - added branches                //
//              - removed IDLE, halt/cont loop  //
//    Jon Moeller, Daryl K.,                    //
// Version 1.06 - added default signals to ENST //
//              - added SWP instruction         //
//              - removed extra cycle after     //
//                cache miss (using else)       //
//              - improved handshaking with MEM //
//                in IF only.                   //
//    Mike Ni, Matt Crum, Jon Moeller, Amit     //
//    Pandey, Anthony Doggett, Kevin Duda       //
// Version 1.07 - Switch `PSB to `MOV and `MOV  //
//                to `PSA                       //
//              - Modified DP section :         //
//                - Changed ALU_A_Sel to select //
//                  RF_A_Bus.                   //
//                - Allowed DP instructions to  //
//                  execute if S bit set.       //
//                - Changed RF_Write_Bus_Sel to //
//                  select Alu_Result.          //
//              - Removed Default ALU_A_Sel     //
//                from ENST                     //
//    Kevin Duda, Amit Pandey, Mike Ni          //
// Version 1.08 - Removed Default nOPC from     //
//                ENST                          //
//              - Changed Width of              //
//                RF_Bus_Write_Sel to 3 bits    //
//              - Moved nSTALL signal to 2nd    //
//                cycle on LDR only.            //
//              - Set ld_ir2_mult = 0 after     //
//                wait loop                     //
//              - LDR wait loop modeled after   //
//                IF wait loop                  //
//    Kevin Duda, Long Truong, Matt Crum, Mike  //
//    Ni					//
// Version 1.09 - Added a register to hold the	//
//		  ALU_Result for driving the A	//
//		  bus in an LDR instruction for //
//		  more than 1 cycle		//	
//		- This caused the mux which is	//
//		  controlled by AR_Bus_ALU_Sel	//
//		  to become a 4 input mux in	//
//		  the datapath			//
//		- We also added the enable	//
//		  signal for this register	//
//		  to the controller and datapath//
//    Deanna Perry, Matt Crum                   //
// Version 1.10 - Fixed register relative LDR   //
//              - Fixed IFetch after LDR by add //
//                nOPC = 0 before wait state    //
//    Mike Ni                                   //
// Version 1.11 - Fixed Store for multiple STR  //
//              - Fixed LDR for LDR after STR   //
//    Amit Pandey, Mike Ni		        //
//                                              //
// Version 1.12 - Fixed Multiply instruction    //
//     Amit Pandey 			        //
// version 1.13 - Added MSR and MRS	        //
//     - Vince and Amit 4/27/00		        //
// version 1.14 - Added sub8 unit for BL,       //
//                exception return address      //
//                adjustment.                   //
//     - Jon & Daryl K. 4/27/00	                //
// Version 1.15 - Added TST, TEQ, CMP, CMN      //
//     Mike Ni                                  //
// Version 1.16 - Added more selective criteria //
//		  to the if statement that      //
//		  decodes MSR and MRS to avoid  //
//                overlap with other insts.     //
//		- Added some visual breaks      //
//		  between sections of code      //
//     Matt Crum                                //
// Version 1.17 - changed CMN to set            //
//                Alu_Cntrl to `ADD instead of  //
//                `RSB                          //
//	Matt Crum			        //
// Version 1.18 - added ALU_Hold_Sel in the     //
// module interface. This keeps address constant//
// during mem requests -- Amit Pandey 4/30/00   //
//////////////////////////////////////////////////

// Please note all changes in the revision history 
// with a note of what you modified and who you are

// Arm Controller module and input/output definitions
// Deanna Perry, 3-29

// Included interfaces as defined by djperry
// Rearranged, cleaned up some parts
// Jon Moeller, 3-30

// Revised LDR/STR, added MUL, Data Proc., removed
// @(posedge sysclk) on signal assignments.
// Made various changes.
// Jon Moeller & Matt Crum, 4-2

// Added some mux select lines that were left out in LDR/STR
// instructions
// Amit Pandey 4/4/00

// Added branches, SWI,exception handlers, removed
// IDLE state and halt/cont loop.
// Jon Moeller, Daryl K., 4/6/00

// Debugged branch instruction - Amit & Isaac 4/17/00

`include "defines.v"

`timescale 1ns/100ps 

// LOCAL DEFINES (temporary)


// module declaration for controller of ARM7
module armcontroller(A_Addr_Sel,B_Addr_Sel,RF_Addr_Write_Sel,RF_Bus_Write_Sel,RF_PC_Write_Sel,
		     RF_Load_Write,RF_Load_Flags,RF_PSR_R_Sel,RF_PSR_W_Sel,RF_PSR_Read,
		     SC_Type,SC_Source,SZE_Sel,SZE_Ctrl,SAM_Ctrl,BS_Input_Sel,BS_Enable,BS_Cin,
		     AR_Bus_ALU_Sel,AR_Bus_Sel,WD_DBE,WD_Load,nOPC,nCPI,CPA,CPB,nMREQ,nRW,MAS,nWAIT,
                     Alu_A_Sel,Alu_Cntrl,Multiplier_Enable,Multiplier_Ready,ir2_bus,ir2_mult_bus,
		     ir1_zero,ir2_zero,ld_ir2_mult,nSTALL,BBUS_Src,sysclk,nRESET,ABORT,
		     nFIQ,nIRQ,ALU_Hold_Enable,ALU_Hold_Sel,Link_Sel);
   
   // Input/Output Declarations by instantiated module
   
   // Register File
   output 		        B_Addr_Sel;
   output [2:0] 	     RF_Addr_Write_Sel,RF_Bus_Write_Sel;
   output [1:0] 	     A_Addr_Sel;
   output [3:0] 	     RF_PC_Write_Sel;
   output 		     RF_Load_Write,RF_Load_Flags,RF_PSR_R_Sel,RF_PSR_W_Sel;
   input [31:0] 	     RF_PSR_Read;
   
   // Super CPSR
   output [4:0]		     SC_Type;
   output [3:0]		     SC_Source;
   
   // Zero/Sign Extender
   output [1:0] 	     SZE_Sel;
   output 		     SZE_Ctrl;	 
   
   // Barrel Shifter
   output [1:0] 	     SAM_Ctrl;
   output 		     BS_Input_Sel;	 
   output 		     BS_Enable;
   output 		     BS_Cin;
   
   // Address Register
   output [1:0]		     AR_Bus_ALU_Sel;
   output [1:0] 	     AR_Bus_Sel;
   output                    ALU_Hold_Enable;
   output 		     ALU_Hold_Sel; // 1 := select A_Bus 0 := sel Alu_Result
   output                    Link_Sel; // 0 = PC - 4; 1 = PC
		        
   // Write Data Register
   output 		     WD_DBE;
   output                    WD_Load;
   
   //Coprocessor
   output 		     nOPC,nCPI;
   input 		     CPA,CPB;
   
   //Memory Interface
   
   output 		     nMREQ;
   output 		     nRW;
   output [1:0] 	     MAS;
   input 		     nWAIT;   
   
   //ALU
   output [1:0] 	     Alu_A_Sel;
   output [4:0] 	     Alu_Cntrl;
   
   //Multiplier
   output 		     Multiplier_Enable;
   input 		     Multiplier_Ready;
   
   
   //general
   input [31:0] 	     ir2_bus, ir2_mult_bus;
   output 		     ir1_zero, ir2_zero, ld_ir2_mult,nSTALL, BBUS_Src;
   input 		     sysclk;
   
   // Exception Signals
   
   input 		     nRESET; 	 
   input 		     ABORT;
   input 		     nFIQ;
   input 		     nIRQ;
   
   // Reg and Wire declarations by module
   
   // Register File
   reg 			        B_Addr_Sel;
   reg [2:0] 		     RF_Addr_Write_Sel, RF_Bus_Write_Sel;
   reg [1:0] 		     A_Addr_Sel;
   reg [3:0] 		     RF_PC_Write_Sel;
   reg 			     RF_Load_Write,RF_Load_Flags,RF_PSR_R_Sel,RF_PSR_W_Sel;
   wire [31:0] 		     RF_PSR_Read;
   
   // Super CPSR
   reg 	[4:0]		     SC_Type;
   reg 	[3:0]		     SC_Source;
   
   // Zero/Sign Extender
   reg [1:0] 		     SZE_Sel;
   reg 			     SZE_Ctrl;
   
   // Barrel Shifter
   reg [1:0] 		     SAM_Ctrl;
   reg 			     BS_Input_Sel;	 
   reg 			     BS_Enable;
   reg 			     BS_Cin;
   
   // Address Register
   reg [1:0]	             AR_Bus_ALU_Sel;
   reg [1:0] 		     AR_Bus_Sel;
   reg                       ALU_Hold_Enable;
   reg 			     ALU_Hold_Sel; 			     
   reg 			     Link_Sel; 			     

   // Write Data Register
   reg 			     WD_DBE;
   reg  		     WD_Load;
   
   //Coprocessor
   reg 			     nOPC,nCPI;
   wire 		     CPA,CPB;
   
   //Memory Interface
   
   reg 			     nMREQ;
   reg 			     nRW;
   reg [1:0] 		     MAS;
   wire 		     nWAIT;      
   
   //ALU
   reg [1:0] 		     Alu_A_Sel;
   reg [4:0] 		     Alu_Cntrl;
   
   //Multiplier
   reg 			     Multiplier_Enable;
   wire 		     Multiplier_Ready;
   
   
   //general
   wire [31:0] 		     ir2_bus, ir2_mult_bus;
   reg 			     ir1_zero, ir2_zero, ld_ir2_mult, nSTALL, BBUS_Src;   
   wire 		     sysclk;
   
   // Exception Signals
   
   wire 		     nRESET; 	 
   wire 		     ABORT;
   wire 		     nFIQ;
   wire 		     nIRQ;
   
   // internal state 
   reg [`NUM_STATE_BITS-1:0] present_state;
   
   always
      begin
	 @(posedge sysclk) enter_new_state(`INIT);
	 RF_PC_Write_Sel = `RF_PC_WRITE_SEL_0;                     // mux 0 into PC;
	 SC_Type = 5'b10000;                                       // change mode
	 SC_Source = `SC_CTRL_SELECT_SOURCE_USR_MODE;              // select USR mode
	 RF_Load_Flags = 1;                                        // assert loading of PSR
         RF_PSR_W_Sel = 0;					   // select CPSR
         RF_PSR_R_Sel = 0;				           // select CPSR
         AR_Bus_Sel = 1;     // select PC
	 ir1_zero = 1;						   // fill pipeline with NOPs
	 ir2_zero = 1;
         @(posedge sysclk);

	 forever @(sysclk or nRESET or ABORT or nFIQ or nIRQ)
	    begin                                                  // handle exceptions
	       //if( sysclk==1 && nRESET == 1 && ABORT ==0 && nFIQ == 0 && nIRQ ==0)
	       //  enter_new_state(`F1);
	       
	       if (nRESET == 0)
		  begin
		     SC_Type = 5'b10000;                           // change mode
		     SC_Source = `SC_CTRL_SELECT_SOURCE_SVC_MODE;  // select SVC mode
		     RF_Bus_Write_Sel = `RF_BUS_WRITE_SEL_LINK_ADDR; 
		     RF_Addr_Write_Sel = `RF_ADDR_WRITE_SEL_R14;    
		     RF_Load_Write = 1;                            // save PC into R14_svc
		     RF_PC_Write_Sel = `RF_PC_WRITE_SEL_0;         // mux 0 into PC;
		  end // if (nRESET == 0)
	       else if (ABORT == 1)
		  begin
		     SC_Type = 5'b10000;                           // change mode
		     SC_Source = `SC_CTRL_SELECT_SOURCE_ABT_MODE;  // select ABT mode
		     RF_Bus_Write_Sel = `RF_BUS_WRITE_SEL_LINK_ADDR; 
		     RF_Addr_Write_Sel = `RF_ADDR_WRITE_SEL_R14;    
		     RF_Load_Write = 1;                            // save PC into R14_abt
		     RF_PC_Write_Sel = `RF_PC_WRITE_SEL_C;         // mux h'C into PC;
		  end // if (ABORT == 1)
	       else if (nFIQ == 0)
		  begin
		     SC_Type = 5'b10000;                           // change mode
		     SC_Source = `SC_CTRL_SELECT_SOURCE_FIQ_MODE;  // select FIQ mode
		     RF_Bus_Write_Sel = `RF_BUS_WRITE_SEL_LINK_ADDR; 
		     RF_Addr_Write_Sel = `RF_ADDR_WRITE_SEL_R14;    
		     RF_Load_Write = 1;                            // save PC into R14_fiq
		     RF_PC_Write_Sel = `RF_PC_WRITE_SEL_1C;        // mux h'1C into PC;
		  end // if (nFIQ == 0)
	       else if (nIRQ == 0)
		  begin
		     SC_Type = 5'b10000;                           // change mode
		     SC_Source = `SC_CTRL_SELECT_SOURCE_IRQ_MODE;  // select IRQ mode
		     RF_Bus_Write_Sel = `RF_BUS_WRITE_SEL_LINK_ADDR; 
		     RF_Addr_Write_Sel = `RF_ADDR_WRITE_SEL_R14;    
		     RF_Load_Write = 1;                            // save PC into R14_irq
		     RF_PC_Write_Sel = `RF_PC_WRITE_SEL_18;        // mux h'18 into PC;
		  end // if (nIRQ == 0)
	       else
		  begin  
		   @(posedge sysclk) enter_new_state(`F1);		     
		     
		     if (condx(ir2_bus[31:28],RF_PSR_Read)  // condition passed
                                           // data processing instruction that writes to PC
			 && ((ir2_bus[27:26]==2'b00 && ir2_bus[15:12]==15 && 
			      ~(ir2_bus[24:23] == 5'b10)) 
			     || (ir2_bus[27:25]==5))) // or branch instruction
			//     ~(ir2_bus[27:23] == 5'b00010 && ir2_bus[21:16] == 6'b101001 &&
			//     ir2_bus[11:4] == 8'b00000000)) || ir2_bus[27:25]==5))
			begin // "B/R15"
			   ir1_zero = 1;
			end // if (condx(ir2_bus[31:28],RF_PSR_Read)...
		     else
			begin // "NORMAL"
			   ir1_zero = 0;
			   ir2_zero = 0;

			   nOPC = 0;
			   RF_PC_Write_Sel = `RF_PC_WRITE_SEL_PC_PLUS4;
		   	   AR_Bus_Sel = 2;
			   nMREQ = 0; // request instruction from memory

			   BBUS_Src = 0; // select read data reg to drive B bus.
			   nRW = 0;
			   MAS = 2'b10;
			   //@(negedge nWAIT);
		           #2;
			   AR_Bus_Sel = 1;
			   // INSTRUCTION FETCH LOOP
			   while(~nWAIT)
			      begin
			      
				 nSTALL = 0;
			         RF_PC_Write_Sel = 4'b0110;
				 #2;
				 if (nWAIT)
				    begin
				       nMREQ = 1;  // deassertion
				       nOPC = 0; // fetching instruction (not data)
				       nSTALL = 1; // deassert nSTALL
			   	       nOPC = 0;  // fetching instruction (not data)
				    end
				 else
				    @(posedge sysclk) enter_new_state(`FETCH);
			      end // while (~nWAIT)
			   RF_PC_Write_Sel = `RF_PC_WRITE_SEL_PC_PLUS4;
		   	   AR_Bus_Sel = 2;	  
			   // ir2 <- ir1 - happens when nSTALL = 1
			end // else: !if(condx(ir2_bus[31:28],RF_PSR_Read)...
		     // CONDITIONALLY EXECUTE INSTRUCTIONS
		     if (condx(ir2_bus[31:28],RF_PSR_Read))
			begin

//************************************** SWAP **************************************************************//

			   if ((ir2_bus[27:23] == 5'b00010) && (ir2_bus[11:4] == 8'b00001001)
                               && (ir2_bus[21:20] == 2'b00))  // SWP			      
			      begin						 
				 // First load the data to be written to mem into Write Data Reg 
				 // and also load the Address Reg with address			    			      
				 ld_ir2_mult = 1;
				 A_Addr_Sel = `RF_ADDR_A_SEL_IR21916;						      
				 //ALU_Hold_Enable = 1;
				 
				 AR_Bus_ALU_Sel = `AR_BUS_ALU_SEL_A_BUS;// selects ALU out
				 
				 AR_Bus_Sel = 2'b00; // Select AR_Bus_Alu input to Add Reg			      
				 B_Addr_Sel = `RF_ADDR_B_SEL_IR230;
				 BBUS_Src = 0; // select regfile to drive B bus
						      
				 WD_Load = 1; 
				 @(posedge sysclk) enter_new_state(`SWAP_1);
				 nSTALL = 0;
				 RF_PC_Write_Sel = 4'b0110;
				 //ALU_Hold_Enable = 0;
				 
				 //AR_Bus_ALU_Sel = `AR_BUS_ALU_SEL_ALU_HOLD; // Selects ALU hold out
				 WD_Load = 0; // deassert load to WDreg
				 if( ir2_mult_bus[22] == 0 )				      
				    MAS = 2'b10;		
				 else
				    MAS = 2'b00;	   							    
				 nRW = 0;
				 nOPC = 1;
				 nMREQ = 0;  // request memory for data
				 
				 #2;
				 while(~nWAIT)
				    begin
				       nSTALL = 0;
				       RF_PC_Write_Sel = 4'b0110;
				       #2;
				       if (nWAIT)
					  begin
					     nMREQ = 1;  // deassertion
					  end
				       else
					  @(posedge sysclk) enter_new_state(`LOAD_REQUEST);
				    end // while (~nWAIT)			 
				 
				 // @(posedge sysclk);
				 // Write the data from memory into the regfile
				 
				 nMREQ = 1;  // deassertion
				 RF_Addr_Write_Sel = `RF_ADDR_WRITE_SEL_IR2_MULT1512;
				 RF_Bus_Write_Sel = `RF_BUS_WRITE_SEL_ALU_RESULT;			
				 BBUS_Src = 1; // select read data reg to drive B bus.
				 BS_Enable = 0; // disable shifter
				 Alu_Cntrl = `MOV;
				 RF_Load_Write = 1;
				 

				 @(posedge sysclk) enter_new_state(`SWAP_3);				    
				 nSTALL = 0;				 
				 nRW = 1;
				 nOPC = 1;				   
				 WD_DBE = 1; // enable write data register
				 nMREQ = 0; // request memory
				 RF_PC_Write_Sel = 4'b0110;
				 
				 #2;
				 while(~nWAIT)
				    begin
				       WD_DBE = 1;
				       nSTALL = 0;
				       RF_PC_Write_Sel = 4'b0110;
				       #2;
				       if (nWAIT)
					  begin
					     nMREQ = 1;
					  end // if (nWAIT)
				       else
					  @(posedge sysclk) enter_new_state(`STORE_REQUEST);
				    end // while (~nWAIT)	
				 AR_Bus_Sel = 1;
				 // 						      
			      end // if ((ir2_bus[27:23] == 5'b00010) && (ir2_bus[11:4] == 8'b00001001))

//************************************** DP or MULT or MRS/MSR **************************************************************//

			   else if (ir2_bus[27:26] == 2'b00) // "DP or MUL or MRS or MSR"
			      if ((ir2_bus[25:23] == 3'b010) && ((ir2_bus[21:16] == 6'b001111) || (ir2_bus[21:12] == 10'b1010011111))) //"MRS or reg to PSR MSR"
				 begin
				    if (ir2_bus[21:16] == 6'b001111) //"MRS" PSR to reg
				       begin
					  RF_Addr_Write_Sel = `RF_ADDR_WRITE_SEL_IR21512; // Select PSR address
					  RF_Bus_Write_Sel = `RF_BUS_WRITE_SEL_PSR_READ; // Select PSR data
					  RF_PSR_R_Sel = ir2_bus[22]; // Either CPSR or SPSR_mode		
					  RF_Load_Write = 1; // Write to regfile
				       end // if (ir2_bus[21:16] == 6'b001111)				    
				    else if(ir2_bus[21:12] == 10'b1010011111) // reg to PSR MSR
				       begin
					  A_Addr_Sel = `RF_ADDR_A_SEL_IR230; //Rm
					  Alu_A_Sel = `ALU_A_SEL_A; // Select regfile
					  Alu_Cntrl = `PSA; // Pass A
					  SC_Source = `SC_CTRL_SELECT_SOURCE_ALU; // Select ALU Result
					  SC_Type = `SC_TYPE_CHANGE_MODE;					 
					  RF_PSR_W_Sel = ir2_bus[22]; // Either CPSR or SPSR_mode
					  RF_Load_Flags = 1;
					  RF_Load_Flags <= @(posedge sysclk) 0;	  
				       end // if (ir2_bus[21:12] == 10'b1010011111)	       
				 end // if (ir2_bus[25:23] == 3'b010)

//************************************** MULT **************************************************************//
			   
			      else
			        if ((ir2_bus[27:22] == 6'b000000) && 
                                    (ir2_bus[7:4] == 4'b1001)) // "MUL"
				 begin
				    A_Addr_Sel = `RF_ADDR_A_SEL_IR230; // Rm
				    B_Addr_Sel = `RF_ADDR_B_SEL_IR21512; // Rn
				    RF_Addr_Write_Sel = `RF_ADDR_WRITE_SEL_IR21916; // Rd to regfile
				    Multiplier_Enable = 1; // ready to multiply	
				    ld_ir2_mult = 1;
				    nOPC = 1;
				    nSTALL = 0;
				    RF_PC_Write_Sel = 4'b0110;	
				    AR_Bus_Sel = 1;			    
				    @(posedge sysclk);
				    ld_ir2_mult = 0;				    
				    RF_Addr_Write_Sel = `RF_ADDR_WRITE_SEL_IR2_MULT1916; // Rd to regfile 
				    RF_PC_Write_Sel = 4'b0110;
				    nOPC = 1;
				    nSTALL = 0;
				    @(posedge sysclk);
				    RF_Addr_Write_Sel = `RF_ADDR_WRITE_SEL_IR2_MULT1916; // Rd to regfile
				    RF_PC_Write_Sel = 4'b0110;				    
				    nOPC = 1;
				    nSTALL = 0;
				    #2;
				    while (!Multiplier_Ready)
				       begin
				    	  nOPC = 1;
					  nSTALL = 0;				
					  @(posedge sysclk) enter_new_state(`MULT);
					  RF_PC_Write_Sel = 4'b0110;
					  RF_Addr_Write_Sel = `RF_ADDR_WRITE_SEL_IR2_MULT1916; // Rd to regfile
				       end // while (!Multiplier_Ready)

`ifdef BUG4
`else
                                    Link_Sel = 1;
                                    // handle case where BL follows Multiply
`endif
				    AR_Bus_Sel = 1;
				    Alu_A_Sel = `ALU_A_SEL_MUL; // route multiplier output to ALU input A
				    BBUS_Src = 0; // select regfile to drive B bus.
				    BS_Input_Sel = 0; // Rn to ALU B input
				    BS_Enable = 0; // pass through shifter
				    if (ir2_mult_bus[21] == 1) // MLA
				       Alu_Cntrl = `ADD; // add A and B inputs
				    else // MUL
				       Alu_Cntrl = `PSA;
`ifdef BUG3
`else
                                    RF_Bus_Write_Sel = 
                                      `RF_BUS_WRITE_SEL_ALU_RESULT; 
                                      // Select output from ALU
`endif
				    RF_Load_Write = 1; // load Rd into regfile

				 end // if ((ir2_bus[27:22] == 6'b000000) && (ir2_bus[7:4] == 4'b1001))

//************************************** DP **************************************************************//

			      else
				 begin // "DP"
				    A_Addr_Sel = `RF_ADDR_A_SEL_IR21916;
				    Alu_A_Sel = `ALU_A_SEL_A;				    
				    if (ir2_bus[25] == 1) // operand 2 is an immediate value
				       begin
					  BS_Input_Sel = `BS_INPUT_SEL_EXT; // Barrel Shifter input is zero extended immediate
					  SZE_Ctrl = 0;
					  SZE_Sel = `SZE_SEL_IR2_70;
					  if( ir2_bus[11:8] == 4'b0000 )
					     begin
						BS_Enable = 0;
					     end // if ( ir2_bus[11:8] == 4'b0000 )
					  else
					     begin
						SAM_Ctrl = `SHIFT_TYPE4; // Rotate right
						BS_Enable = 1; // enable shifter
					     end // else: !if( ir2_bus[11:8] == 4'b0000 )
					  
				       end // if (ir2_bus[25] == 1)
				    else
				       begin
					  BS_Input_Sel = `BS_INPUT_SEL_B; // operand 2 is from regfile
					  B_Addr_Sel = `RF_ADDR_B_SEL_IR230; // select register to be shifted
					  if (ir2_bus[4] == 0)
					     SAM_Ctrl = `SHIFT_TYPE1;
					  else
					     SAM_Ctrl = `SHIFT_TYPE2;
					  BS_Enable = 1; // enable shifter
				       end // else: !if(ir2_bus[25] == 1)
				    
				    /////////////////////////////////////
				    // TST,TEQ,CMP,CMN - Set OpCode    
				    /////////////////////////////////////
				    if ((ir2_bus[24:21] == 4'h8) ||
					(ir2_bus[24:21] == 4'h9) ||
					(ir2_bus[24:21] == 4'ha) ||
					(ir2_bus[24:21] == 4'hb))
				       begin
					  if (ir2_bus[24:21] == 4'hb)
					     begin
						Alu_Cntrl = 5'b00100;
					     end // if (ir2_bus[24:21] == 4'hb)
					  else
					     begin
						Alu_Cntrl = {2'b00,ir2_bus[23:21]};
					     end // else: !if(ir2_bus[24:21] == 4'hb) 
				       end
				    else
				       begin
					  Alu_Cntrl = {1'b0,ir2_bus[24:21]};
				       end
				    
				    if ((ir2_bus[24:21] == 4'h8) || 	//These instructions write back condition codes
					(ir2_bus[24:21] == 4'h9) || 
					(ir2_bus[24:21] == 4'ha) || 
					(ir2_bus[24:21] == 4'hb) || (ir2_bus[20] == 1))
				       begin
				       
				      //if (ir2_bus[15:12] != 4'hE) 	//normal operation if dest. is not R15
				      if (ir2_bus[15:12] != 4'hF) 	//normal operation if dest. is not R15
					begin	
	 					RF_Load_Flags = 1; // assert loading of PSR
						RF_PSR_W_Sel = 0; // Enable writing to CPSR
				       		case (Alu_Cntrl)
						`AND, `EOR, `ORR, `MOV, `BIC, `MVN:
				       			begin
	 						SC_Type = `SC_TYPE_CHANGE_NO_V;  // change mode
							SC_Source = `SC_CTRL_SELECT_SOURCE_SFT_FLAGS;// Select Super CPSR to read flags from Alu
							end

						`SUB, `RSB, `ADD, `ADC, `SBC, `RSC:
							begin
	 						SC_Type = `SC_TYPE_CHANGE_ALL_FLAGS;  // change mode
							SC_Source = `SC_CTRL_SELECT_SOURCE_ALU_FLAGS;// Select Super CPSR to read flags from Alu
							end
						endcase	
					end
				      else	//load in SPSR -> CPSR (assumed not called while in user mode).
				      	begin
	 					RF_Load_Flags = 1; // assert loading of PSR
						RF_PSR_W_Sel = 0; // Enable writing to CPSR
						RF_PSR_R_Sel = 1; // Enable reading from SPSR
	 					SC_Type = `SC_TYPE_CHANGE_ALL_FLAGS;  // change mode
						SC_Source = `SC_CTRL_SELECT_SOURCE_PASS_PSR;// Select Super CPSR to read flags from Alu
					end

				       end // if ((ir2_bus[24:21] == 4'h8) ||...
				    // else
				    //   begin
			            if (!(ir2_bus[24:21] == 4'h8) && 				//NOT these instructions write back results
					!(ir2_bus[24:21] == 4'h9) && 
					!(ir2_bus[24:21] == 4'ha) && 
					!(ir2_bus[24:21] == 4'hb))
				       begin
					  RF_Addr_Write_Sel = `RF_ADDR_WRITE_SEL_IR21512; // Select proper destination register
					  RF_Bus_Write_Sel = `RF_BUS_WRITE_SEL_ALU_RESULT; // Select output from ALU
					  RF_Load_Write = 1; // Enable regfile load
				       end // if (!(ir2_bus[24:21] == 4'h8) &&...
			             //end // else: !if((ir2_bus[24:21] == 4'h8) ||...
				 end // else: !if((ir2_bus[27:22] == 6'b000000) && (ir2_bus[7:4] == 4'b1001))

//************************************** BRANCHES **************************************************************//

		              else if (ir2_bus[27:25] == 3'b101) // BRANCHES
				 begin				  
				    
				    if (ir2_bus[24] == 1) // Determine whether or not to link
				       begin
					  // LINK code - write PC+4 into R14
					  RF_Bus_Write_Sel = `RF_BUS_WRITE_SEL_LINK_ADDR;
					  RF_Addr_Write_Sel = `RF_ADDR_WRITE_SEL_R14;
					  RF_Load_Write = 1;
				       end // if (ir2_bus[24] == 1)
				    //BRANCH code - add PC to sign-extended offset << 2
				    Alu_A_Sel = `ALU_A_SEL_PC; //Put PC into ALU
				    
				    SZE_Sel = `SZE_SEL_IR2_230; // put ir2[23:0] into sign-extender
				    SZE_Ctrl = 1; // sign-extend ir2[23:0]
				    BS_Input_Sel = `BS_INPUT_SEL_EXT;//put sign-extended ir2[23:0] into Barrel Shifter
				    SAM_Ctrl = `SHIFT_TYPE3; // Logical shift left by 2
				    BS_Enable = 1;
				    Alu_Cntrl = `ADD;
				    // Place result into PC
				    RF_PC_Write_Sel = `RF_PC_WRITE_SEL_ALU_RESULT;
				    
				    // clear pipeline
				    ir1_zero = 1;
				    //ir2_zero = 1;
				    
				    AR_Bus_ALU_Sel = `AR_BUS_ALU_SEL_ALU_RESULT;
				    ALU_Hold_Sel = 0; // Pass Alu_Result to the ALU_Hold Reg				    
				    ALU_Hold_Enable = 1;
				    AR_Bus_Sel = 2'b00;	 
				    @(posedge sysclk) enter_new_state(`FETCH);
				    AR_Bus_ALU_Sel = `AR_BUS_ALU_SEL_ALU_HOLD;
				    ALU_Hold_Enable = 0;
				    AR_Bus_Sel = 2'b00;
				    nMREQ = 0; // request instruction from memory
				    nOPC = 0; // fetching instruction (not data)
				    BBUS_Src = 0; // select read data reg to drive B bus.
				    nRW = 0;
				    MAS = 2'b10;						    
				    #2;
				    
				    // INSTRUCTION FETCH LOOP	
				    while(~nWAIT)
				       begin
					  nSTALL = 0;
					  RF_PC_Write_Sel = 4'b0110;
					  #2;
					  if (nWAIT)
					     begin
						nMREQ = 1;  // deassertion
						nSTALL = 1; // deassert nSTALL
					     end
					  else
					     @(posedge sysclk) enter_new_state(`FETCH);
				       end // while (~nWAIT)
				    
				    RF_PC_Write_Sel = `RF_PC_WRITE_SEL_PC_PLUS4;
				    AR_Bus_Sel = 2;	   
				    
				 end // if (ir2_bus[27:25] == 3'b101)
			   
//************************************** SWI **************************************************************//
			   
			   else if (ir2_bus[27:24] == 4'b1111) // "SWI"
			      begin
				 SC_Type = 5'b10000;                           // change mode
				 SC_Source = `SC_CTRL_SELECT_SOURCE_SVC_MODE;  // select SVC mode
				 RF_Bus_Write_Sel = `RF_BUS_WRITE_SEL_LINK_ADDR; 
				 RF_Addr_Write_Sel = `RF_ADDR_WRITE_SEL_R14;    
				 RF_Load_Write = 1;                            // save PC into R14_svc
				 RF_PC_Write_Sel = `RF_PC_WRITE_SEL_8;         // route 8 to PC
			      end // if (ir2_bus[27:24] == 4'b1111)
			   
//************************************** LDR and STR **************************************************************//

		           else if (ir2_bus[27:26] == 2'b01) // LDR/STR
			      begin
				 if (ir2_bus[25]==1)
				    begin
				       B_Addr_Sel = `RF_ADDR_B_SEL_IR230;
				       BS_Input_Sel = `BS_INPUT_SEL_B; // selects B bus to barrel shifter
				       
				       if( ir2_bus[4] == 1 ) // use shifting rules 
					  SAM_Ctrl = `SHIFT_TYPE2;
				       else
					  SAM_Ctrl = `SHIFT_TYPE1;				
				    end // if (ir2_bus[25]==1)
				 else
				    begin
				       SZE_Sel = `SZE_SEL_IR2110;
				       BS_Input_Sel = `BS_INPUT_SEL_EXT; // selects sext immediate val.
				       SZE_Ctrl = 0; // tells extender to use zero fill
				       SAM_Ctrl = `SHIFT_TYPE3; // aligns by shifting 2
				    end // else: !if(ir2_bus[25]==1)
				 if (ir2_bus[23]==1) 
				    Alu_Cntrl = `ADD;
				 else
				    Alu_Cntrl = `SUB;
				 A_Addr_Sel = `RF_ADDR_A_SEL_IR21916;
				 Alu_A_Sel = `ALU_A_SEL_A;
				 
				 // Check for pre/post indexing. If pre indexing need to check for
				 // Write back otherwise for post indexing always write back
				 if( ir2_bus[24] == 1)
				    begin // Pre-indexed						    
				       AR_Bus_Sel = 2'b00; // `AR_ALU_SEL = 2'b00; in regfile define file
				       AR_Bus_ALU_Sel = `AR_BUS_ALU_SEL_ALU_RESULT; // selects ALU out
				       if ( ir2_bus[21] == 1 ) // Check for Write-back bit
					  begin
					     RF_Addr_Write_Sel = `RF_ADDR_WRITE_SEL_IR21916;
					     RF_Bus_Write_Sel = `RF_BUS_WRITE_SEL_ALU_RESULT;
					     RF_Load_Write = 1;
					  end // if ( ir2_bus[21] == 1 )
				    end // if ( ir2_bus[24] == 1)					      
				 else
				    begin
				       AR_Bus_Sel = 2'b00;   // Select AR_BUS_ALU
				       AR_Bus_ALU_Sel = `AR_BUS_ALU_SEL_A_BUS; // Select the base register
				       // Since post indexed, write back by default(no need to check)
				       RF_Addr_Write_Sel = `RF_ADDR_WRITE_SEL_IR21916;
				       RF_Bus_Write_Sel = `RF_BUS_WRITE_SEL_ALU_RESULT;
				       RF_Load_Write = 1;
				    end // else: !if( ir2_bus[24] == 1)				 
				 
				 //AR_Bus_Sel = 2'b00; // `AR_ALU_SEL = 2'b00; in regfile define file
				 // AR_Bus_ALU_Sel = `AR_BUS_ALU_SEL_ALU_RESULT; // selects ALU out
				 ld_ir2_mult = 1; // latch multicycle instruction.
				 if( ir2_bus[24] == 0)
				    ALU_Hold_Sel = 1; // Pre-index so pass Alu_Result
				 else
				    ALU_Hold_Sel = 0; // Post-indexing so pass A_Bus				 
				 ALU_Hold_Enable = 1; // latch ALU_Result
				 
				// nSTALL = 0;     // assert STALL
				 if (ir2_bus[22] == 0)
				    MAS = 2'b10; // word
				 else
				    MAS = 2'b00; // byte
				 if (ir2_bus[20]==1) // LDR
				    begin
				       
				       //RF_PC_Write_Sel = `RF_PC_WRITE_SEL_RF_PC_READ;	
				       @(posedge sysclk);
				       RF_Load_Write = 0;				       
				       RF_PC_Write_Sel = 4'b0110;
				       ALU_Hold_Enable = 0;

				       if(ir2_bus[24] == 1)
				       AR_Bus_ALU_Sel = `AR_BUS_ALU_SEL_ALU_HOLD;
				       else
					  begin
					     AR_Bus_ALU_Sel = `AR_BUS_ALU_SEL_A_BUS;
					     A_Addr_Sel = `RF_ADDR_A_SEL_IR2_MULT1916;
					  end // else: !if(ir2_mult_bus[24] == 1)
				       ld_ir2_mult = 0;
				       nSTALL = 0;
				       nRW = 0;
				       nOPC = 1;				       
				       nMREQ = 0;  // request memory
				       #2;
				       while(~nWAIT)
					  begin
					     nSTALL = 0;
					     RF_PC_Write_Sel = 4'b0110;
					     #2;
					     if (nWAIT)
						begin
						   nMREQ = 1;  // deassertion
						end
					     else
						@(posedge sysclk) enter_new_state(`LOAD_REQUEST);
					  end // while (~nWAIT)
				       //@(posedge sysclk);
				       			       
				       nMREQ = 1;  // deassertion
				       //nSTALL = 1; // deassert nSTALL
				       AR_Bus_Sel = 1;
				       RF_Addr_Write_Sel = `RF_ADDR_WRITE_SEL_IR2_MULT1512;
				       RF_Bus_Write_Sel = `RF_BUS_WRITE_SEL_D;			
				       BBUS_Src = 1; // select read data reg to drive B bus.
				       BS_Enable = 0; // disable shifter
				       Alu_Cntrl = `MOV;
				       RF_Load_Write = 1;
				    end // if (ir2_bus[20]==1)
				 else //STR
				    begin
				       BBUS_Src = 0;//select regfile to drive BBus
				       WD_Load = 1;
				       @(posedge sysclk);
				       RF_Load_Write = 0;				       
				       RF_PC_Write_Sel = 4'b0110;
				       WD_Load = 0;
				       AR_Bus_Sel = 0;
				       ALU_Hold_Enable = 0;

				       if(ir2_bus[24] == 1)
					  AR_Bus_ALU_Sel = `AR_BUS_ALU_SEL_ALU_HOLD;
				       else
					  begin
					     AR_Bus_ALU_Sel = `AR_BUS_ALU_SEL_A_BUS;
					     A_Addr_Sel = `RF_ADDR_A_SEL_IR2_MULT1916;
					     
					  end // else: !if(ir2_mult_bus[24] == 1)
				        				       				 
				       ld_ir2_mult = 0;
				       nSTALL = 0;
				       nRW = 1;
				       nOPC = 1;
				       nMREQ = 0; // request memory
				       B_Addr_Sel =  `RF_ADDR_WRITE_SEL_IR2_MULT1512;
				       BS_Enable = 0; // disable shifter
				       Alu_Cntrl = `MOV;
				       WD_DBE = 1; // enable write data register
				       #2;
				       while(~nWAIT)
					  begin
					     WD_DBE = 1;
					     nSTALL = 0;
					     RF_PC_Write_Sel = 4'b0110;
					     #2;
					     if (nWAIT)
						begin
						   nMREQ = 1;
						end // if (nWAIT)
					    else
						@(posedge sysclk) enter_new_state(`STORE_REQUEST);
					  end // while (~nWAIT)
				       AR_Bus_Sel = 1;
				    end // else: !if(ir2_bus[20]==1)
			      end // if (ir2_bus[27:26] == 2'b01)

//************************************** FPU INSTRUCTIONS **************************************************************//

				else if (ir2_bus[27:24] == 4'b1110)  // CRT or CDO
				   begin
	 			      if (ir2_bus[4] == 1) // CRT
					begin
				         nCPI = 0;
					@(negedge CPA or posedge sysclk);
					    if (CPA == 1)	//trap
					       begin		
						  @(posedge sysclk) enter_new_state(`FPU_1A);
						  SC_Type = 5'b10000;                           // change mode
						  RF_PC_Write_Sel = `RF_PC_WRITE_SEL_4;         // mux 4 into PC;
						  ir1_zero = 1;				      // clear out the pipeline
						  SC_Source = `SC_CTRL_SELECT_SOURCE_UND_MODE;  // select SVC mode
					       end // if (CPA == 1)
					     else
					       	begin
						  ld_ir2_mult = 1;
						  
						  if (ir2_bus[20] == 0)
						    begin
						  	BBUS_Src = 0; // select RF to drive B bus.
							WD_Load = 1; //load WDR
						  	B_Addr_Sel = `RF_ADDR_B_SEL_IR21512; // Rn
						     end
						  else	
						  	begin
						  	WD_DBE = 0; // output Z
							end
						  
						  while (CPB != 0)
						   begin
							@(posedge sysclk) enter_new_state(`FPU_2A); //waiting for them to finish
				         		nCPI = 0;
					 		nSTALL = 0;  		//stalling
						  	//ld_ir2_mult = 1;
						   end
							@(posedge sysclk) enter_new_state(`FPU_2A); //waiting for them to finish
				         	  nCPI = 0;
						  nOPC = 1;
					 	nSTALL = 0;  		//stalling
						  
							#1;
						  if (ir2_mult_bus[20] == 1)  // Load/Store
						     begin
							RF_Addr_Write_Sel = `RF_ADDR_WRITE_SEL_IR2_MULT1512;
							RF_Load_Write = 1;
							RF_Bus_Write_Sel = `RF_BUS_WRITE_SEL_D;
						     end
						  else	
						  	begin
						  	WD_DBE = 1; // output WDR
							end
						  //nSTALL = 1;  		//un-stalling
						  ld_ir2_mult = 0; 	 // latch multicycle instruction.
						 end	//else
					    //nCPI = 1;
					 end //if (ir2_bus[4] == 1)
				      else 	// CDO
					 begin	
					    nCPI = 0;
					@(negedge CPA or posedge sysclk);
					    if (CPA == 1)
					       begin
						  @(posedge sysclk) enter_new_state(`FPU_1A);
						  SC_Type = 5'b10000;                           // change mode
						  RF_PC_Write_Sel = `RF_PC_WRITE_SEL_4;         // mux 4 into PC;
						  ir1_zero = 1;				      // clear out the pipeline
						  SC_Source = `SC_CTRL_SELECT_SOURCE_UND_MODE;  // select SVC mode
					       end // if (CPA == 1) else
					      	begin
					       	  while (CPB != 0)
						    begin
							@(posedge sysclk) enter_new_state(`FPU_2A); //waiting for them to finish
						  nSTALL = 0;  		 //stalling
						     end
						  nSTALL = 0;  		 //stalling
							@(posedge sysclk) enter_new_state(`FPU_2A); //one more cycle after CPB <- 0
						  nSTALL = 1;  		 //un-stalling
					    	end  //else
					    nCPI = 1;
					 end //end CDO
				   end //if (ir2_bus[27:24] == 4'b1110)
				     else if (ir2_bus[27:25] == 3'b110)   //CDT
					begin
					   WD_DBE = 0; // output Z
					   if (ir2_bus[24] == 0)		//postindexing
					      begin
						 A_Addr_Sel = `RF_ADDR_A_SEL_IR21916;						      
						 AR_Bus_ALU_Sel = `AR_BUS_ALU_SEL_A_BUS;// selects A Bus
						 AR_Bus_Sel = 2'b01; // Select AR_Bus_Alu input to Add Reg
					      end
					   else if(ir2_bus[19:16] == 15)	// special case for r15
					      begin
						 AR_Bus_Sel = 2'b01; // Select PC+4 input to Add Reg			      
					      end
					   else				//all other cases
					      begin
						 ALU_Hold_Sel = 0; // Pass Alu_Result						 
						 ALU_Hold_Enable = 1;
						 AR_Bus_ALU_Sel = `AR_BUS_ALU_SEL_ALU_RESULT;// selects ALU_RESULT
						 AR_Bus_Sel = 2'b00; // Select AR_Bus_Alu input to Add Reg			      
						 A_Addr_Sel = `RF_ADDR_A_SEL_IR21916;						      
						 Alu_A_Sel = `ALU_A_SEL_A; // route A output to ALU input A
						 BS_Input_Sel = `BS_INPUT_SEL_EXT; // Barrel Shifter input is zero extended immediate
						 SZE_Ctrl = 0;
						 SZE_Sel = `SZE_SEL_IR2_70;
						 SAM_Ctrl = `SHIFT_TYPE3; // Logical shift left by 2
						 if (ir2_bus[23]==1) 
						    Alu_Cntrl = `ADD;
						 else
						    Alu_Cntrl = `SUB;
						 AR_Bus_Sel = 2'b00; // `AR_ALU_SEL = 2'b00; in regfile define file
						 AR_Bus_ALU_Sel = `AR_BUS_ALU_SEL_ALU_RESULT; // selects ALU out
					      end
					   nSTALL = 1;
					   
					   @(posedge sysclk) 
					      begin
						 ALU_Hold_Enable = 0;
						 AR_Bus_ALU_Sel = `AR_BUS_ALU_SEL_ALU_HOLD;
						 nSTALL = 0;
						 RF_PC_Write_Sel = 4'b0110;
						 ld_ir2_mult = 0;
						 nRW = 0;
						 nOPC = 1;				       
						 nMREQ = 0;  // request memory
						 #2;
						 while(~nWAIT)
						    begin
						       nSTALL = 0;
						       RF_PC_Write_Sel = 4'b0110;
						       #2;
						       if (nWAIT)
							  begin
							     nSTALL = 1;
							     nCPI = 0;
							     nMREQ = 1;  // deassertion
							  end
						       else
							  @(posedge sysclk) enter_new_state(`LOAD_REQUEST);
						    end // while (~nWAIT)
						 
						 nMREQ = 1;  // deassertion
					      end
					   // main loop where the coprocessor does work
					   
					@(negedge CPA or posedge sysclk);
					    if (CPA == 1)	//trap
					       begin		
						  @(posedge sysclk) enter_new_state(`FPU_1A);
						  SC_Type = 5'b10000;                           // change mode
						  RF_PC_Write_Sel = `RF_PC_WRITE_SEL_4;         // mux 4 into PC;
						  ir1_zero = 1;				      // clear out the pipeline
						  SC_Source = `SC_CTRL_SELECT_SOURCE_UND_MODE;  // select SVC mode
					       end // if (CPA == 1)
					     else
					       	begin
						  ld_ir2_mult = 1;
						  
						  while (CPB != 0)
						   begin
							@(posedge sysclk) enter_new_state(`FPU_2A); //waiting for them to finish
				         		nCPI = 0;
					 		nSTALL = 0;  		//stalling
						  	//ld_ir2_mult = 1;
						   end
							@(posedge sysclk) enter_new_state(`FPU_2A); //waiting for them to finish
				         	  nCPI = 0;
						  nOPC = 1;
					 	  nSTALL = 0;  		//stalling
						  ld_ir2_mult = 0; 	 // latch multicycle instruction.
						 //end	//else
							#1;

						 //get ready for post-indexing for multicycle cases
						 A_Addr_Sel = `RF_ADDR_A_SEL_IR2_MULT1916;						      
						 SZE_Sel = `SZE_SEL_IR2_MUL70;
						 RF_Addr_Write_Sel = `RF_ADDR_WRITE_SEL_IR2_MULT1916;    
						 nSTALL = 1;  //not stalling
						 
						 if (ir2_mult_bus[24] == 0)		//postindexing
						    begin
						       AR_Bus_ALU_Sel = `AR_BUS_ALU_SEL_ALU_RESULT;// selects ALU_RESULT
						       AR_Bus_Sel = 2'b00; // Select AR_Bus_Alu input to Add Reg			      
						       Alu_A_Sel = `ALU_A_SEL_A; // route A output to ALU input A
						       BS_Input_Sel = `BS_INPUT_SEL_EXT; // Barrel Shifter input is zero extended immediate
						       SZE_Ctrl = 0;
						       SAM_Ctrl = `SHIFT_TYPE3; // Logical shift left by 2
						       if (ir2_mult_bus[23]==1) 
							  Alu_Cntrl = `ADD;
						       else
							  Alu_Cntrl = `SUB;
						       AR_Bus_Sel = 2'b00; // `AR_ALU_SEL = 2'b00; in regfile define file
						       AR_Bus_ALU_Sel = `AR_BUS_ALU_SEL_ALU_RESULT; // selects ALU out
						    end
						 
						 //Write Back
						 if (ir2_mult_bus[21] == 1)
						    begin
						       RF_Bus_Write_Sel = `RF_BUS_WRITE_SEL_ALU_RESULT;	    
						       RF_Load_Write = 1;
						    end
						end //else	 
					nSTALL = 1;  //not stalling
					   nCPI = 1;
					end //else if (ir2_bus[27:25] == 3'b110)
			   
					  else $display("other instructions...");
			end // if (condx(ir2_bus[31:28],RF_PSR_Read))
		  end // else: !if(nIRQ == 0)
	    end // forever @(sysclk
      end // always begin
   
   // ENTER NEW STATE TASK ////////////////////////////////////////////////////
   
   task enter_new_state;
      input [`NUM_STATE_BITS-1:0] this_state;
      begin
	 present_state = this_state;
	 
	 // reset signals to their defaults
	 //ir1_zero = 0;
	 //ir2_zero = 0;

         //nOPC = 0;
	 WD_Load = 0;
	 WD_DBE = 0;
	 RF_Load_Write = 0;	 	 
         if ((ir2_bus[27:24] != 4'b1011) && 
             !((ir2_bus[27:22] == 6'b000000) && (ir2_bus[7:4] == 4'b1001)))
            Link_Sel = 0;

	 // reset all other signals to 0...

	 // Register File
	 A_Addr_Sel = 0; 
	 B_Addr_Sel = 0;
	 RF_Addr_Write_Sel = 3'b100;
	 //RF_Bus_Write_Sel = 2'b00;
	 RF_PC_Write_Sel = 4'b0110;
	 RF_Load_Flags = 0;
	 RF_PSR_R_Sel = 0;	 
	 RF_PSR_W_Sel = 0;	 

	 // Super CPSR
	 SC_Type = 0;
	 SC_Source = 0;

	 // Zero/Sign Extender
	 SZE_Sel = 2'b00;
	 SZE_Ctrl = 0;

	 // Barrel Shifter
	 SAM_Ctrl = 2'b00;
	 BS_Input_Sel = 0;	 
	 BS_Enable = 0;
	 BS_Cin = 0;   

	 // Address Register
	 //AR_Bus_ALU_Sel = 0;
	 //AR_Bus_Sel = 2'b01;	 

	 //Coprocessor	 	     
	 nCPI = 1;   

	 //Memory Interface
	 nMREQ = 1;
	 nRW = 0;
	 //MAS = 2'b00;		 

	 //ALU
	 //Alu_A_Sel = 2'b00;
	 Alu_Cntrl = 5'b00000;	 

	 //Multiplier
	 Multiplier_Enable = 0;	

	 //general		
	 ld_ir2_mult = 0;
	 nSTALL = 1;
	 BBUS_Src = 0;
	
      end
   endtask // enter_new_state
   
   // CONDX FUNCTION //////////////////////////////////////////////////////////
   
   function condx;
      input [3:0] condtype;
      input [31:0] cpsr;
      begin
	 case (condtype)
	   4'b0000: condx = cpsr[30];  // EQ
	   4'b0001: condx = !cpsr[30]; // NE
	   4'b0010: condx = cpsr[29];  // CS
	   4'b0011: condx = !cpsr[29]; // CC
	   4'b0100: condx = cpsr[31];  // MI
	   4'b0101: condx = !cpsr[31]; // PL
	   4'b0110: condx = cpsr[28];  // VS
	   4'b0111: condx = !cpsr[28]; // VC
	   // 4'b1000: condx = cpsr[29] & !cpsr[30];  // HI
	   4'b1000: condx = cpsr[29] && !cpsr[30];  // HI
`ifdef BUG1
	   4'b1001: condx = !cpsr[29] & cpsr[30];  // LS
`else
	   4'b1001: condx = !cpsr[29] || cpsr[30];  // LS
`endif
	   4'b1010: condx = cpsr[31] == cpsr[28];  // GE
	   4'b1011: condx = cpsr[31] != cpsr[28];  // LT
	   4'b1100: condx = !cpsr[30] && (cpsr[31] == cpsr[28]);  // GT
	   4'b1101: condx = cpsr[30] || (cpsr[31] != cpsr[28]);  // LE
	   4'b1110: condx = 1;         // AL
	   default: condx = 0;
	 endcase // case(condtype)
      end
   endfunction // condx
   
endmodule // armcontroller
					      


