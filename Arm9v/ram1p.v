`timescale 1ns/10ps
/*****************************************************************************
$RCSfile: ram1p.v,v $
$Revision: 1.1 $
$Author: kohlere $
$Date: 2000/03/28 02:45:57 $
$State: Exp $
$Source: &

Description:  Cache Memory Module

*****************************************************************************/

module ram1p (nGCLK, write_sel, read_sel, write_port, read_port, wr_ena);

parameter       NL = 128;       //Number of Cache Lines (kB = 32*NL/1024)
parameter       LSS = 7;        //Line Select Bits = Log2(NL)

/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/

input	[255:0]		write_port;	//Write Value
input 	[LSS-1:0]	read_sel;	//Read Select Line
input	[LSS-1:0]	write_sel;	//Write Select Line
input			nGCLK;		//Clock Signal
input			wr_ena;		//Write Enable

output	[255:0]		read_port;	//Read Line

/*------------------------------------------------------------------------
        Signal Declarations
------------------------------------------------------------------------*/

//reg	[255:0]	mem	[NL-1:0];	//Memory Declaration
wire	[255:0]	read_port;		//Read Port
wire	[31:0]  a0, a1, a2, a3;		//Read Ports from Rams
wire	[31:0]  a4, a5, a6, a7;		//Read Ports from Rams
wire	[LSS:0] addra, addrb;		//Address Lines

/* Modify the Address so that the 2 ported 256x32 SRAM
   looks like a 128x64 single ported SRAM */
//Note, there are actually 256 lines, 
assign addra = {read_sel,1'b0};
assign addrb = {read_sel,1'b1};

/* Assign the Read Port Output */
assign read_port = {a7,a6,a5,a4,a3,a2,a1,a0};

/* 2 ported Ram, 1 read, 1 write */
RAMB_256x32_DP  ram0 
    (
      .addra(addra),
      .addrb(addrb),
      .dia(write_port[31:0]),
      .dib(write_port[63:32]),  
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

RAMB_256x32_DP  ram1
    (
      .addra(addra),
      .addrb(addrb),
      .dia(write_port[95:64]),
      .dib(write_port[127:96]),
      .clka(nGCLK),
      .clkb(nGCLK),
      .wea(wr_ena),
      .web(wr_ena),
      .ena(1'b1),
      .enb(1'b1),
      .rsta(1'b0),           
      .rstb(1'b0),           
      .doa(a2),              
      .dob(a3)               
    );

RAMB_256x32_DP  ram2
    (
      .addra(addra),
      .addrb(addrb),
      .dia(write_port[159:128]),
      .dib(write_port[191:160]),
      .clka(nGCLK),
      .clkb(nGCLK),
      .wea(wr_ena),
      .web(wr_ena),
      .ena(1'b1),
      .enb(1'b1),
      .rsta(1'b0),           
      .rstb(1'b0),           
      .doa(a4),              
      .dob(a5)               
    );

RAMB_256x32_DP  ram3
    (
      .addra(addra),
      .addrb(addrb),
      .dia(write_port[223:192]),
      .dib(write_port[255:224]),
      .clka(nGCLK),
      .clkb(nGCLK),
      .wea(wr_ena),
      .web(wr_ena),
      .ena(1'b1),
      .enb(1'b1),
      .rsta(1'b0),           
      .rstb(1'b0),           
      .doa(a6),              
      .dob(a7)               
    );

endmodule

