// SDRAM model with AVL implementation source file. 
// written by Chris Fester 4-5-00

`timescale 1ns/100ps 

module SDRAM_model_AVL(Addr, Data, nRAS, nCAS, nWE, SEQ, nCS, MCLK, BYTE);
   input [31:0]	Addr;
   inout [31:0] Data;
   input 	MCLK, SEQ, nRAS, nCAS, BYTE, nWE, nCS;

   wire [31:0] 	Addr, Data;
   wire 	MCLK, SEQ, nRAS, nCAS, BYTE, nWE, nCS;

   reg [31:0] 	Dataout;

   assign Data = Dataout;

   reg [31:0] 	AddrBuf;
   reg [31:0] 	WriteBuf;
   reg [31:0] 	TempWriteBuf;
   reg [31:0] 	TempAddrBuf;

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
	          //Dataout = 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
	       @(posedge MCLK) #1;// nop delay 3
	       
	       @(posedge MCLK) #1;// write data state
	          // now we'll actually put the data into the array.  
	          if (BYTE == 1'b0)
		     begin
			TempAddrBuf = {AddrBuf[31:2],2'b00};
            `ifdef DEBUG 
			$display("storing 32 bits: AddrBuf %x, WriteBuf %x", 
				 TempAddrBuf, WriteBuf);
            `endif
			$load_vector(TempAddrBuf, WriteBuf, "write");
		     end
		  else
		     begin
			TempAddrBuf = {AddrBuf[31:2],2'b00}; 
			$load_vector(TempAddrBuf, TempWriteBuf, "read");
			case(AddrBuf[1:0])
			  2'b00 : begin
			     TempWriteBuf = {TempWriteBuf[31:8], 
					     WriteBuf[7:0]};
			  end
			  2'b01 : begin
			     TempWriteBuf = {TempWriteBuf[31:16], 
					     WriteBuf[15:8], 
					     TempWriteBuf[7:0]};
			  end
			  2'b10 : begin
			     TempWriteBuf = {TempWriteBuf[31:24], 
					     WriteBuf[23:16], 
					     TempWriteBuf[15:0]};
			  end
			  2'b11 : begin
			     TempWriteBuf = {WriteBuf[31:24], 
					     TempWriteBuf[23:0]};
			  end
			endcase
            `ifdef DEBUG
			$display("Storing byte at offset:%x whole word is:%x Word address is:%x",
				 AddrBuf[1:0], TempWriteBuf, TempAddrBuf);
            `endif
			$load_vector(TempAddrBuf, TempWriteBuf, "write");
		     end // else: !if(BYTE == 1'b0)
	       
	       @(posedge MCLK) #1;// precharge
	       
	       @(posedge MCLK) #1;// nop delay 4
              `ifdef DEBUG
	          $display("Memory store complete.");		
              `endif
	    end
	 else if ((nRAS == 1'b0) && (nWE == 1'b1)) // we have a memory read
	    begin
           `ifdef DEBUG
	       $display("Memory load beginning...");
           `endif
	       
	       //@(posedge MCLK) #1;// nop delay 1
	       
	       @(posedge MCLK) #1;// nop delay 2
	       
	       @(posedge MCLK) #1;// cas state
	          if (nCAS != 1'b0)
		     $display("ERROR: nCAS not dropped!");
	          // we'll latch in the address here...
	          TempAddrBuf = {Addr[31:4],4'b0000};
	       
	       //@(posedge MCLK) #1;// nop delay 3
	       
	       @(posedge MCLK) #1;// data state 1
	          $load_vector(TempAddrBuf, TempWriteBuf, "read");
	          Dataout <= @(posedge MCLK) TempWriteBuf;
              `ifdef DEBUG
	          $display("loaded word 1 - Addr: %x, DataOut: %x", TempAddrBuf, TempWriteBuf);
	          `endif

	       @(posedge MCLK) #1;// data state 2
	          TempAddrBuf = {Addr[31:4],4'b0100}; 
	          $load_vector(TempAddrBuf, TempWriteBuf, "read");
	          Dataout <= @(posedge MCLK) TempWriteBuf;
              `ifdef DEBUG
	          $display("loaded word 2 - Addr: %x, DataOut: %x", TempAddrBuf, TempWriteBuf);
              `endif
	       
	       @(posedge MCLK) #1;// data state 3
	          TempAddrBuf = {Addr[31:4],4'b1000};
	          $load_vector(TempAddrBuf, TempWriteBuf, "read");
	          Dataout <= @(posedge MCLK) TempWriteBuf;
              `ifdef DEBUG
	          $display("loaded word 3 - Addr: %x, DataOut: %x", TempAddrBuf, TempWriteBuf);
              `endif
	       
	       @(posedge MCLK) #1;// data state 4
	          TempAddrBuf = {Addr[31:4],4'b1100};
	          $load_vector(TempAddrBuf, TempWriteBuf, "read");
	          Dataout <= @(posedge MCLK) TempWriteBuf;
              `ifdef DEBUG
	          $display("loaded word 4 - Addr: %x, DataOut: %x", TempAddrBuf, TempWriteBuf);
              `endif
	       
	       @(posedge MCLK) #1;// precharge
              `ifdef DEBUG
	          $display("Memory load complete."); 
              `endif
	    end
      end
   
endmodule

