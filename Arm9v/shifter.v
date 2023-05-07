`timescale 1ns/10ps
/*****************************************************************************
$RCSfile: shifter.v,v $
$Revision: 1.1 $
$Author: kohlere $
$Date: 2000/03/24 01:52:17 $
$State: Exp $

Description: 32-bit Barrel Shifter used by ARM9

*****************************************************************************/

module shifter (op1, shift_amount, shift_type, C, result, shift_c_out);

/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/
input	[31:0]	op1;		//Operand to Shift
input 	[7:0]   shift_amount;	//Value of Shift (in bits) 	
input	[2:0]   shift_type;	//Shift Controller
input		C;		//Current C Flag
output	[31:0]	result;		//Shifter Result
output		shift_c_out;	//Carry Out of Shifter


/*	Shifter Controls
----------------------------------------------------- 
  shift_type[1:0]	2'b00: LSL (Logical Left)
		 	2'b01: LSR (Logical Right)
		   	2'b10: ASR (Arithmetic Right)
			2'b11: ROR (Rotate Right)
   shift_type[2]	1'b1:  ALU Shift Reg by Imm
			1'b0:  All Other Shifts
*/
//Detect 32-bit Shifts
wire equal_32 = (shift_amount == 8'h20);

//Detect Shifts >= 32
wire over_32 = (| shift_amount[7:5]);

//Perform the Shift Operation

reg [32:0] shift;		//{shift_c_out, result}
always @(shift_type or shift_amount or op1 or C or equal_32 or over_32)
begin
    casex ({shift_type[1:0],over_32,shift_amount[4:0]}) //synopsys full_case parallel_case
	//LSL's
	8'h00: shift = {C, op1};
	8'h01: shift = {op1, 1'h0};
	8'h02: shift = {op1[30:0], 2'h0};
	8'h03: shift = {op1[29:0], 3'h0};
	8'h04: shift = {op1[28:0], 4'h0};
	8'h05: shift = {op1[27:0], 5'h00};
	8'h06: shift = {op1[26:0], 6'h00};
	8'h07: shift = {op1[25:0], 7'h00};
	8'h08: shift = {op1[24:0], 8'h00};
	8'h09: shift = {op1[23:0], 9'h000};
	8'h0A: shift = {op1[22:0], 10'h000};
	8'h0B: shift = {op1[21:0], 11'h000};
	8'h0C: shift = {op1[20:0], 12'h000};
	8'h0D: shift = {op1[19:0], 13'h0000};
	8'h0E: shift = {op1[18:0], 14'h0000};
	8'h0F: shift = {op1[17:0], 15'h0000};
	8'h10: shift = {op1[16:0], 16'h0000};
	8'h11: shift = {op1[15:0], 17'h00000};
	8'h12: shift = {op1[14:0], 18'h00000};
	8'h13: shift = {op1[13:0], 19'h00000};
	8'h14: shift = {op1[12:0], 20'h00000};
	8'h15: shift = {op1[11:0], 21'h000000};
	8'h16: shift = {op1[10:0], 22'h000000};
	8'h17: shift = {op1[9:0], 23'h000000};
	8'h18: shift = {op1[8:0], 24'h000000};
	8'h19: shift = {op1[7:0], 25'h0000000};
	8'h1A: shift = {op1[6:0], 26'h0000000};
	8'h1B: shift = {op1[5:0], 27'h0000000};
	8'h1C: shift = {op1[4:0], 28'h0000000};
	8'h1D: shift = {op1[3:0], 29'h00000000};
	8'h1E: shift = {op1[2:0], 30'h00000000};
	8'h1F: shift = {op1[1:0], 31'h00000000};
	8'b001?????: begin
		       if (equal_32)
			 shift = {op1[0], 32'h00000000}; 
		       else
			 shift = 33'h000000000;
		     end


	//Logical Right Shifts
	8'h40: begin
		  if (shift_type[2])
		    shift = {op1[31], 32'h00000000};
		  else
		    shift = {C, op1};
		 end
	8'h41: shift = {op1[0], 1'h0, op1[31:1]};
	8'h42: shift = {op1[1], 2'h0, op1[31:2]};
        8'h43: shift = {op1[2], 3'h0, op1[31:3]};
        8'h44: shift = {op1[3], 4'h0, op1[31:4]};
        8'h45: shift = {op1[4], 5'h00, op1[31:5]};
        8'h46: shift = {op1[5], 6'h00, op1[31:6]};
        8'h47: shift = {op1[6], 7'h00, op1[31:7]};
        8'h48: shift = {op1[7], 8'h00, op1[31:8]};
        8'h49: shift = {op1[8], 9'h000, op1[31:9]};
        8'h4A: shift = {op1[9], 10'h000, op1[31:10]};
        8'h4B: shift = {op1[10], 11'h000, op1[31:11]};   
        8'h4C: shift = {op1[11], 12'h000, op1[31:12]};   
        8'h4D: shift = {op1[12], 13'h0000, op1[31:13]};  
        8'h4E: shift = {op1[13], 14'h0000, op1[31:14]};  
        8'h4F: shift = {op1[14], 15'h0000, op1[31:15]};  
        8'h50: shift = {op1[15], 16'h0000, op1[31:16]};
        8'h51: shift = {op1[16], 17'h00000, op1[31:17]};
        8'h52: shift = {op1[17], 18'h00000, op1[31:18]};
        8'h53: shift = {op1[18], 19'h00000, op1[31:19]};
        8'h54: shift = {op1[19], 20'h00000, op1[31:20]};
        8'h55: shift = {op1[20], 21'h000000, op1[31:21]};
        8'h56: shift = {op1[21], 22'h000000, op1[31:22]};
        8'h57: shift = {op1[22], 23'h000000, op1[31:23]};
        8'h58: shift = {op1[23], 24'h000000, op1[31:24]};
        8'h59: shift = {op1[24], 25'h0000000, op1[31:25]};
        8'h5A: shift = {op1[25], 26'h0000000, op1[31:26]};
        8'h5B: shift = {op1[26], 27'h0000000, op1[31:27]};
        8'h5C: shift = {op1[27], 28'h0000000, op1[31:28]};
        8'h5D: shift = {op1[28], 29'h00000000, op1[31:29]};
        8'h5E: shift = {op1[29], 30'h00000000, op1[31:30]};
        8'h5F: shift = {op1[30], 31'h00000000, op1[31]};
	8'b011?????: begin
		       if (equal_32)
			 shift = {op1[31], 32'h00000000};
		       else
			 shift = 33'h000000000;
		     end

	//Arithmetic Right Shifts
	8'h80: begin
		   if (shift_type[2])
		     shift = {op1[31], {32{op1[31]}}};
		   else
		     shift = {C, op1};
		 end
        8'h81: shift = {op1[0], {1{op1[31]}}, op1[31:1]};
        8'h82: shift = {op1[1], {2{op1[31]}}, op1[31:2]};
        8'h83: shift = {op1[2], {3{op1[31]}}, op1[31:3]};
        8'h84: shift = {op1[3], {4{op1[31]}}, op1[31:4]};
        8'h85: shift = {op1[4], {5{op1[31]}}, op1[31:5]};
        8'h86: shift = {op1[5], {6{op1[31]}}, op1[31:6]};
        8'h87: shift = {op1[6], {7{op1[31]}}, op1[31:7]};
        8'h88: shift = {op1[7], {8{op1[31]}}, op1[31:8]};
        8'h89: shift = {op1[8], {9{op1[31]}}, op1[31:9]};
        8'h8A: shift = {op1[9], {10{op1[31]}}, op1[31:10]};
        8'h8B: shift = {op1[10], {11{op1[31]}}, op1[31:11]};
        8'h8C: shift = {op1[11], {12{op1[31]}}, op1[31:12]};
        8'h8D: shift = {op1[12], {13{op1[31]}}, op1[31:13]};
        8'h8E: shift = {op1[13], {14{op1[31]}}, op1[31:14]};
        8'h8F: shift = {op1[14], {15{op1[31]}}, op1[31:15]};
        8'h90: shift = {op1[15], {16{op1[31]}}, op1[31:16]};
        8'h91: shift = {op1[16], {17{op1[31]}}, op1[31:17]};
        8'h92: shift = {op1[17], {18{op1[31]}}, op1[31:18]};
        8'h93: shift = {op1[18], {19{op1[31]}}, op1[31:19]};
        8'h94: shift = {op1[19], {20{op1[31]}}, op1[31:20]};
        8'h95: shift = {op1[20], {21{op1[31]}}, op1[31:21]};
        8'h96: shift = {op1[21], {22{op1[31]}}, op1[31:22]};
        8'h97: shift = {op1[22], {23{op1[31]}}, op1[31:23]};
        8'h98: shift = {op1[23], {24{op1[31]}}, op1[31:24]};
        8'h99: shift = {op1[24], {25{op1[31]}}, op1[31:25]};
        8'h9A: shift = {op1[25], {26{op1[31]}}, op1[31:26]};
        8'h9B: shift = {op1[26], {27{op1[31]}}, op1[31:27]};
        8'h9C: shift = {op1[27], {28{op1[31]}}, op1[31:28]};
        8'h9D: shift = {op1[28], {29{op1[31]}}, op1[31:29]};
        8'h9E: shift = {op1[29], {30{op1[31]}}, op1[31:30]};
        8'h9F: shift = {op1[30], {31{op1[31]}}, op1[31]};
	8'b101?????: shift = {{33{op1[31]}}};

	//Rotate Right Shfits
	8'b11000000: begin
		   if (shift_type[2])
		     shift = {op1[0], C, op1[31:1]}; 
		   else
		     shift = {C, op1};
		 end
	8'b11?00001: shift = {op1[0], op1[0], op1[31:1]};
        8'b11?00010: shift = {op1[1], op1[1:0], op1[31:2]};
        8'b11?00011: shift = {op1[2], op1[2:0], op1[31:3]};
        8'b11?00100: shift = {op1[3], op1[3:0], op1[31:4]};
        8'b11?00101: shift = {op1[4], op1[4:0], op1[31:5]};
        8'b11?00110: shift = {op1[5], op1[5:0], op1[31:6]};
        8'b11?00111: shift = {op1[6], op1[6:0], op1[31:7]};
        8'b11?01000: shift = {op1[7], op1[7:0], op1[31:8]};
        8'b11?01001: shift = {op1[8], op1[8:0], op1[31:9]};
        8'b11?01010: shift = {op1[9], op1[9:0], op1[31:10]};
        8'b11?01011: shift = {op1[10], op1[10:0], op1[31:11]};
        8'b11?01100: shift = {op1[11], op1[11:0], op1[31:12]};
        8'b11?01101: shift = {op1[12], op1[12:0], op1[31:13]};
        8'b11?01110: shift = {op1[13], op1[13:0], op1[31:14]};
        8'b11?01111: shift = {op1[14], op1[14:0], op1[31:15]};
        8'b11?10000: shift = {op1[15], op1[15:0], op1[31:16]};
        8'b11?10001: shift = {op1[16], op1[16:0], op1[31:17]};
        8'b11?10010: shift = {op1[17], op1[17:0], op1[31:18]};
        8'b11?10011: shift = {op1[18], op1[18:0], op1[31:19]};
        8'b11?10100: shift = {op1[19], op1[19:0], op1[31:20]};
        8'b11?10101: shift = {op1[20], op1[20:0], op1[31:21]};
        8'b11?10110: shift = {op1[21], op1[21:0], op1[31:22]};
        8'b11?10111: shift = {op1[22], op1[22:0], op1[31:23]};
        8'b11?11000: shift = {op1[23], op1[23:0], op1[31:24]};
        8'b11?11001: shift = {op1[24], op1[24:0], op1[31:25]};
        8'b11?11010: shift = {op1[25], op1[25:0], op1[31:26]};
        8'b11?11011: shift = {op1[26], op1[26:0], op1[31:27]};
        8'b11?11100: shift = {op1[27], op1[27:0], op1[31:28]};
        8'b11?11101: shift = {op1[28], op1[28:0], op1[31:29]};
        8'b11?11110: shift = {op1[29], op1[29:0], op1[31:30]};
        8'b11?11111: shift = {op1[30], op1[30:0], op1[31]};
	8'b11100000: shift = {op1[31], op1[31:0]}; 
    endcase
end

wire [31:0] result = shift[31:0];
wire shift_c_out = shift[32];

endmodule
