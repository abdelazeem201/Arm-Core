------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Configuration : Mezz_Mem_Card_Config
--
--  Entity        : Mezzanine_Card
--
--  Filename      : mezz_mem_card_cfg.vhd
--
--  Date          : 3/3/99
--
--  Description   : A sample configuration file for the mezzanine
--                  memory card.  Copy this file and follow the 
--                  instructions below in order to customize the
--                  model for your application.
--
------------------------------------------------------------------------

library SYSTEM;

------------------------ Configuration Declaration ---------------------

configuration Mezz_Mem_Card_Config of Mezzanine_Card is
  for Mezz_Mem_Card
    for U_Left_Bank : Shared_Memory64_Bank
      use entity SYSTEM.Shared_Memory64_Bank ( Standard );
      for Standard

        for U_Mem0 : Memory64_Bank
          --------------------------------------------------------------
          --
          --  1.  Change the architecture of the Left Mem64_Bank 0 
          --      to meet your design's memory needs:
          --
          --        Empty   : No memory needed
          --        Static  : Memory needed by the application
          --
          --      Also, change size of the memory being modeled by 
          --      modifying the MEM_SIZE generic to the size of memory
          --      used by the application (not necessarily the size of
          --      the memory on the actual hardware).  Keep in mind that
          --      simulation times can become very slow as the memory
          --      model size gets larger.
          --      
          --
          --------------------------------------------------------------
          use entity SYSTEM.Memory64_Bank ( Static )
          generic map ( MEM_SIZE => 2**8 );
        end for;
  
        for U_Mem1 : Memory64_Bank
          --------------------------------------------------------------
          --
          --  2.  Change the architecture of the Left Mem64_Bank 1 
          --      to meet your design's memory needs:
          --
          --        Empty   : No memory needed
          --        Static  : Memory needed by the application
          --
          --      Also, change size of the memory being modeled by 
          --      modifying the MEM_SIZE generic to the size of memory
          --      used by the application (not necessarily the size of
          --      the memory on the actual hardware).  Keep in mind that
          --      simulation times can become very slow as the memory
          --      model size gets larger.
          --      
          --
          --------------------------------------------------------------
          use entity SYSTEM.Memory64_Bank ( Static )
          generic map ( MEM_SIZE => 2**8 );
        end for;

      end for;
    end for;
    for U_Right_Bank : Shared_Memory64_Bank
      use entity SYSTEM.Shared_Memory64_Bank ( Standard );
      for Standard

        for U_Mem0 : Memory64_Bank
          --------------------------------------------------------------
          --
          --  3.  Change the architecture of the Right Mem64_Bank 0 
          --      to meet your design's memory needs:
          --
          --        Empty   : No memory needed
          --        Static  : Memory needed by the application
          --
          --      Also, change size of the memory being modeled by 
          --      modifying the MEM_SIZE generic to the size of memory
          --      used by the application (not necessarily the size of
          --      the memory on the actual hardware).  Keep in mind that
          --      simulation times can become very slow as the memory
          --      model size gets larger.
          --      
          --
          --------------------------------------------------------------
          use entity SYSTEM.Memory64_Bank ( Static )
          generic map ( MEM_SIZE => 2**8 );
        end for;
  
        for U_Mem1 : Memory64_Bank
          --------------------------------------------------------------
          --
          --  4.  Change the architecture of the Right Mem64_Bank 1 
          --      to meet your design's memory needs:
          --
          --        Empty   : No memory needed
          --        Static  : Memory needed by the application
          --
          --      Also, change size of the memory being modeled by 
          --      modifying the MEM_SIZE generic to the size of memory
          --      used by the application (not necessarily the size of
          --      the memory on the actual hardware).  Keep in mind that
          --      simulation times can become very slow as the memory
          --      model size gets larger.
          --      
          --
          --------------------------------------------------------------
          use entity SYSTEM.Memory64_Bank ( Static )
          generic map ( MEM_SIZE => 2**19 );
        end for;

      end for;
    end for;

  end for;
end configuration;

