;; ARMulator configuration file type 3
;; Copyright (c) 1998-2001 ARM Limited. All Rights Reserved.
;;

;; This is a non-user-editable configuration file for the ARM Advanced
;; Core Simulator.

;; RCS $Revision: 1.1.4.17.2.4 $
;; Checkin $Date: 2002/10/17 16:53:44 $
;; Revising $Author: acollier $

;; Comment this out for benchmarking
;; For the moment we assume that if no clock speed has been set on the
;; command-line, the user wishes to use a wall-clock for timing
#if !CPUSPEED
Clock=Real
#endif

;; This line controls whether (some) models give more useful descriptions
;; of what they are on startup, and during running.
;Verbose=False

;; To enable faster watchpoints, set "WatchpointsEnabled"
;WatchpointsEnabled=True

;; Uncomment next line if you wish to boot ARM966E-S with hivecs
;ARM966BootHiVectors

;; *****************************************************************
;; ARMulator Peripheral Models
;; Central list of peripherals 
;; Use this list to enable/disable peripherals
;; *****************************************************************
;; To enable a peripheral change the rhs to True
;; To disable a peripheral change the rhs to FALSE

; This is False by default.
WDogEnabled=False

; Note that DCC is enabled by default if running on a processor
; with an EmbeddedICE macrocell

;; end of peripheral list
;; *****************************************************************

;; ARMulator can tell you how much stack your program uses (at a
;; substantial runtime cost)
TrackStack=False

{ PeripheralSets
#if MEMORY_ACI_ARMul
  { Processors_Common_ACS=Peripherals_Common_ACS
  }
#else
  { Processors_Common_ACS=Processors_Common_No_Peripherals_ACS
  }
#endif
}

;;
;; This is the list of all processors supported by ARMulator.
;;

{ Processors
  ;; This isn't a processor.
  Default=ARM7TDMI

  ;; Entries are of the form:
  ;
  ; { <processor-name>=<processor-prototype>
  ; ... features ...
  ; }
  ;

  ;; ARM7 family

  { ARM7TDMI_rev4=Processors_Common_ACS
    ;; Features
    Processor=ARM7TDMI_rev4
    meta_moduleserver_processor=ARM7TDMI_rev4
    Core=ARM7
    ARMulator=GASP7
    Architecture=4T
    Nexec=True
    LateAborts=True
    Debug=True
    { DCC=Default_DebugCommsNoInterrupt
    }
  }

  ;; Variants of ARM7TDMI
  { ASB7TDMI_rev4=ARM7TDMI_rev4
    Processor=ASB7TDMI_rev4
    meta_moduleserver_processor=ASB7TDMI_rev4
  }
  { A7S_rev4=ARM7TDMI_rev4
    Processor=A7S_rev4
    meta_moduleserver_processor=A7S_rev4
  }

  { ARM710T_rev2=ARM7TDMI_rev4
    Processor=ARM710T_rev2
    meta_moduleserver_processor=ARM710T_rev2
    Memory=ARM710T_rev2
  }

  { ARM720T_rev3=ARM7TDMI_rev4
    Processor=ARM720T_rev3
    meta_moduleserver_processor=ARM720T_rev3
    HighExceptionVectors=True
    Memory=ARM720T_rev3
  }


  { ARM720T_rev4=A7S_rev4
    Processor=ARM720T_rev4
    meta_moduleserver_processor=ARM720T_rev4
    HighExceptionVectors=True
    Memory=GASP720Tr4CacheMMU
    HasMMU=True
  }
  
  ;; ARM9 family

  ;; ARM9E variants
  { ARM9ES_rev0=Processors_Common_ACS
    ;; Features:
    Processor=ARM9ES_rev0
    meta_moduleserver_processor=ARM9ES_rev0
    Core=ARM9
    ARMulator=ARM9ulator
    Architecture=4T
    Nexec=True
    MultipleEarlyAborts=True
    AbortsStopMultiple=True
    CoreCycles=True
    HighExceptionVectors=True
    ARM9Extensions=True
    ARM9CoprocessorInterface=True
    ;;StrongARMAware
    ;;NoLDCSTC
    ;;NoCDP
    { DCC=Default_DebugCommsNoInterrupt
    }
  }

  { ARM9ES_rev1=Processors_Common_ACS
    ;; Features:
    Processor=ARM9ES_rev1
    meta_moduleserver_processor=ARM9ES_rev1
    Core=ARM9
    ARMulator=ARM9ulator
    Architecture=4T
    Nexec=True
    MultipleEarlyAborts=True
    AbortsStopMultiple=True
    CoreCycles=True
    HighExceptionVectors=True
    ARM9Extensions=True
    ARM9CoprocessorInterface=True
    ARMv5PExtensions=True
    ;;StrongARMAware
    ;;NoLDCSTC
    ;;NoCDP
    { DCC=Default_DebugCommsNoInterrupt
    }
  }

  { ARM9ES_rev2=ARM9ES_rev1
    ;; Features:
    Processor=ARM9ES_rev2
    meta_moduleserver_processor=ARM9ES_rev2

    ARM9OptimizedMemory=True
    ARM9OptimizedDAborts=True
    
    ARMJavaExtensions=False
  }

  { ARM9EJS_rev0=Processors_Common_ACS
    ;; Features:
    Processor=ARM9EJS_rev0
    meta_moduleserver_processor=ARM9EJS_rev0
    Core=ARM9
    ARMulator=ARM9ulator
    Architecture=4T
    Nexec
    MultipleEarlyAborts=True
    AbortsStopMultiple=True
    CoreCycles=True
    HighExceptionVectors=True
    ARM9Extensions=True
    ARMv5PExtensions=True
    ARM9OptimizedMemory
    ARM9CoprocessorInterface=True
    ARMJavaExtensions=True
    ;;StrongARMAware
    ;;NoLDCSTC
    ;;NoCDP
    { DCC=Default_DebugCommsNoInterrupt
    }
  }

  { ARM9EJS_rev1=Processors_Common_ACS
    ;; Features:
    Processor=ARM9EJS_rev1
    meta_moduleserver_processor=ARM9EJS_rev1
    Core=ARM9
    ARMulator=ARM9ulator
    Architecture=4T
    Nexec
    MultipleEarlyAborts=True
    AbortsStopMultiple=True
    CoreCycles=True
    HighExceptionVectors=True
    ARM9Extensions=True
    ARMv5PExtensions=True
    ARM9OptimizedMemory=True
    ARM9OptimizedDAborts=True
    ARM9CoprocessorInterface=True
    ARMJavaExtensions=True
    ARMJavaV1Extensions=True

    ;;StrongARMAware
    ;;NoLDCSTC
    ;;NoCDP
    { DCC=Default_DebugCommsNoInterrupt
    }
  }

  { ARM9TDMI_rev1=Processors_Common_ACS
    ;; Features:
    Processor=ARM9TDMI_rev1
    meta_moduleserver_processor=ARM9TDMI_rev1
    Core=ARM9
    ARMulator=ARM9ulator
    Architecture=4T
    Nexec=True
    MultipleEarlyAborts=True
    AbortsStopMultARM920Tr1iple=True
    CoreCycles=True
    HighExceptionVectors=True
    ARM9CoprocessorInterface=True
    ;;StrongARMAware
    ;;NoLDCSTC
    ;;NoCDP
    { DCC=Default_DebugCommsNoInterrupt
    }
  }

  { ARM9TDMI_rev3=Processors_Common_ACS
    ;; Features:
    Processor=ARM9TDMI_rev3
    meta_moduleserver_processor=ARM9TDMI_rev3
    Core=ARM9
    ARMulator=ARM9ulator
    Architecture=4T
    Nexec=True
    MultipleEarlyAborts=True
    AbortsStopMultiple=True
    CoreCycles=True
    HighExceptionVectors=True
    ARM9OptimizedDAborts=True
    ARM9CoprocessorInterface=True
    ;;StrongARMAware
    ;;NoLDCSTC
    ;;NoCDP
    { DCC=Default_DebugCommsNoInterrupt
    }
  }

  ;; Variants of ARM9TDMI
  { ARM940T_rev1=ARM9TDMI_rev1
    Processor=ARM940T_rev1
    meta_moduleserver_processor=ARM940T_rev1
    Memory=ARM940T_rev1
    HasPU=True
  }

  { ARM920T_rev0=ARM9TDMI_rev1
    Processor=ARM920T_rev0
    meta_moduleserver_processor=ARM920T_rev0
    Memory=ARM920T_rev0
    HasMMU=True
  }
  { ARM920T_rev1=ARM9TDMI_rev3
    Processor=ARM920T_rev1
    meta_moduleserver_processor=ARM920T_rev1
    Memory=ARM920T_rev1
    HasMMU=True
  }

  { ARM922T_rev0=ARM9TDMI_rev3
    Processor=ARM922T_rev0
    meta_moduleserver_processor=ARM922T_rev0
    Memory=ARM922T_rev0
    HasMMU=True
  }

  ;; Variants of ARM9E-S

  { ARM966ES_rev1=ARM9ES_rev1
    Processor=ARM966ES_rev1
    meta_moduleserver_processor=ARM966ES_rev1
    Memory=ARM966ES_rev1
    HasSRAM=True
  }
  { ARM966ESDPR_rev1=ARM9ES_rev1
    Processor=ARM966ESDPR_rev1
    meta_moduleserver_processor=ARM966ESDPR_rev1
    Memory=ARM966ESDPR_rev1
    HasSRAM=True
  }
  { ARM966ES_rev2=ARM9ES_rev2
    Processor=ARM966ES_rev2
    meta_moduleserver_processor=ARM966ES_rev2
    Memory=ARM966ES_rev2
    HasSRAM=True

    IRamSize=0x10000
    DRamSize=0x10000
  }

  { ARM926EJS_rev0=ARM9EJS_rev1
    Processor=ARM926EJS_rev0
    meta_moduleserver_processor=ARM926EJS_rev0
    Memory=ARM926EJS_rev0
    HasMMU=True
    HasSRAM=True
    ; Default TCM size
    IRamSize=0x10000
    DRamSize=0x10000
    ; Default Cache size
    ICache_Lines=256
    DCache_Lines=256
  }

  { ARM946ES_rev1=ARM9ES_rev1
    Processor=ARM946ES_rev1
    meta_moduleserver_processor=ARM946ES_rev1
    Memory=ARM946ES_rev1
    HasPU=True
    HasSRAM=True
    ; Default TCM size
    IRamSize=0x10000
    DRamSize=0x10000
    ; Default Cache size
    ICache_Lines=512
    DCache_Lines=512
  }

  ;; ARM10 family

  { ARM1020E_rev1=Processors_Common_ACS
    ;; Features:
    Processor=ARM1020E_rev1
    meta_moduleserver_processor=ARM1020E_rev1
    Core=ARM10
    ARMulator=GASP10
    Architecture=4T
    Nexec=True
    MultipleEarlyAborts=True
    AbortsStopMultiple=True
    CoreCycles=True
    HighExceptionVectors=True
    ARM9Extensions=True
    ARMv5PExtensions=True
    ARM9CoprocessorInterface=True
    ;;StrongARMAware
    ;;NoLDCSTC
    ;;NoCDP
  }
}

;;
;; List of memory models
;;

{ Memories
  ;;
  ;; If there is a cache/mmu memory-model defined, then it loads the
  ;; memory named as Memories:Default to handle external accesses.
  ;;

#if MEMORY_ACI_ARMul
  ;; Coverification ACS with ARM Coverification Interface (ACI)
  Default=ACI_ARMul
  { ACI_ARMul
    TraceRegisters=True
    CheckPrediction=False
    ACIDll=armacsaci
    Debug=False
  }

#elif MEMORY_CycleVeneer
  ;; CCM has NUL_BIU load its Veneer model, which loads a
  ;; sacrificial Flat memory, which is replaced by the Vendor
  Default=NUL_BIU
  { Nul_BIU
    Memory=CycleVeneer
  }
  { CycleVeneer
    Memory=Flat
#if CCM_DEBUG==True
    Debug=True
#else
    Debug=False
#endif
  }

#else
  ;; Fall back on ARMulator behaviour with NUL_BIU loading Flat
  Default=NUL_BIU
  { Nul_BIU
    Memory=Flat
  }

#endif

  ;; The "ARM720CacheMMU" model provides the cache/MMU model for the ARM720T
  ARM710T_rev2=ARM720CacheMMU
  ARM720T_rev3=ARM720CacheMMU

  { ARM720CacheMMU
#if Validate
    Config=Standard
#endif
    Config=Enhanced

    ARM710T_rev2:ChipNumber=0x710
    ARM710T_rev2:Revision=2
    ARM710T_rev2:CacheAssociativity=4
    ARM710T_rev2:CacheBlocks=128

    ARM720T_rev3:ChipNumber=0x720
    ARM720T_rev3:Revision=2
    ARM720T_rev3:CacheAssociativity=4
    ARM720T_rev3:CacheBlocks=128
    ARM720T_rev3:ProcessId

    ;; Clock speed controlled by a pair of values:
    CCCFG=0
    MCCFG=8
    HighExceptionVectors=True

    Memory=Default
  }
  
  { GASP720Tr4CacheMMU
    Memory=Default
  }

  ;; The "ARM920CacheMMU" model provides the cache/MMU model for the ARM920
  ARM920T_rev0=ARM920CacheMMU
  ARM920T_rev1=ARM920CacheMMU

  { ARM920CacheMMU
    ;; Whether to have the "verbose" $statistics
    Counters=True

    ARM920T_rev0:Revision=0
    ARM920T_rev1:Revision=1

    ICache_Associativity=64
    DCache_Associativity=64
    ICache_Lines=512
    DCache_Lines=512
    ChipNumber=0x920

    Config=Enhanced
    ProcessId=True

    ;; Clock speed controlled by a pair of values:
    CCCFG=
    MCCFG=8

    Memory=Default
  }

  ;; The "ARM922CacheMMU" model provides the cache/MMU model for the ARM922
  ARM922T_rev0=ARM922CacheMMU

  { ARM922CacheMMU
    ;; Whether to have the "verbose" $statistics
    Counters=True

    ;; ARM920T revision corresponding to rev0 ARM922T
    Revision=1

    ICache_Associativity=64
    DCache_Associativity=64
    ICache_Lines=256
    DCache_Lines=256
    ChipNumber=0x922

    Config=Enhanced
    ProcessId=True
    HasMMU=True

    ;; Clock speed controlled by a pair of values:
    CCCFG=
    MCCFG=8

    Memory=Default
  }

  ;; The "ARM940CacheMPU" model provides the cache/PU model for the ARM940
  ARM940T_rev1=ARM940CacheMPU

  { ARM940CacheMPU
    ;; Whether to have the "verbose" $statistics
    Counters=True

    ChipNumber=0x940
    ARM940T_rev1:Revision=1 

    ;;Set the number of cache lines
    ICache_Associativity=64
    DCache_Associativity=64
    ICache_Lines=256
    DCache_Lines=256
    ;; 256 = 4 Kbytes
    ;; 512 = 8 Kbytes

    ;; Clock speed controlled by:
    MCCFG=10

    Memory=Default
  }

  ARM966ES_rev1=ARM9xxE
  ARM966ESDPR_rev1=ARM9xxE

  { ARM9xxE
    ;; Whether to have the "verbose" $statistics
    Counters=True

#if ARM966BootHiVectors
    VIntHi=True
#else
    VIntHi=FALSE
#endif
    ARM966ES_rev1:IRamSize=0x10000
    ARM966ES_rev1:DRamSize=0x10000
    ARM966ES_rev1:WriteBufferWords=12
    ARM966ES_rev1:ChipNumber=0x966
    ARM966ES_rev1:Revision=1
    ARM966ES_rev1:HasDMA=1

    ARM966ESDPR_rev1:IRamSize=0x10000
    ARM966ESDPR_rev1:DRamSize=0x10000
    ARM966ESDPR_rev1:WriteBufferWords=12
    ARM966ESDPR_rev1:ChipNumber=0x966
    ARM966ESDPR_rev1:Revision=0
    ARM966ESDPR_rev1:HasDMA=1

    Config=Enhanced
    MCCFG=1
    Memory=Default
  }

  ARM966ES_rev2=ARM966E

  { ARM966E
    ;; Whether to have the "verbose" $statistics
    Counters=True

#if ARM966BootHiVectors
    VIntHi=True
 #if ARM966BootTCMEnabled
    INITRAM=True
 #endif
#else
    VIntHi=FALSE
#endif

    Config=Enhanced
    MCCFG=1
    Memory=Default
  }

  ARM926EJS_rev0=ARM926EJ

  { ARM926EJ

#if ARM9x6BootHiVectors || ARM966BootHiVectors
    VIntHi=TRUE
#else 
    VIntHi=FALSE
#endif                       
    Config=Enhanced

    Revision=3

    MCCFG=1
    Memory=Default
  }

  ARM946ES_rev1=ARM946E

  { ARM946E

#if ARM9x6BootHiVectors || ARM966BootHiVectors
    VIntHi=TRUE
#else 
    VIntHi=FALSE
#endif                       
    Config=Enhanced

    MCCFG=1
    Memory=Default
  }

}

;; Co-processor bus
CoprocessorBus=ARMCoprocessorBus

;;
;; Coprocessor configurations
;;

{ Coprocessors
  ;; Here is the list of co-processors, in the form:
  ; Coprocessor[<n>]=Name
}

;;
;; Basic models (ARMulator extensions)
;;

{ EarlyModels
  ;;
  ;; "EarlyModels" get run before memory initialisation, "Models" after.
  ;;

  { EventConverter
  }

#if MODEL_Watchpoints && WatchpointsEnabled==True
  ;; Inserts a watchpoint model into the memory hierarchy.
  Watchpoints
#endif
}

{ Peripherals
  ;; Special version of Debug comms channel which does not generate
  ;; an IRQ at startup.

  ;; Debug comms channel model checks if it's on a processor with ICE
  ;; The "Rate" parameter governs how often it tries to give data back
  ;; to the debugger, so models the real latency of a JTAG-based system.
  { DebugCommsNoInterrupt
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
  { No_DebugCommsNoInterrupt=Nothing
    META_GUI_INTERFACE=Dcc
  }
}
