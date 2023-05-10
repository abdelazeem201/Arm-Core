//=============================================================================
//  The confidential and proprietary information contained in this file may
//  only be used by a person authorised under and to the extent permitted
//  by a subsisting licensing agreement from ARM Limited.
//  
//                   (C) COPYRIGHT 2010 ARM Limited.
//                           ALL RIGHTS RESERVED
//  
//  This entire notice must be reproduced on all copies of this file
//  and copies of this file may only be made by a person if such person is
//  permitted to do so under the terms of a subsisting license agreement
//  from ARM Limited.
//  
//------------------------------------------------------------------------------
//  Version and Release Control Information:
//  
//  File Revision       : 88733
//
//  Date                :  2010-03-26 12:27:41 +0000 (Fri, 26 Mar 2010)
//  
//  Release Information : BP063-VL-70004-r0p0-00rel0
//  
//------------------------------------------------------------------------------
//  Purpose             : AXI4-Lite Protocol Assertion message undefines
//==============================================================================

`include "Axi4PC_message_undefs.v"
`ifdef AXI4LITEPC_MESSAGES
        `undef ERRS_AXI4LITE_BRESP_EXOKAY 
        `undef ERRS_AXI4LITE_RRESP_EXOKAY 
        `undef AUXM_AXI4LITE_DATA_WIDTH
        `undef AXI4LITEPC_MESSAGES 
`endif

//============================ End ===========================================--
