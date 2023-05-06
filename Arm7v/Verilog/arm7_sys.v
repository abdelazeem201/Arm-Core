/////////////////////////////////////////////////////////////////
//  ARM7 TOP LEVEL v1.0,  6-23-2000                            //
//  ECE 371 EMR, Spring 2000                                   //
//  COMPONENT:  ARM7 system top level                          //
// ----------------------------------------------------------- //
//  File created by J. Shin 8/30/00 to remove memory from      //
//  datapath.
/////////////////////////////////////////////////////////////////

`timescale 1ns/100ps
`include "arm7.v"
`include "MemoryInterface.v"

///////////////////////////
// Top arm7 Module       //
///////////////////////////
module arm7_sys (nOPC, nCPI, CPA, CPB, sysclk, nRESET, nFIQ, nIRQ, ABORT);

// Input/Output declarations
   output        nOPC, nCPI;
   input         CPA, CPB;
   input         sysclk;
   input         nRESET;
   input         nFIQ;
   input         nIRQ;
   input         ABORT;


   wire          nOPC, nCPI;
   wire          CPA, CPB;
   wire          sysclk;
   wire          nRESET;           // Exception Signals
   wire          nFIQ;
   wire          nIRQ;
   wire          ABORT;
   wire         nMREQ;
   wire         nRW;
   wire [1:0]   MAS;
   wire         nWAIT;
   wire [31:0]  D;
   wire [31:0]  A;

   // Declare internal wires 
   // Register File
   // Super CPSR
   // Zero/Sign Extender
   // Barrel Shifter
   // Address Register
   // Write Data Register
   //Memory Interface
   //ALU
   //Multiplier
   //general

   //Instantiate arm7
    arm7 DUT_ARM7 (nOPC, nCPI, CPA, CPB, sysclk, nRESET, nFIQ, nIRQ, 
                   ABORT, nMREQ, nRW, MAS, nWAIT, A, D);
    
   //Instantiate MemoryInferface 
    MemoryInterface DUT_MMU (D, A, nMREQ, nRW, MAS, nWAIT, sysclk, nRESET); 

endmodule

