// defines.v


// States in the ARM
`define NUM_STATE_BITS  6
`define INIT		6'b000000	
`define F1		6'b000001
`define RESET		6'b000010
`define ABORT_DATA	6'b000011
`define ABORT_PREFETCH	6'b000100
`define FIQ		6'b000101
`define IRQ		6'b000110
`define IDLE		6'b000111
`define FETCH		6'b001000
`define LOAD_REQUEST	6'b001001
`define STORE_REQUEST	6'b001010
`define SOURCE_TO_WDREG	6'b001011
`define SWAP_1		6'b001100
`define SWAP_2		6'b001101
`define SWAP_3		6'b001110
`define SWAP_4		6'b001111
`define SWAP_5		6'b010000
`define SWAP_6		6'b010001		
`define SWAP_7		6'b010010
`define FPU_1A		6'b010011
`define FPU_1B		6'b010100
`define FPU_2A		6'b010101
`define FPU_2B		6'b010110
`define FPU_3		6'b010111
`define FPU_4		6'b011000
`define FPU_5		6'b011001
`define FPU_6		6'b011010
`define FPU_7		6'b011011
`define MULT            6'b011100

// ALU Control Signal Encodings

`define AND		5'b00000
`define EOR		5'b00001 //Same as EOR
`define SUB		5'b00010 //Same as SUB
`define RSB		5'b00011 //Same as RSB
`define ADD		5'b00100 
`define ADC		5'b00101 //Same as ADC
`define SBC		5'b00110 //Same as SBC
`define RSC		5'b00111 //Same as RSC
//TST
//TEQ
//CMP
//CMN
`define ORR		5'b01100 //Same as ORR
`define MOV		5'b01101 //Same as MOV
`define BIC		5'b01110 //Same as BIC
`define MVN             5'b01111 //MVN
`define PSA		5'b10000

// Shift Maker encodings

`define SHIFT_TYPE1 2'b00 
`define SHIFT_TYPE2 2'b01 
`define SHIFT_TYPE3 2'b10 
`define SHIFT_TYPE4 2'b11 

// Sign Extender Encodings

`define SZE_SEL_IR2110    2'b00
`define SZE_SEL_IR2_MUL70 2'b01
`define SZE_SEL_IR2_70    2'b10
`define SZE_SEL_IR2_230   2'b11 

// MUX control signals

//======================================================

// ALU_A_SEL ( 2 bit)

`define ALU_A_SEL_MUL	2'b00
`define ALU_A_SEL_A	2'b01
`define ALU_A_SEL_PC	2'b10
`define ALU_A_SEL_C	2'b11


// Barrel Shifter BS_INPUT_SEL (1 bit)

`define BS_INPUT_SEL_B		1'b0
`define BS_INPUT_SEL_EXT	1'b1


// Mux: RF_ADDR_WRITE_SEL (3 bits)

`define RF_ADDR_WRITE_SEL_IR21916               3'b000
`define RF_ADDR_WRITE_SEL_IR2_MULT1916          3'b001
`define RF_ADDR_WRITE_SEL_IR21512               3'b010
`define RF_ADDR_WRITE_SEL_IR2_MULT1512          3'b011
`define RF_ADDR_WRITE_SEL_R14                   3'b100 

// RF_BUS_WRITE_SEL (3 bits)

`define RF_BUS_WRITE_SEL_A_MAR			3'b000
`define RF_BUS_WRITE_SEL_RF_PC_READ    		3'b001
`define RF_BUS_WRITE_SEL_ALU_RESULT		3'b010 
`define RF_BUS_WRITE_SEL_PC_PLUS4               3'b011
`define RF_BUS_WRITE_SEL_D     		        3'b100
`define RF_BUS_WRITE_SEL_PSR_READ 	        3'b101
`define RF_BUS_WRITE_SEL_LINK_ADDR              3'b110

// RF_PC_WRITE_SEL  (4 bits)

`define RF_PC_WRITE_SEL_0			4'b0000
`define RF_PC_WRITE_SEL_4			4'b0001		
`define RF_PC_WRITE_SEL_8			4'b0010
`define RF_PC_WRITE_SEL_C	         	4'b0011
`define RF_PC_WRITE_SEL_1C			4'b0100
`define RF_PC_WRITE_SEL_18			4'b0101
`define RF_PC_WRITE_SEL_RF_PC_READ		4'b0110
`define RF_PC_WRITE_SEL_ALU_RESULT		4'b0111
`define RF_PC_WRITE_SEL_PC_PLUS4		4'b1000


// AR_BUS_ALU_SEL ( 1 bits) 

`define AR_BUS_ALU_SEL_ALU_RESULT		2'b00
`define AR_BUS_ALU_SEL_A_BUS     		2'b01
`define AR_BUS_ALU_SEL_ALU_HOLD			2'b10


// RF_ADDR_A_SEL ( 1bit)
`define RF_ADDR_A_SEL_IR21916			2'b00
`define RF_ADDR_A_SEL_IR230			2'b01
`define RF_ADDR_A_SEL_IR2_MULT1916		2'b10


// RF_ADDR_B_SEL ( 1bit)
`define RF_ADDR_B_SEL_IR21512			1'b0
`define RF_ADDR_B_SEL_IR230			1'b1

// Super_CPSR controls
`define SC_CTRL_SELECT_SOURCE_ALU              4'b0000
`define SC_CTRL_SELECT_SOURCE_USR_MODE         4'b0001
`define SC_CTRL_SELECT_SOURCE_SVC_MODE         4'b0010
`define SC_CTRL_SELECT_SOURCE_ABT_MODE         4'b0011
`define SC_CTRL_SELECT_SOURCE_FIQ_MODE         4'b0100
`define SC_CTRL_SELECT_SOURCE_IRQ_MODE         4'b0101
`define SC_CTRL_SELECT_SOURCE_UND_MODE	       4'b0110

`define SC_CTRL_SELECT_SOURCE_ALU_FLAGS	     4'b1000
`define SC_CTRL_SELECT_SOURCE_SFT_FLAGS	     4'b1001
`define SC_CTRL_SELECT_SOURCE_PASS_PSR	     4'b1010

`define SC_TYPE_CHANGE_MODE		5'b10000
`define SC_TYPE_CHANGE_ALL_FLAGS	5'b01111
`define SC_TYPE_CHANGE_NO_V		5'b01101

`define SC_USR_MODE	11'b00000010000
`define SC_SVC_MODE	11'b00001010011
`define SC_ABT_MODE     11'b00001010111
`define SC_FIQ_MODE     11'b00001110001
`define SC_IRQ_MODE     11'b00001010010
`define SC_UND_MODE     11'b00001011011
