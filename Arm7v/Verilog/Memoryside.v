// Verilog source file for the MemoryASM
// Written by Chris Fester 3-28-00
// This represents the "memory controller" side of the Memory Interface.  It runs
// with the assumption that it is being connected to PC100 SDRAM.  Please see
// documentation in regards to other assumptions made about the SDRAM.

`define NUM_MEM_STATE_BITS 5
`define BEHAVIORAL 1

// state defines
`define MEM_IDLE_STATE		5'h00

`define ST_RAS_STATE		5'h01
`define ST_NOP_DELAY_STATE1	5'h02
`define ST_NOP_DELAY_STATE2 5'h03
`define ST_CAS_STATE		5'h04
`define ST_NOP_DELAY_STATE3	5'h05
`define ST_WRITE_DATA_STATE	5'h06
`define ST_PRECHARGE_STATE	5'h07
`define ST_NOP_DELAY_STATE4 5'h08

`define LD_RAS_STATE		5'h10
`define LD_NOP_DELAY_STATE1	5'h11
`define LD_NOP_DELAY_STATE2	5'h12
`define LD_CAS_STATE		5'h13
`define LD_NOP_DELAY_STATE3	5'h14
`define LD_NOP_DELAY_STATE4 5'h15
`define LD_DATA_STATE1		5'h16
`define LD_DATA_STATE2		5'h17
`define LD_DATA_STATE3		5'h18
`define LD_DATA_STATE4		5'h19
`define LD_PRECHARGE_STATE	5'h1a

module memory_coupler (A, mem_A, mem_D, mem_nRAS, mem_nCAS, mem_nRW, mem_SEQ, mem_nCS, 
		       mem_MCLK, mem_BYTE, st_busy, ld_busy, 
		       write_buffer_is_byte, write_buffer_D, write_buffer_A, 
		       Store_Trigger, Load_Trigger, 
		       load_from_mem_req, load_from_mem_data, load_from_mem_offset, clk, reset);

   // Address used for loads
   input [31:0] A;
   
   // Triggers for the state machine to start
   input 	Store_Trigger, Load_Trigger;

   // Bus buffers from cache module
   input [31:0] write_buffer_D, write_buffer_A;

   // byte flag
   input 	write_buffer_is_byte;

   // Standard self-explanatory signals
   input 	clk, reset;

   // SDRAM control signals
   output 	mem_nRAS, mem_nCAS, mem_nRW, mem_SEQ, mem_nCS, mem_MCLK, mem_BYTE; 

   // SDRAM busses
   output [31:0] mem_A;
   inout [31:0]  mem_D;

   // busy signals
   output 	 st_busy, ld_busy;

   // cache load signals
   output 	 load_from_mem_req;
   output [31:0] load_from_mem_data;
   output [1:0]  load_from_mem_offset;

   wire [31:0] 	 A;
   wire 	 Store_Trigger, Load_Trigger;
   wire [31:0] 	 write_buffer_D, write_buffer_A;
   wire 	 write_buffer_is_byte;
   wire 	 clk, reset;

   reg 		 mem_nRAS, mem_nCAS, mem_nRW, mem_SEQ, mem_nCS, mem_BYTE;
   wire 	 mem_MCLK;
   reg [31:0] 	 mem_A;
   wire [31:0] 	 mem_D;
   reg 		 st_busy, ld_busy;
   reg 		 load_from_mem_req;
   reg [31:0] 	 load_from_mem_data;
   reg [1:0] 	 load_from_mem_offset;
   
   
   // internal signals
   reg [`NUM_MEM_STATE_BITS -1:0] state;
   reg [31:0] 			  mem_Dout;
   

   assign mem_MCLK = clk;
   assign mem_D = mem_Dout;

   always @(posedge clk or posedge reset)
      begin
	 if (reset == 1'b1)
	    state = `MEM_IDLE_STATE;
	 else
	    begin
	       `ifdef BEHAVIORAL
		  #1;
	       `endif
		  case (state)
		    `MEM_IDLE_STATE : begin
		       mem_Dout <= @(posedge clk) 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
		       mem_nRAS <= @(posedge clk) 1'b1;
		       mem_nCAS <= @(posedge clk) 1'b1;
		       mem_nRW <= @(posedge clk) 1'b0;
		       mem_SEQ <= @(posedge clk) 1'b0;
		       mem_nCS <= @(posedge clk) 1'b1;
		       st_busy <= @(posedge clk) 1'b0;
		       ld_busy <= @(posedge clk) 1'b0;
		       mem_BYTE <= @(posedge clk) 1'b0;
		       #1;
		       if (Store_Trigger == 1'b1)
			  begin
			     st_busy <= @(posedge clk) 1'b1;
			     mem_A <= @(posedge clk) write_buffer_A;
			     enter_new_mem_state(`ST_RAS_STATE);
			  end
		       else if (Load_Trigger == 1'b1)
			  begin
			     ld_busy <= @(posedge clk) 1'b1;
			     mem_A <= @(posedge clk) A;
			     enter_new_mem_state(`LD_RAS_STATE);
			  end	
		    end
		    // *** Begin store portion ************************ 8 states.
		    `ST_RAS_STATE : begin
		       mem_nRAS <= @(posedge clk) 1'b0;
		       mem_BYTE <= @(posedge clk) write_buffer_is_byte;
		       mem_Dout <= @(posedge clk) write_buffer_D;
		       mem_nRW <= @(posedge clk) 1'b1;
		       mem_nCS <= @(posedge clk) 1'b0;
		       enter_new_mem_state(`ST_NOP_DELAY_STATE1);
		    end
		    `ST_NOP_DELAY_STATE1 : begin
		       mem_nCS <= @(posedge clk) 1'b1;
		       enter_new_mem_state(`ST_NOP_DELAY_STATE2);	
		    end
		    `ST_NOP_DELAY_STATE2 : begin
		       mem_nRAS <= @(posedge clk) 1'b1;
		       enter_new_mem_state(`ST_CAS_STATE);
		    end
		    `ST_CAS_STATE : begin
		       mem_nCAS <= @(posedge clk) 1'b0;
		       mem_nCS <= @(posedge clk) 1'b0;
		       enter_new_mem_state(`ST_NOP_DELAY_STATE3);
		    end
		    `ST_NOP_DELAY_STATE3 : begin
		       mem_nCS <= @(posedge clk) 1'b1;
		       enter_new_mem_state(`ST_WRITE_DATA_STATE);
		    end
		    `ST_WRITE_DATA_STATE : begin
		       mem_Dout <= @(posedge clk) 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
		       enter_new_mem_state(`ST_PRECHARGE_STATE);
		    end
		    `ST_PRECHARGE_STATE : begin
		       // empty state
		       enter_new_mem_state(`ST_NOP_DELAY_STATE4);
		    end
		    `ST_NOP_DELAY_STATE4 : begin
		       // empty state
		       enter_new_mem_state(`MEM_IDLE_STATE);
		    end
		    // *** Begin load portion ***************************** 11 states.
		    `LD_RAS_STATE : begin
		       mem_nRAS <= @(posedge clk) 1'b0;
		       mem_nCS <= @(posedge clk) 1'b0;
		       enter_new_mem_state(`LD_NOP_DELAY_STATE1);	
		    end
		    `LD_NOP_DELAY_STATE1 : begin
		       mem_nCS <= @(posedge clk) 1'b1;
		       enter_new_mem_state(`LD_NOP_DELAY_STATE2);
		    end
		    `LD_NOP_DELAY_STATE2 : begin
		       mem_nRAS <= @(posedge clk) 1'b1;
		       enter_new_mem_state(`LD_CAS_STATE);
		    end
		    `LD_CAS_STATE : begin
		       mem_nCAS <= @(posedge clk) 1'b0;
		       mem_nCS <= @(posedge clk) 1'b0;
		       enter_new_mem_state(`LD_NOP_DELAY_STATE3);
		    end
		    `LD_NOP_DELAY_STATE3 : begin
		       mem_nCS <= @(posedge clk) 1'b1;
		       enter_new_mem_state(`LD_NOP_DELAY_STATE4);
		    end
		    `LD_NOP_DELAY_STATE4 : begin
		       enter_new_mem_state(`LD_DATA_STATE1);
		    end
		    `LD_DATA_STATE1 : begin
		       load_cache_line(0, mem_D);
		       enter_new_mem_state(`LD_DATA_STATE2);
		    end
		    `LD_DATA_STATE2 : begin
		       load_cache_line(1, mem_D);
		       enter_new_mem_state(`LD_DATA_STATE3);
		    end
		    `LD_DATA_STATE3 : begin
		       load_cache_line(2, mem_D);
		       enter_new_mem_state(`LD_DATA_STATE4);
		    end
		    `LD_DATA_STATE4 : begin
		       load_cache_line(3, mem_D);
		       enter_new_mem_state(`LD_PRECHARGE_STATE);
		    end
		    `LD_PRECHARGE_STATE : begin
		       load_from_mem_req <= @(posedge clk) 1'b0;
		       enter_new_mem_state(`MEM_IDLE_STATE);
		    end
		    default : begin
		       enter_new_mem_state(`MEM_IDLE_STATE);
		    end
		  endcase
	    end
      end

   // task for memory_coupler to enter a new state
   task enter_new_mem_state;
      input [`NUM_MEM_STATE_BITS-1:0] this_state;
      begin
	 state <= @(posedge clk) this_state;
      end
   endtask

   // task for memory_coupler to load a cache line
   task load_cache_line;
      input [1:0] offset;
      input [31:0] data_to_move;
      begin
	 #2;
	 load_from_mem_req <= @(posedge clk) 1'b1;
	 load_from_mem_offset <= @(posedge clk) offset;
	 @(negedge clk); // put here to guarantee that the data will be
     // avaliable before the next _positive_ clock edge.
	 load_from_mem_data <= @(posedge clk) data_to_move;
      end
   endtask

endmodule
