// Address Register
//   Jeffrey J. Cook (jjcook)

`define AR_ALU_SEL	2'b00
`define AR_PC_SEL	2'b01
`define	AR_PC_4_SEL	2'b10
`timescale 1ns/100ps

module addr_reg(AR_Bus_Alu, AR_Bus_PC, AR_Bus_PC_4, AR_Bus_Sel, AR_Output_Bus, sysclk);

input	[31:0]	AR_Bus_Alu;
input	[31:0]	AR_Bus_PC;
input	[31:0]	AR_Bus_PC_4;
input	[1:0]	AR_Bus_Sel;
input	sysclk;
output	[31:0]	AR_Output_Bus;

// inputs
wire	[31:0]	AR_Bus_Alu;
wire	[31:0]	AR_Bus_PC;
wire	[31:0]	AR_Bus_PC_4;
wire	[1:0]	AR_Bus_Sel;

wire	sysclk;

// outputs
reg	[31:0]	AR_Output_Bus;

always @(posedge sysclk)
begin
	case(AR_Bus_Sel)
	`AR_ALU_SEL	:	AR_Output_Bus = AR_Bus_Alu;
	`AR_PC_SEL	:	AR_Output_Bus = AR_Bus_PC;
	`AR_PC_4_SEL	:	AR_Output_Bus = AR_Bus_PC_4;
	default		:	AR_Output_Bus = 32'bX;
	endcase
end

endmodule
