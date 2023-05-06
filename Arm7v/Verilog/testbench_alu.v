/////////////////////////////////////////////////////////////
//  Verilog Test Bench v2.0,  3-28-2000                    //
//  ECE 371 EMR, Spring 2000                               //
//  By Steve Behling                                       //
//  COMPONENT:  ALU                                        //
//  INCLUDED FILE: alu.v                                   //
//  FILE OUTPUT:  alu_test.out                             //
//  DIRECTIONS:  Supply test inputs below where specified. //
//               If verbose == 0, a specific test is run,  //
//               and thus Alu_Cntrl,Expected_Result, and   //
//               Expected_Signals must be supplied.        //
//               If verbose == 1, only Alu_A,Alu_B, and    //
//               Alu_C need be supplied.  All possible     //
//               operations will be performed and logged.  //
/////////////////////////////////////////////////////////////

//Instantiate ALU for DUT
`include "alu.v"

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
                #50 clk = ~clk;
        always @(posedge clk)
                if ($time > TIME_LIMIT) #70 $stop;
endmodule

////////////////////////
//top level test bench//
////////////////////////
module alu_top;
        reg [31:0] Alu_A, Alu_B;
        reg Alu_C;
        reg [4:0] Alu_Cntrl;
	reg [31:0] Expected_Result; //Supplied by the user
	reg [3:0] Expected_Signals;

        wire [31:0] Alu_Result;
        wire [3:0] Alu_Signals;
        wire sysclk;

	integer file;       //the number for the log file
	integer num_tests;  //the number of tests ran
	integer num_errors; //the number of errors found
	integer verbose;    //1: dump all results to file, 0: log errors only

        cl #20000 clock(sysclk);  //instantiate clock

	//instantiate device under test
        ALU_ARM7 ALU_DUT(Alu_A, Alu_B, Alu_C, 
                         Alu_Cntrl, Alu_Signals, Alu_Result);

	//Open logfile and begin tests
	initial
	 begin
	   num_tests = 0;
	   num_errors = 0;
	   $stop;

	   file = $fopen("test_alu.out");  //open the log file

	   $fdisplay(file,"ALU Test Log");
	   $fdisplay(file,"___________________");

	//////////////////////
	//Supply tests here!//
	//////////////////////

	Alu_A = 12;
	Alu_B = 4;
	Alu_C = 0;
	Expected_Result = 8;
	Expected_Signals = 0;
	Alu_Cntrl = 2;   //expected result == 8
	verbose = 0;

	out_to_file;     //invokes logging!
    @(posedge sysclk);

	Alu_A = 7;
	Alu_B = 2;
	Alu_C = 0;
	verbose = 1;

	out_to_file;     //invokes logging! (series of tests)
    @(posedge sysclk);

	Alu_A = 7;
	Alu_B = 2;
	Alu_C = 1;
	verbose = 1;

	out_to_file;     //invokes logging! (series of tests)
    @(posedge sysclk);

	Alu_A = 128;
	Alu_B = 64;
	Alu_C = 1;
	verbose = 1;

	out_to_file;     //invokes logging! (series of tests)
    @(posedge sysclk);

	Alu_A = 12;
	Alu_B = 4;
	Alu_C = 0;
	Expected_Result = 8;
	Expected_Signals = 0;
	Alu_Cntrl = 2;   //expected result == 8
	verbose = 0;

	out_to_file;     //invokes logging!
    @(posedge sysclk);

	//END TESTS//

	$fdisplay(file,"%d tests ran, %d errors found",num_tests,num_errors);
	$fdisplay(file,"--Tests Completed--");  //signal end of tests

	$stop;               // Halt simulator
	$finish;             // Stop all simulation
	$fclose(file);       // It's always good to close what you open

	   end


  /////////////////////////////////
  // Perform test and log errors //
  /////////////////////////////////
  task out_to_file;
   begin
	if (verbose == 1) //perform all operations and log ALL results
	  begin
	    for (Alu_Cntrl=0; Alu_Cntrl <= 12; Alu_Cntrl=Alu_Cntrl + 1)
              begin
                @(posedge sysclk);
                $fdisplay(file,"Alu_A=%h Alu_B=%h Alu_C=%h Alu_Cntrl=%b Alu_Result=%h Alu_Signals=%b",Alu_A,Alu_B,Alu_C,Alu_Cntrl,Alu_Result,Alu_Signals);
		num_tests = num_tests + 1;
              end
	    $fdisplay(file,"================");
          end
	else if (verbose == 0) //perform selected test and only log errors
	  begin
	    @(posedge sysclk);
	    num_tests = num_tests + 1;
	    if ( (Alu_Result !== Expected_Result ) ||
		 (Alu_Signals !== Expected_Signals) )
	      begin
	        num_errors = num_errors + 1;
	        $fdisplay(file,"******Incorrect RESULT or FLAGS!******");
                $fdisplay(file,"Alu_A=%h Alu_B=%h Alu_C=%h Alu_Cntrl=%b Alu_Result=%h Expected_Result=%h Alu_Signals=%b Expected_Signals=%b",Alu_A,Alu_B,Alu_C,Alu_Cntrl,Alu_Result,Expected_Result,Alu_Signals,Expected_Signals);
	      end
	    else
	      begin
		$fdisplay(file,"Test#%d ran without incident.",num_tests);
	      end
	    $fdisplay(file,"================");
          end
   end
  endtask

endmodule


