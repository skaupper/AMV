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
use work.prol16_pack.all;
-------------------------------------------------------------------------------

entity control_tb is

end control_tb;

-------------------------------------------------------------------------------

architecture Bhv of control_tb is

  component control
    port (
      clk_i              : in  std_ulogic;
      res_i              : in  std_ulogic;
      op_code_i          : in  op_code_t;
      reg_decode_error_i : in  std_ulogic;
      sel_pc_o           : out std_ulogic;
      sel_load_o         : out std_ulogic;
      sel_addr_o         : out std_ulogic;
      clk_en_pc_o        : out std_ulogic;
      clk_en_reg_file_o  : out std_ulogic;
      clk_en_op_code_o   : out std_ulogic;
      alu_func_o         : out alu_func_t;
      carry_o            : out std_ulogic;
      carry_i            : in  std_ulogic;
      zero_i             : in  std_ulogic;
      mem_rd_stb_o       : out std_ulogic;
      mem_wr_stb_o       : out std_ulogic;
      illegal_inst_o     : out std_ulogic;
      cpu_halt_o         : out std_ulogic);
  end component;

  component datapath
    port (
      clk_i              : in  std_ulogic;
      res_i              : in  std_ulogic;
      op_code_o          : out op_code_t;
      reg_decode_error_o : out std_ulogic;
      sel_pc_i           : in  std_ulogic;
      sel_load_i         : in  std_ulogic;
      sel_addr_i         : in  std_ulogic;
      clk_en_pc_i        : in  std_ulogic;
      clk_en_reg_file_i  : in  std_ulogic;
      clk_en_op_code_i   : in  std_ulogic;
      alu_func_i         : in  alu_func_t;
      carry_i            : in  std_ulogic;
      carry_o            : out std_ulogic;
      zero_o             : out std_ulogic;
      mem_addr_o         : out data_vec_t;
      mem_data_o         : out data_vec_t;
      mem_data_i         : in  data_vec_t);
  end component;

  signal res_i            : std_ulogic;
  signal op_code          : op_code_t;
  signal reg_decode_error : std_ulogic;
  signal sel_pc           : std_ulogic;
  signal sel_load         : std_ulogic;
  signal sel_addr         : std_ulogic;
  signal clk_en_pc        : std_ulogic;
  signal clk_en_reg_file  : std_ulogic;
  signal clk_en_op_code   : std_ulogic;
  signal alu_func         : alu_func_t;
  signal carry_o          : std_ulogic;
  signal carry_i          : std_ulogic;
  signal zero             : std_ulogic;
  signal mem_rd_stb       : std_ulogic;
  signal mem_wr_stb       : std_ulogic;
  signal illegal_inst     : std_ulogic;
  signal cpu_halt         : std_ulogic;

  signal mem_addr, mem_data_o, mem_data_i : data_vec_t;

  -- clock
  signal clk_i : std_logic := '1';

  constant R0 : std_ulogic_vector(4 downto 0) := "00000";
  constant R1 : std_ulogic_vector(4 downto 0) := "00001";
  constant R2 : std_ulogic_vector(4 downto 0) := "00010";
  constant R3 : std_ulogic_vector(4 downto 0) := "00011";
  constant R4 : std_ulogic_vector(4 downto 0) := "00100";
  constant R5 : std_ulogic_vector(4 downto 0) := "00101";
  constant R6 : std_ulogic_vector(4 downto 0) := "00110";
  constant R7 : std_ulogic_vector(4 downto 0) := "00111";
  
begin  -- Bhv

  dut_control : control
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
      carry_o            => carry_o,
      carry_i            => carry_i,
      zero_i             => zero,
      mem_rd_stb_o       => mem_rd_stb,
      mem_wr_stb_o       => mem_wr_stb,
      illegal_inst_o     => illegal_inst,
      cpu_halt_o         => cpu_halt);

  dut_datapath : datapath
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
      carry_i            => carry_o,
      carry_o            => carry_i,
      zero_o             => zero,
      mem_addr_o         => mem_addr,
      mem_data_o         => mem_data_o,
      mem_data_i         => mem_data_i);

  -- clock generation
  clk_i <= not clk_i after 50 ns;

  -- Reset generation
  res_i <= '0', '1' after 300 ns;


  mem_data_i <= opc_loadi_c & R0 & R0 after 301 ns, "0000000000000000" after 501 ns,
                opc_loadi_c & R1 & R0 after 601 ns, "0000000000000001" after 801 ns,
                opc_loadi_c & R2 & R0 after 901 ns, "0000000000000010" after 1101 ns,
                opc_loadi_c & R3 & R0 after 1201 ns, "0000000000000011" after 1401 ns,
                opc_loadi_c & R4 & R0 after 1501 ns, "0000000000000100" after 1701 ns,
                opc_loadi_c & R5 & R0 after 1801 ns, "0000000000000101" after 2001 ns,
                opc_loadi_c & R6 & R0 after 2101 ns, "0000000000000110" after 2301 ns,
                opc_loadi_c & R7 & R0 after 2401 ns, "0000000000000111" after 2601 ns,

                opc_inc_c & R0 & R0 after 2701 ns,
                opc_inc_c & R1 & R0 after 2901 ns,
                opc_inc_c & R2 & R0 after 3101 ns,
                opc_inc_c & R3 & R0 after 3301 ns,
                opc_inc_c & R4 & R0 after 3501 ns,
                opc_inc_c & R5 & R0 after 3701 ns,
                opc_inc_c & R6 & R0 after 3901 ns,
                opc_inc_c & R7 & R0 after 4101 ns,

                opc_loadi_c & R0 & R0 after 4301 ns, "0000000011110000" after 4501 ns,
                
                opc_add_c & R0 & R0 after 4601 ns,
                opc_add_c & R1 & R0 after 4801 ns,
                opc_add_c & R2 & R0 after 5001 ns,
                opc_add_c & R3 & R0 after 5201 ns,
                opc_add_c & R4 & R0 after 5401 ns,
                opc_add_c & R5 & R0 after 5601 ns,
                opc_add_c & R6 & R0 after 5801 ns,
                opc_add_c & R7 & R0 after 6001 ns,
                
                opc_loadi_c & R0 & R0 after 6201 ns, "1111111111111111" after 6401 ns,
                
                opc_add_c & R1 & R0 after 6501 ns,
                opc_add_c & R2 & R0 after 6701 ns,
                opc_add_c & R3 & R0 after 6901 ns,
                opc_add_c & R4 & R0 after 7101 ns,
                opc_add_c & R5 & R0 after 7301 ns,
                opc_add_c & R6 & R0 after 7501 ns,
                opc_add_c & R7 & R0 after 7901 ns,

                opc_loadi_c & R0 & R0 after 8101 ns, "1010101001010101" after 8301 ns,
                
                opc_move_c & R1 & R0 after 8401 ns,
                opc_move_c & R2 & R0 after 8601 ns,
                opc_move_c & R3 & R0 after 8801 ns,
                opc_move_c & R4 & R0 after 9001 ns,
                opc_move_c & R5 & R0 after 9201 ns,
                opc_move_c & R6 & R0 after 9401 ns,
                opc_move_c & R7 & R0 after 9601 ns,
                
                opc_sleep_c & R0 & R0 after 9801 ns;
  
end Bhv;

-------------------------------------------------------------------------------
