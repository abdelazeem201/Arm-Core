/////////////////////////////////////////////////////////////
//  Verilog Test Bench v2.0,  3-29-2000                    //
//  ECE 371 EMR, Spring 2000                               //
//  By Steve Behling                                       //
//  COMPONENT:  BOOTH MULTIPLIER                           //
//  INCLUDED FILE: booth.v                                 //
//  FILE OUTPUT:  test_booth.out                           //
//  DIRECTIONS:  Supply test inputs below where specified. //
//               If verbose == 0, only errors are logged.  //
//               If verbose == 1, all tests are logged.    //
//  SAMPLE TEST:					   //
//	Multiplier_A = 32;				   //
//	Multiplier_B = 256;  //expect to see 8192          //	
//	verbose = 1;					   //
//							   //
//	out_to_file;     //invokes logging!		   //
//    @(posedge sysclk);				   //
/////////////////////////////////////////////////////////////

//Instantiate Multiplier for DUT
`include "booth.v"

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
module booth_top;
        reg [31:0] Multiplier_A, Multiplier_B;
        reg enable;
	reg [31:0] Expected_Result; //Equal to Multiplier_A * Multiplier_B

        wire [31:0] Multiplier_Result;
        wire ready;
        wire sysclk;

	integer file;       //the number for the log file
	integer num_tests;  //the number of tests run
	integer num_errors; //the number of errors found
	integer verbose;    //1: dump all results to file, 0: log errors only

        cl #200000 clock(sysclk);  //instantiate clock

	//instantiate device under test
        Booth_multiplier MULT_DUT(enable, Multiplier_A, Multiplier_B, Multiplier_Result, ready, sysclk);

	//Open logfile and begin tests
	initial
	 begin
	   num_tests = 0;
	   num_errors = 0;
	   $stop;

	   file = $fopen("test_booth.out");  //open the log file

	   $fdisplay(file,"Multiplier Test Log");
	   $fdisplay(file,"___________________");

/////////////////////////////////////////////////////////
	//Supply tests here!//
/////////////////////////////////////////////////////////

	Multiplier_A = 12;
	Multiplier_B = 4;   //expect to see a result of 48
	verbose = 0;

	out_to_file;     //invokes logging!

    @(posedge sysclk);
	Multiplier_A = 32;
	Multiplier_B = 256;  //expect to see 8192
	verbose = 1;
	out_to_file;     //invokes logging!

    @(posedge sysclk);
	Multiplier_A = 2;
	Multiplier_B = 11;  //expect to see 22
	verbose = 1;
	out_to_file;     //invokes logging!

    @(posedge sysclk);
	Multiplier_A = 4;
	Multiplier_B = 11;  //expect to see 44
	verbose = 1;
	out_to_file;     //invokes logging!

    @(posedge sysclk);
	Multiplier_A = 12;
	Multiplier_B = 12;  //expect to see 144
	verbose = 1;
	out_to_file;     //invokes logging!

    @(posedge sysclk);


/////////END TESTS///////////////////////////////////////

	$fdisplay(file,"%d tests run, %d errors found",num_tests,num_errors);
	$fdisplay(file,"--Tests Completed--");  //signal end of tests

	$stop;               // Halt simulator
	$finish;             // Stop all simulation
	$fclose (file);      // It's always good to close what you open

	   end


  /////////////////////////////////
  // Perform test and log errors //
  /////////////////////////////////
  task out_to_file;
   begin
	@(posedge sysclk);
	enable = 1'b1;
	@(posedge sysclk);
	wait(~ready);
	enable = 1'b0;
	wait(ready);
	@(posedge sysclk);

	Expected_Result = Multiplier_A * Multiplier_B;

	if (verbose == 1)	//log ALL results
	  begin
	    if ( Multiplier_Result !== Expected_Result )
	      begin
	        num_errors = num_errors + 1;
		$fdisplay(file,"******Incorrect Result!******");
	      end
                $fdisplay(file,"Multiplier_A=%h Multiplier_B=%h Multiplier_Result=%h Expected_Result=%h",Multiplier_A,Multiplier_B,Multiplier_Result,Expected_Result);
		num_tests = num_tests + 1;
	    $fdisplay(file,"================");
          end
	else if (verbose == 0)	//only log errors
	  begin
	    num_tests = num_tests + 1;
	    if ( Multiplier_Result !== Expected_Result )
	      begin
	        num_errors = num_errors + 1;
	        $fdisplay(file,"******Incorrect Result!******");
  		$fdisplay(file,"Multiplier_A=%h Multiplier_B=%h Multiplier_Result=%h Expected_Result=%h",Multiplier_A,Multiplier_B,Multiplier_Result,Expected_Result);              
	      end
	    else
	      begin
		$fdisplay(file,"Test#%d run without incident.",num_tests);
	      end
	    $fdisplay(file,"================");
          end
   end
  endtask

endmodule


