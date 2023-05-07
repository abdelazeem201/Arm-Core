`timescale 1ns/10ps
`include "pardef"
/*****************************************************************************
$RCSfile: mapspsr.v,v $
$Revision: 1.1 $
$Author: kohlere $
$Date: 2000/03/24 01:52:16 $
$State: Exp $


Description:  Based on the processor mode, this unit creates the SPSR index.
	
		Mode	SPSR Index
		==================
		FIQ	000
		SVC	001
		ABT	010
		IRQ	011
		UNDE	100
		OTHERS	111

For User or System Modes, as well as non-defined modes, this unit will
return a value of 111 (7), indicating that there is no SPSR for the 
current state of the processor.
	
*****************************************************************************/

module mapspsr (mode, spsr_index);

/*------------------------------------------------------------------------
        Ports
------------------------------------------------------------------------*/
input	[4:0]	mode;		//5-Bit Mode of Processor
output  [2:0]   spsr_index;     //3-Bit Index of SPSR

/*------------------------------------------------------------------------
        Combinational Always Block
------------------------------------------------------------------------*/
reg	[2:0]	spsr_index;		//Declare Output of Multiplexer

always @(mode)
    begin
	case (mode) //synopsys full_case parallel_case
	    `FIQ:  spsr_index = 3'h0;
	    `IRQ:  spsr_index = 3'h3;
	    `SVC:  spsr_index = 3'h1;
	    `ABT:  spsr_index = 3'h2;
	    `UNDE: spsr_index = 3'h4;
	    default: spsr_index = 3'h7;
	endcase
    end

endmodule
