// testbench for register file

// really really incomplete in number of tests!

`include "regfile.v"

module top;

   reg sysclk;

   reg		[`ADDRLEN-1:0]	RF_Addr_A,RF_Addr_B,RF_Addr_C,RF_Addr_Write;
   reg		[`DBUSLEN-1:0]	RF_Bus_Write,RF_PC_Write;
   reg		RF_Load_Write,RF_Load_Flags,RF_PSR_R_Sel,RF_PSR_W_Sel;	
   reg		[`FLAGSLEN-1:0]	RF_Flags_Write;

// outputs regs
   wire		[`DBUSLEN-1:0]	RF_Bus_A,RF_Bus_B,RF_Bus_C,RF_PC_Read,RF_PSR_Read;

   integer file;       //the number for the log file
   integer num_tests;  //the number of tests run

   registerfile myregs (RF_Addr_A, RF_Addr_B, RF_Addr_C, RF_Addr_Write,
                        RF_Bus_Write, RF_Load_Write, RF_PC_Write,
                        RF_Flags_Write, RF_Load_Flags, RF_PSR_R_Sel,
                        RF_PSR_W_Sel, RF_Bus_A, RF_Bus_B, RF_Bus_C,
                        RF_PC_Read, RF_PSR_Read, sysclk);

   initial sysclk = 0;

   always #5 sysclk = ~sysclk;

   always #1000 $finish;

   initial
      begin
        num_tests = 0;
	$stop;

        file = $fopen ("test_regfile.out");  //open the log file
        $fdisplay (file,"regfile Test Log");
        $fdisplay (file,"___________________");

	@(posedge sysclk);
	RF_Flags_Write = `MODE_USER;	// set processor mode
	RF_Load_Flags = 1;		// enable loading of cpsr
	RF_PSR_W_Sel = 0;
	RF_PSR_R_Sel = 0;
	RF_Load_Write = 1'b0;
        out_to_file;

	@(posedge sysclk);
        out_to_file;

	@(posedge sysclk);
	RF_Load_Flags = 0;
	RF_Addr_A = 4'b0000;
	RF_Addr_B = 4'b0001;
	RF_Addr_C = 4'b0010;
	RF_Addr_Write = 4'b0000;
	RF_Bus_Write = 32'h0a;
	RF_Load_Write = 1'b1;
        out_to_file;

	@(posedge sysclk);
	RF_Addr_Write = 4'b0001;
	RF_Bus_Write = 32'h0b;
        out_to_file;

	@(posedge sysclk);
	RF_Addr_Write = 4'b0010;
	RF_Bus_Write = 32'h0c;
        out_to_file;

	@(posedge sysclk);
	RF_Load_Write = 1'b0;
	RF_Addr_Write = 4'b0000;
	RF_Bus_Write = 32'h00;
        out_to_file;

	@(posedge sysclk);
	RF_Addr_A = 4'b0000;
	RF_Addr_B = 4'b0000;
	RF_Addr_C = 4'b0000;
        out_to_file;

	@(posedge sysclk);
	RF_Addr_A = 4'b0001;
	RF_Addr_B = 4'b0001;
	RF_Addr_C = 4'b0001;
        out_to_file;

	@(posedge sysclk);
	RF_Addr_A = 4'b0010;
	RF_Addr_B = 4'b0010;
	RF_Addr_C = 4'b0010;
        out_to_file;

	@(posedge sysclk);
	RF_Addr_A = 4'b0000;
	RF_Addr_B = 4'b0000;
	RF_Addr_C = 4'b0000;
        out_to_file;

	@(posedge sysclk);
	RF_Addr_A = 4'b0010;
	RF_Addr_B = 4'b0001;
	RF_Addr_C = 4'b0000;
        out_to_file;

	@(posedge sysclk);
	$stop;
	
	RF_Load_Write = 1'b0;
        out_to_file;

	@(posedge sysclk);
	RF_Addr_A = 4'b0010;
	RF_Bus_Write = 32'hFFFFFFFF;
        out_to_file;

	@(posedge sysclk);
	RF_Load_Write = 1'b1;
        out_to_file;

	@(posedge sysclk);
	RF_Load_Write = 1'b0;
	RF_Addr_A = 4'b0000;
        out_to_file;

	@(posedge sysclk);
        out_to_file;

	@(posedge sysclk);
        out_to_file;

	@(posedge sysclk);
	RF_Flags_Write = `MODE_FIQ;	// change processor mode
	RF_Load_Flags = 1;
        out_to_file;

	@(posedge sysclk);
	RF_Load_Flags = 0;
        out_to_file;

	@(posedge sysclk);
	RF_PSR_R_Sel = 1;
        out_to_file;

	@(posedge sysclk);
        out_to_file;

	@(posedge sysclk);
        out_to_file;

	@(posedge sysclk);
	RF_PSR_R_Sel = 0;
        out_to_file;

	@(posedge sysclk);
        out_to_file;

	@(posedge sysclk);
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
         $fdisplay (file, "Load_Write=%b Addr_Write=%h Bus_Write=%h",
           RF_Load_Write, RF_Addr_Write, RF_Bus_Write); 
         $fdisplay (file, "Addr_A=%h Addr_B=%h Addr_C=%h Bus_A=%h Bus_B=%h Bus_C=%h", 
           RF_Addr_A, RF_Addr_B, RF_Addr_C, 
           RF_Bus_A, RF_Bus_B, RF_Bus_C);
         $fdisplay (file, "RF_PC_Write=%h RF_Load_Flags=%b RF_PSR_R_Sel=%b RF_PSR_W_Sel=%b RF_Flags_Write=%b RF_PC_Read=%h RF_PSR_Read=%h",
           RF_PC_Write, RF_Load_Flags,
           RF_PSR_R_Sel, RF_PSR_W_Sel, RF_Flags_Write, 
           RF_PC_Read, RF_PSR_Read);

         $fdisplay(file,"================");
      end
  endtask

endmodule

