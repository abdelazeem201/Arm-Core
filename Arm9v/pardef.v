`timescale 1ns/10ps
/*****************************************************************************
$RCSfile: pardef.v,v $
$Revision: 1.3 $
$Author: kohlere $
$Date: 2000/03/28 04:39:17 $
$State: Exp $

Description: This is a list of parameters and define statments used in 
		the ARM.

*****************************************************************************/
module pardef();
//Fill FSM Parameters
`define IDLE                    (3'h7)
`define FIRST_FILL              (3'h0)
`define SECOND_FILL             (3'h1)
`define THIRD_FILL              (3'h3)
`define FOURTH_FILL             (3'h2)
`define FIRST_MISPREDICT        (3'h4)
`define SECOND_MISPREDICT       (3'h5)
`define THIRD_MISPREDICT        (3'h6)

//Count FSM Parmaeters
`define NO_COUNT 		(2'h0)
`define SECOND_CYCLE		(2'h1)
`define THIRD_CYCLE		(2'h3) 
`define FOURTH_PLUS_CYCLE	(2'h2)

//Coprocessor Handshaking States
`define ABSENT  (2'b10)                 //Coprocessor is not Present  
`define WAIT    (2'b00)                 //Coprocessor is busy
`define GO      (2'b01)                 //Coprocessor is ready
`define LAST    (2'b11)                 //Last cycle of Cop Inst.  

//Opcode Definitions
`define ALU  (4'h0)
`define LDRH (4'h1)
`define STRH (4'h2)
`define MUL  (4'h3)
`define MULL (4'h4)
`define SWAP (4'h5)
`define MRS  (4'h6)
`define MSR  (4'h7)
`define STRW (4'h8)
`define LDRW (4'h9)
`define UND  (4'hA)
`define STM  (4'hB)
`define LDM  (4'hC)
`define BR   (4'hD)
`define COP  (4'hE)
`define SWI  (4'hF)

//Flag Definitions
`define EQ   (4'b0000)          //Z set           => equal
`define NE   (4'b0001)          //Z clear         => not equal
`define CS   (4'b0010)          //C set           => unsigned hgr or same 
`define CC   (4'b0011)          //C clear         => unsigned lower
`define MI   (4'b0100)          //N set           => negative
`define PL   (4'b0101)          //N clear         => positive or zero
`define VS   (4'b0110)          //V set           => overflow
`define VC   (4'b0111)          //V clear         => no overflow
`define HI   (4'b1000)          //C set & Z clear => unsigned higher
`define LS   (4'b1001)          //C clear | Z set => unsigend lwr or same
`define GE   (4'b1010)          //N equals V      => greater or equal
`define LT   (4'b1011)          //N not equal V   => less than
`define GT   (4'b1100)          //Z clear & (N=Z) => greater than
`define LE   (4'b1101)          //Z set | (N!=Z)  => less than or equal
`define AL   (4'b1110)          //(ignored)
`define NV   (4'b1111)          //Reserved        => never

//ALU Funciton Code Definitions
`define AND  (4'b0000)          //ALU opcode AND
`define EOR  (4'b0001)          //ALU opcode Exclusive-OR
`define SUB  (4'b0010)          //ALU opcode Subtract (Rd = Rn - Op2)
`define RSB  (4'b0011)          //ALU opcode Reverse Subtract (Rd = Op2 - Rn)
`define ADD  (4'b0100)          //ALU opcode ADD
`define ADC  (4'b0101)          //ALU opcode ADD with Carry
`define SBC  (4'b0110)          //ALU opcode Subtract with Carry
`define RSC  (4'b0111)          //ALU opcode Reverse Subtract with Carry
`define TST  (4'b1000)          //ALU opcode Test Bits
`define TEQ  (4'b1001)          //ALU opcode Test Bitwise Equality
`define CMP  (4'b1010)          //ALU opcode Compare
`define CMN  (4'b1011)          //ALU opcode Compare Negative
`define ORR  (4'b1100)          //ALU opcode OR
`define MOV  (4'b1101)          //ALU opcode Move Register or Constant
`define BIC  (4'b1110)          //ALU opcode Bit Clear
`define MVN  (4'b1111)          //ALU opcode Move Negative Register

//ARM Mode/State Definitions
`define USR  (5'b10000)         //User Mode
`define FIQ  (5'b10001)         //FIQ Mode 
`define IRQ  (5'b10010)         //IRQ Mode 
`define SVC  (5'b10011)         //Supervisor Mode
`define ABT  (5'b10111)         //Abort Mode
`define UNDE (5'b11011)         //Undefined Mode
`define SYS  (5'b11111)         //System Mode   

//DCache Parameters
`define DWPL 	(8)		//D$ Words/Line
`define DLS	(`DWPL * 32)	//D$ Line Size
`define DNL	(256)		//D$ Number of Lines
`define DLSS	(8)		//Line Select Bits = Log2(DNL)
`define DLSH	(`DLSS+4)	//LS High Bit Add = <Tag><LSS><word><byte>
`define DPSL	(`DLSH+1)	//Page Select Low Bit
`define DTS	(2+(32-`DPSL))	//Tag Size D,V,Page Select
`define DTH	(`DTS-1)	//Tag High Bit Value
`define DPSH	(`DTH-2)	//Page Select High Bit Value

//Data Access Sizes
`define         BYTE    (2'b00) //Byte Access
`define         HALF    (2'b01) //Halfword Access
`define         WORD    (2'b10) //Word Access
`define         DOUB    (2'b11) //Double

//ICache Parameters
`define IWPL    (8)             //I$ Words/Line
`define ILS     (`IWPL * 32)    //I$ Line Size (Bits)
`define INL     (128)           //I$ Number of Lines (kB = 32*NL/1024)
`define ILSS    (7)             //Line Select Bits = Log2(INL)
`define ILSH    (`ILSS+4)       //LS High Bit Add = <Tag><LSS><word><byte>
`define IPSL    (`ILSH+1)       //Page Select Low Bit
`define ITS     (2+(32-`IPSL))  //Tag Size D,V,Page Select
`define ITH     (`ITS-1)        //Tag High Bit Value
`define IPSH    (`ITH-2)        //Page Select High Bit Value

//Read/Write Definition
`define READ    (1'b1)          //Data Read Operation
`define WRTE    (1'b0)          //Data Write Operation

endmodule
