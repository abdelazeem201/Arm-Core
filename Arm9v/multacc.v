`timescale 1ns/10ps
/*****************************************************************************
$RCSfile: multacc.v,v $
$Revision: 1.1 $
$Author: kohlere $
$Date: 2000/03/24 01:52:16 $
$State: Exp $
$Source: /home/lefurgy/tmp/ISC-repository/isc/hardware/ARM10/behavioral/pipelined/fpga2/multacc.v,v $

Description:  This is a 32x8 mac unit using a 4-2 (5-3) compressor tree.
		It is actually performing a 32x32 in 4 8-bit chunks.  
		To accomodate signed/unsigned math, the operands have
		been sign extended making them 33x10.  

*****************************************************************************/
module multacc (op1, op2, op2_1, acc, acc_op1, acc_op2,
			byte_slice, msb);

input	[63:0]	acc;		//Value to be accumulated
input	[32:0]	op1;		//1st Operand
input	[9:0]	op2;		//2nd Operand
input	[1:0]	byte_slice;	//Which Byte?
input		op2_1;		//Op2[-1] (Needed for Booth)
input		msb;		//Mult by MS Byte

output	[63:0]	acc_op1;	//acc_op1
output	[63:0]	acc_op2;	//acc_op2

/*--------------------------------------------------------------
		Generate the Partial Products
--------------------------------------------------------------*/

wire	[33:0]	pp1, pp2, pp3, pp4;	//Partial Products
wire	[33:0]	pp5, pp5_msb;		//Partial Products
wire		cin1, cin2, cin3, cin4;	//Negative PP
wire		cin5, cin5_msb;

ppselect xpps1 (.mcand(op1), .sel({op2[1:0],op2_1}), .pp(pp1),
			.cin(cin1));

ppselect xpps2 (.mcand(op1), .sel(op2[3:1]), .pp(pp2),
                        .cin(cin2));

ppselect xpps3 (.mcand(op1), .sel(op2[5:3]), .pp(pp3),
                        .cin(cin3));

ppselect xpps4 (.mcand(op1), .sel(op2[7:5]), .pp(pp4),
                        .cin(cin4));

ppselect xpps5 (.mcand(op1), .sel(op2[9:7]), .pp(pp5_msb), 
			.cin(cin5_msb));

assign pp5 = (msb & (op2[9:7] != 3'h7)) ? pp5_msb : 34'h000000000;
assign cin5 = (msb & (op2[9:7] != 3'h7)) ? cin5_msb : 1'b0;

/*--------------------------------------------------------------
                Generate the Level 0 Compressors
--------------------------------------------------------------*/
wire    [39:0]  i1_0;
wire    [39:0]  i2_0;
wire    [39:0]  i3_0;
wire    [39:0]  i4_0;
wire	[39:0]	ci_0;

wire	[39:0]	c1_0;
wire	[39:0]	s0_0;
wire	[39:0]	s1_0;

wire	[35:0]	i20_body;
wire	[37:0]	i30_body;
wire	[39:0]	i40_body;

assign i20_body = {pp2,1'b0,cin1};
assign i30_body = {pp3,1'b0,cin2,2'h0};
assign i40_body = {pp4,cin5,cin3,4'h0};

assign i1_0 = {{6{pp1[33]}},pp1};
assign i2_0 = {{4{i20_body[35]}},i20_body};
assign i3_0 = {{2{i30_body[37]}},i30_body};
assign i4_0 = i40_body;
assign ci_0 = {c1_0[38:0],1'b0};

comp42_n40 level0 (.I1(i1_0), .I2(i2_0), .I3(i3_0), .I4(i4_0), 
			.CI(ci_0), .C1(c1_0), .S0(s0_0), .S1(s1_0));

wire [4:0] select = {c1_0[39],pp4[33],pp3[33],pp2[33],pp1[33]};

/*--------------------------------------------------------------
                Generate the Level 1 Compressors
--------------------------------------------------------------*/

reg	[63:0]	i1_1;
reg	[63:0]	i2_1;
reg	[63:0]	i3_1;
wire	[63:0]	i4_1;
wire	[63:0]	ci_1;

wire	[63:0]	c1_1;
wire	[63:0]	s0_1;
wire	[63:0]	s1_1;

wire	[41:0]	i11_body;

assign i11_body = {pp5,cin5,(cin4 | cin5),cin5,5'b0};

always @(byte_slice or i11_body)
    begin
        case (byte_slice) //synopsys full_case parallel_case
            3'h0: i1_1 <= {{22{i11_body[41]}},i11_body};
            3'h1: i1_1 <= {{14{i11_body[41]}},i11_body,8'h00};
            3'h2: i1_1 <= {{6{i11_body[41]}},i11_body,16'h0000};
            3'h3: i1_1 <= {i11_body[39:0],24'h000000};
        endcase
    end

always @(byte_slice or s0_0 or select)
    begin
        case (byte_slice) //synopsys full_case parallel_case
            3'h0: begin
                   casex (select) //synopsys full_case parallel_case
		    5'b?0001,
		    5'b?0010,
		    5'b?0100,
		    5'b?1000,
		    5'b00111,
		    5'b01011,
		    5'b01101,
		    5'b01110,
		    5'b?1111: i2_1 <= {24'hFFFFFF,s0_0};
		    default: i2_1 <= {24'h000000,s0_0};
		   endcase
		  end
	    
	    3'h1: begin
		   casex (select) //synopsys full_case parallel_case
                    5'b?0001,
                    5'b?0010,
                    5'b?0100,
                    5'b?1000,
                    5'b00111,
                    5'b01011,
                    5'b01101,
                    5'b01110,
                    5'b?1111: i2_1 <= {16'hFFFF,s0_0,8'h00};
		    default: i2_1 <= {16'h0000,s0_0,8'h00};
		   endcase
		  end

	    3'h2: begin
                   casex (select) //synopsys full_case parallel_case
                    5'b?0001,
                    5'b?0010,
                    5'b?0100,
                    5'b?1000,
                    5'b00111,
                    5'b01011,
                    5'b01101,
                    5'b01110,
                    5'b?1111: i2_1 <= {8'hFF,s0_0,16'h0000};
		    default: i2_1 <= {8'h00,s0_0,16'h0000};
		   endcase
		  end
	
	    3'h3: i2_1 <= {s0_0,24'h000000};
	endcase
    end

always @(byte_slice or cin5 or s1_0 or select)
    begin
	case (byte_slice) //synopsys full_case parallel_case
	    3'h0: begin
		   casex (select) //synopsys full_case parallel_case
		    5'b?0011,
		    5'b?0110,
		    5'b?1100,
		    5'b?0101,
		    5'b?1001,
		    5'b?1010,
		    5'b?0111,
		    5'b?1011,
		    5'b?1101,
		    5'b?1110,
		    5'b?1111: i3_1 <= {24'hFFFFFF,s1_0[38:0],1'b0};

		    5'b11000,
		    5'b10100,
		    5'b10010,
		    5'b10001: i3_1 <= {24'h000001,s1_0[38:0],1'b0};

		    default: i3_1 <= {23'h000000,s1_0,1'b0};

		   endcase
		  end

	    3'h1: begin
		   casex (select) //synopsys full_case parallel_case
		    5'b?0011,
                    5'b?0110,
                    5'b?1100,
                    5'b?0101,   
                    5'b?1001,
                    5'b?1010,
                    5'b?0111,
                    5'b?1011,
                    5'b?1101,
                    5'b?1110,
                    5'b?1111: 
			i3_1 <= {16'hFFFF,s1_0[38:0],9'h000};

                    5'b10001: i3_1 <= {16'h0001,s1_0[38:0],9'h000};

		    default: 
			i3_1 <= {15'h0000,s1_0,9'h000};
		   endcase
		  end
		
	    3'h2: begin
		   casex (select) //synopsys full_case parallel_case
                    5'b?0011,
                    5'b?0110,
                    5'b?1100,
                    5'b?0101,
                    5'b?1001,
                    5'b?1010,
                    5'b?0111,
                    5'b?1011,
                    5'b?1101,
                    5'b?1110,
                    5'b?1111: 
			i3_1 <= {8'hFF,s1_0[38:0],17'h00000};

                    5'b10001: i3_1 <= {8'h01,s1_0[38:0],17'h00000};

		    default: 
			i3_1 <= {7'h00,s1_0,17'h00000};
		   endcase
		  end

	    3'h3: i3_1 <= {s1_0[38:0],25'h000000};
	endcase
    end

assign i4_1 = acc;

assign ci_1 = {c1_1[62:0],1'b0};

comp42_n64 level1 (.I1(i1_1), .I2(i2_1), .I3(i3_1), .I4(i4_1),
			.CI(ci_1), .C1(c1_1), .S0(s0_1), .S1(s1_1));

wire [63:0] acc_op1;
wire [63:0] acc_op2;
assign acc_op1 = s0_1;
assign acc_op2 = {s1_1[62:0],1'b0};

endmodule

