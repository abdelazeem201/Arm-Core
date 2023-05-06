------------------------------------------------------------------------
--
--  Copyright (C) 1998-1999, Annapolis Micro Systems, Inc.
--  All Rights Reserved.
--
------------------------------------------------------------------------

------------------------------------------------------------------------
--
--  Entity        : LAD_Bus_Basic_IO
--
--  Architecture  : Structure
--
--  Filename      : lad_bus_io_entarch.vhd
--
--  Date          : 9/3/99
--
--  Description   : Models the interface to the PEX LAD-bus pads.
--
------------------------------------------------------------------------

------------------------------- Glossary -------------------------------
--
--  Name Key:
--  =========
--  _AS       : Address Strobe
--  _CE       : Clock Enable
--  _CS       : Chip Select
--  _DS       : Data Strobe
--  _EN       : Enable
--  _OE       : Output Enable
--  _RD       : Read Select
--  _WE       : Write Enable
--  _WR       : Write Select
--  _d[d...]  : Delayed (registered) signal (each 'd' denotes one 
--              level of delay)
--  _n        : Active low signals (must be last part of name)
--
--  Port Name             Width    Dir   Description
--  ====================  ======   ===   ===============================
--  Pads.Addr_Data          32      B    Address/data bus pads
--  Pads.DS_n                1      I    Data strobe input pad
--  Pads.Reg_n               1      I    Register select input pad
--  Pads.WR_n                1      I    Read/Write select input pad
--  Pads.CS_n                1      I    Chip-select input pad
--  Pads.Int_Req_n           1      O    Interrupt request output pad
--  Pads.DMA_Chan            2      O    DMA channel number indicator
--  Pads.DMA_Stat            2      O    DMA channel status flags
--  User_In.Addr_Data_In    32      O    Incoming address/data
--  User_In.DS_n             1      O    Data strobe
--  User_In.Reg_n            1      O    Register select
--  User_In.WR_n             1      O    Read/Write strobe
--  User_In.CS_n             1      O    Chip-select
--  User_In.DMA_Chan         2      O    DMA channel number indicator
--  User_Out.Addr_Data_Out  32      I    Outgoing data
--  User_Out.Addr_Data_OE_n 32      I    Individual tri-state control
--  User_Out.Int_Req_n       1      I    Interrupt request
--  User_Out.DMA_Stat        2      I    DMA channel status flags
--
------------------------------------------------------------------------

-------------------------- Library Declarations ------------------------

library IEEE, PEX_Lib, SYSTEM;
use IEEE.std_logic_1164.all;
use PEX_Lib.PE_Package.all;
use SYSTEM.Xilinx_Package.all;

--------------------------- Entity Declaration -------------------------

entity LAD_Bus_Basic_IO is
  port
  (
    Pads      : inout LAD_Bus_Pads_Type;
    User_In   :   out LAD_Bus_Basic_IO_In_Type;
    User_Out  : in    LAD_Bus_Basic_IO_Out_Type
  );
end LAD_Bus_Basic_IO;

------------------------ Architecture Declaration ----------------------

architecture Structure of LAD_Bus_Basic_IO is

  attribute nodelay : string;
  attribute nodelay of U_DS : label is " ";
  attribute nodelay of U_Reg : label is " ";
  attribute nodelay of U_WR : label is " ";
  attribute nodelay of U_CS : label is " ";
  attribute nodelay of U_Data_Out_0 : label is " ";
  attribute nodelay of U_Data_Out_1 : label is " ";
  attribute nodelay of U_Data_Out_2 : label is " ";
  attribute nodelay of U_Data_Out_3 : label is " ";
  attribute nodelay of U_Data_Out_4 : label is " ";
  attribute nodelay of U_Data_Out_5 : label is " ";
  attribute nodelay of U_Data_Out_6 : label is " ";
  attribute nodelay of U_Data_Out_7 : label is " ";
  attribute nodelay of U_Data_Out_8 : label is " ";
  attribute nodelay of U_Data_Out_9 : label is " ";
  attribute nodelay of U_Data_Out_10 : label is " ";
  attribute nodelay of U_Data_Out_11 : label is " ";
  attribute nodelay of U_Data_Out_12 : label is " ";
  attribute nodelay of U_Data_Out_13 : label is " ";
  attribute nodelay of U_Data_Out_14 : label is " ";
  attribute nodelay of U_Data_Out_15 : label is " ";
  attribute nodelay of U_Data_Out_16 : label is " ";
  attribute nodelay of U_Data_Out_17 : label is " ";
  attribute nodelay of U_Data_Out_18 : label is " ";
  attribute nodelay of U_Data_Out_19 : label is " ";
  attribute nodelay of U_Data_Out_20 : label is " ";
  attribute nodelay of U_Data_Out_21 : label is " ";
  attribute nodelay of U_Data_Out_22 : label is " ";
  attribute nodelay of U_Data_Out_23 : label is " ";
  attribute nodelay of U_Data_Out_24 : label is " ";
  attribute nodelay of U_Data_Out_25 : label is " ";
  attribute nodelay of U_Data_Out_26 : label is " ";
  attribute nodelay of U_Data_Out_27 : label is " ";
  attribute nodelay of U_Data_Out_28 : label is " ";
  attribute nodelay of U_Data_Out_29 : label is " ";
  attribute nodelay of U_Data_Out_30 : label is " ";
  attribute nodelay of U_Data_Out_31 : label is " ";
  attribute nodelay of U_Addr_Data_In_0 : label is " ";
  attribute nodelay of U_Addr_Data_In_1 : label is " ";
  attribute nodelay of U_Addr_Data_In_2 : label is " ";
  attribute nodelay of U_Addr_Data_In_3 : label is " ";
  attribute nodelay of U_Addr_Data_In_4 : label is " ";
  attribute nodelay of U_Addr_Data_In_5 : label is " ";
  attribute nodelay of U_Addr_Data_In_6 : label is " ";
  attribute nodelay of U_Addr_Data_In_7 : label is " ";
  attribute nodelay of U_Addr_Data_In_8 : label is " ";
  attribute nodelay of U_Addr_Data_In_9 : label is " ";
  attribute nodelay of U_Addr_Data_In_10 : label is " ";
  attribute nodelay of U_Addr_Data_In_11 : label is " ";
  attribute nodelay of U_Addr_Data_In_12 : label is " ";
  attribute nodelay of U_Addr_Data_In_13 : label is " ";
  attribute nodelay of U_Addr_Data_In_14 : label is " ";
  attribute nodelay of U_Addr_Data_In_15 : label is " ";
  attribute nodelay of U_Addr_Data_In_16 : label is " ";
  attribute nodelay of U_Addr_Data_In_17 : label is " ";
  attribute nodelay of U_Addr_Data_In_18 : label is " ";
  attribute nodelay of U_Addr_Data_In_19 : label is " ";
  attribute nodelay of U_Addr_Data_In_20 : label is " ";
  attribute nodelay of U_Addr_Data_In_21 : label is " ";
  attribute nodelay of U_Addr_Data_In_22 : label is " ";
  attribute nodelay of U_Addr_Data_In_23 : label is " ";
  attribute nodelay of U_Addr_Data_In_24 : label is " ";
  attribute nodelay of U_Addr_Data_In_25 : label is " ";
  attribute nodelay of U_Addr_Data_In_26 : label is " ";
  attribute nodelay of U_Addr_Data_In_27 : label is " ";
  attribute nodelay of U_Addr_Data_In_28 : label is " ";
  attribute nodelay of U_Addr_Data_In_29 : label is " ";
  attribute nodelay of U_Addr_Data_In_30 : label is " ";
  attribute nodelay of U_Addr_Data_In_31 : label is " ";


begin

  Init_LAD_Bus_Pads ( Pads );
  Init_LAD_Bus_Basic_IO ( User_In );

    U_DS : IBUF
      port map
      (
        I => Pads.DS_n,
        O => User_In.DS_n
      );

    U_Data_Out_0 : OBUFT
      port map
      (
        O => Pads.Addr_Data(0),
        I => User_Out.Addr_Data_Out(0),
        T => User_Out.Addr_Data_OE_n(0)
      );

    U_Addr_Data_In_0 : IBUF
      port map
      (
        I => Pads.Addr_Data(0),
        O => User_In.Addr_Data_In(0)
      );

    U_Data_Out_1 : OBUFT
      port map
      (
        O => Pads.Addr_Data(1),
        I => User_Out.Addr_Data_Out(1),
        T => User_Out.Addr_Data_OE_n(1)
      );

    U_Addr_Data_In_1 : IBUF
      port map
      (
        I => Pads.Addr_Data(1),
        O => User_In.Addr_Data_In(1)
      );

    U_Data_Out_2 : OBUFT
      port map
      (
        O => Pads.Addr_Data(2),
        I => User_Out.Addr_Data_Out(2),
        T => User_Out.Addr_Data_OE_n(2)
      );

    U_Addr_Data_In_2 : IBUF
      port map
      (
        I => Pads.Addr_Data(2),
        O => User_In.Addr_Data_In(2)
      );

    U_Data_Out_3 : OBUFT
      port map
      (
        O => Pads.Addr_Data(3),
        I => User_Out.Addr_Data_Out(3),
        T => User_Out.Addr_Data_OE_n(3)
      );

    U_Addr_Data_In_3 : IBUF
      port map
      (
        I => Pads.Addr_Data(3),
        O => User_In.Addr_Data_In(3)
      );

    U_Data_Out_4 : OBUFT
      port map
      (
        O => Pads.Addr_Data(4),
        I => User_Out.Addr_Data_Out(4),
        T => User_Out.Addr_Data_OE_n(4)
      );

    U_Addr_Data_In_4 : IBUF
      port map
      (
        I => Pads.Addr_Data(4),
        O => User_In.Addr_Data_In(4)
      );

    U_Data_Out_5 : OBUFT
      port map
      (
        O => Pads.Addr_Data(5),
        I => User_Out.Addr_Data_Out(5),
        T => User_Out.Addr_Data_OE_n(5)
      );

    U_Addr_Data_In_5 : IBUF
      port map
      (
        I => Pads.Addr_Data(5),
        O => User_In.Addr_Data_In(5)
      );

    U_Data_Out_6 : OBUFT
      port map
      (
        O => Pads.Addr_Data(6),
        I => User_Out.Addr_Data_Out(6),
        T => User_Out.Addr_Data_OE_n(6)
      );

    U_Addr_Data_In_6 : IBUF
      port map
      (
        I => Pads.Addr_Data(6),
        O => User_In.Addr_Data_In(6)
      );

    U_Data_Out_7 : OBUFT
      port map
      (
        O => Pads.Addr_Data(7),
        I => User_Out.Addr_Data_Out(7),
        T => User_Out.Addr_Data_OE_n(7)
      );

    U_Addr_Data_In_7 : IBUF
      port map
      (
        I => Pads.Addr_Data(7),
        O => User_In.Addr_Data_In(7)
      );

    U_Data_Out_8 : OBUFT
      port map
      (
        O => Pads.Addr_Data(8),
        I => User_Out.Addr_Data_Out(8),
        T => User_Out.Addr_Data_OE_n(8)
      );

    U_Addr_Data_In_8 : IBUF
      port map
      (
        I => Pads.Addr_Data(8),
        O => User_In.Addr_Data_In(8)
      );

    U_Data_Out_9 : OBUFT
      port map
      (
        O => Pads.Addr_Data(9),
        I => User_Out.Addr_Data_Out(9),
        T => User_Out.Addr_Data_OE_n(9)
      );

    U_Addr_Data_In_9 : IBUF
      port map
      (
        I => Pads.Addr_Data(9),
        O => User_In.Addr_Data_In(9)
      );

    U_Data_Out_10 : OBUFT
      port map
      (
        O => Pads.Addr_Data(10),
        I => User_Out.Addr_Data_Out(10),
        T => User_Out.Addr_Data_OE_n(10)
      );

    U_Addr_Data_In_10 : IBUF
      port map
      (
        I => Pads.Addr_Data(10),
        O => User_In.Addr_Data_In(10)
      );

    U_Data_Out_11 : OBUFT
      port map
      (
        O => Pads.Addr_Data(11),
        I => User_Out.Addr_Data_Out(11),
        T => User_Out.Addr_Data_OE_n(11)
      );

    U_Addr_Data_In_11 : IBUF
      port map
      (
        I => Pads.Addr_Data(11),
        O => User_In.Addr_Data_In(11)
      );

    U_Data_Out_12 : OBUFT
      port map
      (
        O => Pads.Addr_Data(12),
        I => User_Out.Addr_Data_Out(12),
        T => User_Out.Addr_Data_OE_n(12)
      );

    U_Addr_Data_In_12 : IBUF
      port map
      (
        I => Pads.Addr_Data(12),
        O => User_In.Addr_Data_In(12)
      );

    U_Data_Out_13 : OBUFT
      port map
      (
        O => Pads.Addr_Data(13),
        I => User_Out.Addr_Data_Out(13),
        T => User_Out.Addr_Data_OE_n(13)
      );

    U_Addr_Data_In_13 : IBUF
      port map
      (
        I => Pads.Addr_Data(13),
        O => User_In.Addr_Data_In(13)
      );

    U_Data_Out_14 : OBUFT
      port map
      (
        O => Pads.Addr_Data(14),
        I => User_Out.Addr_Data_Out(14),
        T => User_Out.Addr_Data_OE_n(14)
      );

    U_Addr_Data_In_14 : IBUF
      port map
      (
        I => Pads.Addr_Data(14),
        O => User_In.Addr_Data_In(14)
      );

    U_Data_Out_15 : OBUFT
      port map
      (
        O => Pads.Addr_Data(15),
        I => User_Out.Addr_Data_Out(15),
        T => User_Out.Addr_Data_OE_n(15)
      );

    U_Addr_Data_In_15 : IBUF
      port map
      (
        I => Pads.Addr_Data(15),
        O => User_In.Addr_Data_In(15)
      );

    U_Data_Out_16 : OBUFT
      port map
      (
        O => Pads.Addr_Data(16),
        I => User_Out.Addr_Data_Out(16),
        T => User_Out.Addr_Data_OE_n(16)
      );

    U_Addr_Data_In_16 : IBUF
      port map
      (
        I => Pads.Addr_Data(16),
        O => User_In.Addr_Data_In(16)
      );

    U_Data_Out_17 : OBUFT
      port map
      (
        O => Pads.Addr_Data(17),
        I => User_Out.Addr_Data_Out(17),
        T => User_Out.Addr_Data_OE_n(17)
      );

    U_Addr_Data_In_17 : IBUF
      port map
      (
        I => Pads.Addr_Data(17),
        O => User_In.Addr_Data_In(17)
      );

    U_Data_Out_18 : OBUFT
      port map
      (
        O => Pads.Addr_Data(18),
        I => User_Out.Addr_Data_Out(18),
        T => User_Out.Addr_Data_OE_n(18)
      );

    U_Addr_Data_In_18 : IBUF
      port map
      (
        I => Pads.Addr_Data(18),
        O => User_In.Addr_Data_In(18)
      );

    U_Data_Out_19 : OBUFT
      port map
      (
        O => Pads.Addr_Data(19),
        I => User_Out.Addr_Data_Out(19),
        T => User_Out.Addr_Data_OE_n(19)
      );

    U_Addr_Data_In_19 : IBUF
      port map
      (
        I => Pads.Addr_Data(19),
        O => User_In.Addr_Data_In(19)
      );

    U_Data_Out_20 : OBUFT
      port map
      (
        O => Pads.Addr_Data(20),
        I => User_Out.Addr_Data_Out(20),
        T => User_Out.Addr_Data_OE_n(20)
      );

    U_Addr_Data_In_20 : IBUF
      port map
      (
        I => Pads.Addr_Data(20),
        O => User_In.Addr_Data_In(20)
      );

    U_Data_Out_21 : OBUFT
      port map
      (
        O => Pads.Addr_Data(21),
        I => User_Out.Addr_Data_Out(21),
        T => User_Out.Addr_Data_OE_n(21)
      );

    U_Addr_Data_In_21 : IBUF
      port map
      (
        I => Pads.Addr_Data(21),
        O => User_In.Addr_Data_In(21)
      );

    U_Data_Out_22 : OBUFT
      port map
      (
        O => Pads.Addr_Data(22),
        I => User_Out.Addr_Data_Out(22),
        T => User_Out.Addr_Data_OE_n(22)
      );

    U_Addr_Data_In_22 : IBUF
      port map
      (
        I => Pads.Addr_Data(22),
        O => User_In.Addr_Data_In(22)
      );

    U_Data_Out_23 : OBUFT
      port map
      (
        O => Pads.Addr_Data(23),
        I => User_Out.Addr_Data_Out(23),
        T => User_Out.Addr_Data_OE_n(23)
      );

    U_Addr_Data_In_23 : IBUF
      port map
      (
        I => Pads.Addr_Data(23),
        O => User_In.Addr_Data_In(23)
      );

    U_Data_Out_24 : OBUFT
      port map
      (
        O => Pads.Addr_Data(24),
        I => User_Out.Addr_Data_Out(24),
        T => User_Out.Addr_Data_OE_n(24)
      );

    U_Addr_Data_In_24 : IBUF
      port map
      (
        I => Pads.Addr_Data(24),
        O => User_In.Addr_Data_In(24)
      );

    U_Data_Out_25 : OBUFT
      port map
      (
        O => Pads.Addr_Data(25),
        I => User_Out.Addr_Data_Out(25),
        T => User_Out.Addr_Data_OE_n(25)
      );

    U_Addr_Data_In_25 : IBUF
      port map
      (
        I => Pads.Addr_Data(25),
        O => User_In.Addr_Data_In(25)
      );

    U_Data_Out_26 : OBUFT
      port map
      (
        O => Pads.Addr_Data(26),
        I => User_Out.Addr_Data_Out(26),
        T => User_Out.Addr_Data_OE_n(26)
      );

    U_Addr_Data_In_26 : IBUF
      port map
      (
        I => Pads.Addr_Data(26),
        O => User_In.Addr_Data_In(26)
      );

    U_Data_Out_27 : OBUFT
      port map
      (
        O => Pads.Addr_Data(27),
        I => User_Out.Addr_Data_Out(27),
        T => User_Out.Addr_Data_OE_n(27)
      );

    U_Addr_Data_In_27 : IBUF
      port map
      (
        I => Pads.Addr_Data(27),
        O => User_In.Addr_Data_In(27)
      );

    U_Data_Out_28 : OBUFT
      port map
      (
        O => Pads.Addr_Data(28),
        I => User_Out.Addr_Data_Out(28),
        T => User_Out.Addr_Data_OE_n(28)
      );

    U_Addr_Data_In_28 : IBUF
      port map
      (
        I => Pads.Addr_Data(28),
        O => User_In.Addr_Data_In(28)
      );

    U_Data_Out_29 : OBUFT
      port map
      (
        O => Pads.Addr_Data(29),
        I => User_Out.Addr_Data_Out(29),
        T => User_Out.Addr_Data_OE_n(29)
      );

    U_Addr_Data_In_29 : IBUF
      port map
      (
        I => Pads.Addr_Data(29),
        O => User_In.Addr_Data_In(29)
      );

    U_Data_Out_30 : OBUFT
      port map
      (
        O => Pads.Addr_Data(30),
        I => User_Out.Addr_Data_Out(30),
        T => User_Out.Addr_Data_OE_n(30)
      );

    U_Addr_Data_In_30 : IBUF
      port map
      (
        I => Pads.Addr_Data(30),
        O => User_In.Addr_Data_In(30)
      );

    U_Data_Out_31 : OBUFT
      port map
      (
        O => Pads.Addr_Data(31),
        I => User_Out.Addr_Data_Out(31),
        T => User_Out.Addr_Data_OE_n(31)
      );

    U_Addr_Data_In_31 : IBUF
      port map
      (
        I => Pads.Addr_Data(31),
        O => User_In.Addr_Data_In(31)
      );

  U_Reg : IBUF
    port map
    (
      I => Pads.Reg_n,
      O => User_In.Reg_n
    );

  U_WR : IBUF
    port map
    (
      I => Pads.WR_n,
      O => User_In.WR_n
    );

  U_CS : IBUF
    port map
    (
      I => Pads.CS_n,
      O => User_In.CS_n
    );

  U_Int_Req : OBUF
    port map
    (
      O => Pads.Int_Req_n,
      I => User_Out.Int_Req_n
    );

    U_DMA_Chan_0 : IBUF
      port map
      (
        I => Pads.DMA_Chan(0),
        O => User_In.DMA_Chan(0)
      );

    U_DMA_Chan_1 : IBUF
      port map
      (
        I => Pads.DMA_Chan(1),
        O => User_In.DMA_Chan(1)
      );

    U_DMA_Stat_0 : OBUF
      port map
      (
        O => Pads.DMA_Stat(0),
        I => User_Out.DMA_Stat(0)
      );

    U_DMA_Stat_1 : OBUF
      port map
      (
        O => Pads.DMA_Stat(1),
        I => User_Out.DMA_Stat(1)
      );

end Structure;

