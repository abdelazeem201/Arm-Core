// Top level source file for the Memory Interface

`define BEHAVIORAL 1
`timescale 1ns/100ps 

`include "Memoryside.v"
`include "CPUside.v"
//`include "AVLMemory.v"
`include "SimpleMemory.v"

module MemoryInterface(D, A, nMREQ, nRW, MAS, nWAIT, sysclk, nRESET);

   inout [31:0]	D;
   input [31:0] A;
   input 	nMREQ;
   input 	nRW;
   input [1:0] 	MAS;
   output 	nWAIT;
   input 	sysclk, nRESET;
   
   wire [31:0] 	D;
   wire [31:0] 	A;
   wire 	nMREQ, nRW;
   wire [1:0] 	MAS;
   wire 	nWAIT;
   wire 	sysclk, reset;
   wire 	nRESET;
   
   // wires for connecting Memory model
   wire [31:0] 	mem_A, mem_D;
   wire 	mem_MCLK, mem_SEQ, mem_nRAS, mem_nCAS, mem_BYTE;
   wire 	mem_nWE, mem_nCS;
   
   // wires for connecting memory coupler
   wire 	st_busy, ld_busy;
   wire [31:0] 	write_buffer_D;
   wire [31:0] 	write_buffer_A;
   wire 	Store_Trigger, Load_Trigger;
   wire 	write_buffer_is_byte;
   
   // wires for connecting memside and cpuside
   wire 	mem_nRW;
   wire 	load_from_mem_req;
   wire [31:0] 	load_from_mem_data;
   wire [1:0] 	load_from_mem_offset;

   // Interfacing / Naming
   assign mem_MCLK = sysclk;
   assign mem_nWE = ! mem_nRW;
   assign reset = ! nRESET;
   
   memory_coupler memside(A, mem_A, mem_D, mem_nRAS, mem_nCAS, mem_nRW, mem_SEQ, 
			  mem_nCS, mem_MCLK, mem_BYTE, st_busy, ld_busy, 
			  write_buffer_is_byte, write_buffer_D, write_buffer_A, 
			  Store_Trigger, Load_Trigger, load_from_mem_req, 
			  load_from_mem_data, load_from_mem_offset, sysclk, reset);
   
//   SDRAM_model_AVL themem(mem_A, mem_D, mem_nRAS, mem_nCAS, 
//			  mem_nWE, mem_SEQ, mem_nCS, mem_MCLK, mem_BYTE);
   SDRAM_model_simple themem(mem_A, mem_D, mem_nRAS, mem_nCAS, 
			  mem_nWE, mem_SEQ, mem_nCS, mem_MCLK, mem_BYTE);
   
   CPU_coupler cpuside(D, A, nMREQ, nRW, MAS, nWAIT, sysclk, reset, 
		       Store_Trigger, Load_Trigger, 
		       write_buffer_D, write_buffer_A, write_buffer_is_byte, 
		       st_busy, ld_busy, 
		       load_from_mem_req, load_from_mem_data, load_from_mem_offset);
   
endmodule
