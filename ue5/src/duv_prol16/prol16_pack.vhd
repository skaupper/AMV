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
use ieee.numeric_std.all;

package prol16_pack is

  ----------------------------------------------------------------------
  -- clock, reset and sync regs
  constant clock_frequency_c : natural    := 5_000_000;
  -- pragma synthesis_off
  constant clock_period_c    : time       := 1 sec / clock_frequency_c;
  -- pragma synthesis_on
  constant reset_active_nc   : std_ulogic := '0';
  -- reset write before read FFs too (required for FPGAs)
  constant reset_all_ffs_c   : boolean    := false;
  -- is technology an FPGA (/= 0)?
  constant tech_is_fpga_c    : integer    := 0;
  -- how many synchronizer FFs
  constant nr_of_sync_ffs_c  : natural    := 3;

  ----------------------------------------------------------------------
  -- address and data vectors
  constant data_vec_length_c : natural := 16;
  subtype  data_vec_t is std_ulogic_vector(data_vec_length_c - 1 downto 0);

  ----------------------------------------------------------------------
  -- register set
  constant registers_c : natural := 8;  -- max 32
  -- -1 is 'X' or out of range
  subtype  reg_idx_t is integer range -1 to registers_c - 1;

  ----------------------------------------------------------------------
  -- op codes
  subtype op_code_range_t is natural range 15 downto 10;
  subtype ra_range_t is natural range 9 downto 5;
  subtype rb_range_t is natural range 4 downto 0;

  subtype reg_sel_t is std_ulogic_vector(4 downto 0);

  subtype  op_code_t is std_ulogic_vector(5 downto 0);
  constant opc_nop_c   : op_code_t := "000000";
  constant opc_sleep_c : op_code_t := "000001";
  constant opc_loadi_c : op_code_t := "000010";
  constant opc_load_c  : op_code_t := "000011";
  constant opc_store_c : op_code_t := "000100";
  constant opc_jump_c  : op_code_t := "001000";
  constant opc_jumpc_c : op_code_t := "001010";
  constant opc_jumpz_c : op_code_t := "001011";
  constant opc_jmp_c   : op_code_t := "001000";
  constant opc_jmpc_c  : op_code_t := "001010";
  constant opc_jmpz_c  : op_code_t := "001011";
  constant opc_move_c  : op_code_t := "001100";
  constant opc_and_c   : op_code_t := "010000";
  constant opc_or_c    : op_code_t := "010001";
  constant opc_xor_c   : op_code_t := "010010";
  constant opc_not_c   : op_code_t := "010011";
  constant opc_add_c   : op_code_t := "010100";
  constant opc_addc_c  : op_code_t := "010101";
  constant opc_sub_c   : op_code_t := "010110";
  constant opc_subc_c  : op_code_t := "010111";
  constant opc_comp_c  : op_code_t := "011000";
  constant opc_inc_c   : op_code_t := "011010";
  constant opc_dec_c   : op_code_t := "011011";
  constant opc_shl_c   : op_code_t := "011100";
  constant opc_shr_c   : op_code_t := "011101";
  constant opc_shlc_c  : op_code_t := "011110";
  constant opc_shrc_c  : op_code_t := "011111";

  subtype mnemonic_t is string(1 to 15);
  type    mnemonic_table_t is array(0 to 2**op_code_t'length - 1) of mnemonic_t;
  constant mnemonic_table_c : mnemonic_table_t := (
    00     => "NOP            ",
    -- unfortunately, we can't use
    -- to_integer(unsigned(opc_nop_c)) => "NOP            ",
    -- because:
    -- Aggregate with multiple choices has a non-static choice.
    01     => "SLEEP          ",
    02     => "LOADI $a, imm  ",
    03     => "LOAD $a, $b    ",
    04     => "STORE $a, $b   ",
    08     => "JUMP $a        ",
    10     => "JUMPC $a       ",
    11     => "JUMPZ $a       ",
    12     => "MOVE $a, $b    ",
    16     => "AND $a, $b     ",
    17     => "OR $a, $b      ",
    18     => "XOR $a, $b     ",
    19     => "NOT $a         ",
    20     => "ADD $a, $b     ",
    21     => "ADDC $a, $b    ",
    22     => "SUB $a, $b     ",
    23     => "SUBC $a, $b    ",
    24     => "COMP $a, $b    ",
    26     => "INC $a         ",
    27     => "DEC $a         ",
    28     => "SHL $a         ",
    29     => "SHR $a         ",
    30     => "SHLC $a        ",
    31     => "SHRC $a        ",
    others => "n/a (reserved) ");

  ----------------------------------------------------------------------
  -- alu
  subtype alu_func_t is std_ulogic_vector(3 downto 0);

  constant alu_pass_a_c     : alu_func_t := "0010";
  constant alu_pass_b_c     : alu_func_t := "0011";
  constant alu_and_c        : alu_func_t := "0100";
  constant alu_or_c         : alu_func_t := "0101";
  constant alu_xor_c        : alu_func_t := "0110";
  constant alu_not_c        : alu_func_t := "0111";
  constant alu_add_c        : alu_func_t := "1000";
  constant alu_sub_c        : alu_func_t := "1001";
  constant alu_inc_c        : alu_func_t := "1010";
  constant alu_dec_c        : alu_func_t := "1011";
  constant alu_slc_c        : alu_func_t := "1100";
  constant alu_src_c        : alu_func_t := "1101";


  ----------------------------------------------------------------------
  -- component declarations
  component alu

    -- we do not use data_vec_t to be able to modify the bit width for
    -- functional testing purpose
    generic (
      bit_width_g : integer := 16);

    port (
      side_a_i   : in std_ulogic_vector(bit_width_g - 1 downto 0);
      side_b_i   : in std_ulogic_vector(bit_width_g - 1 downto 0);
      carry_i    : in std_ulogic;
      alu_func_i : in alu_func_t;

      result_o : out std_ulogic_vector(bit_width_g - 1 downto 0);
      carry_o  : out std_ulogic;
      zero_o   : out std_ulogic);

  end component;

  component reg_file
    
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

  end component;

  component datapath

    port (
      clk_i : in std_ulogic;
      res_i : in std_ulogic;

      -- control
      op_code_o          : out op_code_t;
      -- asserted on register index decode error    
      reg_decode_error_o : out std_ulogic;

      sel_pc_i   : in std_ulogic;
      sel_load_i : in std_ulogic;
      sel_addr_i : in std_ulogic;

      clk_en_pc_i       : in std_ulogic;
      clk_en_reg_file_i : in std_ulogic;
      clk_en_op_code_i  : in std_ulogic;

      -- alu
      alu_func_i : in  alu_func_t;
      carry_i    : in  std_ulogic;
      carry_o    : out std_ulogic;
      zero_o     : out std_ulogic;

      -- memory
      mem_addr_o : out data_vec_t;
      mem_data_o : out data_vec_t;
      mem_data_i : in  data_vec_t);

  end component;

  component control
    
    port (
      clk_i : in std_ulogic;
      res_i : in std_ulogic;

      -- datapath
      op_code_i          : in op_code_t;
      reg_decode_error_i : in std_ulogic;

      sel_pc_o   : out std_ulogic;
      sel_load_o : out std_ulogic;
      sel_addr_o : out std_ulogic;

      clk_en_pc_o       : out std_ulogic;
      clk_en_reg_file_o : out std_ulogic;
      clk_en_op_code_o  : out std_ulogic;

      -- alu
      alu_func_o : out alu_func_t;
      carry_o    : out std_ulogic;
      carry_i    : in  std_ulogic;
      zero_i     : in  std_ulogic;

      -- memory
      mem_rd_stb_o : out std_ulogic;
      mem_wr_stb_o : out std_ulogic;

      -- error flag (invalid opcode or register decode error)
      illegal_inst_o : out std_ulogic;
      -- sleep instruction encountered
      cpu_halt_o     : out std_ulogic);

  end component;

  component sync_reset

    generic (
      nr_of_sync_ffs_g : integer := nr_of_sync_ffs_c);

    port (
      clk_i : in std_ulogic;
      res_i : in std_ulogic;

      -- bypass dft violation
      test_mode_i : in std_ulogic;

      res_sync_o : out std_ulogic);     -- synchronized reset

  end component;

  component cpu
    
    port (
      clk_i : in std_ulogic;
      res_i : in std_ulogic;

      -- don't use user types (netlist)
      mem_addr_o : out std_ulogic_vector(data_vec_length_c - 1 downto 0);
      mem_data_o : out std_ulogic_vector(data_vec_length_c - 1 downto 0);
      mem_data_i : in  std_ulogic_vector(data_vec_length_c - 1 downto 0);
      mem_ce_no  : out std_ulogic;      -- chip enable (low active)
      mem_oe_no  : out std_ulogic;      -- output enable (low active)
      mem_we_no  : out std_ulogic;      -- write enable (low active)

      illegal_inst_o : out std_ulogic;
      cpu_halt_o     : out std_ulogic);

  end component;

end prol16_pack;

