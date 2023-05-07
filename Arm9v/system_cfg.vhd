------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Configuration : System_Config
--
--  Entity        : System
--
--  Filename      : system_cfg.vhd
--
--  Date          : 3/24/99
--
--  Description   : Configures a system model made up of a host device
--                  and one or more STARFIRE(tm) devices.
--  https://www.micro-semiconductor.sg/datasheet/07-PEX8311RDK.pdf
------------------------------------------------------------------------

library SYSTEM, PEX_Lib;

------------------------ Configuration Declaration ---------------------

configuration System_Config of System is

  for Structure

    --------------------------------------------------------------------
    --
    --  1.  Change the name of the "Inactive" Host architecture to 
    --      match the architecture of your host design (must be 
    --      something other than "Inactive").
    --
    --------------------------------------------------------------------
    for U_Host : Host
      use entity SYSTEM.Host ( Mem_Copy );
    end for;

    for U_STARFIRE_0 : STARFIRE

      use entity SYSTEM.STARFIRE ( Standard );

      for Standard

        ----------------------------------------------------------------
        --
        --  2.  Change the name of the "Inactive" PE1 architecture to 
        --      match the architecture of your PE1 design (must be 
        --      something other than "Inactive").
        --
        ----------------------------------------------------------------
        for U_PE1 : PEX
          use entity PEX_Lib.PEX ( Mem_Copy );
        end for;

        ----------------------------------------------------------------
        --
        --  3.  Change the architecture of the PE1 left Mem_Bank to
        --      meet your design's memory needs:
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
        ----------------------------------------------------------------
        for U_PE1_Left_Mem : Memory_Bank
          use entity SYSTEM.Memory_Bank ( Static )
            generic map
            (
              MEM_SIZE => 2 ** 18
            );
        end for;

        ----------------------------------------------------------------
        --
        --  4.  Change the architecture of the PE1 right Mem_Bank to
        --      meet your design's memory needs:
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
        ----------------------------------------------------------------
        for U_PE1_Right_Mem : Memory_Bank
          use entity SYSTEM.Memory_Bank ( Static )
            generic map
            (
              MEM_SIZE => 2 ** 16
            );
        end for;

        ----------------------------------------------------------------
        --
        --  5.  Change the configuration of the PE1 mezzanine card to
        --      match the type of mezzanine card you are using with
        --      your design.  Choose from the following configurations:
        --
        --          Empty_Mezz_Card_Config
        --          Mezz_Mem_Card_Config
        --
        ----------------------------------------------------------------
        for U_PE1_Mezz_Card : Mezzanine_Card
          use configuration SYSTEM.Empty_Mezz_Card_Config;
        end for;

        ----------------------------------------------------------------
        --
        --  6.  Change the configuration of the I/O card to match 
        --      the type of I/O card you are using with your design.
        --      Choose from the following configurations:
        --
        --          Empty_IO_Card_Config
        --
        ----------------------------------------------------------------
        for U_IO_Card : IO_Card
          use configuration SYSTEM.Empty_IO_Card_Config;
        end for;

      end for;

    end for;

  end for;

end configuration;

