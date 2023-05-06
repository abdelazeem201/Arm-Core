------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Model Technology ModelSim(tm) Simulation Macro File
--
--  Follow the itemized instructions below in order to customize
--  the STARFIRE(tm) simulation model simulation script to meet
--  your application needs.
--
--  To execute this macro file from the ModelSim(tm) VHDL simulator:
--
--    Using the "File->Execute Macro" menu option select this 
--    file in the browser window and click on "Open".
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  1. Change the PROJECT_BASE variable to your project directory:
--
------------------------------------------------------------------------
set PROJECT_BASE ./


# Do not change this line
cd $PROJECT_BASE

------------------------------------------------------------------------
--
--  2. Change the name of the configuration to match your design (make
--     sure you use all lower case letters, regardless of actual 
--     configuration name):
--
------------------------------------------------------------------------
vsim -t ps system_config

