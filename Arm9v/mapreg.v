`timescale 1ns/10ps
`include "pardef"
/*****************************************************************************
$RCSfile: mapreg.v,v $
$Revision: 1.1 $
$Author: kohlere $
$Date: 2000/03/24 01:52:16 $
$State: Exp $
$Source: /home/lefurgy/tmp/ISC-repository/isc/hardware/ARM10/behavioral/pipelined/fpga2/mapreg.v,v $

Description: Turn the 4-bit Register Field into a 5-bit Address,
		based on the processor mode bits.

*****************************************************************************/
module mapreg (reg_field, mode, reg_addr);

/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/
input	[3:0] 	reg_field;	//4-Bit Operand from Instruction
input 	[4:0]	mode;		//5-Bit Mode from CPSR
output	[4:0]	reg_addr;	//5-Bit Register Address 

/*------------------------------------------------------------------------
        Behavioral Description
------------------------------------------------------------------------*/

//Create the Decode/Mapping Logic

reg [4:0] reg_addr;
always @(mode or reg_field)
begin
    case (mode) //synopsys full_case parallel_case
	`FIQ: begin
		casex(reg_field) //synopsys full_case parallel_case
		    4'h8, 4'h9, 4'hA, 4'hB, 
		    4'hC, 4'hD, 4'hE: reg_addr = {2'b10, reg_field[2:0]};
	
		    default: 	reg_addr = {1'b0, reg_field};
		endcase
	      end

	`SVC: begin
		casex(reg_field) //synopsys full_case parallel_case
		    4'b1101: reg_addr = 5'h17;
		    4'b1110: reg_addr = 5'h18;
		    default: reg_addr = {1'b0, reg_field};
		endcase
	      end

	`ABT: begin 
		casex(reg_field) //synopsys full_case parallel_case
		    4'b1101: reg_addr = 5'h19;
		    4'b1110: reg_addr = 5'h1A;
		    default: reg_addr = {1'b0, reg_field};
		endcase
	      end

	`IRQ: begin
                casex(reg_field) //synopsys full_case parallel_case
		    4'b1101: reg_addr = 5'h1B;
		    4'b1110: reg_addr = 5'h1C;
		    default: reg_addr = {1'b0, reg_field};
		endcase
	      end

	`UNDE: begin
		casex(reg_field) //synopsys full_case parallel_case
		    4'b1101: reg_addr = 5'h1D;
		    4'b1110: reg_addr = 5'h1E;
		    default: reg_addr = {1'b0, reg_field};
		endcase
	      end

	default: reg_addr = {1'b0, reg_field};
    endcase
end
endmodule







