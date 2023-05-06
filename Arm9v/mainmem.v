`timescale 1ns/10ps
/*****************************************************************************
$RCSfile: mainmem.v,v $
$Revision: 1.1 $
$Author: kohlere $
$Date: 2000/03/24 01:52:16 $
$State: Exp $
$Source: /home/lefurgy/tmp/ISC-repository/isc/hardware/ARM10/behavioral/pipelined/fpga2/mainmem.v,v $

Description:  This module simulate main memory using a ZBT Sram mode
		obtained from the IDT web page.

*****************************************************************************/
module mainmem (MMA, MMD, GCLK, MMnWR);

/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/
input	[31:0]	MMA;		//Main Memory Address Bus
input		GCLK;		//Main Memory Clock
input		MMnWR;		//Main Memory not Write, Read

inout	[31:0]	MMD;		//Main Memory Data Bus

/*------------------------------------------------------------------------
        Signal Declarations
------------------------------------------------------------------------*/
wire	adv_ld_ = 1'b0;		//advance (high) / load (low)
wire	bw1_ = 1'b0;		//byte write enable (low)
wire	bw2_ = 1'b0; 		//byte write enable (low)
wire	bw3_ = 1'b0;		//byte write enable (low)
wire	bw4_ = 1'b0;		//byte write enable (low)
wire	ce1_ = 1'b0;		//chip enable (low)
wire	ce2 = 1'b1;		//chip enable
wire	ce2_ = 1'b0;		//chip enable (low)
wire	cen_ = 1'b0;		//clock enable (low)
wire	lbo_ = 1'b0;		//linear order burst sequence
wire	oe_ = 1'b0;		//Output Enable

/*------------------------------------------------------------------------
        Memory Chip Declarations
------------------------------------------------------------------------*/

idt71v546s100 xmem1 (.A(MMA[18:2]), .adv_ld_(adv_ld_), 
		.bw1_(bw1_), .bw2_(bw2_), .bw3_(bw3_), .bw4_(bw4_),
		.ce1_(ce1_), .ce2(ce2), .ce2_(ce2_), .cen_(cen_),
		.clk(GCLK), .IO(MMD), .IOP(), .lbo_(lbo_),
		.oe_(oe_), .r_w_(MMnWR));

endmodule
