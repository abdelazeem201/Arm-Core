// ARM 7 Register File
//  Jeffrey J. Cook

// ** UNTESTED, BEWARE **
`timescale 1ns/100ps

`define	ADDRLEN	4
`define	DBUSLEN	32
`define	FLAGSLEN	11

`define	CPSRSEL	0
`define	SPSRSEL	1

`define	MODE_USER	5'b10000
`define	MODE_FIQ	5'b10001
`define	MODE_IRQ	5'b10010
`define	MODE_SUP	5'b10011
`define	MODE_ABT	5'b10111
`define	MODE_UNDF	5'b11011

`define	R0		4'b0000
`define	R1		4'b0001
`define	R2		4'b0010
`define	R3		4'b0011
`define	R4		4'b0100
`define	R5		4'b0101
`define	R6		4'b0110
`define	R7		4'b0111
`define	R8		4'b1000
`define	R9		4'b1001
`define	R10		4'b1010
`define	R11		4'b1011
`define	R12		4'b1100
`define	R13		4'b1101
`define	R14		4'b1110
`define	R15		4'b1111

module registerfile(RF_Addr_A,RF_Addr_B,RF_Addr_C,RF_Addr_Write,RF_Bus_Write,RF_Load_Write,
				RF_PC_Write,RF_Flags_Write,RF_Load_Flags,RF_PSR_R_Sel, RF_PSR_W_Sel,
				RF_Bus_A,RF_Bus_B,RF_Bus_C,RF_PC_Read,RF_PSR_Read,
				sysclk);

input	[`ADDRLEN-1:0]	RF_Addr_A,RF_Addr_B,RF_Addr_C,RF_Addr_Write;
input	[`DBUSLEN-1:0]	RF_Bus_Write,RF_PC_Write;
input	RF_Load_Write,RF_Load_Flags,RF_PSR_R_Sel,RF_PSR_W_Sel;	
input	[`FLAGSLEN-1:0]	RF_Flags_Write;
input	sysclk;

output	[`DBUSLEN-1:0]	RF_Bus_A,RF_Bus_B,RF_Bus_C,RF_PC_Read,RF_PSR_Read;

wire		[`ADDRLEN-1:0]	RF_Addr_A,RF_Addr_B,RF_Addr_C,RF_Addr_Write;
wire		[`DBUSLEN-1:0]	RF_Bus_Write,RF_PC_Write;
wire		RF_Load_Write,RF_Load_Flags,RF_PSR_R_Sel,RF_PSR_W_Sel;	
wire		[`FLAGSLEN-1:0]	RF_Flags_Write;
wire		sysclk;

// outputs regs
reg		[`DBUSLEN-1:0]	RF_Bus_A,RF_Bus_B,RF_Bus_C,RF_PC_Read,RF_PSR_Read;


// internal regs
reg		[`DBUSLEN-1:0]	rf_int_cpsr;
reg		[`DBUSLEN-1:0]	rf_int_spsr_fiq;
reg		[`DBUSLEN-1:0]	rf_int_spsr_irq;
reg		[`DBUSLEN-1:0]	rf_int_spsr_abt;
reg		[`DBUSLEN-1:0]	rf_int_spsr_svc;
reg		[`DBUSLEN-1:0]	rf_int_spsr_und;

reg		[`DBUSLEN-1:0]	rf_int_r0;
reg		[`DBUSLEN-1:0]	rf_int_r1;
reg		[`DBUSLEN-1:0]	rf_int_r2;
reg		[`DBUSLEN-1:0]	rf_int_r3;
reg		[`DBUSLEN-1:0]	rf_int_r4;
reg		[`DBUSLEN-1:0]	rf_int_r5;
reg		[`DBUSLEN-1:0]	rf_int_r6;
reg		[`DBUSLEN-1:0]	rf_int_r7;
reg		[`DBUSLEN-1:0]	rf_int_r8;
reg		[`DBUSLEN-1:0]	rf_int_r9;
reg		[`DBUSLEN-1:0]	rf_int_r10;
reg		[`DBUSLEN-1:0]	rf_int_r11;
reg		[`DBUSLEN-1:0]	rf_int_r12;
reg		[`DBUSLEN-1:0]	rf_int_r13;
reg		[`DBUSLEN-1:0]	rf_int_r14;
reg		[`DBUSLEN-1:0]	rf_int_r15;
reg		[`DBUSLEN-1:0]	rf_int_r8_fiq;
reg		[`DBUSLEN-1:0]	rf_int_r9_fiq;
reg		[`DBUSLEN-1:0]	rf_int_r10_fiq;
reg		[`DBUSLEN-1:0]	rf_int_r11_fiq;
reg		[`DBUSLEN-1:0]	rf_int_r12_fiq;
reg		[`DBUSLEN-1:0]	rf_int_r13_fiq;
reg		[`DBUSLEN-1:0]	rf_int_r14_fiq;
reg		[`DBUSLEN-1:0]	rf_int_r13_irq;
reg		[`DBUSLEN-1:0]	rf_int_r14_irq;
reg		[`DBUSLEN-1:0]	rf_int_r13_svc;
reg		[`DBUSLEN-1:0]	rf_int_r14_svc;
reg		[`DBUSLEN-1:0]	rf_int_r13_abt;
reg		[`DBUSLEN-1:0]	rf_int_r14_abt;
reg		[`DBUSLEN-1:0]	rf_int_r13_und;
reg		[`DBUSLEN-1:0]	rf_int_r14_und;

// end internal regs

//	PC stuffs
always @(rf_int_r15) RF_PC_Read = rf_int_r15;

always @(posedge sysclk)
begin
	 if(RF_Addr_Write != `R15)
           begin
              // if (rf_int_r15 != RF_PC_Write)
              //   $display ("%d: PC=%x", $time, RF_PC_Write);
              rf_int_r15 <= RF_PC_Write; 
           end
end

//	CPSR/SPSR Reading
always @(rf_int_cpsr)
begin
	if( RF_PSR_R_Sel == `CPSRSEL )	RF_PSR_Read <= rf_int_cpsr;
	if( RF_PSR_R_Sel == `SPSRSEL )
	begin
		case (rf_int_cpsr[4:0])
		`MODE_USER	:	RF_PSR_Read <= 32'bX;
		`MODE_FIQ	:	RF_PSR_Read <= rf_int_spsr_fiq;
		`MODE_IRQ	:	RF_PSR_Read <= rf_int_spsr_irq;
		`MODE_SUP	:	RF_PSR_Read <= rf_int_spsr_svc;
		`MODE_ABT	:	RF_PSR_Read <= rf_int_spsr_abt;
		`MODE_UNDF	:	RF_PSR_Read <= rf_int_spsr_und;
		default		:	RF_PSR_Read <= 32'bX;
		endcase
	end
end

//	CPSR/SPSR Writing
//	perhaps fix this to not destroy currently reserved bits in CPSR/SPSR
always @(posedge sysclk)
begin
	if( RF_Load_Flags )
	begin
		if( RF_PSR_W_Sel == `CPSRSEL )	rf_int_cpsr <= {RF_Flags_Write[10:7],20'b0,RF_Flags_Write[6:5],1'b0,RF_Flags_Write[4:0]};
		if( RF_PSR_W_Sel == `SPSRSEL )
		begin
			// if( rf_int_cpsr[4:0] == MODE_USER )	 error! - not an option, optimized out
			case (rf_int_cpsr[4:0])
			`MODE_FIQ	:	rf_int_spsr_fiq <= {RF_Flags_Write[10:7],20'b0,RF_Flags_Write[6:5],1'b0,RF_Flags_Write[4:0]};
			`MODE_IRQ	:	rf_int_spsr_irq <= {RF_Flags_Write[10:7],20'b0,RF_Flags_Write[6:5],1'b0,RF_Flags_Write[4:0]};
			`MODE_SUP	:	rf_int_spsr_svc <= {RF_Flags_Write[10:7],20'b0,RF_Flags_Write[6:5],1'b0,RF_Flags_Write[4:0]};
			`MODE_ABT	:	rf_int_spsr_abt <= {RF_Flags_Write[10:7],20'b0,RF_Flags_Write[6:5],1'b0,RF_Flags_Write[4:0]};
			`MODE_UNDF	:	rf_int_spsr_und <= {RF_Flags_Write[10:7],20'b0,RF_Flags_Write[6:5],1'b0,RF_Flags_Write[4:0]};
			default		:	begin end
			endcase
		end
	end
end

//	autosave CPSR into SPSR of new mode
//	untested!
always @(posedge sysclk)
begin
	if( RF_Load_Flags )
	begin
		if( RF_PSR_W_Sel == `CPSRSEL && rf_int_cpsr[4:0] == `MODE_USER && RF_Flags_Write[4:0] != `MODE_USER)
		case (RF_Flags_Write[4:0])
		`MODE_FIQ	:	rf_int_spsr_fiq = rf_int_cpsr;
		`MODE_IRQ	:	rf_int_spsr_irq = rf_int_cpsr;
		`MODE_SUP	:	rf_int_spsr_svc = rf_int_cpsr;
		`MODE_ABT	:	rf_int_spsr_abt = rf_int_cpsr;
		`MODE_UNDF	:	rf_int_spsr_und = rf_int_cpsr;
		default		:	begin end
		endcase
	end
end

//	Register Writing
always @(posedge sysclk)
begin
	if( RF_Load_Write )
	begin
		case (rf_int_cpsr[4:0])
		`MODE_USER	:
		begin
			case (RF_Addr_Write)
			`R0	:	rf_int_r0 <= RF_Bus_Write;
			`R1	:	rf_int_r1 <= RF_Bus_Write;
			`R2	:	rf_int_r2 <= RF_Bus_Write;
			`R3	:	rf_int_r3 <= RF_Bus_Write;
			`R4	:	rf_int_r4 <= RF_Bus_Write;
			`R5	:	rf_int_r5 <= RF_Bus_Write;
			`R6	:	rf_int_r6 <= RF_Bus_Write;
			`R7	:	rf_int_r7 <= RF_Bus_Write;
			`R8	:	rf_int_r8 <= RF_Bus_Write;
			`R9	:	rf_int_r9 <= RF_Bus_Write;
			`R10	:	rf_int_r10 <= RF_Bus_Write;
			`R11	:	rf_int_r11 <= RF_Bus_Write;
			`R12	:	rf_int_r12 <= RF_Bus_Write;
			`R13	:	rf_int_r13 <= RF_Bus_Write;
			`R14	:	rf_int_r14 <= RF_Bus_Write;
			`R15	:	rf_int_r15 <= RF_Bus_Write;
			default	:	begin end
			endcase
                     // $display ("%d: R%x=%x", $time, RF_Addr_Write, RF_Bus_Write);
		end
		`MODE_FIQ	:
		begin
			case (RF_Addr_Write)
			`R0	:	rf_int_r0 <= RF_Bus_Write;
			`R1	:	rf_int_r1 <= RF_Bus_Write;
			`R2	:	rf_int_r2 <= RF_Bus_Write;
			`R3	:	rf_int_r3 <= RF_Bus_Write;
			`R4	:	rf_int_r4 <= RF_Bus_Write;
			`R5	:	rf_int_r5 <= RF_Bus_Write;
			`R6	:	rf_int_r6 <= RF_Bus_Write;
			`R7	:	rf_int_r7 <= RF_Bus_Write;
			`R8	:	rf_int_r8_fiq <= RF_Bus_Write;
			`R9	:	rf_int_r9_fiq <= RF_Bus_Write;
			`R10	:	rf_int_r10_fiq <= RF_Bus_Write;
			`R11	:	rf_int_r11_fiq <= RF_Bus_Write;
			`R12	:	rf_int_r12_fiq <= RF_Bus_Write;
			`R13	:	rf_int_r13_fiq <= RF_Bus_Write;
			`R14	:	rf_int_r14_fiq <= RF_Bus_Write;
			`R15	:	rf_int_r15 <= RF_Bus_Write;
			default	:	begin end
			endcase
		end
		`MODE_IRQ 	:
		begin
			case (RF_Addr_Write)
			`R0	:	rf_int_r0 <= RF_Bus_Write;
			`R1	:	rf_int_r1 <= RF_Bus_Write;
			`R2	:	rf_int_r2 <= RF_Bus_Write;
			`R3	:	rf_int_r3 <= RF_Bus_Write;
			`R4	:	rf_int_r4 <= RF_Bus_Write;
			`R5	:	rf_int_r5 <= RF_Bus_Write;
			`R6	:	rf_int_r6 <= RF_Bus_Write;
			`R7	:	rf_int_r7 <= RF_Bus_Write;
			`R8	:	rf_int_r8 <= RF_Bus_Write;
			`R9	:	rf_int_r9 <= RF_Bus_Write;
			`R10	:	rf_int_r10 <= RF_Bus_Write;
			`R11	:	rf_int_r11 <= RF_Bus_Write;
			`R12	:	rf_int_r12 <= RF_Bus_Write;
			`R13	:	rf_int_r13_irq <= RF_Bus_Write;
			`R14	:	rf_int_r14_irq <= RF_Bus_Write;
			`R15	:	rf_int_r15 <= RF_Bus_Write;
			default	:	begin end
			endcase
		end
		`MODE_SUP	:
		begin
			case (RF_Addr_Write)
			`R0	:	rf_int_r0 <= RF_Bus_Write;
			`R1	:	rf_int_r1 <= RF_Bus_Write;
			`R2	:	rf_int_r2 <= RF_Bus_Write;
			`R3	:	rf_int_r3 <= RF_Bus_Write;
			`R4	:	rf_int_r4 <= RF_Bus_Write;
			`R5	:	rf_int_r5 <= RF_Bus_Write;
			`R6	:	rf_int_r6 <= RF_Bus_Write;
			`R7	:	rf_int_r7 <= RF_Bus_Write;
			`R8	:	rf_int_r8 <= RF_Bus_Write;
			`R9	:	rf_int_r9 <= RF_Bus_Write;
			`R10	:	rf_int_r10 <= RF_Bus_Write;
			`R11	:	rf_int_r11 <= RF_Bus_Write;
			`R12	:	rf_int_r12 <= RF_Bus_Write;
			`R13	:	rf_int_r13_svc <= RF_Bus_Write;
			`R14	:	rf_int_r14_svc <= RF_Bus_Write;
			`R15	:	rf_int_r15 <= RF_Bus_Write;
			default	:	begin end
			endcase
		end
		`MODE_ABT 	:
		begin
			case (RF_Addr_Write)
			`R0	:	rf_int_r0 <= RF_Bus_Write;
			`R1	:	rf_int_r1 <= RF_Bus_Write;
			`R2	:	rf_int_r2 <= RF_Bus_Write;
			`R3	:	rf_int_r3 <= RF_Bus_Write;
			`R4	:	rf_int_r4 <= RF_Bus_Write;
			`R5	:	rf_int_r5 <= RF_Bus_Write;
			`R6	:	rf_int_r6 <= RF_Bus_Write;
			`R7	:	rf_int_r7 <= RF_Bus_Write;
			`R8	:	rf_int_r8 <= RF_Bus_Write;
			`R9	:	rf_int_r9 <= RF_Bus_Write;
			`R10	:	rf_int_r10 <= RF_Bus_Write;
			`R11	:	rf_int_r11 <= RF_Bus_Write;
			`R12	:	rf_int_r12 <= RF_Bus_Write;
			`R13	:	rf_int_r13_abt <= RF_Bus_Write;
			`R14	:	rf_int_r14_abt <= RF_Bus_Write;
			`R15	:	rf_int_r15 <= RF_Bus_Write;
			default	:	begin end
			endcase
		end
		`MODE_UNDF	:
		begin
			case (RF_Addr_Write)
			`R0	:	rf_int_r0 <= RF_Bus_Write;
			`R1	:	rf_int_r1 <= RF_Bus_Write;
			`R2	:	rf_int_r2 <= RF_Bus_Write;
			`R3	:	rf_int_r3 <= RF_Bus_Write;
			`R4	:	rf_int_r4 <= RF_Bus_Write;
			`R5	:	rf_int_r5 <= RF_Bus_Write;
			`R6	:	rf_int_r6 <= RF_Bus_Write;
			`R7	:	rf_int_r7 <= RF_Bus_Write;
			`R8	:	rf_int_r8 <= RF_Bus_Write;
			`R9	:	rf_int_r9 <= RF_Bus_Write;
			`R10	:	rf_int_r10 <= RF_Bus_Write;
			`R11	:	rf_int_r11 <= RF_Bus_Write;
			`R12	:	rf_int_r12 <= RF_Bus_Write;
			`R13	:	rf_int_r13_und <= RF_Bus_Write;
			`R14	:	rf_int_r14_und <= RF_Bus_Write;
			`R15	:	rf_int_r15 <= RF_Bus_Write;
			default	:	begin end
			endcase
		end
		default	:	begin end
		endcase
	end
end

//	Register Reading - Bus A	
always #1
begin
	case(rf_int_cpsr[4:0])
	`MODE_USER	:
	begin
		case (RF_Addr_A)
		`R0	:	RF_Bus_A <= rf_int_r0;
		`R1	:	RF_Bus_A <= rf_int_r1;
		`R2	:	RF_Bus_A <= rf_int_r2;
		`R3	:	RF_Bus_A <= rf_int_r3;
		`R4	:	RF_Bus_A <= rf_int_r4;
		`R5	:	RF_Bus_A <= rf_int_r5;
		`R6	:	RF_Bus_A <= rf_int_r6;
		`R7	:	RF_Bus_A <= rf_int_r7;
		`R8	:	RF_Bus_A <= rf_int_r8;
		`R9	:	RF_Bus_A <= rf_int_r9;
		`R10	:	RF_Bus_A <= rf_int_r10;
		`R11	:	RF_Bus_A <= rf_int_r11;
		`R12	:	RF_Bus_A <= rf_int_r12;
		`R13	:	RF_Bus_A <= rf_int_r13;
		`R14	:	RF_Bus_A <= rf_int_r14;
		`R15	:	RF_Bus_A <= rf_int_r15;
		default	:	begin end
		endcase
	end
	`MODE_FIQ	:
	begin
		case (RF_Addr_A)
		`R0	:	RF_Bus_A <= rf_int_r0;
		`R1	:	RF_Bus_A <= rf_int_r1;
		`R2	:	RF_Bus_A <= rf_int_r2;
		`R3	:	RF_Bus_A <= rf_int_r3;
		`R4	:	RF_Bus_A <= rf_int_r4;
		`R5	:	RF_Bus_A <= rf_int_r5;
		`R6	:	RF_Bus_A <= rf_int_r6;
		`R7	:	RF_Bus_A <= rf_int_r7;
		`R8	:	RF_Bus_A <= rf_int_r8_fiq;
		`R9	:	RF_Bus_A <= rf_int_r9_fiq;
		`R10	:	RF_Bus_A <= rf_int_r10_fiq;
		`R11	:	RF_Bus_A <= rf_int_r11_fiq;
		`R12	:	RF_Bus_A <= rf_int_r12_fiq;
		`R13	:	RF_Bus_A <= rf_int_r13_fiq;
		`R14	:	RF_Bus_A <= rf_int_r14_fiq;
		`R15	:	RF_Bus_A <= rf_int_r15;
		default	:	begin end
		endcase
	end
	`MODE_IRQ	:
	begin
		case (RF_Addr_A)
		`R0	:	RF_Bus_A <= rf_int_r0;
		`R1	:	RF_Bus_A <= rf_int_r1;
		`R2	:	RF_Bus_A <= rf_int_r2;
		`R3	:	RF_Bus_A <= rf_int_r3;
		`R4	:	RF_Bus_A <= rf_int_r4;
		`R5	:	RF_Bus_A <= rf_int_r5;
		`R6	:	RF_Bus_A <= rf_int_r6;
		`R7	:	RF_Bus_A <= rf_int_r7;
		`R8	:	RF_Bus_A <= rf_int_r8;
		`R9	:	RF_Bus_A <= rf_int_r9;
		`R10	:	RF_Bus_A <= rf_int_r10;
		`R11	:	RF_Bus_A <= rf_int_r11;
		`R12	:	RF_Bus_A <= rf_int_r12;
		`R13	:	RF_Bus_A <= rf_int_r13_irq;
		`R14	:	RF_Bus_A <= rf_int_r14_irq;
		`R15	:	RF_Bus_A <= rf_int_r15;
		default	:	begin end
		endcase
	end
	`MODE_SUP	:
	begin
		case (RF_Addr_A)
		`R0	:	RF_Bus_A <= rf_int_r0;
		`R1	:	RF_Bus_A <= rf_int_r1;
		`R2	:	RF_Bus_A <= rf_int_r2;
		`R3	:	RF_Bus_A <= rf_int_r3;
		`R4	:	RF_Bus_A <= rf_int_r4;
		`R5	:	RF_Bus_A <= rf_int_r5;
		`R6	:	RF_Bus_A <= rf_int_r6;
		`R7	:	RF_Bus_A <= rf_int_r7;
		`R8	:	RF_Bus_A <= rf_int_r8;
		`R9	:	RF_Bus_A <= rf_int_r9;
		`R10	:	RF_Bus_A <= rf_int_r10;
		`R11	:	RF_Bus_A <= rf_int_r11;
		`R12	:	RF_Bus_A <= rf_int_r12;
		`R13	:	RF_Bus_A <= rf_int_r13_svc;
		`R14	:	RF_Bus_A <= rf_int_r14_svc;
		`R15	:	RF_Bus_A <= rf_int_r15;
		default	:	begin end
		endcase
	end
	`MODE_ABT	:
	begin
		case (RF_Addr_A)
		`R0	:	RF_Bus_A <= rf_int_r0;
		`R1	:	RF_Bus_A <= rf_int_r1;
		`R2	:	RF_Bus_A <= rf_int_r2;
		`R3	:	RF_Bus_A <= rf_int_r3;
		`R4	:	RF_Bus_A <= rf_int_r4;
		`R5	:	RF_Bus_A <= rf_int_r5;
		`R6	:	RF_Bus_A <= rf_int_r6;
		`R7	:	RF_Bus_A <= rf_int_r7;
		`R8	:	RF_Bus_A <= rf_int_r8;
		`R9	:	RF_Bus_A <= rf_int_r9;
		`R10	:	RF_Bus_A <= rf_int_r10;
		`R11	:	RF_Bus_A <= rf_int_r11;
		`R12	:	RF_Bus_A <= rf_int_r12;
		`R13	:	RF_Bus_A <= rf_int_r13_abt;
		`R14	:	RF_Bus_A <= rf_int_r14_abt;
		`R15	:	RF_Bus_A <= rf_int_r15;
		default	:	begin end
		endcase
	end
	`MODE_UNDF	:
	begin
		case (RF_Addr_A)
		`R0	:	RF_Bus_A <= rf_int_r0;
		`R1	:	RF_Bus_A <= rf_int_r1;
		`R2	:	RF_Bus_A <= rf_int_r2;
		`R3	:	RF_Bus_A <= rf_int_r3;
		`R4	:	RF_Bus_A <= rf_int_r4;
		`R5	:	RF_Bus_A <= rf_int_r5;
		`R6	:	RF_Bus_A <= rf_int_r6;
		`R7	:	RF_Bus_A <= rf_int_r7;
		`R8	:	RF_Bus_A <= rf_int_r8;
		`R9	:	RF_Bus_A <= rf_int_r9;
		`R10	:	RF_Bus_A <= rf_int_r10;
		`R11	:	RF_Bus_A <= rf_int_r11;
		`R12	:	RF_Bus_A <= rf_int_r12;
		`R13	:	RF_Bus_A <= rf_int_r13_und;
		`R14	:	RF_Bus_A <= rf_int_r14_und;
		`R15	:	RF_Bus_A <= rf_int_r15;
		default	:	begin end
		endcase
	end
	default	:	RF_Bus_A <= 32'bX;
	endcase
end

//	Register Reading - Bus B	
always #1
begin
	case (rf_int_cpsr[4:0])
	`MODE_USER 	:
	begin
		case (RF_Addr_B)
		`R0	:	RF_Bus_B <= rf_int_r0;
		`R1	:	RF_Bus_B <= rf_int_r1;
		`R2	:	RF_Bus_B <= rf_int_r2;
		`R3	:	RF_Bus_B <= rf_int_r3;
		`R4	:	RF_Bus_B <= rf_int_r4;
		`R5	:	RF_Bus_B <= rf_int_r5;
		`R6	:	RF_Bus_B <= rf_int_r6;
		`R7	:	RF_Bus_B <= rf_int_r7;
		`R8	:	RF_Bus_B <= rf_int_r8;
		`R9	:	RF_Bus_B <= rf_int_r9;
		`R10	:	RF_Bus_B <= rf_int_r10;
		`R11	:	RF_Bus_B <= rf_int_r11;
		`R12	:	RF_Bus_B <= rf_int_r12;
		`R13	:	RF_Bus_B <= rf_int_r13;
		`R14	:	RF_Bus_B <= rf_int_r14;
		`R15	:	RF_Bus_B <= rf_int_r15;
		default	:	RF_Bus_B <= 32'bX;
		endcase
	end
	`MODE_FIQ 	:
	begin
		case (RF_Addr_B)
		`R0	:	RF_Bus_B <= rf_int_r0;
		`R1	:	RF_Bus_B <= rf_int_r1;
		`R2	:	RF_Bus_B <= rf_int_r2;
		`R3	:	RF_Bus_B <= rf_int_r3;
		`R4	:	RF_Bus_B <= rf_int_r4;
		`R5	:	RF_Bus_B <= rf_int_r5;
		`R6	:	RF_Bus_B <= rf_int_r6;
		`R7	:	RF_Bus_B <= rf_int_r7;
		`R8	:	RF_Bus_B <= rf_int_r8_fiq;
		`R9	:	RF_Bus_B <= rf_int_r9_fiq;
		`R10	:	RF_Bus_B <= rf_int_r10_fiq;
		`R11	:	RF_Bus_B <= rf_int_r11_fiq;
		`R12	:	RF_Bus_B <= rf_int_r12_fiq;
		`R13	:	RF_Bus_B <= rf_int_r13_fiq;
		`R14	:	RF_Bus_B <= rf_int_r14_fiq;
		`R15	:	RF_Bus_B <= rf_int_r15;
		default	:	RF_Bus_B <= 32'bX;
		endcase
	end
	`MODE_IRQ	:
	begin
		case (RF_Addr_B)
		`R0	:	RF_Bus_B <= rf_int_r0;
		`R1	:	RF_Bus_B <= rf_int_r1;
		`R2	:	RF_Bus_B <= rf_int_r2;
		`R3	:	RF_Bus_B <= rf_int_r3;
		`R4	:	RF_Bus_B <= rf_int_r4;
		`R5	:	RF_Bus_B <= rf_int_r5;
		`R6	:	RF_Bus_B <= rf_int_r6;
		`R7	:	RF_Bus_B <= rf_int_r7;
		`R8	:	RF_Bus_B <= rf_int_r8;
		`R9	:	RF_Bus_B <= rf_int_r9;
		`R10	:	RF_Bus_B <= rf_int_r10;
		`R11	:	RF_Bus_B <= rf_int_r11;
		`R12	:	RF_Bus_B <= rf_int_r12;
		`R13	:	RF_Bus_B <= rf_int_r13_irq;
		`R14	:	RF_Bus_B <= rf_int_r14_irq;
		`R15	:	RF_Bus_B <= rf_int_r15;
		default	:	RF_Bus_B <= 32'bX;
		endcase
	end
	`MODE_SUP	:
	begin
		case (RF_Addr_B)
		`R0	:	RF_Bus_B <= rf_int_r0;
		`R1	:	RF_Bus_B <= rf_int_r1;
		`R2	:	RF_Bus_B <= rf_int_r2;
		`R3	:	RF_Bus_B <= rf_int_r3;
		`R4	:	RF_Bus_B <= rf_int_r4;
		`R5	:	RF_Bus_B <= rf_int_r5;
		`R6	:	RF_Bus_B <= rf_int_r6;
		`R7	:	RF_Bus_B <= rf_int_r7;
		`R8	:	RF_Bus_B <= rf_int_r8;
		`R9	:	RF_Bus_B <= rf_int_r9;
		`R10	:	RF_Bus_B <= rf_int_r10;
		`R11	:	RF_Bus_B <= rf_int_r11;
		`R12	:	RF_Bus_B <= rf_int_r12;
		`R13	:	RF_Bus_B <= rf_int_r13_svc;
		`R14	:	RF_Bus_B <= rf_int_r14_svc;
		`R15	:	RF_Bus_B <= rf_int_r15;
		default	:	RF_Bus_B <= 32'bX;
		endcase
	end
	`MODE_ABT	:
	begin
		case (RF_Addr_B)
		`R0	:	RF_Bus_B <= rf_int_r0;
		`R1	:	RF_Bus_B <= rf_int_r1;
		`R2	:	RF_Bus_B <= rf_int_r2;
		`R3	:	RF_Bus_B <= rf_int_r3;
		`R4	:	RF_Bus_B <= rf_int_r4;
		`R5	:	RF_Bus_B <= rf_int_r5;
		`R6	:	RF_Bus_B <= rf_int_r6;
		`R7	:	RF_Bus_B <= rf_int_r7;
		`R8	:	RF_Bus_B <= rf_int_r8;
		`R9	:	RF_Bus_B <= rf_int_r9;
		`R10	:	RF_Bus_B <= rf_int_r10;
		`R11	:	RF_Bus_B <= rf_int_r11;
		`R12	:	RF_Bus_B <= rf_int_r12;
		`R13	:	RF_Bus_B <= rf_int_r13_abt;
		`R14	:	RF_Bus_B <= rf_int_r14_abt;
		`R15	:	RF_Bus_B <= rf_int_r15;
		default	:	RF_Bus_B <= 32'bX;
		endcase
	end
	`MODE_UNDF	:
	begin
		case (RF_Addr_B)
		`R0	:	RF_Bus_B <= rf_int_r0;
		`R1	:	RF_Bus_B <= rf_int_r1;
		`R2	:	RF_Bus_B <= rf_int_r2;
		`R3	:	RF_Bus_B <= rf_int_r3;
		`R4	:	RF_Bus_B <= rf_int_r4;
		`R5	:	RF_Bus_B <= rf_int_r5;
		`R6	:	RF_Bus_B <= rf_int_r6;
		`R7	:	RF_Bus_B <= rf_int_r7;
		`R8	:	RF_Bus_B <= rf_int_r8;
		`R9	:	RF_Bus_B <= rf_int_r9;
		`R10	:	RF_Bus_B <= rf_int_r10;
		`R11	:	RF_Bus_B <= rf_int_r11;
		`R12	:	RF_Bus_B <= rf_int_r12;
		`R13	:	RF_Bus_B <= rf_int_r13_und;
		`R14	:	RF_Bus_B <= rf_int_r14_und;
		`R15	:	RF_Bus_B <= rf_int_r15;
		default	:	RF_Bus_B <= 32'bX;
		endcase
	end
	default	:	RF_Bus_B <= 32'bX;
	endcase
end

//	Register Reading - Bus C
always #1
begin
	case (rf_int_cpsr[4:0])
	`MODE_USER	:
	begin
		case (RF_Addr_C)
		`R0	:	RF_Bus_C <= rf_int_r0;
		`R1	:	RF_Bus_C <= rf_int_r1;
		`R2	:	RF_Bus_C <= rf_int_r2;
		`R3	:	RF_Bus_C <= rf_int_r3;
		`R4	:	RF_Bus_C <= rf_int_r4;
		`R5	:	RF_Bus_C <= rf_int_r5;
		`R6	:	RF_Bus_C <= rf_int_r6;
		`R7	:	RF_Bus_C <= rf_int_r7;
		`R8	:	RF_Bus_C <= rf_int_r8;
		`R9	:	RF_Bus_C <= rf_int_r9;
		`R10	:	RF_Bus_C <= rf_int_r10;
		`R11	:	RF_Bus_C <= rf_int_r11;
		`R12	:	RF_Bus_C <= rf_int_r12;
		`R13	:	RF_Bus_C <= rf_int_r13;
		`R14	:	RF_Bus_C <= rf_int_r14;
		`R15	:	RF_Bus_C <= rf_int_r15;
		default	:	RF_Bus_C <= 32'bX;
		endcase
	end
	`MODE_FIQ	:
	begin
		case (RF_Addr_C)
		`R0	:	RF_Bus_C <= rf_int_r0;
		`R1	:	RF_Bus_C <= rf_int_r1;
		`R2	:	RF_Bus_C <= rf_int_r2;
		`R3	:	RF_Bus_C <= rf_int_r3;
		`R4	:	RF_Bus_C <= rf_int_r4;
		`R5	:	RF_Bus_C <= rf_int_r5;
		`R6	:	RF_Bus_C <= rf_int_r6;
		`R7	:	RF_Bus_C <= rf_int_r7;
		`R8	:	RF_Bus_C <= rf_int_r8_fiq;
		`R9	:	RF_Bus_C <= rf_int_r9_fiq;
		`R10	:	RF_Bus_C <= rf_int_r10_fiq;
		`R11	:	RF_Bus_C <= rf_int_r11_fiq;
		`R12	:	RF_Bus_C <= rf_int_r12_fiq;
		`R13	:	RF_Bus_C <= rf_int_r13_fiq;
		`R14	:	RF_Bus_C <= rf_int_r14_fiq;
		`R15	:	RF_Bus_C <= rf_int_r15;
		default	:	RF_Bus_C <= 32'bX;
		endcase
	end
	`MODE_IRQ	:
	begin
		case (RF_Addr_C)
		`R0	:	RF_Bus_C <= rf_int_r0;
		`R1	:	RF_Bus_C <= rf_int_r1;
		`R2	:	RF_Bus_C <= rf_int_r2;
		`R3	:	RF_Bus_C <= rf_int_r3;
		`R4	:	RF_Bus_C <= rf_int_r4;
		`R5	:	RF_Bus_C <= rf_int_r5;
		`R6	:	RF_Bus_C <= rf_int_r6;
		`R7	:	RF_Bus_C <= rf_int_r7;
		`R8	:	RF_Bus_C <= rf_int_r8;
		`R9	:	RF_Bus_C <= rf_int_r9;
		`R10	:	RF_Bus_C <= rf_int_r10;
		`R11	:	RF_Bus_C <= rf_int_r11;
		`R12	:	RF_Bus_C <= rf_int_r12;
		`R13	:	RF_Bus_C <= rf_int_r13_irq;
		`R14	:	RF_Bus_C <= rf_int_r14_irq;
		`R15	:	RF_Bus_C <= rf_int_r15;
		default	:	RF_Bus_C <= 32'bX;
		endcase
	end
	`MODE_SUP	:
	begin
		case (RF_Addr_C)
		`R0	:	RF_Bus_C <= rf_int_r0;
		`R1	:	RF_Bus_C <= rf_int_r1;
		`R2	:	RF_Bus_C <= rf_int_r2;
		`R3	:	RF_Bus_C <= rf_int_r3;
		`R4	:	RF_Bus_C <= rf_int_r4;
		`R5	:	RF_Bus_C <= rf_int_r5;
		`R6	:	RF_Bus_C <= rf_int_r6;
		`R7	:	RF_Bus_C <= rf_int_r7;
		`R8	:	RF_Bus_C <= rf_int_r8;
		`R9	:	RF_Bus_C <= rf_int_r9;
		`R10	:	RF_Bus_C <= rf_int_r10;
		`R11	:	RF_Bus_C <= rf_int_r11;
		`R12	:	RF_Bus_C <= rf_int_r12;
		`R13	:	RF_Bus_C <= rf_int_r13_svc;
		`R14	:	RF_Bus_C <= rf_int_r14_svc;
		`R15	:	RF_Bus_C <= rf_int_r15;
		default	:	RF_Bus_C <= 32'bX;
		endcase
	end
	`MODE_ABT	:
	begin
		case (RF_Addr_C)
		`R0	:	RF_Bus_C <= rf_int_r0;
		`R1	:	RF_Bus_C <= rf_int_r1;
		`R2	:	RF_Bus_C <= rf_int_r2;
		`R3	:	RF_Bus_C <= rf_int_r3;
		`R4	:	RF_Bus_C <= rf_int_r4;
		`R5	:	RF_Bus_C <= rf_int_r5;
		`R6	:	RF_Bus_C <= rf_int_r6;
		`R7	:	RF_Bus_C <= rf_int_r7;
		`R8	:	RF_Bus_C <= rf_int_r8;
		`R9	:	RF_Bus_C <= rf_int_r9;
		`R10	:	RF_Bus_C <= rf_int_r10;
		`R11	:	RF_Bus_C <= rf_int_r11;
		`R12	:	RF_Bus_C <= rf_int_r12;
		`R13	:	RF_Bus_C <= rf_int_r13_abt;
		`R14	:	RF_Bus_C <= rf_int_r14_abt;
		`R15	:	RF_Bus_C <= rf_int_r15;
		default	:	RF_Bus_C <= 32'bX;
		endcase
	end
	`MODE_UNDF	:
	begin
		case (RF_Addr_C)
		`R0	:	RF_Bus_C <= rf_int_r0;
		`R1	:	RF_Bus_C <= rf_int_r1;
		`R2	:	RF_Bus_C <= rf_int_r2;
		`R3	:	RF_Bus_C <= rf_int_r3;
		`R4	:	RF_Bus_C <= rf_int_r4;
		`R5	:	RF_Bus_C <= rf_int_r5;
		`R6	:	RF_Bus_C <= rf_int_r6;
		`R7	:	RF_Bus_C <= rf_int_r7;
		`R8	:	RF_Bus_C <= rf_int_r8;
		`R9	:	RF_Bus_C <= rf_int_r9;
		`R10	:	RF_Bus_C <= rf_int_r10;
		`R11	:	RF_Bus_C <= rf_int_r11;
		`R12	:	RF_Bus_C <= rf_int_r12;
		`R13	:	RF_Bus_C <= rf_int_r13_und;
		`R14	:	RF_Bus_C <= rf_int_r14_und;
		`R15	:	RF_Bus_C <= rf_int_r15;
		default	:	RF_Bus_C <= 32'bX;
		endcase
	end
	default	:	RF_Bus_C <= 32'bX;
	endcase
end

endmodule
