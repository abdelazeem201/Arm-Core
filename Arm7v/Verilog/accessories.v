// miscellaneous devices for ARM7 Controller Datapath
// Deanna Perry, 4/3/00
// mux2, mux24, mux4, mux44, mux8, mux84, decoder, add4, clearable_register


// mux2
// 2 32-bit input multiplexor
// Inputs: i0,i1,sel
// Outputs: out

module mux2(i0, i1, sel, out);
   input [31:0] i0, i1;
   input 	sel;
   output [31:0] out;
   wire [31:0] i0, i1;
   wire        sel;
   reg [31:0]  out;
   always @(i0 or i1 or sel)
      begin
	 if (sel)
	    out = i1;
	 else
	    out = i0;
      end
endmodule // mux2



// mux24
// 2 32-bit input multiplexor
// Inputs: i0,i1,sel
// Outputs: out

module mux24(i0, i1, sel, out);
   input [3:0] i0, i1;
   input       sel;
   output [3:0] out;
   wire [3:0] i0, i1;
   wire        sel;
   reg [3:0]  out;
   always @(i0 or i1 or sel)
      begin
	 if (sel)
	    out = i1;
	 else
	    out = i0;
      end
endmodule // mux24



// mux4
// 4 32-bit input multiplexor
// Inputs: i0,i1,i2,i3,sel
// Outputs: out

module mux4(i0, i1, i2, i3, sel, out);
   input [31:0] i0, i1, i2, i3;
   input [1:0]	sel;
   output [31:0] out;
   wire [31:0] i0, i1, i2, i3;
   wire [1:0]  sel;
   reg [31:0]  out;
   always @(i0 or i1 or i2 or i3 or sel)
      begin
	 case (sel)
	     2'b00: out = i0;
	     2'b01: out = i1;
	     2'b10: out = i2;
	     2'b11: out = i3;
         endcase
      end
endmodule // mux4



// mux44
// 4 32-bit input multiplexor
// Inputs: i0,i1,i2,i3,sel
// Outputs: out

module mux44(i0, i1, i2, i3, sel, out);
   input [3:0] i0, i1, i2, i3;
   input 	sel;
   output [3:0] out;
   wire [3:0] i0, i1, i2, i3;
   wire [1:0]  sel;
   reg [3:0]  out;
   always @(i0 or i1 or i2 or i3 or sel)
      begin
	 case (sel)
	   2'b00: out = i0;
	   2'b01: out = i1;
	   2'b10: out = i2;
	   2'b11: out = i3;
	 endcase
      end
endmodule // mux44



// mux8
// 8 32-bit input multiplexor
// Inputs: i0,i1,i2,i3,sel
// Outputs: out

module mux8(i0, i1, i2, i3, i4, i5,  i6, i7, sel, out);
   input [31:0] i0, i1, i2, i3, i4, i5, i6, i7;
   input 	sel;
   output [31:0] out;
   wire [31:0] i0, i1, i2, i3, i4, i5, i6, i7;
   wire [2:0]  sel;
   reg [31:0]  out;
   always @(i0 or i1 or i2 or i3 or i4 or i5 or i6 or i7 or sel)
      begin
	 case (sel)
	   3'b000: out = i0;
	   3'b001: out = i1;
	   3'b010: out = i2;
	   3'b011: out = i3;
	   3'b100: out = i4;
	   3'b101: out = i5;
	   3'b110: out = i6;
	   3'b111: out = i7;
	 endcase
      end
endmodule // mux8



// mux84
// 8 4-bit input multiplexor
// Inputs: i0,i1,i2,i3,sel
// Outputs: out

module mux84(i0, i1, i2, i3, i4, i5,  i6, i7, sel, out);
   input [3:0] i0, i1, i2, i3, i4, i5, i6, i7;
   input       sel;
   output [3:0] out;
   wire [3:0] i0, i1, i2, i3, i4, i5, i6, i7;
   wire [2:0]  sel;
   reg [3:0]  out;
   always @(i0 or i1 or i2 or i3 or i4 or i5 or i6 or i7 or sel)
      begin
	 case (sel)
	   3'b000: out = i0;
	   3'b001: out = i1;
	   3'b010: out = i2;
	   3'b011: out = i3;
	   3'b100: out = i4;
	   3'b101: out = i5;
	   3'b110: out = i6;
	   3'b111: out = i7;
	 endcase
      end
endmodule // mux84

// mux16
// 16 32-bit input multiplexor
// Inputs: i0,i1,i2,i3,i4,i5,i6,i7,i8,i9,i10,i11,i12,i13,i14,i15,sel
// Outputs: out

module mux16(i0, i1, i2, i3, i4, i5,  i6, i7, i8, i9, i10, i11, i12, i13, i14, i15, sel, out);
   input [31:0] i0, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15;
   input  [3:0]  sel;
   output [31:0] out;
   wire [31:0] i0, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, i12, i13, i14, i15;
   wire [3:0]  sel;
   reg [31:0]  out;
   always @(i0 or i1 or i2 or i3 or i4 or i5 or i6 or i7 or i8 or i9 or i10 or i11 or i12 or i13 or i14 or i15 or sel)
      begin
	 case (sel)
	   4'b0000: out = i0;
	   4'b0001: out = i1;
	   4'b0010: out = i2;
	   4'b0011: out = i3;
	   4'b0100: out = i4;
	   4'b0101: out = i5;
	   4'b0110: out = i6;
	   4'b0111: out = i7;
           4'b1000: out = i8;
           4'b1001: out = i9;
           4'b1010: out = i10;
           4'b1011: out = i11;
           4'b1100: out = i12;
           4'b1101: out = i13;
           4'b1110: out = i14;
           4'b1111: out = i15;
           default: out = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	 endcase
      end
endmodule // mux16



// decoder
// 32-bit decoder
// Inputs: in,sel
// Outputs: o0,o1

module decoder(in,sel,o0,o1);
   input [31:0] in;
   input 	sel;
   output [31:0] o0,o1;
   wire [31:0] 	 in;
   wire        sel;
   reg [31:0] 	o0,o1;
   always @(in or sel)
      begin
	 if (~sel)
	    begin
	       o0=in;
	       o1=32'hzzzz;
	    end // if (sel)
	 else
	 begin
	    o1=in;
	    o0=32'hzzzz;
	 end // else: !if(sel)
      end // always @ (in or sel)
endmodule // decoder




// add4
// 32-bit+32`h0004 custom adder
// Inputs: in
// Outputs: out

module add4(in,out);
   input [31:0] in;
   output [31:0] out;
   wire [31:0] 	 in;
   reg [31:0] 	 out;
   always @(in)
      out = in + 4;
endmodule // add4

// sub4
// 32-bit-32`h0004 custom adder
// Inputs: in
// Outputs: out

module sub4(in,out);
   input [31:0] in;
   output [31:0] out;
   wire [31:0] 	 in;
   reg [31:0] 	 out;
   always @(in)
      out = in - 4;
endmodule // sub4


// clearable_register
// 32-bit clocked register with clear
// Inputs: din, clr, clk, ld
// Outputs: dout

module clearable_register(clk, din, dout, clr, ld);
   input [31:0] din;
   input 	clr, clk, ld;
   output [31:0] dout;
   wire [31:0] 	 din;
   wire 	 clr,clk,ld;
   reg [31:0] 	 dout;
   
   always @ (posedge clk or clr)
      begin
	 if (clr == 1)
	    dout <= 32'hf0000000;
	 else if (ld == 1) 
	    dout <= din;
      end // always @ (posedge clk)
endmodule // clearable_register


// plain_register
// 32-bit clocked register
// Inputs: din, clk, enable
// Outputs: dout

module plain_register(clk, din, dout, enable);
   input [31:0] din;
   input 	clk, enable;
   output [31:0] dout;
   wire [31:0] 	 din;
   wire 	 clk,enable;
   reg [31:0] 	 dout;
   
   always @ (posedge clk)
      begin
	 if (enable == 1) 
	    dout <= din;
      end // always @ (posedge clk)
endmodule // plain_register
