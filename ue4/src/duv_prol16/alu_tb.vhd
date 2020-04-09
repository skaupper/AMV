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

entity alu_tb is

end alu_tb;

-------------------------------------------------------------------------------

architecture bhv of alu_tb is

  component alu
    generic (
      bit_width_g : integer);
    port (
      side_a_i   : in  std_ulogic_vector(bit_width_g - 1 downto 0);
      side_b_i   : in  std_ulogic_vector(bit_width_g - 1 downto 0);
      carry_i    : in  std_ulogic;
      alu_func_i : in  alu_func_t;
      result_o   : out std_ulogic_vector(bit_width_g - 1 downto 0);
      carry_o    : out std_ulogic;
      zero_o     : out std_ulogic);
  end component;

  -- component generics
  constant bit_width_g : integer := 16;

  -- component ports
  signal side_a_i   : std_ulogic_vector(bit_width_g - 1 downto 0);
  signal side_b_i   : std_ulogic_vector(bit_width_g - 1 downto 0);
  signal carry_i    : std_ulogic;
  signal alu_func_i : alu_func_t;
  signal result_o   : std_ulogic_vector(bit_width_g - 1 downto 0);
  signal carry_o    : std_ulogic;
  signal zero_o     : std_ulogic;

  
begin  -- bhv

  -- component instantiation
  DUT : alu
    generic map (
      bit_width_g => bit_width_g)
    port map (
      side_a_i   => side_a_i,
      side_b_i   => side_b_i,
      carry_i    => carry_i,
      alu_func_i => alu_func_i,
      result_o   => result_o,
      carry_o    => carry_o,
      zero_o     => zero_o);

  -- waveform generation
  WaveGen_Proc : process

    procedure TestAlu (
      constant aluFunc              : in std_ulogic_vector(3 downto 0);
      constant sideA, sideB, result : in std_ulogic_vector(bit_width_g - 1 downto 0);
      constant carryIn, carryOut    : in std_ulogic;
      constant name                 : in string) is

      -- workaround, vsim can't do "if result = (others => '0') then..."
      constant zeros : std_ulogic_vector(bit_width_g - 1 downto 0) := (others => '0');
    begin  -- TestAlu
      alu_func_i <= aluFunc;
      side_a_i   <= sideA;
      side_b_i   <= sideB;
      carry_i    <= carryIn;

      wait for 25 ns;

      assert result_o = result report "ALU: Result wrong in " & name severity error;
      assert carry_o = carryOut report "ALU: Carry wrong in " & name severity error;

      if result = zeros then
        assert zero_o = '1' report "ALU: Zero flag not set in " & name severity error;
      else
        assert zero_o = '0' report "ALU: Zero flag not cleared in " & name severity error;
      end if;
    end TestAlu;

    
    procedure TestSideA (
      constant sideA, sideB, result : in std_ulogic_vector(bit_width_g - 1 downto 0);
      constant carryIn, carryOut    : in std_ulogic) is
    begin  -- TestSideA

      TestAlu(alu_pass_a_c, sideA, sideB, result, carryIn, carryOut, "SideA");
      
    end TestSideA;

    procedure TestSideB (
      constant sideA, sideB, result : in std_ulogic_vector(bit_width_g - 1 downto 0);
      constant carryIn, carryOut    : in std_ulogic) is
    begin  -- TestSideB

      TestAlu(alu_pass_b_c, sideA, sideB, result, carryIn, carryOut, "SideB");
      
    end TestSideB;

    procedure TestAnd (
      constant sideA, sideB, result : in std_ulogic_vector(bit_width_g - 1 downto 0);
      constant carryIn, carryOut    : in std_ulogic) is
    begin  -- TestAnd

      TestAlu(alu_and_c, sideA, sideB, result, carryIn, carryOut, "And");
      
    end TestAnd;

    procedure TestOr (
      constant sideA, sideB, result : in std_ulogic_vector(bit_width_g - 1 downto 0);
      constant carryIn, carryOut    : in std_ulogic) is
    begin  -- TestAnd

      TestAlu(alu_or_c, sideA, sideB, result, carryIn, carryOut, "Or");
      
    end TestOr;

    procedure TestXor (
      constant sideA, sideB, result : in std_ulogic_vector(bit_width_g - 1 downto 0);
      constant carryIn, carryOut    : in std_ulogic) is
    begin  -- TestXor
      
      TestAlu(alu_xor_c, sideA, sideB, result, carryIn, carryOut, "Xor");
      
    end TestXor;

    procedure TestNot (
      constant sideA, sideB, result : in std_ulogic_vector(bit_width_g - 1 downto 0);
      constant carryIn, carryOut    : in std_ulogic) is
    begin  -- TestNot

      TestAlu(alu_not_c_side_a, sideA, sideB, result, carryIn, carryOut, "Not");
      
    end TestNot;

    procedure TestAdd (
      constant sideA, sideB, result : in std_ulogic_vector(bit_width_g - 1 downto 0);
      constant carryIn, carryOut    : in std_ulogic) is
    begin  -- TestAdd

      TestAlu(alu_add_c, sideA, sideB, result, carryIn, carryOut, "Add");
      
    end TestAdd;

    procedure TestSub (
      constant sideA, sideB, result : in std_ulogic_vector(bit_width_g - 1 downto 0);
      constant carryIn, carryOut    : in std_ulogic) is
    begin  -- TestSub

      TestAlu(alu_sub_c, sideA, sideB, result, carryIn, carryOut, "Sub");
      
    end TestSub;

    procedure TestInc (
      constant sideA, sideB, result : in std_ulogic_vector(bit_width_g - 1 downto 0);
      constant carryIn, carryOut    : in std_ulogic) is
    begin  -- TestInc

      TestAlu(alu_inc_c, sideA, sideB, result, carryIn, carryOut, "Inc");
      
    end TestInc;

    procedure TestDec (
      constant sideA, sideB, result : in std_ulogic_vector(bit_width_g - 1 downto 0);
      constant carryIn, carryOut    : in std_ulogic) is
    begin  -- TestDec

      TestAlu(alu_dec_c, sideA, sideB, result, carryIn, carryOut, "Dec");
      
    end TestDec;

    procedure TestShl (
      constant sideA, sideB, result : in std_ulogic_vector(bit_width_g - 1 downto 0);
      constant carryIn, carryOut    : in std_ulogic) is
    begin  -- TestShl

      TestAlu(alu_slc_c, sideA, sideB, result, carryIn, carryOut, "Shl");
      
    end TestShl;

    procedure TestShr (
      constant sideA, sideB, result : in std_ulogic_vector(bit_width_g - 1 downto 0);
      constant carryIn, carryOut    : in std_ulogic) is
    begin  -- TestShr

      TestAlu(alu_src_c, sideA, sideB, result, carryIn, carryOut, "Shr");
      
    end TestShr;
    
    
  begin

    TestSideA(X"FFFF", X"0000", X"FFFF", '1', '0');
    TestSideA(X"A5A5", X"FFFF", X"A5A5", '0', '0');
    TestSideA(X"0000", X"A5A5", X"0000", '1', '0');

    TestSideB(X"FFFF", X"0000", X"0000", '1', '0');
    TestSideB(X"A5A5", X"FFFF", X"FFFF", '0', '0');
    TestSideB(X"0000", X"A5A5", X"A5A5", '1', '0');

    TestAnd(X"0000", X"0000", X"0000", '1', '0');
    TestAnd(X"FFFF", X"0000", X"0000", '1', '0');
    TestAnd(X"0000", X"FFFF", X"0000", '0', '0');
    TestAnd(X"F0F0", X"0F0F", X"0000", '1', '0');
    TestAnd(X"A5A5", X"5A5A", X"0000", '1', '0');
    TestAnd(X"FFFF", X"FFFF", X"FFFF", '0', '0');
    TestAnd(X"A5A5", X"A5A5", X"A5A5", '1', '0');
    TestAnd(X"0001", X"0001", X"0001", '1', '0');
    TestAnd(X"1234", X"FFFF", X"1234", '0', '0');
    TestAnd(X"4321", X"FFFF", X"4321", '1', '0');

    TestOr(X"0000", X"0000", X"0000", '0', '0');
    TestOr(X"FFFF", X"0000", X"FFFF", '0', '0');
    TestOr(X"0000", X"FFFF", X"FFFF", '0', '0');
    TestOr(X"F0F0", X"0F0F", X"FFFF", '0', '0');
    TestOr(X"A5A5", X"5A5A", X"FFFF", '0', '0');
    TestOr(X"0000", X"0000", X"0000", '0', '0');
    TestOr(X"0000", X"1234", X"1234", '0', '0');
    TestOr(X"1234", X"0000", X"1234", '0', '0');
    TestOr(X"4321", X"4321", X"4321", '0', '0');
    TestOr(X"FFFF", X"4321", X"FFFF", '0', '0');

    TestXor(X"0000", X"0000", X"0000", '1', '0');
    TestXor(X"FFFF", X"0000", X"FFFF", '1', '0');
    TestXor(X"0000", X"FFFF", X"FFFF", '0', '0');
    TestXor(X"F0F0", X"0F0F", X"FFFF", '1', '0');
    TestXor(X"A5A5", X"5A5A", X"FFFF", '1', '0');
    TestXor(X"FFFF", X"FFFF", X"0000", '0', '0');
    TestXor(X"FFFF", X"A5A5", X"5A5A", '1', '0');
    TestXor(X"5A5A", X"FFFF", X"A5A5", '1', '0');
    TestXor(X"F0F0", X"F0F0", X"0000", '0', '0');
    TestXor(X"A5A5", X"A5A5", X"0000", '1', '0');

    TestNot(X"0000", X"0000", X"FFFF", '1', '0');
    TestNot(X"FFFF", X"0000", X"0000", '1', '0');
    TestNot(X"0000", X"FFFF", X"FFFF", '0', '0');
    TestNot(X"FFFF", X"FFFF", X"0000", '1', '0');
    TestNot(X"A5A5", X"1234", X"5A5A", '1', '0');

    TestAdd(X"0000", X"1234", X"1234", '0', '0');
    TestAdd(X"0000", X"1234", X"1235", '1', '0');
    TestAdd(X"1234", X"0000", X"1234", '0', '0');
    TestAdd(X"1234", X"0000", X"1235", '1', '0');
    TestAdd(X"0000", X"0000", X"0000", '0', '0');
    TestAdd(X"0000", X"0000", X"0001", '1', '0');
    TestAdd(X"FFFF", X"FFFF", X"FFFE", '0', '1');
    TestAdd(X"FFFF", X"FFFF", X"FFFF", '1', '1');
    TestAdd(X"1234", X"FFFF", X"1233", '0', '1');
    TestAdd(X"1234", X"1234", X"2468", '0', '0');
    TestAdd(X"0000", X"1234", X"1234", '0', '0');
    TestAdd(X"FFFF", X"0000", X"0000", '1', '1');
    TestAdd(X"FFFF", X"0001", X"0000", '0', '1');

    TestSub(X"0000", X"0000", X"0000", '0', '0');
    TestSub(X"FFFF", X"0000", X"FFFF", '0', '0');
    TestSub(X"2468", X"1234", X"1234", '0', '0');
    TestSub(X"0000", X"0001", X"FFFF", '0', '1');
    TestSub(X"FFFF", X"2468", X"DB97", '0', '0');
    TestSub(X"1234", X"2468", X"EDCC", '0', '1');
    TestSub(X"0001", X"0000", X"0001", '0', '0');
    TestSub(X"0000", X"0001", X"FFFF", '0', '1');
    TestSub(X"0000", X"0000", X"FFFF", '1', '1');
    TestSub(X"0000", X"0001", X"FFFE", '1', '1');
    TestSub(X"1234", X"0000", X"1233", '1', '0');
    TestSub(X"FFFF", X"FFFE", X"0000", '1', '0');

    TestInc(X"0000", X"0000", X"0001", '0', '0');
    TestInc(X"0000", X"0000", X"0001", '1', '0');
    TestInc(X"0000", X"0001", X"0001", '0', '0');
    TestInc(X"0000", X"0001", X"0001", '1', '0');
    TestInc(X"000F", X"1111", X"0010", '0', '0');
    TestInc(X"00FF", X"4321", X"0100", '1', '0');
    TestInc(X"FFFF", X"0000", X"0000", '1', '1');

    TestDec(X"0000", X"0000", X"FFFF", '0', '1');
    TestDec(X"0000", X"FFFF", X"FFFF", '0', '1');
    TestDec(X"0000", X"0000", X"FFFF", '1', '1');
    TestDec(X"0000", X"FFFF", X"FFFF", '1', '1');
    TestDec(X"0001", X"0000", X"0000", '0', '0');
    TestDec(X"1000", X"1234", X"0FFF", '0', '0');
    TestDec(X"1001", X"FFFF", X"1000", '0', '0');

    TestShl(X"0000", X"0000", X"0000", '0', '0');
    TestShl(X"0001", X"FFFF", X"0002", '0', '0');
    TestShl(X"1111", X"1234", X"2222", '0', '0');
    TestShl(X"FFFF", X"0000", X"FFFE", '0', '1');
    TestShl(X"0000", X"0000", X"0001", '1', '0');
    TestShl(X"FFFF", X"0000", X"FFFF", '1', '1');
    TestShl(X"8000", X"0000", X"0000", '0', '1');
    TestShl(X"8888", X"0000", X"1111", '1', '1');

    TestShr(X"0000", X"0000", X"0000", '0', '0');
    TestShr(X"0000", X"1234", X"8000", '1', '0');
    TestShr(X"FFFF", X"4321", X"7FFF", '0', '1');
    TestShr(X"FFFF", X"0000", X"FFFF", '1', '1');
    TestShr(X"1111", X"0000", X"0888", '0', '1');
    TestShr(X"1111", X"0000", X"8888", '1', '1');
    TestShr(X"4444", X"0000", X"2222", '0', '0');

    report "Simulation complete, ending with failure!" severity failure;
    
  end process WaveGen_Proc;

end bhv;

-------------------------------------------------------------------------------

