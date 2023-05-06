`timescale 1ns/10ps
/*****************************************************************************
$RCSfile: itag.v,v $
$Revision: 1.3 $
$Author: kohlere $
$Date: 2000/05/04 18:14:56 $
$State: Exp $
$Source: &

Description:  Tag Memory Module

*****************************************************************************/

module itag (nGCLK, write_sel, read_sel, write_port, read_port, wr_ena);

parameter       NL = 128;       //Number of Cache Lines (kB = 32*NL/1024)
parameter       LSS = 7;        //Line Select Bits = Log2(NL)
parameter       LSH = LSS + 4;  //LS High Bit Add = <Tag><LSS><word><byte>
parameter       PSL = LSH + 1;  //Page Select Low Bit
parameter       TS=2+(32-PSL);  //Tag Size D,V,Page Select
parameter       ZEROS=33-TS;    //Number of Zeros to Add

/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/

input	[TS-1:0]	write_port;	//Write Value
input 	[LSS-1:0]	read_sel;	//Read Select Line
input	[LSS-1:0]	write_sel;	//Write Select Line
input			nGCLK;		//Clock
input			wr_ena;		//Write Enable

output	[TS-1:0]	read_port;	//Read Line

/*------------------------------------------------------------------------
        Signal Declarations
------------------------------------------------------------------------*/

//reg	[TS-1:0] tag	[NL-1:0];	//Memory Declaration
wire	[TS-1:0] read_port;		//Read Port
wire	[LSS:0]  addra, addrb;		//Address Lines
wire	[15:0]	 a0, a1;		//Cache Outputs
wire	[15:0]	 dib;

/* Modify the Address so that the 2 ported 256x32 SRAM
   looks like a 128x64 single ported SRAM */
//Note, there are actually 256 lines, 
assign addra = {read_sel,1'b0};
assign addrb = {read_sel,1'b1};
assign dib = {10'h000,write_port[TS-1:16]};
assign read_port = {a1[TS-17:0],a0};

/* 2 ported Ram, 1 read, 1 write */
RAMB_256x16_DP ram0
    (
	.addra(addra), 
        .addrb(addrb),
        .dia(write_port[15:0]),
        .dib(dib),
        .clka(nGCLK),
        .clkb(nGCLK),
        .wea(wr_ena),
        .web(wr_ena),
        .ena(1'b1),
        .enb(1'b1),
        .rsta(1'b0),
        .rstb(1'b0),
        .doa(a0),
        .dob(a1)
    );

endmodule
