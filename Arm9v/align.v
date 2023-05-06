`timescale 1ns/10ps
/*****************************************************************************
$RCSfile: align.v,v $
$Revision: 1.1 $
$Author: kohlere $
$Date: 2000/03/24 01:52:16 $
$State: Exp $

Description: This is the Data Aligning Module.  This takes care of data
		misalignment due to misaligned addresses and the BIGEND
		control signal.

Note:  The output enable signal is active high in this block.  This is
	basically a signal which says a store needs to take place.  It
	is not the same enable that enables the actual memory system.

*****************************************************************************/

module align (BIGEND, data, addr_low, out_ena, unsigned_byte,
		unsigned_hw, signed_byte, signed_hw, data_bus,
		loaded_data);

/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/

input   [63:0]  data;		//Unaligned Data to be applied to bus
input	[1:0]	addr_low;	//Low Order Bits of Address
input		BIGEND;		//Big Endian = 1
input		out_ena;	//Output Enable for Data Bus
input 		unsigned_byte;	//Data should be Unsigned Byte
input		unsigned_hw;	//Data should be Unsigned Halfword
input		signed_byte;	//Data should be Signed Byte
input		signed_hw;	//Data should be Signed Hw

inout	[63:0]	data_bus;	//Actual Data Bus

output	[63:0]	loaded_data;	//Aligned Data from Memory

/*------------------------------------------------------------------------
        Declarations
------------------------------------------------------------------------*/

wire 	[63:0]	data_bus;
reg	[63:0]  muxed_data;
reg	[63:0]	loaded_data;

/*------------------------------------------------------------------------
        Combinational Always Blocks
------------------------------------------------------------------------*/

//Drive the Data Bus
assign data_bus = out_ena ? muxed_data : 64'hzzzzzzzzzzzzzzzz;

//Set Up Data to be put on Data Bus
always @(data or unsigned_byte or unsigned_hw)
    begin
	case ({unsigned_hw, unsigned_byte}) //synopsys full_case parallel_case

	    //Word Store, Big Endian or Little Endian
	    //No alignment necessary
	    2'b00: muxed_data = data;

	    //Unsigned Byte Store, Big/Little Endian
	    //No alignment necessary
	    2'b01: muxed_data = {8{data[7:0]}};

	    //Unsigned Halfword, Big/Little Endian
	    //No alignment necessary
	    2'b10: muxed_data = {4{data[15:0]}};

	    //Halfword and Byte Activated...ERROR
	    //Store entire word in this case
	    2'b11: muxed_data = data;

	endcase
end

//Set the Alignment for the input data
always @(data_bus or unsigned_hw or unsigned_byte or
		signed_hw or signed_byte or BIGEND or
		addr_low)
    begin
	casex ({BIGEND, addr_low, unsigned_hw, signed_hw, 
		unsigned_byte, signed_byte}) //synopsys full_case parallel_case
	
	//Word Accesses
	    //Address on Word Boundary
	    7'b?000000: loaded_data = data_bus;
	    
	    //LE & WB+1 -or- BE & WB+3
	    7'b0010000,
	    7'b1110000: loaded_data =
		{data_bus[39:32],data_bus[63:40],
		 data_bus[7:0],data_bus[31:8]};
 
	    //LE & WB+2 -or- BE & WB+2
	    7'b?100000: loaded_data = 
		{data_bus[47:32],data_bus[63:48],
		 data_bus[15:0],data_bus[31:16]};

	    //LE & WB+3 -or BE & WB+1
	    7'b0110000,
	    7'b1010000: loaded_data = 
		{data_bus[55:0],data_bus[63:56],
		 data_bus[23:0],data_bus[31:24]};

	//Unsigned Halfword Accesses
	    //LE & WB+0,1 -or- BE & WB+2,3
	    7'b00?1000,
	    7'b11?1000: loaded_data = 
		{{16{1'b0}},data_bus[47:32],{16{1'b0}},data_bus[15:0]};

	    //LE & WB+2,3 -or- BE & WB+0,1
	    7'b01?1000,
	    7'b10?1000: loaded_data = 
		{{16{1'b0}},data_bus[63:48],{16{1'b0}},data_bus[31:16]};

	//Signed Halfword Accesses
	    //LE & WB+0,1 -or- BE & WB+2,3
	    7'b00?0100,
	    7'b11?0100: loaded_data = 
		{{16{data_bus[47]}},data_bus[47:32],
		 {16{data_bus[15]}},data_bus[15:0]};

	    //LE & WB+2,3 -or- BE & WB+1,2
	    7'b01?0100,
	    7'b10?0100: loaded_data = 
		{{16{data_bus[63]}},data_bus[63:48],
		 {16{data_bus[31]}},data_bus[31:16]};

	//Unsigned Byte Accesses
	    //LE & WB -or- BE & WB+3
	    7'b0000010,
	    7'b1110010: loaded_data = 
		{{24{1'b0}},data_bus[39:32],{24{1'b0}},data_bus[7:0]};

	    //LE & WB+1 -or- BE & WB+2
	    7'b0010010,
	    7'b1100010: loaded_data = 
		{{24{1'b0}},data_bus[47:40],{24{1'b0}},data_bus[15:8]};

	    //LE & WB+2 -or- BE & WB+1
            7'b0100010,
	    7'b1010010: loaded_data = 
		{{24{1'b0}},data_bus[55:48],{24{1'b0}},data_bus[23:16]};

	    //LE & WB+3 -or- BE & WB
	    7'b0110010,
	    7'b1000010: loaded_data = 
		{{24{1'b0}},data_bus[63:56],{24{1'b0}},data_bus[31:24]};

	//Signed Byte Accesses
	    //LE & WB -or- BE & WB+3
	    7'b0000001,
	    7'b1110001: loaded_data = 
		{{24{data_bus[39]}},data_bus[39:32],
		 {24{data_bus[7]}},data_bus[7:0]};
	
	    //LE & WB+1 -or- BE & WB+2
	    7'b0010001,
	    7'b1100001: loaded_data = 
		{{24{data_bus[47]}},data_bus[47:40],
		 {24{data_bus[15]}},data_bus[15:8]};

	    //LE & WB+2 -or BE & WB+1
	    7'b0100001,
	    7'b1010001: loaded_data = 
		{{24{data_bus[55]}},data_bus[55:48],
		 {24{data_bus[23]}},data_bus[23:16]};

	    //LE & WB+3 -or BE & WB
	    7'b0110001,
	    7'b1000001: loaded_data = 
		{{24{data_bus[63]}},data_bus[63:56],
		 {24{data_bus[31]}},data_bus[31:24]};

	//Error
	    default: loaded_data = data_bus;
	endcase
    end
endmodule
