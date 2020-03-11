-------------------------------------------------------------------------------
--! @file      blinkylight.vhd
--! @author    Michael Wurm <wurm.michael95@gmail.com>
--! @copyright 2017-2019 Michael Wurm
--! @brief     BlinkyLight implementation.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library blinkylightlib;
use blinkylightlib.blinkylight_pkg.all;

--! @brief Entity declaration of blinkylight
--! @details
--! The blinkylight implementation.

entity blinkylight is
  port (
    CLK50 : in  std_logic;
    KEY   : in  std_logic_vector(0 downto 0);
    SW    : in  std_logic_vector(9 downto 0);
    LEDR  : out std_logic_vector(9 downto 0));

end entity blinkylight;

--! (((Runtime configurable))) RTL implementation of blinkylight
architecture rtl of blinkylight is
  -----------------------------------------------------------------------------
  --! @name Types and Constants
  -----------------------------------------------------------------------------
  --! @{

  --! @}
  -----------------------------------------------------------------------------
  --! @name Internal Registers
  -----------------------------------------------------------------------------
  --! @{

  --! @}
  -----------------------------------------------------------------------------
  --! @name Internal Wires
  -----------------------------------------------------------------------------
  --! @{

  --! @}

begin -- architecture rtl

  -----------------------------------------------------------------------------
  -- Outputs
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Signal Assignments
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Instantiations
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Registers
  -----------------------------------------------------------------------------

end architecture rtl;
