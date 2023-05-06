// Simple tester for CPUside

`include "CPUside.v"

`define DEBUG

module top;
   // All regs
   reg [31:0]   A;
   tri [31:0] 	D;
   reg 		nMREQ, nRW, sysclk, reset;
   wire 	nWAIT;
   reg [1:0] 	MAS;
   wire 	Store_Trigger, Load_Trigger;
   wire [31:0] 	write_buffer_data, write_buffer_addr;
   wire 	write_buffer_is_byte;
   reg 		st_busy, ld_busy;
   reg 		load_from_mem_req;
   reg [31:0] 	load_from_mem_data;
   reg [1:0] 	load_from_mem_offset;
   
   reg [31:0] 	Dout;
   
   
   assign D = Dout;
   
   // Test pieces
   CPU_coupler CC(D, A, nMREQ, nRW, MAS, nWAIT, sysclk, reset, 
		  Store_Trigger, Load_Trigger, 
		  write_buffer_data, write_buffer_addr, write_buffer_is_byte, 
		  st_busy, ld_busy, load_from_mem_req, load_from_mem_data, load_from_mem_offset);

   always #64 sysclk = ~sysclk;

`ifdef DEBUG	 
   always @(posedge sysclk) #32
      begin
	 $write("%d A=%h D=%h {nWAIT,nMREQ,nRW,MAS}=%b st/ld_bsy=%b  ",
		$time, A, D, {nWAIT,nMREQ, nRW, MAS}, {st_busy, ld_busy});

	 $write("ld_frm_mem{req,data,offst}={%b,%h,%h} ",
		load_from_mem_req, load_from_mem_data, load_from_mem_offset);
		
	 $display("Ld/StTrigger=%b state=%h, victim-dedres=%b",
		  {Load_Trigger, Store_Trigger}, CC.present_cpu_state, CC.victim_dedsec_result);
      end // always @ (posedge slowclk) #20
`endif
	   
      
   initial
      begin
         $stop;
	 sysclk = 0;
	 st_busy = 0;
	 ld_busy = 0;
	 Dout = 32'hzzzzzzzz;
	 load_from_mem_data = 32'h12345678;
	 load_from_mem_offset = 00;
	 load_from_mem_req = 0;

	 #200;
	 @(posedge sysclk) #1;
	 // Load (1)
	 A = 1;
	 nMREQ = 0;
	 nRW = 0;
	 MAS = 2'b10;
	 reset = 0;
	 $display("Load initiated");
	 #10;
	 if (! Load_Trigger)
	    $display("error: Load_Trigger not asserted (should be cache miss)");
	 ld_busy <= 1;
	 @(posedge sysclk) #1;
	 load_from_mem_offset = 2'b00;
	 load_from_mem_req = 1;
	 @(posedge sysclk) #1;
	 load_from_mem_offset = 2'b01;
	 @(posedge sysclk) #1;
	 load_from_mem_offset = 2'b10;
	 @(posedge sysclk) #1;
	 load_from_mem_offset = 2'b11;
	 ld_busy <= @(posedge sysclk) 0;
	 load_from_mem_req <= @(posedge sysclk) 0;
	 
	 #2000;
	 $display ("Ending load...");
	 nMREQ = 1;
	 $display("Main cache line 0 is now:");
	 $display("0: main_cache=%h tag=%h valid=%b dedsec=%h",
		  CC.main_cache[0], CC.main_cache_tag[0], 
		  CC.main_cache_valid[0], CC.main_cache_dedsec[0]);
	 
	 $display("Victim cache should be empty.");
	 $display("Victim - oldest = 2'b%b", CC.oldest_victim_line);
	 
	 $display("0: victim_cache=%h tag=%h, valid=%b, dedsec=%h",
		  CC.victim_cache[0], CC.victim_cache_tag[0], 
		  CC.victim_cache_valid[0], CC.victim_cache_dedsec[0]);
	 
	 $display("1: victim_cache=%h tag=%h, valid=%b, dedsec=%h",
		  CC.victim_cache[1], CC.victim_cache_tag[1], 
		  CC.victim_cache_valid[1], CC.victim_cache_dedsec[1]);
	 
	 $display("2: victim_cache=%h tag=%h, valid=%b, dedsec=%h",
		  CC.victim_cache[2], CC.victim_cache_tag[2], 
		  CC.victim_cache_valid[2], CC.victim_cache_dedsec[2]);
	 
	 $display("3: victim_cache=%h tag=%h, valid=%b, dedsec=%h",
		  CC.victim_cache[3], CC.victim_cache_tag[3], 
		  CC.victim_cache_valid[3], CC.victim_cache_dedsec[3]);
	 #200;
	 
	 @(posedge sysclk) #1;
	 // Store (2)
	 A = 2;
	 nMREQ = 0;
	 nRW = 1;
	 MAS = 2'b10;
	 reset = 0;
	 Dout = 32'hABCD9876;
	 $display("Store initiated");
	 #20;
	 if (! Store_Trigger)
	    $display("error: Store_Trigger not signalled");
	 @(posedge sysclk) #1;
	 $display("write_buffer=%h, write_buffer_is_byte=%b", 
		  write_buffer_data, write_buffer_is_byte);
	 #30;
	 $display("write_buffer=%h, write_buffer_is_byte=%b", 
		  write_buffer_data, write_buffer_is_byte);
	 @(posedge sysclk) #1;
	 $display("write_buffer=%h, write_buffer_is_byte=%b", 
		  write_buffer_data, write_buffer_is_byte);
	 #1000;
	 nMREQ = 1;

	 #500;
	 @(posedge sysclk) #1;
	 // Load conflicting address
	 A = 32'h401;
	 nMREQ = 0;
	 nRW = 0;
	 MAS = 2'b10;
	 reset = 0;
	 $display("Load initiated (to generate a conflict with first load)");
	 #10 if (! Load_Trigger)
	    $display("error: Load_Trigger not asserted - should be cache miss");
	 ld_busy <= 1;
	 @(posedge sysclk) #1;
	 load_from_mem_offset = 2'b00;
	 load_from_mem_req = 1;
	 @(posedge sysclk) #1;
	 load_from_mem_offset = 2'b01;
	 @(posedge sysclk) #1;
	 load_from_mem_offset = 2'b10;
	 @(posedge sysclk) #1;
	 load_from_mem_offset = 2'b11;
	 ld_busy <= @(posedge sysclk) 0;
	 load_from_mem_req <= @(posedge sysclk) 0;
	 #500;
	 nMREQ = 1;
	 $display("The first load should now be in the victim cache:");
	 
	 $display("Victim - oldest = 2'b%b", CC.oldest_victim_line);
	 
	 $display("0: victim_cache=%h tag=%h, valid=%b, dedsec=%h",
		  CC.victim_cache[0], CC.victim_cache_tag[0], 
		  CC.victim_cache_valid[0], CC.victim_cache_dedsec[0]);
	 
	 $display("1: victim_cache=%h tag=%h, valid=%b, dedsec=%h",
		  CC.victim_cache[1], CC.victim_cache_tag[1], 
		  CC.victim_cache_valid[1], CC.victim_cache_dedsec[1]);
	 
	 $display("2: victim_cache=%h tag=%h, valid=%b, dedsec=%h",
		  CC.victim_cache[2], CC.victim_cache_tag[2], 
		  CC.victim_cache_valid[2], CC.victim_cache_dedsec[2]);
	 
	 $display("3: victim_cache=%h tag=%h, valid=%b, dedsec=%h",
		  CC.victim_cache[3], CC.victim_cache_tag[3], 
		  CC.victim_cache_valid[3], CC.victim_cache_dedsec[3]);
	 
	 $display("Main cache line 0 is now:");
	 $display("0: main_cache=%h tag=%h valid=%b dedsec=%h",
		  CC.main_cache[0], CC.main_cache_tag[0], 
		  CC.main_cache_valid[0], CC.main_cache_dedsec[0]);

	 #500;
	 @(posedge sysclk);
	 // Load (1)
	 A = 1;
	 nMREQ = 0;
	 nRW = 0;
	 MAS = 2'b10;
	 reset = 0;
	 $display("Load initiated (1: should come from victim cache)");
	 #10 if (Load_Trigger)
	    $display("error: Load_Trigger asserted - should have come from cache");
	 ld_busy <= 1;
	 @(posedge sysclk) #1;
	 load_from_mem_offset = 2'b00;
	 load_from_mem_req = 1;
	 
	 @(posedge sysclk) #1;
	 load_from_mem_offset = 2'b01;
	 
	 @(posedge sysclk) #1;
	 load_from_mem_offset = 2'b10;
	 
	 @(posedge sysclk) #1;
	 load_from_mem_offset = 2'b11;
	 ld_busy <= @(posedge sysclk) 0;
	 load_from_mem_req <= @(posedge sysclk) 0;
	 #500;

	 $display("Main cache line 0 is now:");
	 $display("0: main_cache=%h tag=%h valid=%b dedsec=%h",
		  CC.main_cache[0], CC.main_cache_tag[0], 
		  CC.main_cache_valid[0], CC.main_cache_dedsec[0]);
	 
	 $display("Victim - oldest = 2'b%b", CC.oldest_victim_line);
	 
	 $display("0: victim_cache=%h tag=%h, valid=%b, dedsec=%h",
		  CC.victim_cache[0], CC.victim_cache_tag[0], 
		  CC.victim_cache_valid[0], CC.victim_cache_dedsec[0]);
	 
	 $display("1: victim_cache=%h tag=%h, valid=%b, dedsec=%h",
		  CC.victim_cache[1], CC.victim_cache_tag[1], 
		  CC.victim_cache_valid[1], CC.victim_cache_dedsec[1]);
	 
	 $display("2: victim_cache=%h tag=%h, valid=%b, dedsec=%h",
		  CC.victim_cache[2], CC.victim_cache_tag[2], 
		  CC.victim_cache_valid[2], CC.victim_cache_dedsec[2]);
	 
	 $display("3: victim_cache=%h tag=%h, valid=%b, dedsec=%h",
		  CC.victim_cache[3], CC.victim_cache_tag[3], 
		  CC.victim_cache_valid[3], CC.victim_cache_dedsec[3]);
	 #200;
	 //$stop;	 
	 $finish;
      end // initial begin

endmodule // top
