`timescale 1ns/10ps
/*****************************************************************************
$RCSfile: mult.v,v $
$Revision: 1.4 $
$Author: kohlere $       
$Date: 2000/04/10 00:26:33 $
$State: Exp $


Description:  This is the multiplication unit.  It is capable of performing
		32*32=32, 32*32=64, Signed and Unsigned, and accumulate.
		This performs a multicycle multiply (32x8).  The result
		is passed through the alu in the EX stage to add the current
		value to the running increment of the multiply.  
                
*****************************************************************************/
module mult (enable, op1, op2, a, l, u, nGCLK, reset, acc_op1, acc_op2,
		sum, hold_next, nWAIT);

/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/
input  [63:0]	sum;			//Sum of Last Multiply
input  [31:0] 	op1;			//Operand 1
input  [31:0] 	op2;			//Operand 2
input		enable;			//Inst is a Multiply
input		a;			//Accumulate Control Bit
input		l;			//Long Control Bit
input		u;			//Unsigned Control Bit
input		reset;			//Reset Signal
input     	nGCLK;			//Clock Signal
input		nWAIT;			//Clock Enable

output [63:0]	acc_op1;		//Accumulate Op1
output [63:0]	acc_op2;		//Accumulate Op2
output		hold_next;		//Need Next Cycle/Continue Mult.

/*------------------------------------------------------------------------
        Variable Declarations
------------------------------------------------------------------------*/

reg	[63:0]	res_n_1;		//Result of Previous Cycle
reg	[63:0]	acc;			//Multiplexed Acc Value
reg	[63:0]	acc_op1;		//Accumulate Op1
reg	[63:0]	acc_op2;		//Accumulate Op2
reg	[31:0] 	mult_op1;		//Mult Op1
reg	[31:0] 	mult_op2;		//Mult Op2
reg	[2:0]	next_count;		//Next State Logic
reg	[2:0]	total_delay;		//Value to Compare Delay Counter
reg	[2:0]	count;			//Current Cycle #
reg		no_load_ops;		//Load Operands (active low)

wire	[63:0]	res_op1;                //Input #1 to Adder
wire	[63:0]	res_op2;                //Input #2 to Adder
wire	[32:0]	mult_op2_ext;		//Mult Op2 Extended
wire	[31:0]	acc_low;		//Low Order Acc Value
wire	[31:0]	acc_high;		//High Order Acc Value
wire    [9:0]   op1_byte;               //Muxed Op1 Byte
wire	[2:0]	inc_count;		//Count + 1
wire	[1:0]   byte_slice;             //Which Byte are we Operating On
wire            op1_byte_1;             //Op1_byte[-1]
wire            top_byte;               //Single Cycle Mult
wire		last_cycle;		//This is final Mult Cycle
wire		byte_1_or;		//OR of op1[31:24]
wire		byte_2_or;		//OR of op1[23:16]
wire		byte_3_or;		//OR of op1[15:8]
wire            byte_1_and;		//AND of op1[31:24]
wire            byte_2_and;		//AND of op1[23:16]
wire            byte_3_and;		//AND of op1[15:8]
wire		hold_next;		//Need Next Cycle/Cont Mult
wire		first;			//Output for first_cycle

/*------------------------------------------------------------------------
        Basic Assignments
------------------------------------------------------------------------*/

//Set the Accumulate Operands
assign acc_low = op2;
assign acc_high = op1;

//Or/And the top 24 Bits of Operand 1
//The and signals can not go high if the
//operation is an Unsigned Long Multiply
assign byte_1_or 	= (| mult_op1[31:24]);
assign byte_2_or	= (| mult_op1[23:16]);
assign byte_3_or	= (| mult_op1[15:8]);
assign byte_1_and	= (& mult_op1[31:24]) & !(!u & l);
assign byte_2_and	= (& mult_op1[23:16]) & !(!u & l);
assign byte_3_and	= (& mult_op1[15:8]) & !(!u & l);

//Check for the first cycle of the multiply
assign #1 first = (count == 3'h0);

//Set a Signal which indicates that the ex enable should be disabled
//The signal goes high when all operands are loaded and remains high
//until the final cycle.
assign #1 hold_next = (count < total_delay) &&
		   !((count == 3'h0) && a) && (enable) & ~reset;

//Extend the Byte sent to the multiplier to 9-bits for the
//purposes of Signed/Unsigned multiplication
assign mult_op2_ext = !(!u & l) ? {mult_op2[31],mult_op2} 
				: {1'b0,mult_op2};

//Decode the last Cycle
assign #1 last_cycle = (count == total_delay);
	
//Increment the Count Value
assign inc_count = count + 1;

//Determine which Byte is being multiplied so the results can
//be shifted appropriately in the multiply grid.
assign byte_slice = count[1:0];

/*------------------------------------------------------------------------
        Component Instantions
------------------------------------------------------------------------*/

// instantiate multacc
multacc xmultacc1 (.op1(mult_op2_ext), .op2(op1_byte),
		.op2_1(op1_byte_1), .acc(acc), .acc_op1(res_op1),
		.byte_slice(byte_slice), .acc_op2(res_op2),
		.msb(top_byte));

/*------------------------------------------------------------------------
        Sequential Blocks
------------------------------------------------------------------------*/
//Latch the Result of Previous Cycle
//synopsys async_set_reset "reset"
//synopsys sync_set_reset "reset"
always @(posedge nGCLK)
  begin
    if (reset)
      res_n_1 <= 64'h0000000000000000;
    else if (nWAIT)
      begin
        if (enable)
          res_n_1 <= sum;
      end
  end

//Set up the mult_op1 operand
//Because no_load_ops changes on rising edge
//and count on falling edge, no glitches in 
//latch enable.

wire nLoadOps = ~(~no_load_ops && (count == 3'h0));
always @(nGCLK or op1 or nLoadOps or mult_op1)
  begin
    if (nGCLK)
      begin
        if (~nLoadOps)
	  mult_op1 <= op1;
	else
	  mult_op1 <= mult_op1;
      end
  end

//Set up the mult_op2 operand
always @(op2 or nLoadOps or mult_op2 or nGCLK)
  begin
    if (nGCLK)
      begin
        if (~nLoadOps)
          mult_op2 <= op2;
        else
          mult_op2 <= mult_op2;
      end
  end

//Create the past delay reg
//synopsys sync_set_reset "reset"
always @(posedge nGCLK)
  begin
    if (reset)
      count <= 3'h0;
    else if (nWAIT)
      count <= next_count;
  end

//Give the first half cycle to load Mult Op1/Op2
//synopsys async_set_reset "reset"
reg load_reset;
wire nThisReset;
assign nThisReset = ~reset & no_load_ops;
always @(posedge nGCLK or negedge nThisReset)
  begin
    if (~nThisReset)
      load_reset <= 1'b1;
    else if (nWAIT)
      begin
        if (enable)
          load_reset <= reset;
        else
          load_reset <= 1'b0;
      end
  end
wire nThatReset;
assign nThatReset = ~load_reset;
always @(negedge nGCLK or negedge nThatReset)
  begin
    if (~nThatReset)
      no_load_ops <= 1'b0;
    else
      begin
        if (enable & (count == 3'h0) & (total_delay != 3'h0))
          no_load_ops <= 1'b1;
        else if (enable & (count == total_delay))
          no_load_ops <= 1'b0;
      end
  end

/*------------------------------------------------------------------------
	Combinational Always Blocks        
------------------------------------------------------------------------*/
//Next State Logic for Delay FSM
always @(inc_count or enable or total_delay or count)
    begin
	if (enable && (count < total_delay))
	    next_count = inc_count;
	else
	    next_count = 3'h0;
    end

//Value to Load the Delay Count with on start of Multiply Cycles
//Some of the Cases overlap, but this is ok because the overlap
//corresponds to cases that are impossible (i.e. or = 0, and = 1)
always @(byte_1_or or byte_2_or or byte_3_or or 
	 byte_1_and or byte_2_and or byte_3_and or a)
    begin
	casex ({byte_1_or,byte_1_and,
		    byte_2_or,byte_2_and,
		    byte_3_or,byte_3_and,a}) //synopsys full_case parallel_case
            //Op1[31:16] = all0/all1, no acc
//            7'b0?0?0?0,
//            7'b?1?1?10: total_delay <= 3'h0;
	
            //Op1[31:8] = all0/all1, acc
            //Op1[31:16] = all0/all1, no acc
	    7'b0?0?0?1,
	    7'b?1?1?11,
	    7'b0?0?1?0,
            7'b?1?1?00: total_delay <= 3'h1;

            //Op1[31:16] = all0/all1, acc
            //Op1[31:24] = all0/all1, no acc
            7'b0?0?1?1,
            7'b?1?1?01,
	    7'b0?1???0,
            7'b?1?0??0: total_delay <= 3'h2;

            //Op1[31:24] = all0/all1, acc
            // no acc
	    7'b0?1???1,
	    7'b?1?0??1,
	    7'b10????0: total_delay <= 3'h3;

            // acc
	    7'b10????1: total_delay <= 3'h4;

	    default: total_delay <= 3'h0;
	endcase
    end

reg [9:0] next_op1_byte;
always @(count or mult_op1)
    begin
	case (count[1:0]) //synopsys full_case parallel_case
//	    2'b00: next_op1_byte = mult_op1[9:0];
	    2'b01: next_op1_byte = mult_op1[17:8];
	    2'b10: next_op1_byte = mult_op1[25:16];
	    2'b11: next_op1_byte = {2'h0,mult_op1[31:24]};
	    default: next_op1_byte = mult_op1[9:0];
	endcase
    end

reg next_op1_byte_1;
always @(count or mult_op1)
    begin
	case (count[1:0]) //synopsys full_case parallel_case
//            2'b00: next_op1_byte_1 = 1'b0;
            2'b01: next_op1_byte_1 = mult_op1[7];
            2'b10: next_op1_byte_1 = mult_op1[15];
            2'b11: next_op1_byte_1 = mult_op1[23];
            default: next_op1_byte_1 = 1'b0;
        endcase
    end

assign op1_byte = next_op1_byte;
assign op1_byte_1 = next_op1_byte_1;

//Mux the acc value to enter into the multiplier.
//This can be 0 (first cycle) or the previous result
//of the multiply (intermediate cycles) or the acc
//value from the instruction (last mac cycle).

always @(acc_low or acc_high or count or res_n_1 
		or last_cycle or a or l)
    begin
	if (count == 3'h0) 	//First Cycle
	    acc <= 64'h0000000000000000;
	else if (last_cycle & a)
	  begin
	    if (l)
	      acc <= {acc_high,acc_low};
	    else
	      acc <= {32'h00000000,acc_low};
	  end
	else
	    acc <= res_n_1;
    end

//Mux the Two Mult results to the Adder.  If an Accumulate
//is necessary, then on the final cycle, bypass the mult unit
//and send res_n_1 + acc

always @(last_cycle or a or res_n_1 or res_op1)
    begin
	if (last_cycle & a)
	    acc_op1 <= res_n_1;
	else
	    acc_op1 <= res_op1;
    end

always @(last_cycle or a or acc or res_op2)
    begin
	if (last_cycle & a)
	    acc_op2 <= acc;
	else
	    acc_op2 <= res_op2;
    end

//Set up the top_byte signal.  This signals that the MSB of
//Op1 is being sent and that its necessary to use an extra 
//Partial Product to correct in these cases:
//1) Unsigned Multiply 
//2) Early Exit from Multiplication

assign top_byte = (!u & (byte_slice == 2'h3)) |
		  ((!byte_1_or | byte_1_and) & (byte_slice == 2'h2)) | 
		  ((!(byte_1_or | byte_2_or) | (byte_1_and & byte_2_and)) & (byte_slice == 2'h1)) |
		  ((!(byte_1_or | byte_2_or | byte_3_or) | (byte_1_and & byte_2_and & byte_3_and)) & (byte_slice == 2'h0));

endmodule
