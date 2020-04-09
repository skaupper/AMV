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

library work;
use work.prol16_pack.all;

entity reg_file is

  generic (
    registers_g : integer := registers_c;
    is_fpga_g   : integer := tech_is_fpga_c);

  port (
    clk_i : in std_ulogic;
    -- no reset (efficient FPGA implementation)

    reg_a_idx_i       : in reg_idx_t;
    reg_b_idx_i       : in reg_idx_t;
    clk_en_reg_file_i : in std_ulogic;

    reg_i   : in  data_vec_t;
    reg_a_o : out data_vec_t;
    reg_b_o : out data_vec_t);

end reg_file;

architecture rtl of reg_file is
  type registers_t is array (registers_g-1 downto 0) of data_vec_t;

  signal registers : registers_t;
begin  -- rtl

  -----------------------------------------------------------------------------
  -- read ports
  -----------------------------------------------------------------------------
  reg_a_o <= registers(reg_a_idx_i) when reg_a_idx_i /= -1 else (others => 'X');
  reg_b_o <= registers(reg_b_idx_i) when reg_b_idx_i /= -1 else (others => 'X');

  -----------------------------------------------------------------------------
  -- write ports
  -----------------------------------------------------------------------------
  reg_write : process (clk_i)
  begin  -- process reg_write
    if clk_i'event and clk_i = '1' then  -- rising clock edge
      if clk_en_reg_file_i = '1' then
		if reg_a_idx_i /= -1 then
          registers(reg_a_idx_i) <= reg_i;
        end if;
      end if;
    end if;
  end process reg_write;
end rtl;
