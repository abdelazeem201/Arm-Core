;; ARMulator configuration file type 3
;; - peripherals.dsc -
;; Copyright (c) 1996-2001 ARM Limited. All Rights Reserved.

;; RCS $Revision$
;; Checkin $Date$
;; Revising $Author$

;;
;; This is a non-user-edittable configuration file for ARMulator (ADS1.2)
;;

{ Peripherals

  { Trickbox
    MODEL_DLL_FILENAME=Trickbox
    META_GUI_INTERFACE=Trickbox
    NewTrickBox=1

    ;TrickBoxBaseAddress=0x3100000
    ;TrickBoxTubeAddress=0x3000000
    ;TrickBoxSWIAccAddress=0x3000060
    TrickBoxLowAbortAddress=0x03000040
    TrickBoxHighAbortAddress=0x03000044
    TrickBoxSingleAbortAddress=0x03000064
    ;[for 9EJ]TrickBoxSingleAbortAddress=0x3100008

    ;TrickBoxSingleAbortDefault=0x00600000
    TrickBoxSingleAbortDefault=0x50000020
    ;Not used yet.
    ;TrickBoxLowAbortDefault=0x00700000 or 0x40000000
    ;TrickBoxHighAbortDefault=0x01f00000 or 0x4fffffff
  }
  { No_Trickbox=Nothing
    META_GUI_INTERFACE=Trickbox
  }

  { Tracer
    ;VERBOSE=True
    MODEL_DLL_FILENAME=Tracer
    META_GUI_INTERFACE=Tracer
    ;; Output options - can be plaintext to file, binary to file or to RDI log
    ;; window. (Checked in the order RDILog, File, BinFile.)
    RDILog=False
    File=armul.trc
    BinFile=armul.trc
    Unbuffered=False
    ;; Tracer options - what to trace
    TraceInstructions=True
    TraceOpcodeFetch=True
    TraceRegisters=False
    TraceMemory=True
    ;; WARNING ARMISS doesn't support TraceIdle or TraceNonAccounted.
    TraceIdle=False
    TraceNonAccounted=False
    TraceEvents=False
    TimeStamp=False
    ;; Where to trace memory - if not set, it will trace at the core.
    ;; WARNING - only core tracing is supported in ARMISS.
    TraceBus=False
    ;; Flags - disassemble instructions; start up with tracing enabled;
    Disassemble=False
    StartOn=False
  }
  { No_Tracer=Nothing
    META_GUI_INTERFACE=Tracer
  }

  { WatchDog
    MODEL_DLL_FILENAME=Watchdog
    META_GUI_INTERFACE=WatchDog
    Waits=0
    Range:Base=0xb0000000
    KeyValue=0x12345678
    WatchPeriod=0x80000
    IRQPeriod=3000
    IntNumber=16
    StartOnReset=True
    RunAfterBark=True
  }
  { No_WatchDog=Nothing
    META_GUI_INTERFACE=WatchDog
  }

  { Profiler
    MODEL_DLL_FILENAME=Profiler
    META_GUI_INTERFACE=Profiler
    ;; For example - to profile the PC value when cache misses happen, set:
    ;Type=Event
    ;Event=0x00010001
    ;EventWord=pc
    Type=Cycle
  }
  { No_Profiler=Nothing
    META_GUI_INTERFACE=Profiler
  }

  ;; Debug comms channel model checks if it's on a processor with ICE
  ;; The "Rate" parameter governs how often it tries to give data back
  ;; to the debugger, so models the real latency of a JTAG-based system.
  { DebugComms
    MODEL_DLL_FILENAME=Dcc
    META_GUI_INTERFACE=Dcc
    Rate=76
    ReadDelay=38
    WriteDelay=108
    MCCfg=15
    ; Whether RX and TX are wired up to IRQ/interrupt controller
    IRQOnCommsChannel=False
    ; Interrupt priorities when using an interrupt controller
    CommRXIRQNo=2
    CommTXIRQNo=3
    meta_moduleserver_component=DCC_CP14
  }
  { No_DebugComms=Nothing
    META_GUI_INTERFACE=Dcc
  }

  ;; The StackUse model continually monitors the stack pointer and
  ;; reports the amount of stack used in $statistics. It needs to be
  ;; configured with the stack's location.
  { StackUse
    MODEL_DLL_FILENAME=Stackuse
    META_GUI_INTERFACE=Stackuse
    StackBase=0x80000000
    StackLimit=0x70000000
  }
  { No_StackUse=Nothing
    META_GUI_INTERFACE=Stackuse
  }

  { Validate
    MODEL_DLL_FILENAME=Validate
    META_GUI_INTERFACE=ValidateCP
  }
  { No_Validate=Nothing
    META_GUI_INTERFACE=ValidateCP
  }

  { Semihost
    MODEL_DLL_FILENAME=Semihost
    META_GUI_INTERFACE=Semihost
    ANGEL=True
    AngelSWIARM=0x123456
    AngelSWIThumb=0xab
    ; If TRUE, we halt when an Angel SWI is called with
    ; an unimplemented code in R0 - otherwise we just return -1.
    HaltOnUnknownSysNumber=False
    ; Demon is only needed for validation.
    DEMON=False
    ; Swi's 0x80 .. 0x9F are needed for Demon, so DEMON=True overrides
    ; EXIT_SWIS=False.
    EXIT_SWIS=False
    ; And the default memory map
    HeapBase=0x00000000
    HeapLimit=0x07000000
    StackBase=0x08000000
    StackLimit=0x07000000

    ;; Demon configuration

    ;; Configure the locations of stacks, etc.
    AddrSuperStack=0xa00
    AddrAbortStack=0x800
    AddrUndefStack=0x700
    AddrIRQStack=0x500
    AddrFIQStack=0x400

    ;; The default location of the user mode stack
    AddrUserStack=0x80000

    ;; Start of the "soft vector" code
    AddrSoftVectors=0xa40

    ;; Where to place a copy of the command line
    AddrCmdLine=0xf00

    ;; Address and workspace for installed handlers
    AddrsOfHandlers=0xad0

    ;; Default handlers
    SoftVectorCode=0xb80
  }
  { No_Semihost=Nothing
    META_GUI_INTERFACE=Semihost
  }

  { Timer
    MODEL_DLL_FILENAME=Timer
    META_GUI_INTERFACE=Timer
    ;Range=0x0a800000,0x0a80003f
    Waits=0
    Range:Base=0x0a800000
    CLK=20000000
    ;; You MUST supply the MCCFG value for the processor
    TicMCCfg=2
    ;; Interrupt controller source bits - 4 and 5 as standard
    IntOne=4
    IntTwo=5
    ;meta_moduleserver_component=RPS_Timer
  }
  { No_Timer=Nothing
    META_GUI_INTERFACE=Timer
  }

  { IntCtrl
    MODEL_DLL_FILENAME=Intc
    META_GUI_INTERFACE=Intc
    ;Range=0x0a000000,0x0a00010c
    Waits=0
    Range:Base=0x0a000000
    ;meta_moduleserver_component=RPS_Interrupt_Controller
  }
  { No_IntCtrl=Nothing
    META_GUI_INTERFACE=Intc
  }

  { Millisec
    MODEL_DLL_FILENAME=Millisec
    META_GUI_INTERFACE=Millisec
    Range:Base=0x0bfffff0
  }
  { No_Millisec=Nothing
    META_GUI_INTERFACE=Millisec
  }

  { Nothing
    MODEL_DLL_FILENAME=Nothing
  }

  { Tube
    MODEL_DLL_FILENAME=Tube
    META_GUI_INTERFACE=Tube
    ;Range=0x0d800020,0x0d800023
    ;-obs-Range=0x03000000,0x03000004
    Range:Base=0x0d800020
  }
  { No_Tube=Nothing
    META_GUI_INTERFACE=Tube
  }

  { RDIMSVR
    MODEL_DLL_FILENAME=rdimsvr
    target_controller_type=armulate
  }

  ; This is really armmap.
  { Bus
    MODEL_DLL_FILENAME=Bus
  }

  ; These are default values. Don't edit this file!
  ; Edit peripherals.ami to change pagetable setting

  { Pagetables
    MODEL_DLL_FILENAME=Pagetab
    META_GUI_INTERFACE=Pagetab
    ; The GUI should not offer this - the user is expected to
    ; prefer their settings in Default_Pagetables.
    META_CONFIG_ABSTRACT
    ;
    MMU=No
    AlignFaults=No
    Cache=Yes
    WriteBuffer=Yes
    Prog32=Yes
    Data32=Yes
    LateAbort=Yes
    ;; The following is set to the default setting of the processor core
    ;; (which is controlled from the command-line or configuration window).
    ;; Only uncomment if you wish to override that setting.
    ;BigEnd=
    BranchPredict=Yes
    ICache=Yes
    HighExceptionVectors=No

    PageTableBase=0xa0000000
    DAC=0x00000001

    ;; Used by the 940 to control the clock mode. Use this flag
    ;; to configure the clock mode for the processor. If FastBus is enabled
    ;; fast bus mode will be used otherwise synchronous mode is used.
 
    FastBus=No
    ; Don't turn these on until you have read an ARM966 manual, to avoid confusion.
    ; Normally you need code to initialise the contents of IRAM and DRAM.
    IRAM=No
    DRAM=No

    { Region[0]
      VirtualBase=0
      PhysicalBase=0
      Size=4GB
      Cacheable=Yes
      Bufferable=Yes
      Updateable=Yes
      Domain=0
      AccessPermissions=3
      Translate=Yes
    }
  }
  { No_Pagetables=Nothing
    META_GUI_INTERFACE=Pagetab
  }

  { Mapfile
    META_GUI_INTERFACE=Mapfile
    MODEL_DLL_FILENAME=Mapfile
    CountWaitStates=False
    AMBABusCounts=False
    ;SpotISCycles=True|False
    SpotISCycles=False
    ;ISTiming=Late|Early|Speculative
    ISTiming=Late
  }
  { No_Mapfile=Nothing
    META_GUI_INTERFACE=Mapfile
  }

  { Codeseq
    META_GUI_INTERFACE=Codeseq
    MODEL_DLL_FILENAME=Codeseq
  }
  { No_Codeseq
    META_GUI_INTERFACE=Codeseq
    MODEL_DLL_FILENAME=Nothing
  }

  { Flatmem
    MODEL_DLL_FILENAME=Flatmem
  }
  { SCamba
    MODEL_DLL_FILENAME=SCamba
  }
}

;; EOF peripherals.dsc
