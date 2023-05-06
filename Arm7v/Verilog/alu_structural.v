// Name:  Tam Nguyen, Long Pham, Thinh Le
//Alu_structural Code

`include "defines.v"
`timescale 1ns/100ps

module ALU_ARM7(Alu_A, Alu_B, Alu_C, Alu_Cntrl, Alu_Signals, Alu_Result);
	input [31:0] Alu_A, Alu_B;
	input  Alu_C;
	input [4:0] Alu_Cntrl;
	output [3:0] Alu_Signals;
	output [31:0] Alu_Result;
	wire Alu_C;
	wire [31:0] Alu_A, Alu_B;
	wire [4:0] Alu_Cntrl;
	wire [3:0] Alu_Signals;
	wire [31:0] Alu_Result;
	wire [31:0] in0, in1, in2, in3, in4;
	wire [31:0] in5, in6, in7, in8, in9, in10, in11, in12;
	wire C2,C3,C4,C5,C6,C7,V2,V3,V4,V5,V6,V7; 
	wire Alu_C_not1, Alu_C_not2;


	csa CSA2(Alu_A, Alu_B, 1'b0, C2, V2, in2);   	//A + B
	csa CSA3(Alu_A, Alu_B, Alu_C, C3, V3, in3);  	//A + B + Carry
	csa CSA4(Alu_A, ~Alu_B, 1'b1, C4, V4, in4);  	//A - B
	csa CSA5(Alu_A, ~Alu_B, Alu_C, C5, V5, in5);    //A - B + Carry - 1
	csa CSA6(~Alu_A, Alu_B, 1'b1, C6,V6, in6);  	//B - A
	csa CSA7(Alu_B, ~Alu_A, Alu_C, C7, V7, in7);    //B - A + Carry - 1
	bitwise_and a(Alu_A,Alu_B,in8);	        	//A & B
	bitwise_xor x(Alu_A,Alu_B,in9);	        	//A ^ B
	bitwise_or o(Alu_A,Alu_B,in10);	        	//A | B
	bitwise_and a1(Alu_A, ~Alu_B, in11);         	//A & ~B
	bitwise_not n1(Alu_B, in12);			//~B
	mux13_to_1 MUX12_1(Alu_A, Alu_B, in2, in3, in4, in5, 
		in6, in7, in8, in9, in10, in11, in12,  Alu_Cntrl, Alu_Result);
	buf buf_out(Alu_Signals[3],Alu_Result[31]); 	//N flag
	comparator COMP(Alu_Result,'d0,Alu_Signals[2]); //Z flag
	
	mux6_1 MUXC(C2, C3, 1'b0, 1'b0, 1'b0, 1'b0, 
				Alu_Cntrl, Alu_Signals[1]);     //C flag
	
	mux6_1 MUXV(V2,V3,V4,V5,V6,V7,Alu_Cntrl,Alu_Signals[0]);//V flag

endmodule

module bitwise_and(in1,in2,out);
	input [31:0] in1,in2;
	output [31:0] out;
	wire [31:0] in1,in2;
	reg  [31:0] out;
	
	always @(in1 or in2)
	    out = in1 & in2;
endmodule

module bitwise_xor(in1,in2,out);
	input [31:0] in1,in2;
	output [31:0] out;
	wire [31:0] in1,in2;
	reg  [31:0] out;
	
	always @(in1 or in2)
	    out = in1 ^ in2;
endmodule

module bitwise_or(in1,in2,out);
	input [31:0] in1,in2;
	output [31:0] out;
	wire [31:0] in1,in2;
	reg  [31:0] out;
	
	always @(in1 or in2)
	    out = in1 | in2;
endmodule

module bitwise_not(in, out);
	input [31:0] in;
	output [31:0] out;
	wire [31:0] in;
	reg  [31:0] out;
	
	always @(in)
	    out = ~in;
endmodule

//Structural description of CSA
module csa(A, B, Cin, Cout, Overflow, Sum);
	input [31:0] A, B;
	input Cin;
	output Cout, Overflow;  //The^m Overflow signal 
	output [31:0] Sum;
	wire [31:0] A, B;	
	wire Cin;
	wire Cout, Overflow;
	wire [31:0] Sum;
	wire C4, C18, C08, or_out, C8_bar;
	wire [3:0] s14_s17, s04_s07, Sum3_0, Sum7_4;
	
	wire C013, C013_bar, C113, C113_bar, and_out, C13;
	wire [4:0] s18_112, s08_012, Sum12_8;

	wire C019, C119, orb_out, C19_bar,v5_1,v5_0,prev_cout,v1,v0;
	wire [5:0] s113_118, s013_018, Sum18_13;

	wire C026, C026_bar, C126, C126_bar, and2a_out;
	wire [6:0] s119_125, s019_025, Sum25_19;

	wire C032, C132, orc_out, C32_bar, C26, C32;
	wire [5:0] s026_031, s126_131, Sum31_26;

	//First Stage
	adder4  ADDER4(Sum[3:0], C4, A[3:0], B[3:0], Cin);  
	//assign Sum[3:0] = Sum3_0;	//output
	//buf	b0(Sum[0],Sum3_0[0]);
	//buf	b1(Sum[1],Sum3_0[1]);
	//buf	b2(Sum[2],Sum3_0[2]);
	//buf	b3(sum[3],Sum3_0[3]);

	//Second Stage	
	adder4  ADDER4A(s14_s17, C18, A[7:4], B[7:4], 1'b1);
	adder4  ADDER4B(s04_s07, C08, A[7:4], B[7:4], 1'b0);
	mux4	MUX4(s04_s07, s14_s17, C4, Sum[7:4]);
	or or2(or_out, C08, C4);
	nand nand2(C8_bar, or_out, C18);
	//assign Sum[7:4] = Sum7_4;	//output

	//Third Stage
	adder5	ADDER5A(s18_112, C113, A[12:8], B[12:8], 1'b1);
	adder5	ADDER5B(s08_012, C013, A[12:8], B[12:8], 1'b0);
	not	not_a(C013_bar, C013);
	not	not_b(C113_bar, C113);
	mux5	MUX5(s18_112, s08_012, C8_bar, Sum[12:8]);
	and	and2(and_out, C013_bar, C8_bar);
	nor	nor2(C13, C113_bar, and_out);
	//assign  Sum[12:8] = Sum12_8;	//output

	//Fourth Stage
	adder6	ADDER6A(s113_118, C119, A[18:13], B[18:13], 1'b1,v1);
	adder6	ADDER6B(s013_018, C019, A[18:13], B[18:13], 1'b0,v0);
	mux6	MUX6(s013_018, s113_118, C13, Sum[18:13]);
	or	orb(orb_out, C019, C13);
	nand	nandb(C19_bar, C119, orb_out);
	//assign	Sum[18:13] = Sum18_13;	//output

	//Fifth Stage
	adder7	ADDER7A(s119_125, C126, A[25:19], B[25:19], 1'b1);
	adder7	ADDER7B(s019_025, C026, A[25:19], B[25:19], 1'b0);
	not	not_c(C026_bar, C026);
	not	not_d(C126_bar, C126);
	mux7	MUX7(s119_125, s019_025, C19_bar, Sum[25:19]);
	and	and2a(and2a_out, C026_bar, C19_bar);
	nor	nor2a(C26, C126_bar, and2a_out);
	//assign	Sum[25:19] = Sum25_19;	//output 

	//Last Stage
	adder6	ADDER6C(s126_131, C132, A[31:26], B[31:26], 1'b1,v5_1);
	adder6	ADDER6D(s026_031, C032, A[31:26], B[31:26], 1'b0,v5_0);
	mux6	MUX6A(s026_031, s126_131, C26, Sum[31:26]);
	or	orc(orc_out, C032, C26);
	nand	nandc(C32_bar, C132, orc_out);
	//assign	Sum[31:26] = Sum31_26; //last output here
	not	note(C32, C32_bar);
	buf	bufx(Cout,C32);	       //Cout here
	mux2_1	new(v5_0,v5_1,C26,prev_cout);  	
	xor	xor_out(Overflow,C32,prev_cout);  //Overflow signal

endmodule

//G, P generator:
module pg4(a, b, p, g);
	input [3:0] a, b;
	output [3:0] p, g;
	wire [3:0] a, b;
	reg [3:0] p, g;
	
	always @(a or b)
	   begin
		g = a & b;
		p = a ^ b;
	   end
endmodule

/* sum generator */ 
module sum4(s, p, c); 
	input [3:0] p, c;    //4-bit pass and carry-in signals 
	output[3:0] s;       //4-bit sum output 
	wire [3:0] p, c;
	reg [3:0] s; 
	
	always @(p or c)
 	    s = p ^ c; 
endmodule 

/* 4-bit CLA generator */ 
module cla4(cout, p, g, cin); 
	input  [3:0] p, g;	// 2 4-bit inputs 
	input cin;              // carry-in 
	output [3:0] cout;      //4-bit carry-out
	wire [3:0] p, g;	
	wire cin; 
	reg [3:0] cout; 

    // cla4 behavioral description
	always @(p or g or cin)
	   begin 
    		cout[0]    =    g[0]  |  p[0] & cin; 
    		cout[1]    =    g[1]  |  p[1] & cout[0]; 
     		cout[2]    =    g[2]  |  p[2] & cout[1]; 
    		cout[3]    =    g[3]  |  p[3] & cout[2]; 
	   end
endmodule 

/* 4-bit CLA adder cell */ 
module adder4 (s, co, a, b, cin); 
	input    cin;   	//carry-in signal 
	input    [3:0] a, b;    //2 4-bit inputs 
	output   [3:0] s; 	//4-bit SUM output 
	output    co;           //4-bit carry-out
	wire cin;
	wire [3:0] a, b;
	wire [3:0] s; 
	wire [3:0] p, g, cout; 	//intermediate signals 
	wire co; 

    	// 4-bit cla adder structural description 
	pg4  	PG4(a, b, p, g); 
	cla4    CLA4(cout, p, g, cin); 
	sum4    SUM4(s, p, {cout[2:0], cin}); 
    	
	// carry-out behavioral description 
	//assign co = cout[3]; 
	buf b3(co,cout[3]);

endmodule // end of 4-bit CLA adder cell 


//5bits cell
//G, P generator:
module pg5(a, b, p, g);
	input [4:0] a, b;
	output [4:0] p, g;
	wire [4:0] a, b;
	reg [4:0] p, g;
	
	always @(a or b)
	   begin
		g = a & b;
		p = a ^ b;
	   end
endmodule

/* sum generator */ 
module sum5(s, p, c); 
	input [4:0] p, c;    //5-bit pass and carry-in signals 
	output[4:0] s;       //5-bit sum output 
	wire [4:0] p, c;
	reg [4:0] s; 
	
	always @(p or c)
 	    s = p ^ c; 
endmodule 

/* 5-bit CLA generator */ 
module cla5(cout, p, g, cin); 
	input  [4:0] p, g;	//2 5-bit inputs 
	input cin;              //carry-in 
	output [4:0] cout;      //5-bit carry-out
	wire [4:0] p, g;	
	wire cin; 
	reg [4:0] cout; 

    // cla5 behavioral description
	always @(p or g or cin)
	   begin 
    		cout[0]    =    g[0]  |  p[0] & cin; 
    		cout[1]    =    g[1]  |  p[1] & cout[0]; 
    		cout[2]    =    g[2]  |  p[2] & cout[1]; 
    		cout[3]    =    g[3]  |  p[3] & cout[2];
		cout[4]    =    g[4]  |  p[4] & cout[3]; 
	   end
endmodule 

/* 5-bit CLA adder cell */ 
module adder5 (s, co, a, b, cin); 
	input    cin;   	//carry-in signal 
	input    [4:0] a, b;    //2 5-bit inputs 
	output   [4:0] s; 	//5-bit SUM output 
	output    co;           //5-bit carry-out
	wire cin;
	wire [4:0] a, b;
	wire [4:0] s; 
	wire [4:0] p, g, cout; 	//intermediate signals 
	wire co; 

    	// 5-bit cla adder structural description 
	pg5  	PG5(a, b, p, g); 
	cla5    CLA5(cout, p, g, cin); 
	sum5    SUM5(s, p, {cout[3:0], cin}); 
    	
	// carry-out behavioral description 
	//assign co = cout[4]; 
	buf buf_out(co,cout[4]);

endmodule // end of 5-bit CLA adder cell 

//6bits cell
//G, P generator:
module pg6(a, b, p, g);
	input [5:0] a, b;
	output [5:0] p, g;
	wire [5:0] a, b;
	reg [5:0] p, g;
	
	always @(a or b)
	   begin
		g = a & b;
		p = a ^ b;
	   end
endmodule

/* sum generator */ 
module sum6(s, p, c); 
	input [5:0] p, c;    //6-bit pass and carry-in signals 
	output[5:0] s;       //6-bit sum output 
	wire [5:0] p, c;
	reg [5:0] s; 
	
	always @(p or c)
 	    s = p ^ c; 
endmodule 

/* 6-bit CLA generator */ 
module cla6(cout,c_overflow, p, g, cin); 
	input  [5:0] p, g;	//2 6-bit inputs 
	input cin;              //carry-in 
	output [5:0] cout;      //6-bit carry-out
	output c_overflow;
	wire [5:0] p, g;	
	wire cin; 
	reg [5:0] cout; 
	reg  c_overflow;

    // cla6 behavioral description
	always @(p or g or cin)
	   begin 
    		cout[0]    =    g[0]  |  p[0] & cin; 
    		cout[1]    =    g[1]  |  p[1] & cout[0]; 
    		cout[2]    =    g[2]  |  p[2] & cout[1]; 
    		cout[3]    =    g[3]  |  p[3] & cout[2];
		cout[4]    =    g[4]  |  p[4] & cout[3];
		cout[5]	   =    g[5]  |  p[5] & cout[4]; 
		c_overflow = cout[4];
	   end
endmodule 

/* 6-bit CLA adder cell */ 
module adder6 (s, co, a, b, cin,v); 
	input    cin;   	//carry-in signal 
	input    [5:0] a, b;    //2 6-bit inputs 
	output   [5:0] s; 	//6-bit SUM output 
	output    co;           //6-bit carry-out
	output v;		// bit 4th of Cout
	wire cin;
	wire [5:0] a, b;
	wire [5:0] s; 
	wire [5:0] p, g, cout; 	//intermediate signals 
	wire co, overflow_in,v;

    	// 6-bit cla adder structural description 
	pg6  	PG6(a, b, p, g); 
	cla6    CLA6(cout,overflow_in, p, g, cin); 
	sum6    SUM6(s, p, {cout[4:0], cin}); 
    	
	// carry-out behavioral description 
	buf bu_f(co,cout[5]); 
	buf b10(v,overflow_in);		//bit 4th of Cout.

endmodule // end of 6-bit CLA adder cell 

//7 bits

//G, P generator:
module pg7(a, b, p, g);
	input [6:0] a, b;
	output [6:0] p, g;
	wire [6:0] a, b;
	reg [6:0] p, g;
	
	always @(a or b)
	   begin
		g = a & b;
		p = a ^ b;
	   end
endmodule

/* sum generator */ 
module sum7(s, p, c); 
	input [6:0] p, c;    //7-bit pass and carry-in signals 
	output[6:0] s;       //7-bit sum output 
	wire [6:0] p, c;
	reg [6:0] s; 
	
	always @(p or c)
 	    s = p ^ c; 
endmodule 

/* 7-bit CLA generator */ 
module cla7(cout, p, g, cin); 
	input  [6:0] p, g;	//2 7-bit inputs 
	input cin;              //carry-in 
	output [6:0] cout;      //7-bit carry-out
	wire [6:0] p, g;	
	wire cin; 
	reg [6:0] cout; 

    // cla7 behavioral description
	always @(p or g or cin)
	   begin 
    		cout[0]    =    g[0]  |  p[0] & cin; 
    		cout[1]    =    g[1]  |  p[1] & cout[0]; 
    		cout[2]    =    g[2]  |  p[2] & cout[1]; 
    		cout[3]    =    g[3]  |  p[3] & cout[2];
		cout[4]    =    g[4]  |  p[4] & cout[3]; 
		cout[5]    =    g[5]  |  p[5] & cout[4];
		cout[6]    =    g[6]  |  p[6] & cout[5];
	   end
endmodule 

/* 7-bit CLA adder cell */ 
module adder7 (s, co, a, b, cin); 
	input    cin;   	//carry-in signal 
	input    [6:0] a, b;    //2 7-bit inputs 
	output   [6:0] s; 	//7-bit SUM output 
	output    co;           //7-bit carry-out
	wire cin;
	wire [6:0] a, b;
	wire [6:0] s; 
	wire [6:0] p, g, cout; 	//intermediate signals 
	wire co; 

    	// 7-bit cla adder structural description 
	pg7  	PG7(a, b, p, g); 
	cla7    CLA7(cout, p, g, cin); 
	sum7    SUM7(s, p, {cout[5:0], cin}); 
    	
	// carry-out behavioral description 
	buf b11(co,cout[6]); 

endmodule // end of 7-bit CLA adder cell 

//mux4

module mux4 (in1, in2, sel, out);
	input [3:0] in1, in2;
	input sel;
	output [3:0] out;
	
	wire [3:0] in1, in2;
	wire sel;
	reg [3:0] out;

	always @(in1 or in2 or sel)
	  begin
	    if (sel)
	      out = in2;
	    else
	      out = in1;
	  end
endmodule

//mux2_1 1 bit

module mux2_1(in1,in2,sel,out);
	input in1,in2,sel;
	output out;
	wire in1,in2,sel;
	reg out;
	
	always @(in1 or in2 or sel)
	  begin
	    if (sel)
	      out = in2;
	    else
	      out = in1;
	  end
endmodule

//mux5

module mux5 (in1, in2, sel, out);
	input [4:0] in1, in2;
	input sel;
	output [4:0] out;
	
	wire [4:0] in1, in2;
	wire sel;
	reg [4:0] out;

	always @(in1 or in2 or sel)
	  begin
	    if (sel)
	      out = in2;
	    else
	      out = in1;
	  end
endmodule

//mux6

module mux6 (in1, in2, sel, out);
	input [5:0] in1, in2;
	input sel;
	output [5:0] out;
	
	wire [5:0] in1, in2;
	wire sel;
	reg [5:0] out;

	always @(in1 or in2 or sel)
	  begin
	    if (sel)
	      out = in2;
	    else
	      out = in1;
	  end
endmodule
	
//mux7

module mux7 (in1, in2, sel, out);
	input [6:0] in1, in2;
	input sel;
	output [6:0] out;
	
	wire [6:0] in1, in2;
	wire sel;
	reg [6:0] out;

	always @(in1 or in2 or sel)
	  begin
	    if (sel)
	      out = in2;
	    else
	      out = in1;
	  end
endmodule

//Mux12_to_1(Behavior Description)

module mux13_to_1(in0, in1, in2, in3, in4, in5, in6, in7,
			in8, in9, in10, in11, in12, sel, out);
	input [31:0] in0, in1, in2, in3, in4, in5, in6;
	input [31:0] in7, in8, in9, in10, in11, in12;
	input [4:0] sel;
	output	[31:0] out;
	wire  [31:0] in0, in1, in2, in3, in4, in5, in6;
	wire  [31:0] in7, in8, in9, in10, in11,in12;
	wire [4:0] sel;
	reg [31:0] out;
	
	always @(in0 or in1 or in2 or in3 or in4 or in5 or in6 or in7 or
		  in8 or in9 or in10 or in11 or in12 or sel)

	   begin
		case (sel)
			`PSA:	out = in0;
			`MOV:	out = in1;
			`ADD:	out = in2;
			`ADC:	out = in3;
			`SUB:	out = in4;
			`SBC:	out = in5;
			`RSB:	out = in6;
			`RSC:	out = in7;
			`AND:	out = in8;
			`EOR:	out = in9;
			`ORR:	out = in10;
			`BIC:	out = in11;
			`MVN:	out = in12;
			default:	
				out = 1'hx;
		endcase
	    end
endmodule

//Comparator module
module comparator(x, y, zero_flag);
	input [31:0] x, y;
	output zero_flag;
	wire [31:0] x, y;
	reg zero_flag;
	
	always @(x or y)
	    begin
		if (x == y) 
		   zero_flag = 1;
		else 
		   zero_flag = 0;
	    end
endmodule

//Mux6_1 module

module mux6_1(in2, in3, in4, in5, in6, in7, sel, out);
	input in2, in3, in4, in5, in6, in7;
	input [4:0] sel;
	output out;
	wire in2, in3, in4, in5, in6, in7;
	wire [4:0] sel;
	reg out;
	
	always @(in2 or in3 or in4 or in5 or in6 or in7 or sel)
		begin
			case (sel) 
				'd2:	out = in2;
				'd3:	out = in3;
				'd4:	out = in4;
				'd5:	out = in5;
				'd6:	out = in6;
				'd7:	out = in7;
				default:
					out = 0;
			endcase
		end
endmodule

/*
//Test right here.

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













































