-- This file is part of Prol16.
--
-- Copyright (C) 2005-2008 Rainer Findenig
-- Based on work done by Markus Lindorfer
--
-- Prol16 is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- Prol16 is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with Prol16.  If not, see <http://www.gnu.org/licenses/>.

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity spikefilter_tb is

end spikefilter_tb;

-------------------------------------------------------------------------------

architecture bhv of spikefilter_tb is

  component spikefilter
    generic (
      no_sync_ffs_g      :     integer);
    port (
      clk_i              : in  std_ulogic;
      res_i              : in  std_ulogic;
      input_pin_i        : in  std_ulogic;
      rise_edge_on_pin_o : out std_ulogic;
      fall_edge_on_pin_o : out std_ulogic;
      level_on_pin_o     : out std_ulogic);
  end component;

  -- component generics
  constant no_sync_ffs_g : integer := 3;

  -- component ports
  signal res_i              : std_ulogic;
  signal input_pin_i        : std_ulogic;
  signal rise_edge_on_pin_o : std_ulogic;
  signal fall_edge_on_pin_o : std_ulogic;
  signal level_on_pin_o     : std_ulogic;

  -- clock
  signal Clk : std_logic := '1';

  constant Frequency : integer := 20000000;
  constant CycleTime : time    := (1e9/Frequency) * 1 ns;
begin  -- bhv

  -- component instantiation
  DUT : spikefilter
    generic map (
      no_sync_ffs_g      => no_sync_ffs_g)
    port map (
      clk_i              => Clk,
      res_i              => res_i,
      input_pin_i        => input_pin_i,
      rise_edge_on_pin_o => rise_edge_on_pin_o,
      fall_edge_on_pin_o => fall_edge_on_pin_o,
      level_on_pin_o     => level_on_pin_o);

  -- clock generation
  Clk <= not Clk after CycleTime;

  res_i <= '0', '1' after 30 ns;

  input_pin_i <= '0' after 80 ns,
                 '1' after 160 ns,
                 '0' after 170 ns,
                 '1' after 180 ns,
                 '0' after 240 ns,
                 '1' after 500 ns,
                 'L' after 850 ns,
                 'H' after 950 ns,
                 'L' after 1300 ns,
                 -- start violating the setup time, minimal setup time = approx 85 ps
                 '1' after 2000 ns - 20 ps,
                 '0' after 3000 ns - 20 ps,
                 '1' after 4000 ns - 10 ps,
                 '0' after 5000 ns - 10 ps,
                 -- violate the hold time
                 '1' after 10000 ns,
                 '0' after 11000 ns,
                 '1' after 12000 ns,
                 '0' after 13000 ns
;

end bhv;

-------------------------------------------------------------------------------

configuration spikefilter_tb_bhv_cfg of spikefilter_tb is
  for bhv
  end for;
end spikefilter_tb_bhv_cfg;

-------------------------------------------------------------------------------
