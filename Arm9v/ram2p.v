`timescale 1ns/10ps
/*****************************************************************************
$RCSfile: ram2p.v,v $
$Revision: 1.2 $
$Author: kohlere $
$Date: 2000/04/08 19:19:45 $
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
wire	[31:0]  a0, a1, a2, a3;		//Read Ports from Rams
wire	[31:0]  a4, a5, a6, a7;		//Read Ports from Rams
wire	[31:0]  b0, b1, b2, b3;		//Read Ports from Rams
wire	[31:0]	b4, b5, b6, b7;		//Read Ports from Rams

reg written;				//Did we just write the cache?
reg [LSS-1:0] written_addr;		//Which Line did we write?
reg [LSS-1:0] addr_read;		//Which Line did we read?

//Record Where Write was To
always @(posedge nGCLK)
  begin
    addr_read <= read_sel;
    if (wr_ena)
      written_addr <= write_sel;
  end

//If writing to Same Port, Must Forward Data to Output
always @(addr_read or written_addr or written or a7 or a6 or
		a5 or a4 or a3 or a2 or a1 or a0 or b7 or
		b6 or b5 or b4 or b3 or b2 or b1 or b0)
  begin
    if ((addr_read == written_addr))
      read_port <= {b7, b6, b5, b4, b3, b2, b1, b0};
    else
      read_port <= {a7, a6, a5, a4, a3, a2, a1, a0};
  end

/* 2 ported Ram, 1 read, 1 write */
RAMB_256x32_DP  ram0 
    (
      .addra(read_sel),
      .addrb(write_sel),
      .dia(32'h0),
      .dib(write_port[31:0]),  
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

RAMB_256x32_DP  ram1
    (
      .addra(read_sel),
      .addrb(write_sel),
      .dia(32'h0),
      .dib(write_port[63:32]),
      .clka(nGCLK),
      .clkb(nGCLK),
      .wea(1'b0),
      .web(wr_ena),
      .ena(1'b1),
      .enb(wr_ena),
      .rsta(1'b0),           
      .rstb(1'b0),           
      .doa(a1),              
      .dob(b1)               
    );

RAMB_256x32_DP  ram2
    (
      .addra(read_sel),
      .addrb(write_sel),
      .dia(32'h0),
      .dib(write_port[95:64]),
      .clka(nGCLK),
      .clkb(nGCLK),
      .wea(1'b0),
      .web(wr_ena),
      .ena(1'b1),
      .enb(wr_ena),
      .rsta(1'b0),           
      .rstb(1'b0),           
      .doa(a2),              
      .dob(b2)               
    );

RAMB_256x32_DP  ram3
    (
      .addra(read_sel),
      .addrb(write_sel),
      .dia(32'h0),
      .dib(write_port[127:96]),
      .clka(nGCLK),
      .clkb(nGCLK),
      .wea(1'b0),
      .web(wr_ena),
      .ena(1'b1),
      .enb(wr_ena),
      .rsta(1'b0),           
      .rstb(1'b0),           
      .doa(a3),              
      .dob(b3)               
    );

RAMB_256x32_DP  ram4
    (
      .addra(read_sel),
      .addrb(write_sel),
      .dia(32'h0),
      .dib(write_port[159:128]),
      .clka(nGCLK),
      .clkb(nGCLK),
      .wea(1'b0),
      .web(wr_ena),
      .ena(1'b1),
      .enb(wr_ena),
      .rsta(1'b0),           
      .rstb(1'b0),           
      .doa(a4),              
      .dob(b4)               
    );

RAMB_256x32_DP  ram5
    (
      .addra(read_sel),
      .addrb(write_sel),
      .dia(32'h0),
      .dib(write_port[191:160]),
      .clka(nGCLK),
      .clkb(nGCLK),
      .wea(1'b0),
      .web(wr_ena),
      .ena(1'b1),
      .enb(wr_ena),
      .rsta(1'b0),           
      .rstb(1'b0),           
      .doa(a5),              
      .dob(b5)               
    );

RAMB_256x32_DP  ram6
    (
      .addra(read_sel),
      .addrb(write_sel),
      .dia(32'h0),
      .dib(write_port[223:192]),
      .clka(nGCLK),
      .clkb(nGCLK),
      .wea(1'b0),
      .web(wr_ena),
      .ena(1'b1),
      .enb(wr_ena),
      .rsta(1'b0),           
      .rstb(1'b0),           
      .doa(a6),              
      .dob(b6)               
    );

RAMB_256x32_DP  ram7
    (
      .addra(read_sel),
      .addrb(write_sel),
      .dia(32'h0),
      .dib(write_port[255:224]),
      .clka(nGCLK),
      .clkb(nGCLK),
      .wea(1'b0),
      .web(wr_ena),
      .ena(1'b1),
      .enb(wr_ena),
      .rsta(1'b0),           
      .rstb(1'b0),           
      .doa(a7),              
      .dob(b7)               
    );


endmodule

