// Testbed for SDRAM model with AVL implementation
// written by Chris Fester 4-5-00

`include "AVLMemory.v"
`include "Memoryside.v"

module top;
   reg [31:0] outsideAddr;
   wire [31:0] A;
   wire [31:0] D;
   wire        nRAS, nCAS, nRW, SEQ, nCS, MCLK, BYTE;
   wire        st_busy, ld_busy;
   reg 	       write_buffer_is_byte;
   reg [31:0]  write_buffer_D, write_buffer_A;
   reg 	       Store_Trigger, Load_Trigger;
   wire        load_from_mem_req;
   wire [31:0] load_from_mem_data;
   wire [1:0]  load_from_mem_offset;
   reg 	       sysclk;
   reg 	       reset;

   wire        nWE;	
   memory_coupler memside(outsideAddr, A, D, nRAS, nCAS, nRW, SEQ, nCS, MCLK, BYTE, 
			  st_busy, ld_busy, 
			  write_buffer_is_byte, write_buffer_D, write_buffer_A, 
			  Store_Trigger, Load_Trigger, load_from_mem_req, 
			  load_from_mem_data, load_from_mem_offset, sysclk, reset);

   SDRAM_model_AVL mem(A, D, nRAS, nCAS, nWE, SEQ, nCS, MCLK, BYTE);

   always #10 sysclk = ~sysclk;

   assign nWE = ! nRW;

   always @(posedge sysclk)
      $display("MEM: A=%h D=%h {nRAS,nCAS,nRW}=%b, load req=%b", 
	       A, D, {nRAS, nCAS, nRW}, load_from_mem_req);

   initial
      begin
	 sysclk = 1'b0;
	 outsideAddr = 32'h00000000;
	 write_buffer_is_byte = 1'b0;
	 write_buffer_D = 32'h00000000;
	 write_buffer_A = 32'h00000000;
	 Store_Trigger = 1'b0;
	 Load_Trigger = 1'b0;
	 reset = 1'b0;

	 #40;
	 reset = 1'b1;

	 #20;
	 reset = 1'b0;  // here we'll store an entire cache line.
	 write_buffer_D = 32'h01010101;
	 write_buffer_A = 32'h00000000;
	 Store_Trigger = 1'b1;
	 #20;
	 Store_Trigger = 1'b0;

	 #(20 * 8); // 8 states for store.
	 write_buffer_D = 32'hF0123456;
	 write_buffer_A = 32'h00000004;
	 Store_Trigger = 1'b1;
	 #20;
	 Store_Trigger = 1'b0;

	 #(20 * 8);
	 write_buffer_D = 32'h79ABCDEF;
	 write_buffer_A = 32'h00000008;
	 Store_Trigger = 1'b1;
	 #20;
	 Store_Trigger = 1'b0;

	 #(20 * 8);
	 write_buffer_D = 32'hDEADF00F;
	 write_buffer_A = 32'h0000000C;
	 Store_Trigger = 1'b1;
	 #20;
	 Store_Trigger = 1'b0;		

	 #(20 * 8); // now we're going to load that stored cacheline...
	 Load_Trigger = 1'b1;
	 outsideAddr = 32'h00000000;
	 #20;
	 Load_Trigger = 1'b0;
	 
	 #(20*10); // 10 states for load...
	 // now we'll store a byte...
	 write_buffer_is_byte = 1'b1;
	 write_buffer_D = 32'h00CC0000;
	 write_buffer_A = 32'h00000002;
	 Store_Trigger = 1'b1;
	 #20;
	 Store_Trigger = 1'b0;		

	 #(20*8);
	 // now we're going to load that stored cacheline with the modified byte:
	 Load_Trigger = 1'b1;
	 outsideAddr = 32'h00000000;
	 #20;
	 Load_Trigger = 1'b0;

	 #(20*10);

	 #200;

	 //$finish;
	 $shm_open("waves.shm");
	 $shm_probe(top.outsideAddr, top.A, top.D, top.nRAS, top.nCAS, top.nRW, top.SEQ, 
		    top.nCS, top.MCLK, top.BYTE, top.st_busy, top.ld_busy, 
		    top.write_buffer_is_byte, top.write_buffer_D, top.write_buffer_A, 
		    top.Store_Trigger, top.Load_Trigger, top.load_from_mem_req, 
		    top.load_from_mem_data, top.load_from_mem_offset, top.sysclk, top.reset);
	 
	 $shm_probe(top.memside.A, top.memside.clk, top.memside.ld_busy, 
		    top.memside.load_from_mem_data, top.memside.load_from_mem_offset, 
		    top.memside.load_from_mem_req, top.memside.Load_Trigger, top.memside.mem_A, 
		    top.memside.mem_BYTE, top.memside.mem_D, top.memside.mem_Dout, 
		    top.memside.mem_MCLK, top.memside.mem_nCAS, top.memside.mem_nCS, 
		    top.memside.mem_nRAS, top.memside.mem_nRW, top.memside.mem_SEQ, 
		    top.memside.reset, top.memside.st_busy, top.memside.state, 
		    top.memside.Store_Trigger, top.memside.write_buffer_A, 
		    top.memside.write_buffer_D, top.memside.write_buffer_is_byte);
	 
	 $shm_probe(top.mem.Addr, top.mem.AddrBuf, top.mem.BYTE, top.mem.Data, 
		    top.mem.Dataout, top.mem.MCLK, top.mem.nCAS, top.mem.nCS, 
		    top.mem.nRAS, top.mem.nWE, top.mem.SEQ, top.mem.WriteBuf);

	 $stop;
	 $finish;
      end
endmodule
