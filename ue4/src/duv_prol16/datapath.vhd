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

library work;
use work.prol16_pack.all;

entity datapath is

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

end datapath;

architecture rtl of datapath is
  signal RegTmpA, RegTmpB, RegPC : data_vec_t;
  signal RegOpcode               : op_code_t;

  signal RegAIdx, RegBIdx : reg_idx_t;

  signal AluSideA, Load, RaValue, RbValue, Pc, AluResult : data_vec_t;
begin

  -----------------------------------------------------------------------------
  -- ALU instantiation
  -----------------------------------------------------------------------------
  thealu : alu
    generic map (
      bit_width_g => data_vec_length_c)
    port map (
      side_a_i    => AluSideA,
      side_b_i    => RegTmpB,
      carry_i     => carry_i,
      alu_func_i  => alu_func_i,
      result_o    => AluResult,
      carry_o     => carry_o,
      zero_o      => zero_o);

  -----------------------------------------------------------------------------
  -- Regfile instantiation
  -----------------------------------------------------------------------------
  thereg_file : reg_file
    generic map (
      registers_g       => registers_c,
      is_fpga_g         => tech_is_fpga_c)
    port map (
      clk_i             => clk_i,
      reg_a_idx_i       => RegAIdx,
      reg_b_idx_i       => RegBIdx,
      clk_en_reg_file_i => clk_en_reg_file_i,
      reg_i             => Load,
      reg_a_o           => RaValue,
      reg_b_o           => RbValue);

  -----------------------------------------------------------------------------
  -- registers
  -----------------------------------------------------------------------------
  registers : process (clk_i, res_i)

    variable reg_a_idx_v, reg_b_idx_v : integer;

  begin  -- process registers
    if res_i = reset_active_nc then                     -- asynchronous reset (active low)
      RegTmpA   <= (others => '-');
      RegTmpB   <= (others => '-');
      RegPC     <= (others => '0');
      RegOpcode <= opc_nop_c;
      RegAIdx   <= -1;
      RegBIdx   <= -1;
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge

      RegTmpA <= RaValue;
      RegTmpB <= RbValue;

      if clk_en_pc_i = '1' then
        RegPC <= Pc;
      end if;

      if clk_en_op_code_i = '1' then
        RegOpcode <= mem_data_i(op_code_range_t'left downto op_code_range_t'right);

        -- register values
        reg_a_idx_v := to_integer(unsigned(mem_data_i(ra_range_t)));
        reg_b_idx_v := to_integer(unsigned(mem_data_i(rb_range_t)));

        -- negative values for reg_X_idx_v can't occur since they are converted
        -- using signed(...)
        if (reg_a_idx_v < registers_c) then
          RegAIdx <= reg_a_idx_v;
        else
          RegAIdx <= -1;
          -- pragma synthesis_off
          report "Data Path : Register A index decode error!" severity note;
          -- pragma synthesis_on
        end if;

        if (reg_b_idx_v < registers_c) then
          RegBIdx <= reg_b_idx_v;
        else
          RegBIdx <= -1;
          -- pragma synthesis_off
          report "Data Path : Register B index decode error!" severity note;
          -- pragma synthesis_on
        end if;

      end if;

    end if;
  end process registers;

  -----------------------------------------------------------------------------
  -- multiplexers
  -----------------------------------------------------------------------------
  LoadMux : process (mem_data_i, AluResult, sel_load_i)
  begin
    case sel_load_i is
      when '0'    => Load <= AluResult;
      when '1'    => Load <= mem_data_i;
      when others => Load <= (others => 'X');
    end case;
  end process LoadMux;

  AluSideAMux : process (RegTmpA, RegPC, sel_pc_i)
  begin
    case sel_pc_i is
      when '0'    => AluSideA <= RegTmpA;
      when '1'    => AluSideA <= RegPC;
      when others => AluSideA <= (others => 'X');
    end case;
  end process AluSideAMux;

  AddrMux : process (RegPC, RegTmpB, sel_addr_i)
  begin
    case sel_addr_i is
      when '0'    => mem_addr_o <= RegPC;
      when '1'    => mem_addr_o <= RegTmpB;
      when others => mem_addr_o <= (others => 'X');
    end case;
  end process AddrMux;

  PcMux : process (RaValue, AluResult, sel_pc_i)
  begin
    case sel_pc_i is
      when '0'    => Pc <= RaValue;
      when '1'    => Pc <= AluResult;
      when others => Pc <= (others => 'X');
    end case;
  end process PcMux;

  -----------------------------------------------------------------------------
  -- outputs
  -----------------------------------------------------------------------------
  op_code_o  <= RegOpcode;
  mem_data_o <= RegTmpA;
  reg_decode_error_o <= '1' when (RegAIdx = -1 or RegBIdx = -1) else '0';

end rtl;
