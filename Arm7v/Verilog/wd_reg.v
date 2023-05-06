// Write Data Register
//   Jeffrey J. Cook (jjcook)
`timescale 1ns/100ps

module wd_reg(WD_Bus_Write,WD_DBE,WD_Load,WD_DOUT,sysclk);

input	[31:0]	WD_Bus_Write;
input	WD_DBE;
input	WD_Load;
input	sysclk;
output	[31:0]	WD_DOUT;

wire	[31:0]	WD_Bus_Write;
wire	WD_DBE;
wire	WD_Load;
wire	sysclk;

reg	[31:0]	WD_DOUT;

reg	[31:0]	WD_internal;

always @(posedge sysclk)
begin
	if(WD_Load == 1'b1) WD_internal = WD_Bus_Write;
end

always @(WD_DBE)
begin
	case (WD_DBE)
	1'b0	:	WD_DOUT = 32'bZ;
	1'b1	:	WD_DOUT = WD_internal;
	default	:	WD_DOUT	= 32'bX;
	endcase
end

endmodule
