`timescale 1ns/10ps
/*-----------------------------------------------------------------------------
$RCSfile: comp42_2.v,v $
$Author: kohlere $
$Revision: 1.1 $
$Date: 2000/03/24 01:52:16 $
$State: Exp $

Description:    This version is made up of 2 full adders.
		Also a Combinational version.		

Notices:        (C) Matt Postiff and Mike Kelley, 1996
                (C) Copyright The Regents of the University of Michigan, 1996

-----------------------------------------------------------------------------*/

//-----------------------------------------------------------------------------
// module definition
//-----------------------------------------------------------------------------
module comp42_2
(
 I1, I2, I3, I4, CI,		// the 5 not-quite-symmetrical inputs
 C1, S1, S0			// the 3 outputs, column weight indicated
);

//-----------------------------------------------------------------------------
// input and output declarations
//-----------------------------------------------------------------------------

  input I1;
  input I2;
  input I3;
  input I4;
  input CI;
  output C1;
  output S1;
  output S0;
/*============================================================================
//			2-Adder Format
  wire internal_carry;

DW01_add #(1) xadder1 
(
  .A(I2),
  .B(I3),
  .CI(I1),
  .SUM(internal_carry),
  .CO(C1)
 ); 

DW01_add #(1) xadder2
(
  .A(I4),
  .B(CI),
  .CI(internal_carry),
  .SUM(S0),
  .CO(S1)
 ); 
============================================================================*/

/*=========================================================================*/
//			Logic Implementation

wire C1 = !(!(I1 & I2) & !(I3 & I4));
wire int_node1 = !((I3 | I4) & !(I3 & I4));
wire int_node2 = !((I1 | I2) & !(I1 & I2));
wire int_node3 = int_node1 ^ int_node2;
wire int_node4 = !((int_node1 | int_node2) & (!(I1 & I2) | !(I3 & I4))); 
wire S0 = CI ^ int_node3;
wire S1	= (CI & int_node3) | int_node4;


/*==========================================================================*/

/*=========================================================================
//			Mux Implementation

reg node1, node2, node3;
reg C1, S0, S1;

always @(I1 or I2)
  begin
    case (I1) //synopsys full_case parallel_case
	1'b0: node1 = I2;
	1'b1: node1 = !I2;
    endcase
  end

always @(I3 or I4)
  begin
    case (I3) //synopsys full_case parallel_case
        1'b0: node2 = I4;
        1'b1: node2 = !I4;
    endcase
  end

always @(I3 or I1 or node1)
  begin
    case (node1) //synopsys full_case parallel_case
        1'b0: C1 = I1;
        1'b1: C1 = I3;
    endcase
  end

always @(node1 or node2)
  begin
    case (node1) //synopsys full_case parallel_case
        1'b0: node3 = node2;
        1'b1: node3 = !node2;
    endcase
  end

always @(I4 or CI or node3)
  begin
    case (node3) //synopsys full_case parallel_case
        1'b0: S1 = I4;
        1'b1: S1 = CI;    
    endcase
  end

always @(CI or node3)
  begin
    case (node3) //synopsys full_case parallel_case
        1'b0: S0 = CI;
        1'b1: S0 = !CI;
    endcase
  end


============================================================================*/

endmodule // comp42_2

