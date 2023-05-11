// basic arm926 source file
#include "DW_arm926_example.h"
// #include <string.h>   // workaround prob with sparcOS & DW_ahb_icm_tlm
#include "HClkGen.h"
#include "DW_AHB_Monitor.h"
#include "DW_AHB_Arbiter.h"
#include "DW_AHB_Decoder.h"
#include "DW_AHB_Memory.h"
#include "DW_TCMemory.h"
#include "DW_ahb_icm_tlm.h"
#include "ConstGen.h"
#include "DW_arm926ejs.h"
#include "DW_ahb_tlm.h"
#include "DW_IntrGen.h"
#include "DW_arm926_example.h"

void DW_arm926_example::InitInstances() {
    ClockGen = new HClkGen("ClockGen", ibus_ratio, dbus_ratio);
    bool tmp_DBUSMonitor_MonitorTrace = DoTrace;
    ccss_set_parameter("DBUSMonitor.MonitorTrace", tmp_DBUSMonitor_MonitorTrace);
    bool tmp_DBUSMonitor_SignalTrace = DoTrace;
    ccss_set_parameter("DBUSMonitor.SignalTrace", tmp_DBUSMonitor_SignalTrace);
    bool tmp_DBUSMonitor_StatisticsTrace = DoTrace;
    ccss_set_parameter("DBUSMonitor.StatisticsTrace", tmp_DBUSMonitor_StatisticsTrace);
    unsigned int tmp_DBUSMonitor_StatisticsInterval = 128;
    ccss_set_parameter("DBUSMonitor.StatisticsInterval", tmp_DBUSMonitor_StatisticsInterval);
    double tmp_DBUSMonitor_FileTraceStartTime = TraceStartTime;
    ccss_set_parameter("DBUSMonitor.FileTraceStartTime", tmp_DBUSMonitor_FileTraceStartTime);
    double tmp_DBUSMonitor_FileTraceEndTime = TraceEndTime;
    ccss_set_parameter("DBUSMonitor.FileTraceEndTime", tmp_DBUSMonitor_FileTraceEndTime);
    sc_time_unit tmp_DBUSMonitor_FileTraceTimeUnit = SC_NS;
    ccss_set_parameter("DBUSMonitor.FileTraceTimeUnit", tmp_DBUSMonitor_FileTraceTimeUnit);
    DBUSMonitor = new DW_AHB_Monitor("DBUSMonitor", "DBusTraceFile", "DBusStatFile");
    int tmp_DBarbiter_SlaveID = 0;
    ccss_set_parameter("DBarbiter.SlaveID", tmp_DBarbiter_SlaveID);
    bool tmp_DBarbiter_AHB_FULL_INCR = false;
    ccss_set_parameter("DBarbiter.AHB_FULL_INCR", tmp_DBarbiter_AHB_FULL_INCR);
    bool tmp_DBarbiter_EBTEN = false;
    ccss_set_parameter("DBarbiter.EBTEN", tmp_DBarbiter_EBTEN);
    bool tmp_DBarbiter_AHB_WTEN = false;
    ccss_set_parameter("DBarbiter.AHB_WTEN", tmp_DBarbiter_AHB_WTEN);
    bool tmp_DBarbiter_DoTrace = false;
    ccss_set_parameter("DBarbiter.DoTrace", tmp_DBarbiter_DoTrace);
    bool tmp_DBarbiter_CombinatoricMode = false;
    ccss_set_parameter("DBarbiter.CombinatoricMode", tmp_DBarbiter_CombinatoricMode);
    DBarbiter = new DW_AHB_Arbiter("DBarbiter");
    bool tmp_DBdecoder_DoTrace = false;
    ccss_set_parameter("DBdecoder.DoTrace", tmp_DBdecoder_DoTrace);
    DBdecoder = new DW_AHB_Decoder("DBdecoder");
    int tmp_DataMem_SlaveID = 4;
    ccss_set_parameter("DataMem.SlaveID", tmp_DataMem_SlaveID);
    int tmp_DataMem_ReadWaitStates = DataMemReadWaitStates;
    ccss_set_parameter("DataMem.ReadWaitStates", tmp_DataMem_ReadWaitStates);
    int tmp_DataMem_WriteWaitStates = DataMemWriteWaitStates;
    ccss_set_parameter("DataMem.WriteWaitStates", tmp_DataMem_WriteWaitStates);
    bool tmp_DataMem_ReadOnly = false;
    ccss_set_parameter("DataMem.ReadOnly", tmp_DataMem_ReadOnly);
    bool tmp_DataMem_DisableMonitor = false;
    ccss_set_parameter("DataMem.DisableMonitor", tmp_DataMem_DisableMonitor);
    bool tmp_DataMem_DoTrace = false;
    ccss_set_parameter("DataMem.DoTrace", tmp_DataMem_DoTrace);
    DataMem = new DW_AHB_Memory<ahb_slave_if >("DataMem", DataMemStartAddr, DataMemEndAddr,"", BigEndian);
    int tmp_Dtcm_SlaveID = 0;
    ccss_set_parameter("Dtcm.SlaveID", tmp_Dtcm_SlaveID);
    int tmp_Dtcm_ReadWaitStates = 0;
    ccss_set_parameter("Dtcm.ReadWaitStates", tmp_Dtcm_ReadWaitStates);
    int tmp_Dtcm_WriteWaitStates = 0;
    ccss_set_parameter("Dtcm.WriteWaitStates", tmp_Dtcm_WriteWaitStates);
    bool tmp_Dtcm_ReadOnly = false;
    ccss_set_parameter("Dtcm.ReadOnly", tmp_Dtcm_ReadOnly);
    bool tmp_Dtcm_DoTrace = false;
    ccss_set_parameter("Dtcm.DoTrace", tmp_Dtcm_DoTrace);
    bool tmp_Dtcm_WarningEnable = false;
    ccss_set_parameter("Dtcm.WarningEnable", tmp_Dtcm_WarningEnable);
    Dtcm = new DW_TCMemory("Dtcm",TCM_4KB, 0x20000);
    bool tmp_IBUSMonitor_MonitorTrace = DoTrace;
    ccss_set_parameter("IBUSMonitor.MonitorTrace", tmp_IBUSMonitor_MonitorTrace);
    bool tmp_IBUSMonitor_SignalTrace = DoTrace;
    ccss_set_parameter("IBUSMonitor.SignalTrace", tmp_IBUSMonitor_SignalTrace);
    bool tmp_IBUSMonitor_StatisticsTrace = DoTrace;
    ccss_set_parameter("IBUSMonitor.StatisticsTrace", tmp_IBUSMonitor_StatisticsTrace);
    unsigned int tmp_IBUSMonitor_StatisticsInterval = 128;
    ccss_set_parameter("IBUSMonitor.StatisticsInterval", tmp_IBUSMonitor_StatisticsInterval);
    double tmp_IBUSMonitor_FileTraceStartTime = TraceStartTime;
    ccss_set_parameter("IBUSMonitor.FileTraceStartTime", tmp_IBUSMonitor_FileTraceStartTime);
    double tmp_IBUSMonitor_FileTraceEndTime = TraceEndTime;
    ccss_set_parameter("IBUSMonitor.FileTraceEndTime", tmp_IBUSMonitor_FileTraceEndTime);
    sc_time_unit tmp_IBUSMonitor_FileTraceTimeUnit = SC_NS;
    ccss_set_parameter("IBUSMonitor.FileTraceTimeUnit", tmp_IBUSMonitor_FileTraceTimeUnit);
    IBUSMonitor = new DW_AHB_Monitor("IBUSMonitor","IBusTraceFile","IBusStatFile");
    int tmp_IBarbiter_SlaveID = 0;
    ccss_set_parameter("IBarbiter.SlaveID", tmp_IBarbiter_SlaveID);
    bool tmp_IBarbiter_AHB_FULL_INCR = false;
    ccss_set_parameter("IBarbiter.AHB_FULL_INCR", tmp_IBarbiter_AHB_FULL_INCR);
    bool tmp_IBarbiter_EBTEN = false;
    ccss_set_parameter("IBarbiter.EBTEN", tmp_IBarbiter_EBTEN);
    bool tmp_IBarbiter_AHB_WTEN = true;
    ccss_set_parameter("IBarbiter.AHB_WTEN", tmp_IBarbiter_AHB_WTEN);
    bool tmp_IBarbiter_DoTrace = false;
    ccss_set_parameter("IBarbiter.DoTrace", tmp_IBarbiter_DoTrace);
    bool tmp_IBarbiter_CombinatoricMode = false;
    ccss_set_parameter("IBarbiter.CombinatoricMode", tmp_IBarbiter_CombinatoricMode);
    IBarbiter = new DW_AHB_Arbiter("IBarbiter");
    bool tmp_IBdecoder_DoTrace = false;
    ccss_set_parameter("IBdecoder.DoTrace", tmp_IBdecoder_DoTrace);
    IBdecoder = new DW_AHB_Decoder("IBdecoder");
    int tmp_ICM1_SlaveID = 0;
    ccss_set_parameter("ICM1.SlaveID", tmp_ICM1_SlaveID);
    ICM1 = new DW_ahb_icm_tlm<ahb_slave_if >("ICM1", ICM_Configuration);
    int tmp_Itcm_SlaveID = 0;
    ccss_set_parameter("Itcm.SlaveID", tmp_Itcm_SlaveID);
    int tmp_Itcm_ReadWaitStates = 0;
    ccss_set_parameter("Itcm.ReadWaitStates", tmp_Itcm_ReadWaitStates);
    int tmp_Itcm_WriteWaitStates = 0;
    ccss_set_parameter("Itcm.WriteWaitStates", tmp_Itcm_WriteWaitStates);
    bool tmp_Itcm_ReadOnly = false;
    ccss_set_parameter("Itcm.ReadOnly", tmp_Itcm_ReadOnly);
    bool tmp_Itcm_DoTrace = false;
    ccss_set_parameter("Itcm.DoTrace", tmp_Itcm_DoTrace);
    bool tmp_Itcm_WarningEnable = false;
    ccss_set_parameter("Itcm.WarningEnable", tmp_Itcm_WarningEnable);
    Itcm = new DW_TCMemory("Itcm", TCM_4KB, 0xff000);
    bool tmp_LowGen1_ConstValue = false;
    ccss_set_parameter("LowGen1.ConstValue", tmp_LowGen1_ConstValue);
    LowGen1 = new ConstGen<bool >("LowGen1");
    bool tmp_LowGen2_ConstValue = false;
    ccss_set_parameter("LowGen2.ConstValue", tmp_LowGen2_ConstValue);
    LowGen2 = new ConstGen<bool >("LowGen2");
    int tmp_ProgMem_SlaveID = 1;
    ccss_set_parameter("ProgMem.SlaveID", tmp_ProgMem_SlaveID);
    int tmp_ProgMem_ReadWaitStates = ProgMemReadWaitStates;
    ccss_set_parameter("ProgMem.ReadWaitStates", tmp_ProgMem_ReadWaitStates);
    int tmp_ProgMem_WriteWaitStates = ProgMemWriteWaitStates;
    ccss_set_parameter("ProgMem.WriteWaitStates", tmp_ProgMem_WriteWaitStates);
    bool tmp_ProgMem_ReadOnly = false;
    ccss_set_parameter("ProgMem.ReadOnly", tmp_ProgMem_ReadOnly);
    bool tmp_ProgMem_DisableMonitor = false;
    ccss_set_parameter("ProgMem.DisableMonitor", tmp_ProgMem_DisableMonitor);
    bool tmp_ProgMem_DoTrace = false;
    ccss_set_parameter("ProgMem.DoTrace", tmp_ProgMem_DoTrace);
    ProgMem = new DW_AHB_Memory<ahb_slave_if >("ProgMem", ProgMemStartAddr, ProgMemEndAddr,ProgMemImageFile, BigEndian);
    bool tmp_ResetTrue_ConstValue = true;
    ccss_set_parameter("ResetTrue.ConstValue", tmp_ResetTrue_ConstValue);
    ResetTrue = new ConstGen<bool >("ResetTrue");
    int tmp_StackMem_SlaveID = 2;
    ccss_set_parameter("StackMem.SlaveID", tmp_StackMem_SlaveID);
    int tmp_StackMem_ReadWaitStates = StackMemReadWaitStates;
    ccss_set_parameter("StackMem.ReadWaitStates", tmp_StackMem_ReadWaitStates);
    int tmp_StackMem_WriteWaitStates = StackMemWriteWaitStates;
    ccss_set_parameter("StackMem.WriteWaitStates", tmp_StackMem_WriteWaitStates);
    bool tmp_StackMem_ReadOnly = false;
    ccss_set_parameter("StackMem.ReadOnly", tmp_StackMem_ReadOnly);
    bool tmp_StackMem_DisableMonitor = false;
    ccss_set_parameter("StackMem.DisableMonitor", tmp_StackMem_DisableMonitor);
    bool tmp_StackMem_DoTrace = false;
    ccss_set_parameter("StackMem.DoTrace", tmp_StackMem_DoTrace);
    StackMem = new DW_AHB_Memory<ahb_slave_if >("StackMem", StackMemStartAddr, StackMemEndAddr,"", BigEndian);
    unsigned int tmp_arm926_MasterIDibiu = 1;
    ccss_set_parameter("arm926.MasterIDibiu", tmp_arm926_MasterIDibiu);
    unsigned int tmp_arm926_MasterIDdbiu = 2;
    ccss_set_parameter("arm926.MasterIDdbiu", tmp_arm926_MasterIDdbiu);
    arm926 = new DW_arm926ejs("arm926", 1, true, 1, true, BigEndian, ProgName, Debugger);
    int tmp_dbus_BusID = 2;
    ccss_set_parameter("dbus.BusID", tmp_dbus_BusID);
    int tmp_dbus_Priority = 1;
    ccss_set_parameter("dbus.Priority", tmp_dbus_Priority);
    sc_time tmp_dbus_MonitorDelay = SC_ZERO_TIME;
    ccss_set_parameter("dbus.MonitorDelay", tmp_dbus_MonitorDelay);
    dbus = new DW_ahb_tlm<ahb_bus_if, ahb_slave_if >("dbus");
    int tmp_ibus_BusID = 1;
    ccss_set_parameter("ibus.BusID", tmp_ibus_BusID);
    int tmp_ibus_Priority = 2;
    ccss_set_parameter("ibus.Priority", tmp_ibus_Priority);
    sc_time tmp_ibus_MonitorDelay = SC_ZERO_TIME;
    ccss_set_parameter("ibus.MonitorDelay", tmp_ibus_MonitorDelay);
    ibus = new DW_ahb_tlm<ahb_bus_if, ahb_slave_if >("ibus");
    int tmp_icm_arbiter_SlaveID = 0;
    ccss_set_parameter("icm_arbiter.SlaveID", tmp_icm_arbiter_SlaveID);
    bool tmp_icm_arbiter_AHB_FULL_INCR = false;
    ccss_set_parameter("icm_arbiter.AHB_FULL_INCR", tmp_icm_arbiter_AHB_FULL_INCR);
    bool tmp_icm_arbiter_EBTEN = false;
    ccss_set_parameter("icm_arbiter.EBTEN", tmp_icm_arbiter_EBTEN);
    bool tmp_icm_arbiter_AHB_WTEN = false;
    ccss_set_parameter("icm_arbiter.AHB_WTEN", tmp_icm_arbiter_AHB_WTEN);
    bool tmp_icm_arbiter_DoTrace = false;
    ccss_set_parameter("icm_arbiter.DoTrace", tmp_icm_arbiter_DoTrace);
    bool tmp_icm_arbiter_CombinatoricMode = true;
    ccss_set_parameter("icm_arbiter.CombinatoricMode", tmp_icm_arbiter_CombinatoricMode);
    icm_arbiter = new DW_AHB_Arbiter("icm_arbiter");
    bool tmp_icm_decoder_DoTrace = false;
    ccss_set_parameter("icm_decoder.DoTrace", tmp_icm_decoder_DoTrace);
    icm_decoder = new DW_AHB_Decoder("icm_decoder");
    int tmp_intr_gen1_SlaveID = 3;
    ccss_set_parameter("intr_gen1.SlaveID", tmp_intr_gen1_SlaveID);
    int tmp_intr_gen1_ReadWaitStates = 0;
    ccss_set_parameter("intr_gen1.ReadWaitStates", tmp_intr_gen1_ReadWaitStates);
    int tmp_intr_gen1_WriteWaitStates = 0;
    ccss_set_parameter("intr_gen1.WriteWaitStates", tmp_intr_gen1_WriteWaitStates);
    bool tmp_intr_gen1_ReadOnly = false;
    ccss_set_parameter("intr_gen1.ReadOnly", tmp_intr_gen1_ReadOnly);
    bool tmp_intr_gen1_DisableMonitor = false;
    ccss_set_parameter("intr_gen1.DisableMonitor", tmp_intr_gen1_DisableMonitor);
    bool tmp_intr_gen1_DoTrace = false;
    ccss_set_parameter("intr_gen1.DoTrace", tmp_intr_gen1_DoTrace);
    intr_gen1 = new DW_IntrGen<ahb_slave_if >("intr_gen1", IntrGenStartAddr, IntrGenEndAddr, "", BigEndian);

    arm926->dtcm(*Dtcm);
    DBarbiter->ahb_wt_aps(C148);
    DBarbiter->ahb_wt_mask(C149);
    DBarbiter->ahbarbint(C150);
    IBarbiter->ahb_wt_aps(C151);
    IBarbiter->ahb_wt_mask(C152);
    IBarbiter->ahbarbint(C153);
    icm_arbiter->ahb_wt_aps(C154);
    icm_arbiter->ahb_wt_mask(C155);
    icm_arbiter->ahbarbint(C156);
    DBUSMonitor->p(*dbus);
    arm926->dbiu(*dbus);
    arm926->IHClkEn(C176);
    ClockGen->IBusHClkEn(C176);
    arm926->DHClkEn(C177);
    ClockGen->DBusHClkEn(C177);
    ibus->hclk(C178);
    ClockGen->IBusHClk(C178);
    intr_gen1->clk(C179);
    dbus->hclk(C179);
    ClockGen->DBusHClk(C179);
    arm926->ibiu(*ibus);
    IBUSMonitor->p(*ibus);
    dbus->slave_port(*intr_gen1);
    dbus->slave_port(*ICM1);
    ibus->slave_port(*ICM1);
    ICM1->decoder_port(*icm_decoder);
    ICM1->slave_port(*ProgMem);
    dbus->decoder_port(*DBdecoder);
    dbus->arbiter_port(*DBarbiter);
    ibus->arbiter_port(*IBarbiter);
    ibus->decoder_port(*IBdecoder);
    dbus->slave_port(*DataMem);
    dbus->slave_port(*StackMem);
    ICM1->arbiter_port(*icm_arbiter);
    arm926->itcm(*Itcm);
    ProgMem->hresetn(High1);
    DataMem->hresetn(High1);
    dbus->hresetn(High1);
    ibus->hresetn(High1);
    IBdecoder->remap_n(High1);
    StackMem->hresetn(High1);
    icm_decoder->remap_n(High1);
    ClockGen->n_reset(High1);
    DBdecoder->remap_n(High1);
    ResetTrue->Out(High1);
    arm926->INITRAM(INITRAM);
    intr_gen1->INITRAM(INITRAM);
    DBarbiter->pause(Low1);
    LowGen1->Out(Low1);
    icm_arbiter->pause(Low2);
    IBarbiter->pause(Low2);
    LowGen2->Out(Low2);
    arm926->VINITHI(VINITHI);
    intr_gen1->VINITHI(VINITHI);
    arm926->clock(clock);
    ClockGen->Clk(clock);
    intr_gen1->nFIQ(nFIQ);
    arm926->nFIQ(nFIQ);
    arm926->nIRQ(nIRQ);
    intr_gen1->nIRQ(nIRQ);
    arm926->nRESET(nRESET);
    intr_gen1->nRESET(nRESET);
}

void DW_arm926_example::DeleteInstances() {
    if (ClockGen) {delete ClockGen; ClockGen = 0;}
    if (DBUSMonitor) {delete DBUSMonitor; DBUSMonitor = 0;}
    if (DBarbiter) {delete DBarbiter; DBarbiter = 0;}
    if (DBdecoder) {delete DBdecoder; DBdecoder = 0;}
    if (DataMem) {delete DataMem; DataMem = 0;}
    if (Dtcm) {delete Dtcm; Dtcm = 0;}
    if (IBUSMonitor) {delete IBUSMonitor; IBUSMonitor = 0;}
    if (IBarbiter) {delete IBarbiter; IBarbiter = 0;}
    if (IBdecoder) {delete IBdecoder; IBdecoder = 0;}
    if (ICM1) {delete ICM1; ICM1 = 0;}
    if (Itcm) {delete Itcm; Itcm = 0;}
    if (LowGen1) {delete LowGen1; LowGen1 = 0;}
    if (LowGen2) {delete LowGen2; LowGen2 = 0;}
    if (ProgMem) {delete ProgMem; ProgMem = 0;}
    if (ResetTrue) {delete ResetTrue; ResetTrue = 0;}
    if (StackMem) {delete StackMem; StackMem = 0;}
    if (arm926) {delete arm926; arm926 = 0;}
    if (dbus) {delete dbus; dbus = 0;}
    if (ibus) {delete ibus; ibus = 0;}
    if (icm_arbiter) {delete icm_arbiter; icm_arbiter = 0;}
    if (icm_decoder) {delete icm_decoder; icm_decoder = 0;}
    if (intr_gen1) {delete intr_gen1; intr_gen1 = 0;}
}

