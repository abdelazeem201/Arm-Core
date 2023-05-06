`timescale 1ns/10ps
/*****************************************************************************
$RCSfile: tag.v,v $
$Revision: 1.1 $
$Author: kohlere $
$Date: 2000/03/24 01:52:17 $
$State: Exp $
$Source: &

Description:  Tag Memory Module

*****************************************************************************/

module tag (nGCLK, write_sel, read_sel, write_port, read_port, wr_ena);

parameter       NL = 512;       //Number of Cache Lines (kB = 32*NL/1024)
parameter       LSS = 9;        //Line Select Bits = Log2(NL)
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

reg	[TS-1:0] tag	[NL-1:0];	//Memory Declaration
wire	[TS-1:0] read_port;		//Read Port

//synopsys translate_off
assign read_port = tag[read_sel];
always @(posedge nGCLK)
  begin
    if (wr_ena)
      tag[write_sel] <= #2 write_port;
  end
//synopsys translate_on

wire [TS-1:0] tagline0 = tag[0];
wire [TS-1:0] tagline1 = tag[1];

endmodule
