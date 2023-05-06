`timescale 1ns/10ps
/*****************************************************************************
$RCSfile: ram1p_synth.v,v $
$Revision: 1.1 $
$Author: kohlere $
$Date: 2000/05/19 14:02:25 $
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

wire	[255:0]	read_port;		//Read Port

/* 2 ported Ram, 1 read, 1 write */
icram ram0
    (
      .addr(read_sel),
      .di(write_port[255:0]),
      .clk(nGCLK),
      .we(wr_ena),
      .en(1'b1),
      .rst(1'b0),
      .do(read_port)
    );

endmodule
