`timescale 1ns/10ps
/*-----------------------------------------------------------------------------
$RCSfile: ppselect.v,v $
$Author: kohlere $
$Revision: 1.1 $
$Date: 2000/03/24 01:52:17 $
$State: Exp $

Description:    Booth-2 partial product selector logic.
		Structural code for Booth-2 version (Radix-4 Modified)

		The operands are latched before this module; in other words,
		inputs to this module are used in the first stage of
		the calculation, they are NOT latched to begin with.

Notices:        (C) Matt Postiff and Mike Kelley, 1996-1997
                (C) Copyright The Regents of the University of Michigan, 1997

References:     Gary Bewick Stanford Ph.D. Thesis, "Fast Multiplication:
		Algorithms and Implementation", February 1994. See particularly
		Appendix A.

-----------------------------------------------------------------------------*/

//-----------------------------------------------------------------------------
// module definition
//-----------------------------------------------------------------------------
module ppselect
(
  mcand,			// multiplicand
  sel,				// 3 bits of the multiplier to direct Booth2
  pp,				// the partial product bits, 1C if negative
  cin				// set if partial product is negative
);

//-----------------------------------------------------------------------------
// input and output declarations
//-----------------------------------------------------------------------------

input 	[32:0]	mcand;
input 	[2:0]	sel;
output	[33:0]	pp;
output	   	cin;

//-----------------------------------------------------------------------------
// Implementation
//-----------------------------------------------------------------------------

reg	[33:0]	pp;
assign cin = sel[2];

always @(sel or mcand)
    begin
	case (sel) //synopsys full_case parallel_case
	    3'b000: pp <= 34'h000000000;		//+0

	    3'b001,
	    3'b010: pp <= {mcand[32], mcand};		//+1

	    3'b011: pp <= {mcand, 1'b0};		//+2

	    3'b100: pp <= ~{mcand, 1'b0};		//-2

	    3'b101,
	    3'b110: pp <= ~{mcand[32], mcand};		//-1

	    3'b111: pp <= 34'h3FFFFFFFF;  // was all 'b0s (and was wrong)
   endcase
 end

endmodule

