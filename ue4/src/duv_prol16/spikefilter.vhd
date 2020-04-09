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

entity spikefilter is
  
  generic
    (no_sync_ffs_g : integer := 3);
  port
    (clk_i : in std_ulogic;             -- system clock
     res_i : in std_ulogic;             -- asynchronous reset (low active)

     input_pin_i        : in  std_ulogic;
     rise_edge_on_pin_o : out std_ulogic;  -- '1' when a rising  edge was detected on input pin
     fall_edge_on_pin_o : out std_ulogic;  -- '1' when a falling edge was detected on input pin
     level_on_pin_o     : out std_ulogic);  -- (spike) filtered state of input pin = main output

end spikefilter;

architecture rtl of spikefilter is
  -- CaptureFFs has one FF more than requested since one (the last one, in
  -- fact) is used to filter spikes
  signal CaptureFFs : std_ulogic_vector (0 to no_sync_ffs_g);
  signal Level      : std_ulogic;
  signal PrevLevel  : std_ulogic;
begin

  process (clk_i, res_i)
  begin  -- process
    if res_i = '0' then                     -- asynchronous reset (active low)
      CaptureFFs <= (others => '0');
      Level      <= '0';
      PrevLevel  <= '0';
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge

      -- feed the first flip flop
      case input_pin_i is
        when '0' | 'L' => CaptureFFs(0) <= '0';
        when '1' | 'H' => CaptureFFs(0) <= '1';
        when others    => CaptureFFs(0) <= input_pin_i;
      end case;

      -- propagate the signal
      for i in 0 to no_sync_ffs_g - 1 loop
        CaptureFFs(i+1) <= CaptureFFs(i);
      end loop;  -- i

      -- drive the output
      if (CaptureFFs(no_sync_ffs_g - 1) = '0') and (CaptureFFs(no_sync_ffs_g) = '0') then
        Level <= '0';
      end if;

      if (CaptureFFs(no_sync_ffs_g - 1) = '1') and (CaptureFFs(no_sync_ffs_g) = '1') then
        Level <= '1';
      end if;

      -- store the last level
      PrevLevel <= Level;
    end if;
  end process;

  level_on_pin_o     <= Level;
  rise_edge_on_pin_o <= Level and not (PrevLevel);
  fall_edge_on_pin_o <= not (Level) and PrevLevel;
  
end rtl;
