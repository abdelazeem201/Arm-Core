`timescale 1ns/10ps
/*****************************************************************************
$RCSfile: ram2p_synth.v,v $
$Revision: 1.1 $
$Author: kohlere $
$Date: 2000/05/19 14:02:25 $
$State: Exp $
$Source: &

Description:  Cache Memory Module

*****************************************************************************/

module ram2p (nGCLK, write_sel, read_sel, write_port, read_port, wr_ena);

parameter       NL = 256;       //Number of Cache Lines (kB = 32*NL/1024)
parameter       LSS = 8;        //Line Select Bits = Log2(NL)

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

reg	[255:0]	read_port;		//Read Port
wire	[255:0] a0, b0;			//Read Ports from Rams

reg written;				//Did we just write the Cache?
reg [LSS-1:0] written_addr;		//What Line was written
reg [LSS-1:0] addr_read;		//What Line was read

//Record Where Write was To
always @(posedge nGCLK)
  begin
    addr_read <= read_sel;
    if (wr_ena)
      written_addr <= write_sel;
  end

//If writing to Same Port, Must Forward Data to Output
always @(addr_read or written_addr or a0 or b0)
  begin
    if ((addr_read == written_addr))
      read_port <= b0;
    else
      read_port <= a0;
  end

/* 2 ported Ram, 1 read, 1 write */
dcram ram0
    (
      .addra(read_sel),
      .addrb(write_sel),
      .dia(256'h0),
      .dib(write_port),  
      .clka(nGCLK),
      .clkb(nGCLK),
      .wea(1'b0),
      .web(wr_ena),
      .ena(1'b1),
      .enb(wr_ena),
      .rsta(1'b0),
      .rstb(1'b0),  
      .doa(a0),
      .dob(b0)
    );

endmodule

