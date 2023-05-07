`timescale 1ns/10ps
/*****************************************************************************
$RCSfile: decode.v,v $
$Revision: 1.1 $
$Author: kohlere $
$Date: 2000/04/10 18:17:59 $
$State: Exp $


Description: 4->16 decoder

*****************************************************************************/
module
decode (in, out);
input [3:0] in;
output [15:0] out;

reg [15:0] out;

always @(in)
  begin
    case (in) //synopsys full_case parallel_case
      4'h0: out = 16'h0001;
      4'h1: out = 16'h0002;
      4'h2: out = 16'h0004;
      4'h3: out = 16'h0008;
      4'h4: out = 16'h0010;
      4'h5: out = 16'h0020;
      4'h6: out = 16'h0040;
      4'h7: out = 16'h0080;
      4'h8: out = 16'h0100;
      4'h9: out = 16'h0200;
      4'hA: out = 16'h0400;
      4'hB: out = 16'h0800;
      4'hC: out = 16'h1000;
      4'hD: out = 16'h2000;
      4'hE: out = 16'h4000;
      4'hF: out = 16'h8000;
    endcase
  end
endmodule
