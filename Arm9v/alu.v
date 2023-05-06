`timescale 1ns/10ps
/*****************************************************************************
$RCSfile: alu.v,v $
$Revision: 1.1 $
$Author: kohlere $
$Date: 2000/03/24 01:52:16 $
$State: Exp $


Description: 32-bit ALU used for the ARM9.

*****************************************************************************/
module alu (op1, shifted_op2, control, C, result, flags);

/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/
input	[63:0] 	op1;		//Operand 1
input 	[63:0]	shifted_op2;	//Operand 2 (from Shifter)
input	[3:0] 	control;	//Operation Control Bits
input		C;		//Current Carry Flag

output	[63:0]	result;		//Result 
output	[3:0] 	flags;		//Flags (N,Z,C,V)

/*------------------------------------------------------------------------
        Behavioral Description
------------------------------------------------------------------------*/
`include "pardef"

//Create a Multiplexer Which controls the first
//input to the ALU.  This should simplify the ALU

wire [63:0] alu_op1;
reg  [31:0] op1_low;
reg  [31:0] op1_high;
always @(control or op1)
begin
    case (control) //synopsys full_case parallel_case
	`AND,
	`EOR,
	`ORR,
	`ADD,
	`ADC,
	`TEQ,
	`CMN,
	`TST,
	`MOV,
	`SUB,
	`SBC, 
	`CMP,
	`BIC,
	`MVN: op1_low = op1[31:0];

	`RSB,
	`RSC: op1_low = ~op1[31:0];
    endcase
end

always @(op1)
  begin
    op1_high = op1[63:32];
  end

//Put the Two Words together
assign alu_op1 = {op1_high,op1_low};

//Create a Multiplexer Which controls the first 
//input to the ALU.  This should simplify the ALU

wire [63:0] alu_op2;
reg  [31:0] op2_low;
reg  [31:0] op2_high;
always @(control or shifted_op2)
begin
    case (control) //synopsys full_case parallel_case
        `AND,
        `EOR,
        `ORR,
        `ADD,
        `ADC,
        `TEQ,
        `CMN,
        `TST,
        `MOV,
	`RSB,
	`RSC: op2_low[31:0] = shifted_op2[31:0];
                
        `SUB,
        `SBC,
        `CMP,
        `BIC,
        `MVN: op2_low[31:0] = ~shifted_op2[31:0];
    endcase
end

always @(shifted_op2)
  begin
    op2_high = shifted_op2[63:32];
  end

//Put the two words together
assign alu_op2 = {op2_high,op2_low};

//Create a Multiplexer for the Carry 
//Input to the ALU

reg alu_cin;
always @(control or C)
begin
    case (control) //synopsys full_case parallel_case
        `AND,
	`EOR,
	`ADD,
	`TST,
	`TEQ,
	`CMN,
	`ORR,
	`MOV,
	`MVN,
	`BIC: alu_cin = 0;
	
	`SUB,
	`RSB,
	`CMP: alu_cin = 1;

	`ADC,
	`SBC,
	`RSC: alu_cin = C;
    endcase
end


reg [63:0] alu_out;
always @(control or alu_op1 or alu_op2 or alu_cin)
begin
    case (control) //synopsys full_case parallel_case
	`AND,
	`TST,
	`BIC: alu_out = {32'h00000000,(alu_op1[31:0] & alu_op2[31:0])};

	`ORR: alu_out = {32'h00000000,(alu_op1[31:0] | alu_op2[31:0])};	

	`EOR,
	`TEQ: alu_out = {32'h00000000,(alu_op1[31:0] ^ alu_op2[31:0])};

	`SUB,
	`RSB,
	`ADD,
	`ADC,
	`SBC,
	`RSC,
	`CMP,
	`CMN: alu_out = alu_op1 + alu_op2 + alu_cin;

	`MOV,
	`MVN: alu_out = {32'h00000000,alu_op2[31:0]};
    endcase
end

//Create the Flags and Assign the Result
//Flags only based on 32-bit ALU result.
wire [63:0] result = alu_out;		//alu_out = {cout,result[31:0]}
wire [3:0]  flags;
assign flags[3] = alu_out[31];		//N
assign flags[2] = ~(| result[31:0]);	//Z
assign flags[1] = alu_out[32];		//C
assign flags[0] = alu_op1[31]^
		  alu_op2[31]^
		  alu_out[31]^
		  alu_out[32];		//V

endmodule
