`timescale 1ns/100ps
module tb_dhrystone;

reg         clk;

initial clk = 1'b0;

always clk = #500 ~clk;

reg         rst;
initial begin
rst = 1'b1;
#1000 rst = 1'b0;
end

integer irq_cnt = 0;

always @ ( posedge clk )
if ( irq_cnt==9999 )
    irq_cnt <= 0;
else
    irq_cnt <= irq_cnt + 1'b1;
	
wire irq;
assign irq = (irq_cnt==9999);	

reg [7:0] rom_contain [32767:0];

initial begin
   $readmemh("DHRY.bin", rom_contain);
end

wire            rom_en;
wire [31:0]     rom_addr;
reg  [31:0]     rom_data;
always @ ( posedge clk )
if ( rom_en )
    rom_data <= {rom_contain[rom_addr+3],rom_contain[rom_addr+2],rom_contain[rom_addr+1],rom_contain[rom_addr]};
else;

wire          ram_cen;
wire [3:0]    ram_flag;
wire          ram_wen;
wire [31:0]   ram_addr;
wire [31:0]   ram_wdata;

reg [31:0] ram_contain [4095:0];

always @ ( posedge clk )
if ( ram_cen & ram_wen & (ram_addr[31:28]==4'h4 ) ) 
    ram_contain[ram_addr[13:2]] <= {(ram_flag[3]?ram_wdata[31:24]:ram_contain[ram_addr[13:2]][31:24]),(ram_flag[2]?ram_wdata[23:16]:ram_contain[ram_addr[13:2]][23:16]),(ram_flag[1]?ram_wdata[15:8]:ram_contain[ram_addr[13:2]][15:8]),(ram_flag[0]?ram_wdata[7:0]:ram_contain[ram_addr[13:2]][7:0])};
else;

reg [31:0] ram_rdata;

always @ (posedge clk )
if ( ram_cen & ~ram_wen )
    if ( ram_addr == 32'he0000000 )
	    ram_rdata <= 32'h0;
	else if ( ram_addr[31:28]==4'h0 )
	    ram_rdata <= {rom_contain[ram_addr+3],rom_contain[ram_addr+2],rom_contain[ram_addr+1],rom_contain[ram_addr]};
	else 
	    ram_rdata <= ram_contain[ram_addr[13:2]];
else;

always @ ( posedge clk )
if ( ram_cen & ram_wen & ( ram_addr==32'he0000004 ) )
    $write("%s",ram_wdata[7:0]);
else;


arm u_arm(
          .clk         (             clk          ),
          .cpu_en      (             1'b1         ),
          .cpu_restart (             1'b0         ),
          .fiq         (             1'b0         ),
          .irq         (             irq          ),
          .ram_abort   (             1'b0         ),
          .ram_rdata   (             ram_rdata    ),
          .rom_abort   (             1'b0         ),
          .rom_data    (             rom_data     ),
          .rst         (             rst          ),

          .ram_addr    (             ram_addr     ),
          .ram_cen     (             ram_cen      ),
          .ram_flag    (             ram_flag     ),
          .ram_wdata   (             ram_wdata    ),
          .ram_wen     (             ram_wen      ),
          .rom_addr    (             rom_addr     ),
          .rom_en      (             rom_en       )
        ); 

						
endmodule

