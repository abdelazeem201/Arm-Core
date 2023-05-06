`timescale 1ns/10ps
/*****************************************************************************
$RCSfile: miniram.v,v $
$Revision: 1.5 $
$Author: kohlere $
$Date: 2000/04/13 21:55:18 $
$State: Exp $
$Source: &

Description:  Cache Memory Module

*****************************************************************************/

//module miniram (nGCLK, write_sel, read_sel, write_port, read_port, wr_ena);
module miniram (read_sel, read_port);

/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/

//input	[255:0]		write_port;	//Write Value
input 	[3:0]		read_sel;	//Read Select Line
//input	[3:0]		write_sel;	//Write Select Line
//input			nGCLK;		//Clock Signal
//input			wr_ena;		//Write Enable

output	[255:0]		read_port;	//Read Line

/*------------------------------------------------------------------------
        Signal Declarations
------------------------------------------------------------------------*/
reg	[255:0]	read_port;		//Read Port
always @(read_sel)
  begin
    case (read_sel) //synopsys full_case parallel_case
      4'h0: read_port = 256'hed2def01e3a07902e3a0b902e3a0a806e24ee004e92d0f8fe24dd004e3a0da01;
      4'h1: read_port = 256'he1a00000e1a00000e1a00000e1a00000e1a00000ea00000ce3c8801fe49d8004;
      4'h2: read_port = 256'he3c8801fe24e8004e3a07902e3a0b902e3a0a806e92d0f8fe24dd004e3a0da01;
      4'h3: read_port = 256'he1a09820ece87f01ed977f00e08a7729e1a09800e899000fe08b90a9e0489007;
      4'h4: read_port = 256'he1a09821ece87f01ed977f00e08a7729e1a09801ece87f01ed977f00e08a7109;
      4'h5: read_port = 256'he1a09822ece87f01ed977f00e08a7729e1a09802ece87f01ed977f00e08a7109;
      4'h6: read_port = 256'he1a09823ece87f01ed977f00e08a7729e1a09803ece87f01ed977f00e08a7109;
      4'h7: read_port = 256'hffffffff00000000ffffffffe25ef004e8bd0f8fece87f01ed977f00e08a7109;
      4'h8: read_port = 256'h0;                                                               
      4'h9: read_port = 256'h0;                                                               
      4'hA: read_port = 256'h0;                                                               
      4'hB: read_port = 256'h0;                                                               
      4'hC: read_port = 256'h0;                                                               
      4'hD: read_port = 256'h0;                                                               
      4'hE: read_port = 256'h0;                                                               
      4'hF: read_port = 256'h0;                                                               
    endcase
  end
endmodule

