; 1.1.2.3:1.1.2.2
;
; The AREA must have the attribute READONLY, otherwise the linker will not
; place it in ROM.
;
; The AREA must have the attribute CODE, otherwise the assembler will not
; let us put any code in this AREA
;
; Note the '|' character is used to surround any symbols which contain
; non standard characters like '!'.


                AREA    Init, CODE, READONLY


; Now some standard definitions...
Mode_USR        EQU     0x10
Mode_FIQ        EQU     0x11
Mode_IRQ        EQU     0x12
Mode_SVC        EQU     0x13
Mode_ABT        EQU     0x17

I_Bit           EQU     0x80
F_Bit           EQU     0x40

DoneHiVecsCopy  DCD     0

; Locations of various things in our memory system

RAM_Base        EQU     0x10000000      ; 64k RAM at this base
RAM_Limit       EQU     0x10010000
IRQ_Stack       EQU     RAM_Limit-256   ; 1K IRQ stack at top of memory
SVC_Stack       EQU     RAM_Limit-1024  ; followed by SVC stack
USR_Stack       EQU     SVC_Stack-1024  ; followed by USR stack
FIQ_Stack       EQU     USR_Stack-1024  ; followed by FIQ stack
ABT_Stack       EQU     FIQ_Stack-1024  ; followed by Abort stack

; --- Define entry point
        EXPORT  __main  ; defined to ensure that C runtime system
__main                          ; is not linked in
        ENTRY
        

; --- Setup interrupt / exception vectors
    IF :DEF: ROM_AT_ADDRESS_ZERO
; If the ROM is at address 0 this is just a sequence of branches
        B       Reset_Handler
        B       UNDEFHandler
        B       SWIHandler
        B       IABORTHandler
        B       DABORTHandler
        NOP             ; Reserved vector
        B       IRQHandler
        B       FIQHandler
    ELSE
; Otherwise we copy a sequence of LDR PC instructions over the vectors
; (Note: We copy LDR PC instructions because branch instructions
; could not simply be copied, the offset in the branch instruction
; would have to be modified so that it branched into ROM. Also, a
; branch instructions might not reach if the ROM is at an address
; > 32M).
        MOV     R8, #0
        ADR     R9, Vector_Init_Block
        LDMIA   R9!, {R0-R7}
        STMIA   R8!, {R0-R7}
        LDMIA   R9!, {R0-R7}
        STMIA   R8!, {R0-R7}

; Now fall into the LDR PC, Reset_Addr instruction which will continue
; execution at 'Reset_Handler'

Vector_Init_Block
       LDR     PC, Reset_Addr
        LDR     PC, Undefined_Addr
        LDR     PC, SWI_Addr
        LDR     PC, Prefetch_Addr
        LDR     PC, Abort_Addr
        NOP
        LDR     PC, IRQ_Addr
        LDR     PC, FIQ_Addr

Reset_Addr      DCD     Reset_Handler
Undefined_Addr  DCD     UNDEFHandler
SWI_Addr        DCD     SWIHandler
Prefetch_Addr   DCD     IABORTHandler
Abort_Addr      DCD     DABORTHandler
                DCD     0       ; Reserved vector
IRQ_Addr        DCD     IRQHandler
FIQ_Addr        DCD     FIQHandler
    ENDIF

    IMPORT UNDEFHandler
    IMPORT SWIHandler
    IMPORT IABORTHandler
    IMPORT DABORTHandler
    IMPORT IRQHandler
    IMPORT FIQHandler

; The RESET entry point
Reset_Handler

; --- Initialise stack pointer registers
; Enter IRQ mode and set up the IRQ stack pointer
        MOV     R0, #Mode_IRQ:OR:I_Bit:OR:F_Bit ; No interrupts
        MSR     CPSR_c, R0
        LDR     R13, =IRQ_Stack
        LDR     SP, =IRQ_Stack

; Enter FIQ mode and set up the FIQ stack pointer
        MOV     R0, #Mode_FIQ:OR:I_Bit:OR:F_Bit ; No interrupts
        MSR     CPSR_c, R0
        LDR     R13, =FIQ_Stack
        LDR     SP, =FIQ_Stack

; Enter ABT mode and set up the ABT stack pointer
        MOV     R0, #Mode_ABT:OR:I_Bit:OR:F_Bit ; No interrupts
        MSR     CPSR_c, R0
        LDR     R13, =ABT_Stack
        LDR     SP, =ABT_Stack

; Set up other stack pointers if necessary
        ; ...

; Set up the SVC stack pointer last and return to SVC mode
        MOV     R0, #Mode_SVC:OR:I_Bit:OR:F_Bit ; No interrupts
        MSR     CPSR_c, R0
        LDR     R13, =SVC_Stack
        LDR     SP, =SVC_Stack

; --- Initialise memory system
;     Only initialize I-Cache.  D-Cache can only be enabled
;     when the MPU/MCU is enabled
    MRC p15, 0, r4, c1, c0, 0
    MOV r2,#1                   ; Enable I-Cache (b12) only 
    MOV r2,r2, LSL #12        
    ORR r2, r2, r4                    
    MCR p15, 0, r2, c1, c0, 0
    IF :DEF: BIGEND    ; ... big endian
       MRC p15, 0, r14, c1, c0, 0
       MOV r2,#0x80
       ORR R14,R2,#0
       MCR p15, 0, r14, c1, c0, 0
    ENDIF

; --- Initialise critical IO devices
        ; ...

; --- Initialise interrupt system variables here
        ; ...

; --- Enable interrupts
; Now safe to enable interrupts, so do this and remain in SVC mode
        MOV     R0, #Mode_SVC:OR:F_Bit  ; Only IRQ enabled
        MSR     CPSR_c, R0

; --- Initialise memory required by C code

        IMPORT  |Image$$RO$$Limit|      ; End of ROM code (=start of ROM data)
        IMPORT  |Image$$RW$$Base|       ; Base of RAM to initialise
        IMPORT  |Image$$ZI$$Base|       ; Base and limit of area
        IMPORT  |Image$$ZI$$Limit|      ; to zero initialise

        LDR     r0, =|Image$$RO$$Limit| ; Get pointer to ROM data
        LDR     r1, =|Image$$RW$$Base|  ; and RAM copy
        LDR     r3, =|Image$$ZI$$Base|  ; Zero init base => top of initialised data
        CMP     r0, r1                  ; Check that they are different
        BEQ     %F1
0       CMP     r1, r3                  ; Copy init data
        LDRCC   r2, [r0], #4
        STRCC   r2, [r1], #4
        BCC     %B0
1       LDR     r1, =|Image$$ZI$$Limit| ; Top of zero init segment
        MOV     r2, #0
2       CMP     r3, r1                  ; Zero init
        STRCC   r2, [r3], #4
        BCC     %B2


;; Turn on DTCM - For 946
        MOV     r0, #0x06                       ; Size 64kB
        ORR     r0, r0, #0x00020000             ; DTCM base
        MCR     p15, 0, r0, c9, c1, 0           ; Set DTCM area/size
        MRC     p15, 0, r1, c1, c0, 0           ; Read control register
        ORR     r1, r1, #0x0010000              ; DTCM enable
        MCR     p15, 0, r1, c1, c0, 0           ; Set D-RAM mode

;; Turn on ITCM - For 946
;; Will not use, as code starts fetching from ITCM as soon it gets enabled.
;; There is no code loaded in the ITCM. Left here for example
;;      MOV     r0, #0x06                       ; Size 64kB
;;      ORR     r0, r0, #0xf0000000             ; ITCM base
;;      MCR     p15, 0, r0, c9, c1, 1           ; Set DTCM area/size
;;      MRC     p15, 0, r3, c1, c0, 0           ; Read control register
;;      ORR     r3, r3, #0x00040000             ; ITCM Enable
;;      MCR     p15, 0, r3, c1, c0, 0           ; Set ITCM mode



; --- Now change to user mode and set up user mode stack.
        MOV     R0, #Mode_USR
        MSR     CPSR_c, R0
        LDR     sp, =USR_Stack


Switch2TCM    


        IMPORT  main
    [ :DEF:THUMB
                ORR     lr, pc, #1
                BX      lr
                CODE16                          ; Next instruction will be Thumb
    ]
        BL      main
; In a real application we wouldn't normally expect to return, however
; in case we do the debug monitor swi is used to halt the application.
       ; MOV     r0, #0x18           ; angel_SWIreason_ReportException
       ; LDR     r1, =0x20026        ; ADP_Stopped_ApplicationExit
       ; [ :DEF: THUMB
       ;         SWI 0xAB                    ; Angel semihosting Thumb SWI
       ; |
       ;         SWI     0x123456            ; Angel semihosting ARM SWI
       ; ]
alldone
        BL      alldone
        END

        END
