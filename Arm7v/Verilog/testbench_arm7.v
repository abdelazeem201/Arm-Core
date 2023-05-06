/////////////////////////////////////////////////////////////////
//  ARM7 TOP LEVEL TEST BENCH v1.0,  4-6-2000                  //
//  ECE 371 EMR, Spring 2000                                   //
//  Test Bench Team:  Steve Behling                            //
//  COMPONENT:  TEST CHIP                                      //
// ----------------------------------------------------------- //
// Modified by J. Shin 8/30/00 -- removed memory from datapath // 
/////////////////////////////////////////////////////////////////

`timescale 1ns/100ps

/////////////////////////////
// Include component files //
/////////////////////////////

`include "arm7_sys.v"

////////////////
//Clock module//
////////////////
module cl(clk);
        parameter TIME_LIMIT = 110000;
        output  clk;
        reg clk;

        initial
                clk=0;
        always
                #5 clk = ~clk;
        always @(posedge clk)
                if ($time > TIME_LIMIT) #70 $stop;
endmodule

///////////////////////////
// Top Test Bench Module //
///////////////////////////
module top;

   //Coprocessor
   wire 	 nOPC,nCPI;
   wire 	 CPA,CPB;

   //general
   wire		sysclk;

   // Exception Signals
   reg		nRESET;
   reg		ABORT;
   reg		nFIQ;
   reg		nIRQ;

   integer ifile, dfile, dmemout_file, regout_file;
   integer i;

	///////////////////////////////////////////////
	//    Instantiate test chip                  //
	///////////////////////////////////////////////

   //Instantiate the arm7 
   arm7_sys arm7_sys_DUT (nOPC, nCPI, CPA, CPB, sysclk, nRESET, nFIQ, nIRQ, ABORT);

   //Instantiate clock
   cl #20000 clock(sysclk);
/////////////////////////////////////////////////////////////////

   always
       @(posedge sysclk)
        begin
         // $display ("%d: ir1=%x ir2=%x  R15=%x  R14=%x", $time, 
         //   arm7_sys_DUT.DUT_ARM7.DUT_DATA.ir1, arm7_DUT.ir2_bus, 
         //   arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r15,
         //   arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r14);
         // $display ("R14=%x", arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r14);
         // $display ("Rd=%x  ALU_Result=%x  RF_PSR_Read=%b", 
         //   arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r13,
         //   arm7_sys_DUT.DUT_ARM7.DUT_DATA.ALU_Result,arm7_sys_DUT.DUT_ARM7.DUT_DATA.RF_PSR_Read);
        end 

   initial
       begin
        // $stop;

        arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r1 =
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r2 =
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r3 =
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r4 =
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r5 =
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; 
        arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r6 =
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r7 =
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r8 =
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r9 =
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r10 =
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r11 =
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r12 =
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r13 =
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r14 =
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r15 =
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;

                              // instruction memory background = NOP
        for (i = 0; i <= 'h7000; i = i + 1) 
          begin
             arm7_sys_DUT.DUT_MMU.themem.mem_array[i] = 'he1a00000;
          end
                              // data memory background = UNKNOWN
        for (i = 'h7000; i <= 65536; i = i + 1) 
          begin
             arm7_sys_DUT.DUT_MMU.themem.mem_array[i] = 
               32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
          end
                              // initialize exception handling code
                              // initialize exception handling code
        $readmemh ("exception.mem", arm7_sys_DUT.DUT_MMU.themem.mem_array);
                              // initialize instruction memory
        $readmemh ("arm7.imem", arm7_sys_DUT.DUT_MMU.themem.mem_array);
                              // initialize data memory
        $readmemh ("arm7.dmem", arm7_sys_DUT.DUT_MMU.themem.mem_array);

	nFIQ = 1'b1;
	nIRQ = 1'b1;
	ABORT = 1'b0;
	nRESET = 1'b1;
	// nRESET = 1'b0;
	// #50 nRESET = 1'b1;

#10000;
	//Made for exiting via software interrupt handler
// $swi_init(DUT_DATA.A_MAR, sysclk);

	//initialization for my cases API
// $check_state(sysclk);

	//register monitoring PLI
// $regmon_init(ir2_bus,DUT_DATA.regfile1.RF_Addr_Write,DUT_DATA.regfile1.RF_Bus_Write,DUT_DATA.regfile1.RF_Load_Write);

	//if you want to make dump of all of the signal changes
	//$my_monitor(DUT_DATA);

        dmemout_file = $fopen("arm7.dmemout");  //open dmem output file
        // print out used data memory
        // for (i = 0; i <= 65536; i = i + 1) 
        for (i = 'ha000; i <= 65536; i = i + 1) 
           if (arm7_sys_DUT.DUT_MMU.themem.mem_array[i] !==
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
             begin
                $fdisplay (dmemout_file, "%h %h", i, 
                   arm7_sys_DUT.DUT_MMU.themem.mem_array[i]);
             end
        $fclose (dmemout_file);

        regout_file = $fopen ("arm7.regout"); // open reg output file
        if (arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r0 !==
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
           $fdisplay (regout_file, "%0h %h", 0, 
                      arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r0);
        if (arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r1 !==
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
           $fdisplay (regout_file, "%0h %h", 1, 
                      arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r1);
        if (arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r2 !==
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
           $fdisplay (regout_file, "%0h %h", 2, 
                      arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r2);
        if (arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r3 !==
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
           $fdisplay (regout_file, "%0h %h", 3, 
                      arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r3);
        if (arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r4 !==
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
           $fdisplay (regout_file, "%0h %h", 4, 
                      arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r4);
        if (arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r5 !==
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
           $fdisplay (regout_file, "%0h %h", 5, 
                      arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r5);
        if (arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r6 !==
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
           $fdisplay (regout_file, "%0h %h", 6, 
                      arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r6);
        if (arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r7 !==
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
           $fdisplay (regout_file, "%0h %h", 7, 
                      arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r7);
        if (arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r8 !==
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
           $fdisplay (regout_file, "%0h %h", 8, 
                      arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r8);
        if (arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r9 !==
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
           $fdisplay (regout_file, "%0h %h", 9, 
                      arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r9);
        if (arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r10 !==
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
           $fdisplay (regout_file, "%0h %h", 10, 
                      arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r10);
        if (arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r11 !==
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
           $fdisplay (regout_file, "%0h %h", 11, 
                      arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r11);
        if (arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r12 !==
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
           $fdisplay (regout_file, "%0h %h", 12, 
                      arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r12);
        if (arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r13 !==
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
           $fdisplay (regout_file, "%0h %h", 13, 
                      arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r13);
        if (arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r14 !==
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
           $fdisplay (regout_file, "%0h %h", 14, 
                      arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r14);
        if (arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r15 !==
              32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx)
           $fdisplay (regout_file, "%0h %h", 15, 
                      arm7_sys_DUT.DUT_ARM7.DUT_DATA.regfile1.rf_int_r15);

        $finish;
      end

endmodule

