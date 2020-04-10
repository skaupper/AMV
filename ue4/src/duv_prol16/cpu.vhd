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

entity cpu is

  port (
    clk_i : in std_ulogic;
    res_i : in std_ulogic;

    -- don't use user types (netlist)
    mem_addr_o : out std_ulogic_vector(data_vec_length_c - 1 downto 0);
    mem_data_o : out std_ulogic_vector(data_vec_length_c - 1 downto 0);
    mem_data_i : in  std_ulogic_vector(data_vec_length_c - 1 downto 0);
    mem_ce_no  : out std_ulogic;        -- chip enable (low active)
    mem_oe_no  : out std_ulogic;        -- output enable (low active)
    mem_we_no  : out std_ulogic;        -- write enable (low active)

    illegal_inst_o : out std_ulogic;
    cpu_halt_o     : out std_ulogic);

end cpu;

architecture rtl of cpu is

  signal op_code          : op_code_t;
  signal reg_decode_error : std_ulogic;
  signal sel_pc           : std_ulogic;
  signal sel_load         : std_ulogic;
  signal sel_addr         : std_ulogic;
  signal clk_en_pc        : std_ulogic;
  signal clk_en_reg_file  : std_ulogic;
  signal clk_en_op_code   : std_ulogic;
  signal alu_func         : alu_func_t;
  signal carry_in         : std_ulogic;
  signal carry_out        : std_ulogic;
  signal zero             : std_ulogic;
  signal mem_rd_stb       : std_ulogic;
  signal mem_wr_stb       : std_ulogic;

  signal clk_n : std_ulogic;

begin  -- rtl

  datapath_inst : datapath
    port map (
      clk_i              => clk_i,
      res_i              => res_i,
      op_code_o          => op_code,
      reg_decode_error_o => reg_decode_error,
      sel_pc_i           => sel_pc,
      sel_load_i         => sel_load,
      sel_addr_i         => sel_addr,
      clk_en_pc_i        => clk_en_pc,
      clk_en_reg_file_i  => clk_en_reg_file,
      clk_en_op_code_i   => clk_en_op_code,
      alu_func_i         => alu_func,
      carry_i            => carry_in,
      carry_o            => carry_out,
      zero_o             => zero,
      mem_addr_o         => mem_addr_o,
      mem_data_o         => mem_data_o,
      mem_data_i         => mem_data_i);

  control_inst : control
    port map (
      clk_i              => clk_i,
      res_i              => res_i,
      op_code_i          => op_code,
      reg_decode_error_i => reg_decode_error,
      sel_pc_o           => sel_pc,
      sel_load_o         => sel_load,
      sel_addr_o         => sel_addr,
      clk_en_pc_o        => clk_en_pc,
      clk_en_reg_file_o  => clk_en_reg_file,
      clk_en_op_code_o   => clk_en_op_code,
      alu_func_o         => alu_func,
      carry_o            => carry_in,
      carry_i            => carry_out,
      zero_i             => zero,
      mem_rd_stb_o       => mem_rd_stb,
      mem_wr_stb_o       => mem_wr_stb,
      illegal_inst_o     => illegal_inst_o,
      cpu_halt_o         => cpu_halt_o);

  clk_n <= not clk_i;

  mem_ce_no <= mem_rd_stb nor mem_wr_stb;
  mem_oe_no <= mem_rd_stb nand clk_n;
  mem_we_no <= mem_wr_stb nand clk_n;

end rtl;
