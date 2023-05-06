// testbench for write data register

`include "wd_reg.v"

module top;

   reg	sysclk;
   reg	[31:0]	WD_Bus_Write;
   reg	WD_DBE, WD_Load;
   wire	[31:0]	WD_DOUT;

   integer file;       //the number for the log file
   integer num_tests;  //the number of tests run

   wd_reg	wd0(WD_Bus_Write,WD_DBE,WD_Load,WD_DOUT,sysclk);

   initial sysclk = 0;

   always #5 sysclk = ~sysclk;

   always #500 $finish;

   initial
      begin
        num_tests = 0;
	$stop;

        file = $fopen ("test_wd_reg.out");  //open the log file
        $fdisplay (file,"wd_reg Test Log");
        $fdisplay (file,"___________________");

	WD_Bus_Write = 32'h00000000;
        WD_Load = 1'b1;
	WD_DBE = 1'b1;
        out_to_file;

	#20;
	WD_Bus_Write = 32'h55555555;
        WD_Load = 1'b0;
	WD_DBE = 1'b0;
        out_to_file;

	#20;
	WD_Bus_Write = 32'hAAAAAAAA;
        WD_Load = 1'b0;
        out_to_file;

	#20;
	WD_DBE = 1'b1;
        out_to_file;

	#20;
	WD_Bus_Write = 32'h12121212;
        WD_Load = 1'b1;
        out_to_file;

	#20;
	WD_DBE = 1'b1;
        out_to_file;

	#20;
	WD_Bus_Write = 32'h55555555;
        WD_Load = 1'b1;
	WD_DBE = 1'b0;
        out_to_file;

	#20;
	WD_Bus_Write = 32'h00000000;
        out_to_file;

	#20;
	WD_DBE = 1'b1;
        out_to_file;

	#20;
        out_to_file;
        $fdisplay (file,"%d tests run", num_tests);
        $fdisplay (file,"--Tests Completed--");  //signal end of tests

	$finish;
        $fclose (file);
end

  task out_to_file;
      begin
         @(posedge sysclk) #1;
         num_tests = num_tests + 1;
         $fdisplay (file, "WD_Bus_Write=%h WD_DBE=%b WD_Load=%b WD_DOUT=%h",
           WD_Bus_Write, WD_DBE, WD_Load, WD_DOUT);

         $fdisplay(file,"================");
      end
  endtask


endmodule
