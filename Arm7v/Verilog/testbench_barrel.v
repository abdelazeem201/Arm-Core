`include "barrel.v"

module top_Barrel_Shifter;

   reg [31:0] Input_Bus;
   reg [1:0]  Shift_Type;
   reg [4:0]  Shift_Amt;
   reg Cin,Enable;
   wire [31:0] Output_Bus;
   wire Cout;
   integer i;

   integer file;       //the number for the log file
   integer num_tests;  //the number of tests run
   
   Barrel_Shifter BS1(Enable,Input_Bus,Shift_Type,Shift_Amt,Cin,Output_Bus,Cout);

   initial
      begin
        num_tests = 0;
        $stop;

        file = $fopen ("test_barrel.out");  //open the log file
        $fdisplay (file,"barrel Test Log");
        $fdisplay (file,"___________________");

	//No Shift->Pass Data from Input to data   
	Enable=0;
	Cin=0;  
	Shift_Amt=5'b00000;
	Shift_Type=2'b00;
	Input_Bus=32'b00000000000000000000000000000000; 
        out_to_file;

        for (i=0;i<=31;i=i+1)
	 begin   
	    Input_Bus=Input_Bus + 32'b00000000000000000000000000000001;
            out_to_file;
	    #10;    
	 end // for (i=0;i<=31;i=i+1)

         // Left Shift	 
       Enable=1;
       Shift_Type=2'b00;
       Input_Bus[31:0]=32'b00000000000000000000000000000001;
       Shift_Amt=5'b00000;
       out_to_file;

       #10;
       Shift_Amt=5'b00001;
       out_to_file;

       #10;
       Shift_Amt=5'b00010;
       out_to_file;

       #10;
       Shift_Amt=5'b00011;
       out_to_file;

       #10;
       Shift_Amt=5'b00100;
       out_to_file;

       #10;
       Shift_Amt=5'b00101;
       out_to_file;

       #10;

        //Right Shift 	 
       Input_Bus[31:0]=32'b00000000000000000000000000100000;	 
       Enable=1;
       Shift_Type=2'b01;
       Shift_Amt=5'b00000;
       out_to_file;

       #10;
       Shift_Amt=5'b00001;
       out_to_file;

       #10;
       Shift_Amt=5'b00010;
       out_to_file;

       #10;
       Shift_Amt=5'b00011;
       out_to_file;

       #10;
       Shift_Amt=5'b00100;
       out_to_file;

       #10;
       Shift_Amt=5'b00101;
       out_to_file;

       #10;
       //Arithmetic Shift right
       Input_Bus[31:0]=32'b10000000000000000000000000000000;
       Enable=1;
       Shift_Type=2'b10;
       Shift_Amt=5'b00000;
       out_to_file;

       #10;
       Shift_Amt=5'b00001;
       out_to_file;

       #10;
       Shift_Amt=5'b00010;
       out_to_file;

       #10;
       Shift_Amt=5'b00011;
       out_to_file;

       #10;
       Shift_Amt=5'b00100;
       out_to_file;

       #10;
       Shift_Amt=5'b00101;
       out_to_file;

       #10;	  
       Input_Bus[31:0]=32'b00000000000000000000000000000000;
       Shift_Amt=5'b00000;
       out_to_file;

       #10;
       //Rotate Right
       Input_Bus[31:0]=32'b00000000000000000000000000000010;
       Enable=1;
       Shift_Type=2'b11;
       Cin=1'b1;
       Shift_Amt=5'b00000;
       out_to_file;

       #10;
       Shift_Amt=5'b00001;
       out_to_file;

       #10;
       Shift_Amt=5'b00010;
       out_to_file;

       #10;
       Shift_Amt=5'b00011;
       out_to_file;

       #10;
       Shift_Amt=5'b00100;
       out_to_file;

       #10;
       Shift_Amt=5'b00101;
       out_to_file;

       #10;	 
        $fdisplay (file,"%d tests run", num_tests);
        $fdisplay (file,"--Tests Completed--");  //signal end of tests

        $finish;
        $fclose (file);
     end

  task out_to_file;
      begin
         #1;
         num_tests = num_tests + 1;
         $fdisplay (file, "Input_Bus=%h Shift_Type=%b Shift_Amt=%h Cin=%b Enable=%b Output_Bus=%h Cout=%b",
           Input_Bus, Shift_Type, Shift_Amt, Cin, Enable, Output_Bus, Cout);

         $fdisplay(file,"================");
      end
  endtask

endmodule
   
