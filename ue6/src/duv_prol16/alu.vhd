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

entity alu is

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

end alu;

architecture rtl of alu is
  -- results: data
  signal res_or, res_and, res_xor, res_not, res_add, res_shift : std_ulogic_vector(bit_width_g - 1 downto 0);

  -- results: carry
  signal cout_add, cout_shift : std_ulogic;

  -- the real result of the alu
  signal result : std_ulogic_vector(bit_width_g - 1 downto 0);

  -- muxed signals in front of the adder
  signal add_b   : std_ulogic_vector(bit_width_g - 1 downto 0);
  signal add_cin : std_ulogic;
begin  -- rtl

-------------------------------------------------------------------------------
-- low level stuff
-------------------------------------------------------------------------------
  result_o <= result;

  -----------------------------------------------------------------------------
  -- logical operations
  -----------------------------------------------------------------------------
  res_or  <= side_a_i or side_b_i;
  res_and <= side_a_i and side_b_i;
  res_xor <= side_a_i xor side_b_i;
  res_not <= not(side_a_i);

  -----------------------------------------------------------------------------
  -- arithmetical operations (ie, add ;) )
  -----------------------------------------------------------------------------

  -- the muxes for the adder
  adder_muxes       : process (side_b_i, carry_i, alu_func_i)
    variable side_b : std_ulogic_vector(bit_width_g - 1 downto 0);
    variable carry  : std_ulogic;
  begin  -- process adder_muxes
    case alu_func_i is
      when alu_add_c | alu_sub_c =>
        side_b := side_b_i;
        carry  := carry_i;
      when alu_inc_c | alu_dec_c =>
        side_b := (others      => '0');
        carry  := '1';
      when others              =>
        side_b := (others      => '-');
        carry  := '-';
    end case;

    case alu_func_i is
      when alu_add_c | alu_inc_c =>
        add_b   <= side_b;
        add_cin <= carry;
      when alu_sub_c | alu_dec_c =>
        add_b   <= not(side_b);
        add_cin <= not(carry);
      when others              =>
        add_b   <= (others     => '-');
        add_cin <= '-';
    end case;
  end process adder_muxes;

  adder            : process (side_a_i, add_b, add_cin)
    variable res_v : unsigned(bit_width_g + 1 downto 0);
  begin  -- process adder
    res_v := unsigned('0' & side_a_i & '1') + unsigned('0' & add_b & add_cin);
    res_add  <= std_ulogic_vector(res_v(res_v'high - 1 downto res_v'low + 1));
    cout_add <= res_v(res_v'high);
  end process adder;

-----------------------------------------------------------------------------
-- shifting operations
-----------------------------------------------------------------------------
  shifter : process (alu_func_i, side_a_i, carry_i)
  begin  -- process shifter
    case alu_func_i is
      when alu_slc_c           =>
        res_shift  <= side_a_i(bit_width_g - 2 downto 0) & carry_i;
        cout_shift <= side_a_i(bit_width_g - 1);
      when alu_src_c           =>
        res_shift  <= carry_i & side_a_i(bit_width_g - 1 downto 1);
        cout_shift <= side_a_i(0);
      when others             =>
        res_shift  <= (others => '-');
        cout_shift <= '-';
    end case;
  end process shifter;


-------------------------------------------------------------------------------
-- the allmighty muxes
-------------------------------------------------------------------------------
  muxer : process (alu_func_i, res_or, res_and, res_xor, res_not, res_add, cout_add, res_shift, cout_shift, side_a_i, side_b_i)
  begin  -- process muxer
    carry_o <= '0';

    case alu_func_i is
      when alu_add_c | alu_inc_c =>
        result  <= res_add;
        carry_o <= cout_add;
      when alu_sub_c | alu_dec_c =>
        result  <= res_add;
        carry_o <= not cout_add;
      when alu_pass_a_c         =>
        result  <= side_a_i;
      when alu_pass_b_c         =>
        result  <= side_b_i;
      when alu_or_c             =>
        result  <= res_or;
      when alu_and_c            =>
        result  <= res_and;
      when alu_xor_c            =>
        result  <= res_xor;
      when alu_not_c            =>
        result  <= res_not;
      when alu_src_c | alu_slc_c =>
        result  <= res_shift;
        carry_o <= cout_shift;
      when others              =>
        result  <= (others     => 'X');
        carry_o <= 'X';
    end case;
  end process muxer;

-------------------------------------------------------------------------------
-- zero flag assignment
-------------------------------------------------------------------------------
  zero_flag         : process (result)
    variable zero_v : std_ulogic;
  begin  -- process zero_flag
    zero_v := '0';

    for i in result'range loop
      zero_v := zero_v or result(i);
    end loop;  -- i

    zero_o <= not zero_v;
  end process zero_flag;

end rtl;
