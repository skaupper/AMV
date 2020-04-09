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

entity control is

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

end control;

architecture Rtl of control is
  signal Cycle, NextCycle : std_ulogic_vector(2 downto 0);

  constant cCycleReset : std_ulogic_vector(2 downto 0) := "000";
  constant cCycle1     : std_ulogic_vector(2 downto 0) := "001";
  constant cCycle2     : std_ulogic_vector(2 downto 0) := "010";
  constant cCycle3     : std_ulogic_vector(2 downto 0) := "100";

  signal NextMemRead, NextMemWrite : std_ulogic;

  signal Carry, Zero             : std_ulogic;
  signal CarryEnable, ZeroEnable : boolean;

  signal NextCpuHalt, IllegalInst, NextIllegalInst : std_ulogic;

begin  -- Rtl

  Reg : process (clk_i, res_i)
  begin  -- process CycleCounter
    if res_i = reset_active_nc then     -- asynchronous reset (active low)
      -- cycle counter
      Cycle <= cCycleReset;

      -- memory interface
      mem_rd_stb_o <= '0';
      mem_wr_stb_o <= '0';

      -- Flags
      Carry <= '0';
      Zero  <= '0';

      cpu_halt_o <= '0';

      IllegalInst <= '0';
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      -- cycle counter
      Cycle <= NextCycle;

      -- memory interface 
      mem_rd_stb_o <= NextMemRead;
      mem_wr_stb_o <= NextMemWrite;

      if CarryEnable then
        Carry <= carry_i;               -- NextCarry;
      end if;

      if ZeroEnable then
        Zero <= zero_i;                 -- NextZero;
      end if;

      cpu_halt_o <= NextCpuHalt;

      IllegalInst <= NextIllegalInst;
    end if;
  end process Reg;

  -----------------------------------------------------------------------------

  Comb : process(Cycle, op_code_i, reg_decode_error_i, Carry, Zero, IllegalInst)
  begin  -- process Comb
    sel_pc_o   <= '0';
    sel_load_o <= '0';
    sel_addr_o <= '0';

    clk_en_pc_o       <= '0';
    clk_en_reg_file_o <= '0';
    clk_en_op_code_o  <= '0';

    NextMemRead  <= '0';
    NextMemWrite <= '0';

    ZeroEnable  <= false;
    CarryEnable <= false;

    carry_o <= '0';

    alu_func_o <= (others => '-');

    NextCpuHalt     <= '0';
    NextIllegalInst <= '0';

    NextCycle <= Cycle;

    case Cycle is
      -------------------------------------------------------------------------
      -- CycleReset
      -------------------------------------------------------------------------
      when cCycleReset =>
        NextMemRead <= '1';
        NextCycle   <= cCycle3;

        -------------------------------------------------------------------------
        -- Cycle 1
        -------------------------------------------------------------------------  
      when cCycle1 =>
        -- PC = PC+1
        sel_pc_o    <= '1';
        alu_func_o  <= alu_inc_c;
        clk_en_pc_o <= '1';
        NextMemRead <= '1';             -- for loading the next OpCode

        NextCycle <= cCycle2;

        case op_code_i is
          -- Jumps
          when opc_jump_c =>
            if reg_decode_error_i = '0' then
              -- PC = Ra
              sel_pc_o <= '0';
            end if;

          when opc_jumpc_c =>
            if reg_decode_error_i = '0' and Carry = '1' then
              sel_pc_o <= '0';
            end if;

          when opc_jumpz_c =>
            if reg_decode_error_i = '0' and Zero = '1' then
              sel_pc_o <= '0';
            end if;

            -- Store
          when opc_store_c =>
            NextMemRead  <= '0';
            NextMemWrite <= '1';

            -- Sleep
          when opc_sleep_c =>
            NextCpuHalt <= '1';
            clk_en_pc_o <= '0';
            NextCycle   <= cCycle1;

          when opc_nop_c | opc_loadi_c | opc_load_c | opc_move_c | opc_and_c | opc_or_c |
            opc_xor_c | opc_not_c | opc_add_c | opc_addc_c | opc_sub_c | opc_subc_c |
            opc_comp_c | opc_inc_c | opc_dec_c | opc_shl_c | opc_shr_c | opc_shlc_c |
            opc_shrc_c =>
            null;                       -- do nothing, but make the others
                                        -- clause an illegal instruction

          when others =>
            NextIllegalInst <= '1';

        end case;

        if reg_decode_error_i = '1' then
          NextIllegalInst <= '1';
        end if;

        -------------------------------------------------------------------------
        -- Cycle 2
        -------------------------------------------------------------------------
      when cCycle2 =>
        -- load next opcode
        clk_en_op_code_o <= '1';

        -- use alu result to write Ra - standard for ALU opcodes
        sel_load_o        <= '0';
        clk_en_reg_file_o <= '1';

        -- enable the carry and zero flag when the alu is used
        ZeroEnable  <= true;
        CarryEnable <= true;

        -- for most functions, we will continue with cycle 1
        NextCycle <= cCycle1;

        -- ALU COMMANDS                 ---------------------------------------------------------

        -- set up the alu commands
        case op_code_i is
          when opc_and_c              => alu_func_o <= alu_and_c;
          when opc_or_c               => alu_func_o <= alu_or_c;
          when opc_xor_c              => alu_func_o <= alu_xor_c;
          when opc_not_c              => alu_func_o <= alu_not_c;
          when opc_add_c | opc_addc_c => alu_func_o <= alu_add_c;  -- watch for carry!
          when opc_sub_c | opc_subc_c => alu_func_o <= alu_sub_c;  -- watch for carry!
          when opc_comp_c             => alu_func_o <= alu_sub_c;
          when opc_inc_c              => alu_func_o <= alu_inc_c;
          when opc_dec_c              => alu_func_o <= alu_dec_c;
          when opc_shl_c | opc_shlc_c => alu_func_o <= alu_slc_c;  -- watch for carry!
          when opc_shr_c | opc_shrc_c => alu_func_o <= alu_src_c;  -- watch for carry!
          when opc_move_c             => alu_func_o <= alu_pass_b_c;
          when others                 => null;
        end case;

        -- carry handling for the above
        case op_code_i is
          when opc_addc_c | opc_subc_c | opc_shlc_c | opc_shrc_c =>  --
            carry_o <= Carry;
          when others => null;
        end case;

        -- LOAD COMMANDS, NOP, JUMPS    --------------------------------------------

        -- don't set the carry with loads, store and jump
        case op_code_i is
          when opc_load_c | opc_loadi_c | opc_store_c | opc_jump_c |
            opc_jumpc_c | opc_jumpz_c | opc_nop_c | opc_move_c =>

            CarryEnable <= false;
            ZeroEnable  <= false;
          when others => null;
        end case;

        -- load and store command handling
        case op_code_i is
          when opc_load_c =>
            -- memory address := Rb, read to Ra
            sel_addr_o <= '1';
            sel_load_o <= '1';

            -- read next OC
            NextMemRead <= '1';

            -- continue with cycle 3
            NextCycle        <= cCycle3;
            clk_en_op_code_o <= '0';

          when opc_loadi_c =>
            -- PC=PC+1
            sel_pc_o    <= '1';
            alu_func_o  <= alu_inc_c;
            clk_en_pc_o <= '1';

            -- read next OC
            NextMemRead <= '1';

            -- read to Ra (memory address is still PC(+1))
            sel_load_o <= '1';

            -- continue with cycle 3
            NextCycle        <= cCycle3;
            clk_en_op_code_o <= '0';

          when opc_store_c =>
            -- memory address := Rb
            sel_addr_o <= '1';

            -- read next OC
            NextMemRead <= '1';

            -- continue with cycle 3
            NextCycle        <= cCycle3;
            clk_en_op_code_o <= '0';

            -- do not enable the reg file for writing
            clk_en_reg_file_o <= '0';

          when opc_jump_c | opc_jumpc_c | opc_jumpz_c | opc_nop_c | opc_comp_c =>
            -- do not enable the reg file for writing
            clk_en_reg_file_o <= '0';

          when others => null;
        end case;

        if IllegalInst = '1' then
          clk_en_reg_file_o <= '0';
          CarryEnable       <= false;
          ZeroEnable        <= false;

          -- continue in cycle 2 if there was an error, even if the opcode was
          -- load(i) or store
          NextCycle         <= cCycle2;
        end if;

        -------------------------------------------------------------------------
        -- Cycle 3
        -------------------------------------------------------------------------  
      when cCycle3 =>
        clk_en_op_code_o <= '1';
        NextCycle        <= cCycle1;

      when others => null;
    end case;
  end process Comb;

  -----------------------------------------------------------------------------

  illegal_inst_o <= IllegalInst;

end Rtl;
