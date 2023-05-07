`timescale 1ns/10ps
/*-----------------------------------------------------------------------------
Project:        High Speed Floating Point Unit
File:           $RCSfile: comp42_n40.v,v $
Author:         $Author: kohlere $
Version:        $Revision: 1.1 $
Modified:       $Date: 2000/03/24 01:52:16 $
State:          $State: Exp $

Description:    A collection of comp42's, number given in filename.

Notices:        (C) Matt Postiff, Mike Kelley, and Tim Strong, 1996-1997
                (C) Copyright The Regents of the University of Michigan, 1996

References:     

To Do:
-----------------------------------------------------------------------------*/

//-----------------------------------------------------------------------------
// module definition
//-----------------------------------------------------------------------------
module comp42_n40 (I1, I2, I3, I4, CI, C1, S1, S0);

   input [39:0]  I1;
   input [39:0]  I2;
   input [39:0]  I3;
   input [39:0]  I4;
   input [39:0]  CI;

   output [39:0] C1;
   output [39:0] S1;
   output [39:0] S0;
/*
comp42_2 compressor_0
(
 .I1(I1[0]), 
 .I2(I2[0]),
 .I3(I3[0]),
 .I4(I4[0]),
 .CI(CI[0]),
 .C1(C1[0]),
 .S1(S1[0]),
 .S0(S0[0])
);
*/
wire [39:0] S0, S1, C1;
assign S0[0] = I1[0] ^ I2[0];
assign S1[0] = I1[0] & I2[0];
assign C1[0] = 1'b0;
/*
comp42_2 compressor_1
(
 .I1(I1[1]), 
 .I2(I2[1]),
 .I3(I3[1]),
 .I4(I4[1]),
 .CI(CI[1]),
 .C1(C1[1]),
 .S1(S1[1]),
 .S0(S0[1])
);
*/

assign S0[1] = I1[1] ^ I2[1];
assign S1[1] = I1[1]&I2[1];
assign C1[1] = 1'b0;

comp42_2  compressor_2
(
 .I1(I1[2]), 
 .I2(I2[2]),
 .I3(I3[2]),
 .I4(I4[2]),
 .CI(CI[2]),
 .C1(C1[2]),
 .S1(S1[2]),
 .S0(S0[2])
);
/*
comp42_2  compressor_3
(
 .I1(I1[3]), 
 .I2(I2[3]),
 .I3(I3[3]),
 .I4(I4[3]),
 .CI(CI[3]),
 .C1(C1[3]),
 .S1(S1[3]),
 .S0(S0[3])
);
*/

assign S0[3] = CI[3] ^ I1[3] ^ I2[3];
assign S1[3] = CI[3]&I1[3] | CI[3]&I2[3] | I1[3]&I2[3];
assign C1[3] = 1'b0;

comp42_2  compressor_4
(
 .I1(I1[4]), 
 .I2(I2[4]),
 .I3(I3[4]),
 .I4(I4[4]),
 .CI(CI[4]),
 .C1(C1[4]),
 .S1(S1[4]),
 .S0(S0[4])
);
comp42_2  compressor_5
(
 .I1(I1[5]), 
 .I2(I2[5]),
 .I3(I3[5]),
 .I4(I4[5]),
 .CI(CI[5]),
 .C1(C1[5]),
 .S1(S1[5]),
 .S0(S0[5])
);
comp42_2  compressor_6
(
 .I1(I1[6]), 
 .I2(I2[6]),
 .I3(I3[6]),
 .I4(I4[6]),
 .CI(CI[6]),
 .C1(C1[6]),
 .S1(S1[6]),
 .S0(S0[6])
);
comp42_2  compressor_7
(
 .I1(I1[7]), 
 .I2(I2[7]),
 .I3(I3[7]),
 .I4(I4[7]),
 .CI(CI[7]),
 .C1(C1[7]),
 .S1(S1[7]),
 .S0(S0[7])
);
comp42_2  compressor_8
(
 .I1(I1[8]), 
 .I2(I2[8]),
 .I3(I3[8]),
 .I4(I4[8]),
 .CI(CI[8]),
 .C1(C1[8]),
 .S1(S1[8]),
 .S0(S0[8])
);
comp42_2  compressor_9
(
 .I1(I1[9]), 
 .I2(I2[9]),
 .I3(I3[9]),
 .I4(I4[9]),
 .CI(CI[9]),
 .C1(C1[9]),
 .S1(S1[9]),
 .S0(S0[9])
);
comp42_2  compressor_10
(
 .I1(I1[10]), 
 .I2(I2[10]),
 .I3(I3[10]),
 .I4(I4[10]),
 .CI(CI[10]),
 .C1(C1[10]),
 .S1(S1[10]),
 .S0(S0[10])
);
comp42_2  compressor_11
(
 .I1(I1[11]), 
 .I2(I2[11]),
 .I3(I3[11]),
 .I4(I4[11]),
 .CI(CI[11]),
 .C1(C1[11]),
 .S1(S1[11]),
 .S0(S0[11])
);
comp42_2  compressor_12
(
 .I1(I1[12]), 
 .I2(I2[12]),
 .I3(I3[12]),
 .I4(I4[12]),
 .CI(CI[12]),
 .C1(C1[12]),
 .S1(S1[12]),
 .S0(S0[12])
);
comp42_2  compressor_13
(
 .I1(I1[13]), 
 .I2(I2[13]),
 .I3(I3[13]),
 .I4(I4[13]),
 .CI(CI[13]),
 .C1(C1[13]),
 .S1(S1[13]),
 .S0(S0[13])
);
comp42_2  compressor_14
(
 .I1(I1[14]), 
 .I2(I2[14]),
 .I3(I3[14]),
 .I4(I4[14]),
 .CI(CI[14]),
 .C1(C1[14]),
 .S1(S1[14]),
 .S0(S0[14])
);
comp42_2  compressor_15
(
 .I1(I1[15]), 
 .I2(I2[15]),
 .I3(I3[15]),
 .I4(I4[15]),
 .CI(CI[15]),
 .C1(C1[15]),
 .S1(S1[15]),
 .S0(S0[15])
);
comp42_2  compressor_16
(
 .I1(I1[16]), 
 .I2(I2[16]),
 .I3(I3[16]),
 .I4(I4[16]),
 .CI(CI[16]),
 .C1(C1[16]),
 .S1(S1[16]),
 .S0(S0[16])
);
comp42_2  compressor_17
(
 .I1(I1[17]), 
 .I2(I2[17]),
 .I3(I3[17]),
 .I4(I4[17]),
 .CI(CI[17]),
 .C1(C1[17]),
 .S1(S1[17]),
 .S0(S0[17])
);
comp42_2  compressor_18
(
 .I1(I1[18]), 
 .I2(I2[18]),
 .I3(I3[18]),
 .I4(I4[18]),
 .CI(CI[18]),
 .C1(C1[18]),
 .S1(S1[18]),
 .S0(S0[18])
);
comp42_2  compressor_19
(
 .I1(I1[19]), 
 .I2(I2[19]),
 .I3(I3[19]),
 .I4(I4[19]),
 .CI(CI[19]),
 .C1(C1[19]),
 .S1(S1[19]),
 .S0(S0[19])
);
comp42_2  compressor_20
(
 .I1(I1[20]), 
 .I2(I2[20]),
 .I3(I3[20]),
 .I4(I4[20]),
 .CI(CI[20]),
 .C1(C1[20]),
 .S1(S1[20]),
 .S0(S0[20])
);
comp42_2  compressor_21
(
 .I1(I1[21]), 
 .I2(I2[21]),
 .I3(I3[21]),
 .I4(I4[21]),
 .CI(CI[21]),
 .C1(C1[21]),
 .S1(S1[21]),
 .S0(S0[21])
);
comp42_2  compressor_22
(
 .I1(I1[22]), 
 .I2(I2[22]),
 .I3(I3[22]),
 .I4(I4[22]),
 .CI(CI[22]),
 .C1(C1[22]),
 .S1(S1[22]),
 .S0(S0[22])
);
comp42_2  compressor_23
(
 .I1(I1[23]), 
 .I2(I2[23]),
 .I3(I3[23]),
 .I4(I4[23]),
 .CI(CI[23]),
 .C1(C1[23]),
 .S1(S1[23]),
 .S0(S0[23])
);
comp42_2  compressor_24
(
 .I1(I1[24]), 
 .I2(I2[24]),
 .I3(I3[24]),
 .I4(I4[24]),
 .CI(CI[24]),
 .C1(C1[24]),
 .S1(S1[24]),
 .S0(S0[24])
);
comp42_2  compressor_25
(
 .I1(I1[25]), 
 .I2(I2[25]),
 .I3(I3[25]),
 .I4(I4[25]),
 .CI(CI[25]),
 .C1(C1[25]),
 .S1(S1[25]),
 .S0(S0[25])
);
comp42_2  compressor_26
(
 .I1(I1[26]), 
 .I2(I2[26]),
 .I3(I3[26]),
 .I4(I4[26]),
 .CI(CI[26]),
 .C1(C1[26]),
 .S1(S1[26]),
 .S0(S0[26])
);
comp42_2  compressor_27
(
 .I1(I1[27]), 
 .I2(I2[27]),
 .I3(I3[27]),
 .I4(I4[27]),
 .CI(CI[27]),
 .C1(C1[27]),
 .S1(S1[27]),
 .S0(S0[27])
);
comp42_2  compressor_28
(
 .I1(I1[28]), 
 .I2(I2[28]),
 .I3(I3[28]),
 .I4(I4[28]),
 .CI(CI[28]),
 .C1(C1[28]),
 .S1(S1[28]),
 .S0(S0[28])
);
comp42_2  compressor_29
(
 .I1(I1[29]), 
 .I2(I2[29]),
 .I3(I3[29]),
 .I4(I4[29]),
 .CI(CI[29]),
 .C1(C1[29]),
 .S1(S1[29]),
 .S0(S0[29])
);
comp42_2  compressor_30
(
 .I1(I1[30]), 
 .I2(I2[30]),
 .I3(I3[30]),
 .I4(I4[30]),
 .CI(CI[30]),
 .C1(C1[30]),
 .S1(S1[30]),
 .S0(S0[30])
);
comp42_2  compressor_31
(
 .I1(I1[31]), 
 .I2(I2[31]),
 .I3(I3[31]),
 .I4(I4[31]),
 .CI(CI[31]),
 .C1(C1[31]),
 .S1(S1[31]),
 .S0(S0[31])
);
comp42_2  compressor_32
(
 .I1(I1[32]), 
 .I2(I2[32]),
 .I3(I3[32]),
 .I4(I4[32]),
 .CI(CI[32]),
 .C1(C1[32]),
 .S1(S1[32]),
 .S0(S0[32])
);
comp42_2  compressor_33
(
 .I1(I1[33]), 
 .I2(I2[33]),
 .I3(I3[33]),
 .I4(I4[33]),
 .CI(CI[33]),
 .C1(C1[33]),
 .S1(S1[33]),
 .S0(S0[33])
);
comp42_2  compressor_34
(
 .I1(I1[34]), 
 .I2(I2[34]),
 .I3(I3[34]),
 .I4(I4[34]),
 .CI(CI[34]),
 .C1(C1[34]),
 .S1(S1[34]),
 .S0(S0[34])
);
comp42_2  compressor_35
(
 .I1(I1[35]), 
 .I2(I2[35]),
 .I3(I3[35]),
 .I4(I4[35]),
 .CI(CI[35]),
 .C1(C1[35]),
 .S1(S1[35]),
 .S0(S0[35])
);
comp42_2  compressor_36
(
 .I1(I1[36]), 
 .I2(I2[36]),
 .I3(I3[36]),
 .I4(I4[36]),
 .CI(CI[36]),
 .C1(C1[36]),
 .S1(S1[36]),
 .S0(S0[36])
);
comp42_2  compressor_37
(
 .I1(I1[37]), 
 .I2(I2[37]),
 .I3(I3[37]),
 .I4(I4[37]),
 .CI(CI[37]),
 .C1(C1[37]),
 .S1(S1[37]),
 .S0(S0[37])
);
comp42_2  compressor_38
(
 .I1(I1[38]), 
 .I2(I2[38]),
 .I3(I3[38]),
 .I4(I4[38]),
 .CI(CI[38]),
 .C1(C1[38]),
 .S1(S1[38]),
 .S0(S0[38])
);
comp42_2  compressor_39
(
 .I1(I1[39]), 
 .I2(I2[39]),
 .I3(I3[39]),
 .I4(I4[39]),
 .CI(CI[39]),
 .C1(C1[39]),
 .S1(S1[39]),
 .S0(S0[39])
);

endmodule
