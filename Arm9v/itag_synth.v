`timescale 1ns/10ps
/*****************************************************************************
$RCSfile: itag_synth.v,v $
$Revision: 1.1 $
$Author: kohlere $
$Date: 2000/05/19 14:02:25 $
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

wire	[TS-1:0] read_port;		//Read Port

/* 2 ported Ram, 1 read, 1 write */
itagram ram0
    (
	.addr(read_sel), 
        .di(write_port),
        .clk(nGCLK),
        .we(wr_ena),
        .en(1'b1),
        .rst(1'b0),
        .do(read_port)
    );

endmodule
