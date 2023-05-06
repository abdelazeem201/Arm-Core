`timescale 1ns/10ps
/*****************************************************************************
$RCSfile: dtag.v,v $
$Revision: 1.4 $
$Author: kohlere $
$Date: 2000/04/12 16:35:41 $
$State: Exp $
$Source: &

Description:  Tag Memory Module

*****************************************************************************/

module dtag (nGCLK, write_sel, read_sel, write_port, read_port, wr_ena);

parameter       NL = 256;       //Number of Cache Lines (kB = 32*NL/1024)
parameter       LSS = 8;        //Line Select Bits = Log2(NL)
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

reg	[TS-1:0] read_port;		//Read Port
wire	[15:0]	dib;			//Input Data
wire	[15:0]	a0, b0, a1, b1;		//Port Outputs

/* Have to Add a little Logic for Writes and Read of Same Line */
reg written;
reg [LSS-1:0] written_addr;
reg [LSS-1:0] addr_read;

//Record Where Write was To
always @(posedge nGCLK)
  begin
    addr_read <= read_sel;
    if (wr_ena)
      written_addr <= write_sel;
  end

//If writing to Same Port, Must Forward Data to Output
always @(addr_read or written_addr or a0 or b0 or a1 or b1)
  begin
    if ((addr_read == written_addr))
      read_port <= {b1[TS-17:0],b0};  
    else
      read_port <= {a1[TS-17:0],a0};
  end

RAMB_256x16_DP ram0
    (
        .addra(read_sel), 
        .addrb(write_sel),
        .dia(16'h0),
        .dib(write_port[15:0]),
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

assign dib = {{(32-TS){1'b0}},write_port[TS-1:16]};
RAMB_256x16_DP ram1
    (
        .addra(read_sel),
        .addrb(write_sel),
        .dia(16'h0),
        .dib(dib),
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


endmodule


