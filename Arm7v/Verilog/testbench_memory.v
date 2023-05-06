// Simple tester for Memory Interface

// NB. Run in a maximised xterm, with a small font on a very hi-res screen.

`include "MemoryInterface.v"

`define DEBUG

module top;
   // All regs
   reg [31:0] A;
   tri [31:0] D;
   reg 	      nMREQ, nRW, sysclk, reset;
   wire       nWAIT;
   reg [1:0]  MAS;

   reg [31:0] Dout;
   wire       nRESET;
   

   assign D = Dout;
   assign nRESET = ! reset;
   
   // Test pieces
   MemoryInterface MI(D, A, nMREQ, nRW, MAS, nWAIT, sysclk, nRESET);

   always #10 sysclk = ~sysclk;

`ifdef DEBUG	 
   always @(posedge sysclk) #6
      begin
	 $write ("%h A=%h D=%h {nWAIT,nMREQ,nRW,MAS}=%b s/lBsy=%b s/lT=%b ",
		 MI.cpuside.present_cpu_state, A, D, {nWAIT,nMREQ, nRW, MAS}, 
		 {MI.st_busy, MI.ld_busy}, {MI.Store_Trigger, MI.Load_Trigger} );
	 

	 $write ("ld_frm_mem{req,data,offst}={%b,%h,%h} ",
		 MI.load_from_mem_req, MI.load_from_mem_data, MI.load_from_mem_offset);
	 
	 $display("MEM: A=%h D=%h {nRAS,nCAS,nWE,BTE,nCS}=%b",
		  MI.mem_A, MI.mem_D, 
		  {MI.mem_nRAS, MI.mem_nCAS, MI.mem_nWE, MI.mem_BYTE, MI.mem_nCS});
      end // always @ (posedge slowclk) #20
`endif
	   
      
   initial
      begin
	 sysclk = 0;
	 Dout = 32'hz;
	 reset = 1;
	 @(posedge sysclk) #0;
	 reset = 0;
	 #40
	 //$stop;
	 //$shm_open("waves.shm");
	 //$shm_probe(top.p.ac, top.p.but_DEP, top.p.but_MA, top.p.but_PC, top.p.cont, 
	 // top.p.halt, top.p.ir, top.p.link, top.p.ma, top.p.mb, top.p.pc, 
	 // top.p.present_state, top.p.sr, top.p.sysclk);
	 
	 @(posedge sysclk) #0;
	 // Do a store (Word 2)
	 A = 4;
	 nMREQ = 0;
	 nRW = 1;
	 MAS = 2'b10;
	 Dout = 32'hABCD9876;
	 $display("Store initiated: abcd9876 in word 1 (byte 4)");
	 @(posedge sysclk) #0;
	 nMREQ = 1;
	 wait (nWAIT)

	 @(posedge sysclk) #0;
	 // Do a store (Word 2)
	 A = 8;
	 nMREQ = 0;
	 nRW = 1;
	 MAS = 2'b10;
	 Dout = 32'h01010101;
	 $display("Store initiated: 01010101 in word 2 (byte 8)");
	 @(posedge sysclk) #1;
	 nMREQ = 1;
	 wait (nWAIT)

	 @(posedge sysclk) #0;
	 // Do a store (Word 2)
	 A = 32'h0000000c;
	 nMREQ = 0;
	 nRW = 1;
	 MAS = 2'b10;
	 Dout = 32'h0a0a0a0a;
	 $display("Store initiated: 0a0a0a0a in word 3 (byte c)");
	 @(posedge sysclk) #0;
	 nMREQ = 1;
	 wait (nWAIT)

	 nMREQ=1; // Finish store!  (Needed only if we don't wait(nWAIT) before the next thing)
	 #160;
	 
	 @(posedge sysclk) #0;
	 // Do a Load (Word 1)
	 A = 4;
	 Dout = 32'hzzzzzzzz;
	 nMREQ = 0;
	 nRW = 0;
	 MAS = 2'b10;
	 reset = 0;
	 $display("Load initiated: Should retrieve abcd9876 from word 1 (byte 4)");
	 @(posedge sysclk) #0;

	 nMREQ = 1;
	 wait(nWAIT);
	 $display("Data from load is %h", D);
	 
	 //$display ("Ending load...");
	 nRW = 1;
	 nMREQ = 1;
	 #60;
	 
	 @(posedge sysclk) #0;
	 // Do a store (Word 2)
	 A = 8;
	 nMREQ = 0;
	 nRW = 1;
	 MAS = 2'b10;
	 reset = 0;
	 Dout = 32'hABCD9876;
	 $display("Store initiated: abcd9876 in word 2 (byte 8)");
	 
	 @(posedge sysclk) #0;
	 nMREQ = 1;
	 #200;
	 
	 //$stop;	 
	 $finish;
      end // initial begin

endmodule // top

	
