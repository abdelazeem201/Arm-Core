`include "addr_reg.v"

module	top;

   reg	[31:0]	AR_Bus_Alu, AR_Bus_PC, AR_Bus_PC_4;
   reg	[1:0]	AR_Bus_Sel;
   reg	sysclk;
   wire	[31:0]	AR_Output_Bus;

   integer file;       //the number for the log file
   integer num_tests;  //the number of tests ran

   initial	sysclk = 0;

   always #5 sysclk = ~sysclk;

   always #500 $finish;

   addr_reg	ar0(AR_Bus_Alu,AR_Bus_PC,AR_Bus_PC_4,AR_Bus_Sel,AR_Output_Bus,sysclk);

   initial
      begin
        num_tests = 0;
	$stop;

        file = $fopen("test_addr_reg.out");  //open the log file
        $fdisplay(file,"addr_reg Test Log");
        $fdisplay(file,"___________________");

	AR_Bus_Alu = 32'h00000000;
	AR_Bus_PC = 32'h55555555;
	AR_Bus_PC_4 = 32'hAAAAAAAA;
	AR_Bus_Sel = `AR_ALU_SEL;
        out_to_file;     //invokes logging!

	#10;
	AR_Bus_Alu = 32'hFFFFFFFF;
	AR_Bus_Sel = `AR_PC_SEL;
        out_to_file;     //invokes logging!

	#10;
	AR_Bus_PC_4 = 32'h33333333;
	AR_Bus_PC = 32'h11111111;
	AR_Bus_Sel = `AR_PC_4_SEL;
        out_to_file;     //invokes logging!

	#10;
	AR_Bus_Sel = `AR_ALU_SEL;
	AR_Bus_PC_4 = 32'hFFFFFFFF;
        out_to_file;     //invokes logging!

	#10;
        out_to_file;

        $fdisplay(file,"%d tests run",num_tests);
        $fdisplay(file,"--Tests Completed--");  //signal end of tests

	$finish;
        $fclose(file);
   end

  task out_to_file;
      begin
         @(posedge sysclk);
         num_tests = num_tests + 1;
         $fdisplay (file, "AR_Bus_Alu=%h AR_Bus_PC=%h AR_Bus_PC_4=%h AR_Bus_Sel=%b AR_Output_Bus=%h",
           AR_Bus_Alu, AR_Bus_PC, AR_Bus_PC_4, AR_Bus_Sel,
           AR_Output_Bus);

         $fdisplay(file,"================");
      end
  endtask

endmodule
