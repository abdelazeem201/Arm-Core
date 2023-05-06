/////////////////////////////////////////////////////////////////
//  Verilog Test Bench v2.0,  4-3-2000                        //
//  ECE 371 EMR, Spring 2000                                   //
//  Test Bench Team:  Steve Behling			       //
//  COMPONENT:  REGISTER FILE                                  //
//  FILE OUTPUT:  test_reg.out				       //
/////////////////////////////////////////////////////////////////

//Include register file for DUT
`include "regfile.v"


///////////////////////////////
//Clock module:  10 ns cycles//
///////////////////////////////
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


//////////////////////////////////////////////////////
// Top-level module instantiates the register files //
//////////////////////////////////////////////////////
module reg_top;
	reg [`ADDRLEN-1:0] RF_Addr_A, RF_Addr_B, RF_Addr_C, RF_Addr_Write;
	reg [`FLAGSLEN-1:0] RF_Flags_Write;
	reg [`DBUSLEN-1:0] RF_Bus_Write, RF_PC_Write;
	reg RF_Load_Write,RF_Load_Flags,RF_PSR_R_Sel,RF_PSR_W_Sel;

	wire [`DBUSLEN-1:0] RF_Bus_A,RF_Bus_B,RF_Bus_C,RF_PC_Read, RF_PSR_Read;
	wire sysclk;

	integer file;       //the number for the log file
	integer num_tests;  //the number of tests run
	integer verbose;    //0: log out results only, 1: dump registers


	cl #20000 clock(sysclk);  //instantiate clock

	//Instantiate register files!
	registerfile test_reg(RF_Addr_A,RF_Addr_B,RF_Addr_C,RF_Addr_Write,
			RF_Bus_Write,RF_Load_Write,RF_PC_Write,
			RF_Flags_Write,RF_Load_Flags,RF_PSR_R_Sel,
			RF_PSR_W_Sel,RF_Bus_A,RF_Bus_B,RF_Bus_C,
			RF_PC_Read,RF_PSR_Read,sysclk);

	//Open logfile and begin tests
	initial
	 begin
	   num_tests = 0;
	   $stop;

	   file = $fopen("test_reg.out");  //open the log file

	   $fdisplay(file,"Register File Test Log");
	   $fdisplay(file,"___________________");

/////////////////////////////////////////////////////////
	//Supply tests here!//
/////////////////////////////////////////////////////////
@(posedge sysclk);
	RF_Flags_Write = `MODE_USER;
	RF_Load_Flags = 1'b1;
	RF_PSR_W_Sel = 1'b0;
	RF_PSR_R_Sel = 1'b0;   //set up user mode first
	RF_Load_Write = 1'b0;

#20
	RF_Load_Flags = 1'b0;

	RF_Addr_A = 0;
	RF_Addr_B = 0;
	RF_Addr_C = 1;
	RF_Addr_Write = 0;
	RF_Load_Write = 1'b1;
	RF_Bus_Write = 255;
//	RF_Flags_Write = `MODE_USER;
//	RF_PSR_W_Sel = 1'b0;
//	RF_PSR_R_Sel = 1'b0;
//	RF_Load_Flags = 1'b1;
	RF_PC_Write = 4;
      out_to_file;         //perform test

	RF_Addr_A = 0;
	RF_Addr_B = 0;
	RF_Addr_C = 1;
	RF_Addr_Write = 1;
	RF_Load_Write = 1'b1;
	RF_Bus_Write = 65535;
	RF_Flags_Write = `MODE_USER;
	RF_PSR_W_Sel = 1'b0;
	RF_PSR_R_Sel = 1'b0;
	RF_Load_Flags = 1'b0;
	RF_PC_Write = 8;
      out_to_file;         //perform test

	RF_Addr_A = 0;
	RF_Addr_B = 1;
	RF_Addr_C = 1;
	RF_Addr_Write = 2;
	RF_Load_Write = 1'b1;
	RF_Bus_Write = 4095;
	RF_Flags_Write = `MODE_USER;
	RF_PSR_W_Sel = 1'b0;
	RF_PSR_R_Sel = 1'b0;
	RF_Load_Flags = 1'b0;
	RF_PC_Write = 12;
      out_to_file;         //perform test

	RF_Addr_A = 0;
	RF_Addr_B = 1;
	RF_Addr_C = 2;
	RF_Addr_Write = 3;
	RF_Load_Write = 1'b1;
	RF_Bus_Write = 32;
	RF_Flags_Write = `MODE_USER;
	RF_PSR_W_Sel = 1'b0;
	RF_PSR_R_Sel = 1'b0;
	RF_Load_Flags = 1'b0;
	RF_PC_Write = 16;
      out_to_file;         //perform test
/////////END TESTS///////////////////////////////////////

	$fdisplay(file,"%d tests run",num_tests);
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

	num_tests = num_tests + 1;

	$fdisplay(file,"%d Addr_A:%h Addr_B:%h Addr_C:%h", $time,
                    RF_Addr_A, RF_Addr_B, RF_Addr_C);
	$fdisplay(file,"Addr_Write:%h Bus_Write:%h Load_Write:%b",
		    RF_Addr_Write,RF_Bus_Write,RF_Load_Write);
	$fdisplay(file,"PC_Write:%h Flags_Write:%h Load_Flags:%b",
		    RF_PC_Write,RF_Flags_Write, RF_Load_Flags);
	$fdisplay(file,"PSR_R_Sel:%b PSR_W_Sel:%b",
		    RF_PSR_R_Sel, RF_PSR_W_Sel);
#10;
//@(posedge sysclk);
	$fdisplay(file,"Bus_A:%h Bus_B:%h Bus_C:%h PC_Read:%h PSR_Read:%h",
		    RF_Bus_A,RF_Bus_B,RF_Bus_C,RF_PC_Read,RF_PSR_Read);
	$fdisplay(file,"================");

   end
  endtask

endmodule
