// basic_946 source file
#include "DW_arm946_example.h"

#include "DW_AHB_Monitor.h"
#include "HClkGen.h"
#include "DW_AHB_Memory.h"
#include "ConstGen.h"
#include "DW_IntrGen.h"
#include "DW_ahb_tlm.h"
#include "DW_AHB_Arbiter.h"
#include "DW_arm946es.h"
#include "DW_AHB_Decoder.h"
#include "DW_TCMemory.h"
#include "DW_arm946_example.h"

void DW_arm946_example::InitInstances() {
    bool tmp_AHBMonitor_MonitorTrace = DoTrace;
    ccss_set_parameter("AHBMonitor.MonitorTrace", tmp_AHBMonitor_MonitorTrace);
    bool tmp_AHBMonitor_SignalTrace = DoTrace;
    ccss_set_parameter("AHBMonitor.SignalTrace", tmp_AHBMonitor_SignalTrace);
    bool tmp_AHBMonitor_StatisticsTrace = DoTrace;
    ccss_set_parameter("AHBMonitor.StatisticsTrace", tmp_AHBMonitor_StatisticsTrace);
    unsigned int tmp_AHBMonitor_StatisticsInterval = 128;
    ccss_set_parameter("AHBMonitor.StatisticsInterval", tmp_AHBMonitor_StatisticsInterval);
    double tmp_AHBMonitor_FileTraceStartTime = TraceStartTime;
    ccss_set_parameter("AHBMonitor.FileTraceStartTime", tmp_AHBMonitor_FileTraceStartTime);
    double tmp_AHBMonitor_FileTraceEndTime = TraceEndTime;
    ccss_set_parameter("AHBMonitor.FileTraceEndTime", tmp_AHBMonitor_FileTraceEndTime);
    sc_time_unit tmp_AHBMonitor_FileTraceTimeUnit = SC_NS;
    ccss_set_parameter("AHBMonitor.FileTraceTimeUnit", tmp_AHBMonitor_FileTraceTimeUnit);
    AHBMonitor = new DW_AHB_Monitor("AHBMonitor","AHBTraceFile","AHBStatFile");
    ClockGen = new HClkGen("ClockGen",dbus_ratio, ibus_ratio);
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
    bool tmp_DataMem_DoTrace = DoTrace;
    ccss_set_parameter("DataMem.DoTrace", tmp_DataMem_DoTrace);
    DataMem = new DW_AHB_Memory<ahb_slave_if >("DataMem",DataMemStartAddr, DataMemEndAddr, "", BigEndian);
    bool tmp_FalseGen_ConstValue = false;
    ccss_set_parameter("FalseGen.ConstValue", tmp_FalseGen_ConstValue);
    FalseGen = new ConstGen<bool >("FalseGen");
    int tmp_IntrGen_SlaveID = 3;
    ccss_set_parameter("IntrGen.SlaveID", tmp_IntrGen_SlaveID);
    int tmp_IntrGen_ReadWaitStates = 0 ;
    ccss_set_parameter("IntrGen.ReadWaitStates", tmp_IntrGen_ReadWaitStates);
    int tmp_IntrGen_WriteWaitStates = 0 ;
    ccss_set_parameter("IntrGen.WriteWaitStates", tmp_IntrGen_WriteWaitStates);
    bool tmp_IntrGen_ReadOnly = false;
    ccss_set_parameter("IntrGen.ReadOnly", tmp_IntrGen_ReadOnly);
    bool tmp_IntrGen_DisableMonitor = false;
    ccss_set_parameter("IntrGen.DisableMonitor", tmp_IntrGen_DisableMonitor);
    bool tmp_IntrGen_DoTrace = false;
    ccss_set_parameter("IntrGen.DoTrace", tmp_IntrGen_DoTrace);
    IntrGen = new DW_IntrGen<ahb_slave_if >("IntrGen",IntrGenStartAddr,IntrGenEndAddr);
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
    bool tmp_ProgMem_DoTrace = DoTrace;
    ccss_set_parameter("ProgMem.DoTrace", tmp_ProgMem_DoTrace);
    ProgMem = new DW_AHB_Memory<ahb_slave_if >("ProgMem", ProgMemStartAddr,ProgMemEndAddr, ProgMemImageFile, BigEndian);
    bool tmp_ResetGen_ConstValue = true;
    ccss_set_parameter("ResetGen.ConstValue", tmp_ResetGen_ConstValue);
    ResetGen = new ConstGen<bool >("ResetGen");
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
    bool tmp_StackMem_DoTrace = DoTrace;
    ccss_set_parameter("StackMem.DoTrace", tmp_StackMem_DoTrace);
    StackMem = new DW_AHB_Memory<ahb_slave_if >("StackMem", StackMemStartAddr, StackMemEndAddr, "", BigEndian);
    int tmp_ahb_bus_BusID = 1;
    ccss_set_parameter("ahb_bus.BusID", tmp_ahb_bus_BusID);
    int tmp_ahb_bus_Priority = 1;
    ccss_set_parameter("ahb_bus.Priority", tmp_ahb_bus_Priority);
    sc_time tmp_ahb_bus_MonitorDelay = SC_ZERO_TIME;
    ccss_set_parameter("ahb_bus.MonitorDelay", tmp_ahb_bus_MonitorDelay);
    ahb_bus = new DW_ahb_tlm<ahb_bus_if, ahb_slave_if >("ahb_bus");
    int tmp_arbiter_SlaveID = 0;
    ccss_set_parameter("arbiter.SlaveID", tmp_arbiter_SlaveID);
    bool tmp_arbiter_AHB_FULL_INCR = false;
    ccss_set_parameter("arbiter.AHB_FULL_INCR", tmp_arbiter_AHB_FULL_INCR);
    bool tmp_arbiter_EBTEN = false;
    ccss_set_parameter("arbiter.EBTEN", tmp_arbiter_EBTEN);
    bool tmp_arbiter_AHB_WTEN = false;
    ccss_set_parameter("arbiter.AHB_WTEN", tmp_arbiter_AHB_WTEN);
    bool tmp_arbiter_DoTrace = false;
    ccss_set_parameter("arbiter.DoTrace", tmp_arbiter_DoTrace);
    bool tmp_arbiter_CombinatoricMode = false;
    ccss_set_parameter("arbiter.CombinatoricMode", tmp_arbiter_CombinatoricMode);
    arbiter = new DW_AHB_Arbiter("arbiter");
    unsigned  int tmp_arm946_MasterIDbiu = 1;
    ccss_set_parameter("arm946.MasterIDbiu", tmp_arm946_MasterIDbiu);
    arm946 = new DW_arm946es("arm946",1, true, BigEndian, ProgName, Debugger);
    bool tmp_decoder_DoTrace = true;
    ccss_set_parameter("decoder.DoTrace", tmp_decoder_DoTrace);
    decoder = new DW_AHB_Decoder("decoder");
    int tmp_dtcm_SlaveID = 0;
    ccss_set_parameter("dtcm.SlaveID", tmp_dtcm_SlaveID);
    int tmp_dtcm_ReadWaitStates = 0;
    ccss_set_parameter("dtcm.ReadWaitStates", tmp_dtcm_ReadWaitStates);
    int tmp_dtcm_WriteWaitStates = 0;
    ccss_set_parameter("dtcm.WriteWaitStates", tmp_dtcm_WriteWaitStates);
    bool tmp_dtcm_ReadOnly = false;
    ccss_set_parameter("dtcm.ReadOnly", tmp_dtcm_ReadOnly);
    bool tmp_dtcm_DoTrace = false;
    ccss_set_parameter("dtcm.DoTrace", tmp_dtcm_DoTrace);
    bool tmp_dtcm_WarningEnable = false;
    ccss_set_parameter("dtcm.WarningEnable", tmp_dtcm_WarningEnable);
    dtcm = new DW_TCMemory("dtcm", TCM_4KB, 0x20000);
    int tmp_itcm_SlaveID = 0;
    ccss_set_parameter("itcm.SlaveID", tmp_itcm_SlaveID);
    int tmp_itcm_ReadWaitStates = 0;
    ccss_set_parameter("itcm.ReadWaitStates", tmp_itcm_ReadWaitStates);
    int tmp_itcm_WriteWaitStates = 0;
    ccss_set_parameter("itcm.WriteWaitStates", tmp_itcm_WriteWaitStates);
    bool tmp_itcm_ReadOnly = false;
    ccss_set_parameter("itcm.ReadOnly", tmp_itcm_ReadOnly);
    bool tmp_itcm_DoTrace = false;
    ccss_set_parameter("itcm.DoTrace", tmp_itcm_DoTrace);
    bool tmp_itcm_WarningEnable = false;
    ccss_set_parameter("itcm.WarningEnable", tmp_itcm_WarningEnable);
    itcm = new DW_TCMemory("itcm", TCM_4KB, 0xff000);

    AHBMonitor->p(*ahb_bus);
    arm946->biu(*ahb_bus);
    arm946->dtcm(*dtcm);
    arm946->itcm(*itcm);
    ahb_bus->decoder_port(*decoder);
    ahb_bus->arbiter_port(*arbiter);
    arbiter->ahb_wt_aps(C173);
    arbiter->ahbarbint(C175);
    ahb_bus->slave_port(*ProgMem);
    ahb_bus->slave_port(*StackMem);
    ahb_bus->slave_port(*DataMem);
    ahb_bus->slave_port(*IntrGen);
    FalseGen->Out(C193);
    arbiter->pause(C193);
    arm946->DHClkEn(C204);
    ClockGen->DBusHClkEn(C204);
    ClockGen->IBusHClk(C205);
    ClockGen->IBusHClkEn(C206);
    arbiter->ahb_wt_mask(C207);
    ahb_bus->hclk(HCLK);
    IntrGen->clk(HCLK);
    ClockGen->DBusHClk(HCLK);
    ProgMem->hresetn(High);
    StackMem->hresetn(High);
    DataMem->hresetn(High);
    ahb_bus->hresetn(High);
    ResetGen->Out(High);
    decoder->remap_n(High);
    ClockGen->n_reset(High);
    arm946->INITRAM(INITRAM);
    IntrGen->INITRAM(INITRAM);
    arm946->VINITHI(VINITHI);
    IntrGen->VINITHI(VINITHI);
    arm946->clock(clk);
    ClockGen->Clk(clk);
    arm946->nFIQ(nFIQ);
    IntrGen->nFIQ(nFIQ);
    arm946->nIRQ(nIRQ);
    IntrGen->nIRQ(nIRQ);
    arm946->nRESET(nRESET);
    IntrGen->nRESET(nRESET);
}

void DW_arm946_example::DeleteInstances() {
    if (AHBMonitor) {delete AHBMonitor; AHBMonitor = 0;}
    if (ClockGen) {delete ClockGen; ClockGen = 0;}
    if (DataMem) {delete DataMem; DataMem = 0;}
    if (FalseGen) {delete FalseGen; FalseGen = 0;}
    if (IntrGen) {delete IntrGen; IntrGen = 0;}
    if (ProgMem) {delete ProgMem; ProgMem = 0;}
    if (ResetGen) {delete ResetGen; ResetGen = 0;}
    if (StackMem) {delete StackMem; StackMem = 0;}
    if (ahb_bus) {delete ahb_bus; ahb_bus = 0;}
    if (arbiter) {delete arbiter; arbiter = 0;}
    if (arm946) {delete arm946; arm946 = 0;}
    if (decoder) {delete decoder; decoder = 0;}
    if (dtcm) {delete dtcm; dtcm = 0;}
    if (itcm) {delete itcm; itcm = 0;}
}

