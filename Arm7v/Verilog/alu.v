//Name:  Tam Nguyen, Long Pham, Thinh Le
//Behavior of ALU:
//Last modified 4/30/00

//`include "/work1/ece371emr/mcrum/.archCVS/defines.v"
`include "defines.v"
`timescale 1ns/100ps

module ALU_ARM7(Alu_A, Alu_B, Alu_C, Alu_Cntrl, Alu_Signals, Alu_Result);
	input [31:0] Alu_A, Alu_B;
	input Alu_C;
	input [4:0] Alu_Cntrl;
	output [3:0] Alu_Signals;
	output [31:0] Alu_Result;
	wire [31:0] Alu_A, Alu_B;
	wire [4:0] Alu_Cntrl;
	wire Alu_C;
	reg Cin, Cout, Cout_prev;
	integer i;
	reg [31:0] Alu_Result;
	reg [3:0] Alu_Signals;

	always @(Alu_Cntrl or Alu_A or Alu_B or Alu_C)
	begin
		case (Alu_Cntrl)
			`PSA:		//Pass A
				begin
				  Alu_Result = Alu_A;
				  Alu_Signals[1:0] = 2'b00;
				end
			`MOV:		//MOV
				begin
				  Alu_Result = Alu_B;
				  Alu_Signals[1:0]= 2'b00;
				end
			`ADD:		//A + B
				begin
				  Alu_Result = Alu_A + Alu_B;
				  Cin = 0;
 				  for (i = 0; i <= 31; i = i + 1)
	  			    begin
	    				Cout = Alu_A[i] & Alu_B[i] | 
						(Alu_A[i] | Alu_B[i]) & Cin;
	    				Cin = Cout;
	    				if (i == 30)
	      				Cout_prev = Cout;
	  			    end
				  Alu_Signals[1] = Cout;	 	//C flag
				  Alu_Signals[0] = Cout ^ Cout_prev; 	//V flag
				end
			`ADC:		//A + B + C
				begin
				  Alu_Result = Alu_A + Alu_B + Alu_C;
				  Cin = Alu_C;
				  for (i = 0; i <= 31; i = i + 1)
	  			    begin
	    				Cout = Alu_A[i] & Alu_B[i] | 
						(Alu_A[i] | Alu_B[i]) & Cin;
	    				Cin = Cout;
	    				if (i == 30)
	      				Cout_prev = Cout;
	  			    end
				  Alu_Signals[1] = Cout; 		//C flag
				  Alu_Signals[0] = Cout ^ Cout_prev;	//V flag
				end
			`SUB:		//A - B
				begin
				  Alu_Result = Alu_A - Alu_B;
				  Cin = 1;
				  for (i = 0; i <= 31; i = i + 1)
	  			    begin
	    				Cout = Alu_A[i] & ~(Alu_B[i]) | 
						(Alu_A[i] | ~(Alu_B[i])) & Cin;
	    				Cin = Cout;
	    				if (i == 30)
	      				Cout_prev = Cout;
	  			    end
				  Alu_Signals[1] = 0; 			//C flag
				  Alu_Signals[0] = Cout ^ Cout_prev;	//V flag
				end
			`SBC:		//A - B + Carry - 1
				begin
				  Alu_Result = Alu_A - Alu_B + Alu_C - 1;
				  Cin = Alu_C;
				  for (i = 0; i <= 31; i = i + 1)
	  			    begin
	    				Cout = Alu_A[i] & ~(Alu_B[i]) | 
						(Alu_A[i] | ~(Alu_B[i])) & Cin;
	    				Cin = Cout;
	    				if (i == 30)
	      				Cout_prev = Cout;
	  			    end
				  Alu_Signals[1] = 0; 			//C flag
				  Alu_Signals[0] = Cout ^ Cout_prev;	//V flag
				end
			`RSB:		//B - A
				begin
				  Alu_Result = Alu_B - Alu_A;
				  Cin = 1;
				  for (i = 0; i <= 31; i = i + 1)
	  			    begin
	    				Cout = Alu_B[i] & ~(Alu_A[i]) | 
						(Alu_B[i] | ~(Alu_A[i])) & Cin;
	    				Cin = Cout;
	    				if (i == 30)
	      				Cout_prev = Cout;
	  			    end
				  Alu_Signals[1] = 0; 			//C flag
				  Alu_Signals[0] = Cout ^ Cout_prev;	//V flag
				end
			`RSC:		//B - A + Carry - 1
				begin
				  Alu_Result = Alu_B - Alu_A + Alu_C - 1;
				  Cin = Alu_C;
				  for (i = 0; i <= 31; i = i + 1)
	  			    begin
	    				Cout = Alu_B[i] & ~(Alu_A[i]) | 
						(Alu_B[i] | ~(Alu_A[i])) & Cin;
	    				Cin = Cout;
	    				if (i == 30)
	      				Cout_prev = Cout;
	  			    end
				  Alu_Signals[1] = 0; 			//C flag
				  Alu_Signals[0] = Cout ^ Cout_prev;	//V flag
				end
			`AND:		//A AND B
				begin
				  Alu_Result = Alu_A & Alu_B;
				  Alu_Signals[1:0] = 2'b00;
				end
			`EOR:		//A XOR B
				begin
				  Alu_Result = Alu_A ^ Alu_B;
				  Alu_Signals[1:0] = 2'b00;
				end
			`ORR:		//A OR B
				begin
				  Alu_Result = Alu_A | Alu_B;
				  Alu_Signals[1:0] = 2'b00;
				end
			`BIC:		//A AND NOT B
				begin
				  Alu_Result = Alu_A & (~Alu_B);
				  Alu_Signals[1:0] = 2'b00;
				end
			`MVN:		//Not B
				begin
				  Alu_Result = ~Alu_B;
				  Alu_Signals[1:0] = 2'b00;
				end
			default:
				Alu_Result = 1'hx;
		endcase
	Alu_Signals[3] = Alu_Result[31]; 	//N flag
	if (Alu_Result == 0)
	  Alu_Signals[2] = 1'b1;            	//Z flag
	else 
	  Alu_Signals[2] = 1'b0;
	
	end
endmodule

//Test right here.
/*
//clock file
module cl(clk);
	parameter TIME_LIMIT = 110000;
	output	clk;
	reg clk;

	initial
	  	clk=0;
	always	
		#50 clk = ~clk;
	always @(posedge clk)
		if ($time > TIME_LIMIT) #70 $stop;
endmodule


module top;
	reg [31:0] Alu_A, Alu_B;
	reg Alu_C;
	reg [4:0] Alu_Cntrl;
	wire [31:0] Alu_Result;
	wire [3:0] Alu_Signals;
	wire sysclk;

	cl #20000 clock(sysclk);
	ALU_ARM7 ALU_TEST(Alu_A, Alu_B, Alu_C, 
			Alu_Cntrl, Alu_Signals, Alu_Result);

	initial
	    begin
		Alu_A = 2500;
		//Alu_A = 1000
		Alu_B = 1000;
		Alu_C = 0;
		#250;
		@(posedge sysclk);
		for (Alu_Cntrl = 0; Alu_Cntrl <= 12; Alu_Cntrl=Alu_Cntrl + 1)
		   begin
		     @(posedge sysclk);
			$display("Alu_A=%h Alu_B=%h Alu_C=%h Alu_Cntrl=%b Alu_Result=%h Alu_Signals=%b",Alu_Signals,Alu_A,Alu_B,Alu_C,Alu_Cntrl, Alu_Result);
		   end
		$stop;
	     end
endmodule
*/


	
