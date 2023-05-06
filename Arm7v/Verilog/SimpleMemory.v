// SDRAM model (simple) source file
// written by Chris Fester 4-2-00

`timescale 1ns/100ps

// define a 32K size memory address bit range
// `define MEM_WORDS 8192
// `define MEM_ADDR_BITS 13
 `define MEM_ADDR_BITS 17

module SDRAM_model_simple(Addr, Data, nRAS, nCAS, nWE, SEQ, nCS, MCLK, BYTE);
   input [31:0]	Addr;
   inout [31:0] Data;
   input MCLK, SEQ, nRAS, nCAS, BYTE, nWE, nCS;

   wire [31:0] 	Addr, Data;
   wire MCLK, SEQ, nRAS, nCAS, BYTE, nWE, nCS;

   reg [31:0] Dataout;
//   reg [31:0] mem_array [`MEM_ADDR_BITS-1:0];
//   reg [31:0] mem_array[0:8192];
   reg [31:0] mem_array[0:65536];

   assign Data = Dataout;

   // since the ARM uses a nRW signal, and SDRAM uses a nWE signal, 
   // we have to do some inversion here...
   // wire nWE;
   // assign nWE = ~nRW;

   reg [31:0] AddrBuf;
   reg [31:0] WriteBuf;

   always @(posedge MCLK)
   begin
      if ((nRAS == 1'b0) && (nWE == 1'b0)) // we have a memory write
      begin
         `ifdef DEBUG
             $display("Memory store beginning...");
         `endif
         Dataout = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
         @(posedge MCLK) #1;// nop delay 1
         @(posedge MCLK) #1;// nop delay 2
         @(posedge MCLK) #1;// cas state
         if (nCAS != 1'b0)
            $display("ERROR: nCAS not dropped!");
         // we'll latch in the data and address here...
         AddrBuf = Addr;
         WriteBuf = Data;
         @(posedge MCLK) #1;// nop delay 3  
         @(posedge MCLK) #1;// write data state
         // now we'll actually put the data into the array.  
         if (BYTE == 1'b0)
         begin 
            mem_array[{AddrBuf[`MEM_ADDR_BITS -1:2],2'b00}] = WriteBuf;
         end
         else
         begin
            case(AddrBuf[1:0])
               2'b00 : begin
                  mem_array[{AddrBuf[`MEM_ADDR_BITS -1:2],2'b00}] = 
                     (mem_array[{AddrBuf[`MEM_ADDR_BITS -1:2],2'b00}] & 
                      32'hFFFFFF00) | {24'h000000, WriteBuf[7:0]};
               end
               2'b01 : begin
                  mem_array[{AddrBuf[`MEM_ADDR_BITS -1:2],2'b00}] = 
                     (mem_array[{AddrBuf[`MEM_ADDR_BITS -1:2],2'b00}] & 
                      32'hFFFF00FF) | {16'h0000, WriteBuf[15:8], 8'h00};
               end
               2'b10 : begin
                  mem_array[{AddrBuf[`MEM_ADDR_BITS -1:2],2'b00}] = 
                     (mem_array[{AddrBuf[`MEM_ADDR_BITS -1:2],2'b00}] & 
                      32'hFF00FFFF) | {8'h00, WriteBuf[23:16], 16'h0000};
               end
               2'b11 : begin
                  mem_array[{AddrBuf[`MEM_ADDR_BITS -1:2],2'b00}] = 
                     (mem_array[{AddrBuf[`MEM_ADDR_BITS -1:2],2'b00}] & 
                      32'h00FFFFFF) | {WriteBuf[31:24], 24'h000000};
               end
            endcase
         end 
         @(posedge MCLK) #1;// precharge
         @(posedge MCLK) #1;// nop delay 4
      end
      else if ((nRAS == 1'b0) && (nWE == 1'b1)) // we have a memory read
      begin
         `ifdef DEBUG
             $display("Memory read beginning...");
         `endif
//         @(posedge MCLK) #1;// nop delay 1
         @(posedge MCLK) #1;// nop delay 2
         @(posedge MCLK) #1;// cas state
         if (nCAS != 1'b0)
            $display("ERROR: nCAS not dropped!");
         // we'll latch in the address here...
         AddrBuf = Addr;
//         @(posedge MCLK) #1;// nop delay 3  
         @(posedge MCLK) #1;// data state 1
         Dataout = mem_array[{AddrBuf[`MEM_ADDR_BITS -1:4],4'b0000}];
         @(posedge MCLK) #1;// data state 2
         Dataout = mem_array[{AddrBuf[`MEM_ADDR_BITS -1:4],4'b0100}];
         @(posedge MCLK) #1;// data state 3
         Dataout = mem_array[{AddrBuf[`MEM_ADDR_BITS -1:4],4'b1000}];
         @(posedge MCLK) #1;// data state 4
         Dataout = mem_array[{AddrBuf[`MEM_ADDR_BITS -1:4],4'b1100}];
         @(posedge MCLK) #1;// precharge 
      end
   end
      
endmodule

