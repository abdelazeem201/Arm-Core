`timescale 1ns/10ps
/*****************************************************************************
$RCSfile: regfile.v,v $
$Revision: 1.3 $
$Author: kohlere $
$Date: 2000/03/30 01:10:49 $
$State: Exp $
$Source: /home/lefurgy/tmp/ISC-repository/isc/hardware/ARM10/behavioral/pipelined/fpga2/regfile.v,v $

Description: Register File, 31, 32-bit registers (ff's).  Would like
		to use SRAM, but we still don't have the damn memory
		generators.

*****************************************************************************/

module regfile (nGCLK, nWAIT,
		  nRESET, index_a, index_b, write_a, write_b, wena_a,
		  wena_b, w_addr_a, w_addr_b, port_a, port_b, pc_if);

/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/
input 	[31:0]	write_a;		//Data on Write Port A
input	[31:0]	write_b;		//Data on Write Port B
input	[31:0]	pc_if;			//PC Value
input	[4:0]	index_a;		//Read Index A
input	[4:0]	index_b;		//Read Index B
input	[4:0]	w_addr_a;		//Write Index A
input	[4:0]	w_addr_b;		//Write Index B
input		nGCLK;			//Clock
input		nRESET;			//Reset Signal
input		nWAIT;			//Clock Enable
input		wena_a;			//Write Enable A
input		wena_b;			//Write Enable B

output	[31:0]	port_a;			//Read Port A
output	[31:0]	port_b;			//Read Port B	

/*------------------------------------------------------------------------
        Signal Declarations
------------------------------------------------------------------------*/
reg     [31:0]  r0, r1, r2, r3,         //Declare 31, 32-bit registers
                r4, r5, r6, r7,
                r8, r9, r10, r11,
                r12, r13, r14,
                r16, r17, r18, r19,
                r20, r21, r22, r23,
                r24, r25, r26, r27,
                r28, r29, r30;

reg	[31:0]	port_a, port_b;

//Create the two Read Port Muxes
always @(index_a or index_b or r0 or r1 or r2 or r3
                or r4 or r5 or r6 or r7 or r8 or r9
                or r10 or r11 or r12 or r13 or r14
                or r16 or r17 or r18 or r19 or pc_if
                or r20 or r21 or r22 or r23 or r24
                or r25 or r26 or r27 or r28 or r29
                or r30)
    begin
        case (index_a) //synopsys parallel_case
            5'h00:  port_a = r0;  
            5'h01:  port_a = r1;  
            5'h02:  port_a = r2;  
            5'h03:  port_a = r3;  
            5'h04:  port_a = r4;  
            5'h05:  port_a = r5; 
            5'h06:  port_a = r6; 
            5'h07:  port_a = r7; 
            5'h08:  port_a = r8; 
            5'h09:  port_a = r9; 
            5'h0A:  port_a = r10;
            5'h0B:  port_a = r11;
            5'h0C:  port_a = r12;
            5'h0D:  port_a = r13;
            5'h0E:  port_a = r14;
            5'h0F:  port_a = pc_if;
            5'h10:  port_a = r16;
            5'h11:  port_a = r17;
            5'h12:  port_a = r18;
            5'h13:  port_a = r19;   
            5'h14:  port_a = r20; 
            5'h15:  port_a = r21;
            5'h16:  port_a = r22;
            5'h17:  port_a = r23;
            5'h18:  port_a = r24;
            5'h19:  port_a = r25;
            5'h1A:  port_a = r26;
            5'h1B:  port_a = r27;
  	    5'h1C:  port_a = r28;
            5'h1D:  port_a = r29;
            5'h1E:  port_a = r30;
            default: port_a = r0;
    endcase

        case (index_b) //synopsys parallel_case
            5'h00:  port_b = r0;  
            5'h01:  port_b = r1;  
            5'h02:  port_b = r2;  
            5'h03:  port_b = r3; 
            5'h04:  port_b = r4; 
            5'h05:  port_b = r5; 
            5'h06:  port_b = r6; 
            5'h07:  port_b = r7; 
            5'h08:  port_b = r8; 
            5'h09:  port_b = r9; 
            5'h0A:  port_b = r10;
            5'h0B:  port_b = r11;
            5'h0C:  port_b = r12;
            5'h0D:  port_b = r13;
            5'h0E:  port_b = r14;
            5'h0F:  port_b = pc_if;
            5'h10:  port_b = r16;
            5'h11:  port_b = r17;   
            5'h12:  port_b = r18; 
            5'h13:  port_b = r19;
            5'h14:  port_b = r20;
            5'h15:  port_b = r21;
            5'h16:  port_b = r22;
            5'h17:  port_b = r23;
            5'h18:  port_b = r24;
            5'h19:  port_b = r25;
            5'h1A:  port_b = r26;
            5'h1B:  port_b = r27;
            5'h1C:  port_b = r28;
            5'h1D:  port_b = r29;
            5'h1E:  port_b = r30;
            default: port_b = r0;
        endcase
    end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r0 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h00) & (wena_a))
          r0 <= #1 write_a;
        else if ((w_addr_b == 5'h00) & (wena_b))
          r0 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET" 
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r1 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h01) & (wena_a))
          r1 <= #1 write_a;
        else if ((w_addr_b == 5'h01) & (wena_b))
          r1 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r2 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h02) & (wena_a))
          r2 <= #1 write_a;
        else if ((w_addr_b == 5'h02) & (wena_b))
          r2 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r3 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h03) & (wena_a))
          r3 <= #1 write_a;
        else if ((w_addr_b == 5'h03) & (wena_b))
          r3 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r4 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h04) & (wena_a))
          r4 <= #1 write_a;
        else if ((w_addr_b == 5'h04) & (wena_b))
          r4 <= #1 write_b;
      end
end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r5 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h05) & (wena_a))
          r5 <= #1 write_a;
        else if ((w_addr_b == 5'h05) & (wena_b))
          r5 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r6 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h06) & (wena_a))
          r6 <= #1 write_a;
        else if ((w_addr_b == 5'h06) & (wena_b))
          r6 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r7 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h07) & (wena_a))
          r7 <= #1 write_a;
        else if ((w_addr_b == 5'h07) & (wena_b))
          r7 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r8 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h08) & (wena_a))
          r8 <= #1 write_a;
        else if ((w_addr_b == 5'h08) & (wena_b))
          r8 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r9 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h09) & (wena_a))
          r9 <= #1 write_a;
        else if ((w_addr_b == 5'h09) & (wena_b))
          r9 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r10 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h0A) & (wena_a))
          r10 <= #1 write_a;
        else if ((w_addr_b == 5'h0A) & (wena_b))
          r10 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r11 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h0B) & (wena_a))
          r11 <= #1 write_a;
        else if ((w_addr_b == 5'h0B) & (wena_b))
          r11 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r12 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h0C) & (wena_a))
          r12 <= #1 write_a;
        else if ((w_addr_b == 5'h0C) & (wena_b))
          r12 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r13 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h0D) & (wena_a))
          r13 <= #1 write_a;
        else if ((w_addr_b == 5'h0D) & (wena_b))
          r13 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r14 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h0E) & (wena_a))
          r14 <= #1 write_a;
        else if ((w_addr_b == 5'h0E) & (wena_b))
          r14 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r16 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h10) & (wena_a))
          r16 <= #1 write_a;
        else if ((w_addr_b == 5'h10) & (wena_b))
          r16 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r17 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h11) & (wena_a))
          r17 <= #1 write_a;
        else if ((w_addr_b == 5'h11) & (wena_b))
          r17 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r18 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h12) & (wena_a))
          r18 <= #1 write_a;
        else if ((w_addr_b == 5'h12) & (wena_b))
          r18 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r19 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h13) & (wena_a))
          r19 <= #1 write_a;
        else if ((w_addr_b == 5'h13) & (wena_b))
          r19 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r20 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h14) & (wena_a))
          r20 <= #1 write_a;
        else if ((w_addr_b == 5'h14) & (wena_b))
          r20 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r21 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h15) & (wena_a))
          r21 <= #1 write_a;
        else if ((w_addr_b == 5'h15) & (wena_b))
          r21 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r22 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h16) & (wena_a))
          r22 <= #1 write_a;
        else if ((w_addr_b == 5'h16) & (wena_b))
          r22 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r23 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h17) & (wena_a))
          r23 <= #1 write_a;
        else if ((w_addr_b == 5'h17) & (wena_b))
          r23 <= #1 write_b;
      end
end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r24 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h18) & (wena_a))
          r24 <= #1 write_a;
        else if ((w_addr_b == 5'h18) & (wena_b))
          r24 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r25 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h19) & (wena_a))
          r25 <= #1 write_a;
        else if ((w_addr_b == 5'h19) & (wena_b))
          r25 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r26 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h1A) & (wena_a))
          r26 <= #1 write_a;
        else if ((w_addr_b == 5'h1A) & (wena_b))
          r26 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r27 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h1B) & (wena_a))
          r27 <= #1 write_a;
        else if ((w_addr_b == 5'h1B) & (wena_b))
          r27 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r28 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h1C) & (wena_a))
          r28 <= #1 write_a;
        else if ((w_addr_b == 5'h1C) & (wena_b))
          r28 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r29 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h1D) & (wena_a))
          r29 <= #1 write_a;
        else if ((w_addr_b == 5'h1D) & (wena_b))
          r29 <= #1 write_b;
      end
  end

//synopsys async_set_reset "nRESET"
always @(posedge nGCLK or negedge nRESET)
  begin
    if (~nRESET)
      r30 <= #1 32'h0;
    else if (nWAIT)
      begin
        if ((w_addr_a == 5'h1E) & (wena_a))
          r30 <= #1 write_a;
        else if ((w_addr_b == 5'h1E) & (wena_b))
          r30 <= #1 write_b;
      end
  end

endmodule


