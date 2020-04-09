---------------------------------------------------------------------------------------------------
--  1996, Markus Schutti, Johannes Kepler University, Austria
---------------------------------------------------------------------------------------------------
--  VHDL description of PROL16 (16-Bit RISC CPU)
--  VHDL version: IEEE 1076-1987 and IEEE 1076-1993
--  Filename: Global.vhd contains package Global and package body Global
--  Purpose:
---------------------------------------------------------------------------------------------------
--  1.00  11.Sep.96  first version
--  1.01  06.May.97  comment starting with keyword 'synopsys' confused Synopsys -> modified
--  1.02  16.Oct.97  new type: RegFileType; function ToInteger() return -1 when std_ulogic_vector is not valid
--  1.03  29.Jan.98  definition of new datatype: IODataVec
--                   correct function ToHex by inserting mod 16 when Hex-Values are calculated
--                   new function ToDecString(Arg, n : in integer) return string;
--                   new procedure Dec()
--                   new function ToString(Arg: in time)
--                   new constants for memory dump file
--  1.04  02.Feb.98  function ToDecString() returns '?' in case of invalid (negative) argument
--  1.05  13.Feb.01  comment fixed (started with string synopsys)
--                   function ToString(Arg: in time) excluded from synthesis (with pragma)
--  1.06  13.Dec.02  fixed problems with HexString & ToBitString with caused
--                   simulation errors with modelsim > 5.4e
---------------------------------------------------------------------------------------------------
--  Global  ---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

---------------------------------------------------------------------------------------------------
package mem_pack is

constant ClockFrequency : integer := 5_000_000; -- clock frequency in [Hz]
constant ResetActive    : std_ulogic := '1'; -- (asynchronous) reset must be high-active for Xilinx
constant ResetDemanded  : boolean := true; -- Xilinx requires a reset for all(!) flip-flops

constant BitWidth      : integer := 16;
constant DataMax       : integer := (2**BitWidth)-1; -- largest number
constant HexDigits     : integer := 4; -- how many digits are required for hex number representation

subtype DataRange    is natural range (BitWidth-1) downto 0;
subtype DataVec      is std_ulogic_vector(DataRange); -- generic data and addr type
subtype IODataVec    is  std_logic_vector(DataRange);


---------------------------------------------------------------------------------------------------
-- bit structure of opcode: max 6 bits opcode + max 5 bits register Ra + max 5 bits register Rb
---------------------------------------------------------------------------------------------------
constant OpcodeBits  : integer := 6;
constant OpcodeMax   : integer := (2**OpcodeBits)-1;
constant RegFileBits : integer := 5;
constant RegFileMax  : integer := (2**RegFileBits)-1; -- Ra,Rb = 0 to RegFileMax

type OpcodeValueType is record
  Code : std_ulogic_vector(OpcodeBits-1 downto 0);
  Ra   : std_ulogic_vector(RegFileBits-1 downto 0);
  Rb   : std_ulogic_vector(RegFileBits-1 downto 0);
  Imm  : DataVec; -- optional
end record;

subtype OpcodeRange  is natural range 15 downto 10;
subtype RaRange      is natural range  7 downto 5;
subtype RbRange      is natural range  2 downto 0;

subtype OpcodeVec    is std_ulogic_vector(5 downto 0); -- bits of opcode

---------------------------------------------------------------------------------------------------
-- actual size of register file...
---------------------------------------------------------------------------------------------------
constant SizeOfRegFile : integer := 8;
subtype RegFileRange  is natural range 0 to (SizeOfRegFile-1);
subtype RegFileVec    is std_ulogic_vector(2 downto 0); -- register file selection
type    RegFileType   is array (RegFileRange) of DataVec;

---------------------------------------------------------------------------------------------------
-- constants for memory dump file
---------------------------------------------------------------------------------------------------

constant MemDumpWords : integer := 512; -- number of Words in memory dump file
constant MemDumpDigits: integer := 5;   -- how many digits has MemDumpWords

---------------------------------------------------------------------------------------------------
-- further declarations...
---------------------------------------------------------------------------------------------------
subtype TwoBits is std_ulogic_vector(0 to 1); -- unfortunately Synopsys can not handle "downto"-ranges for this purpose

type HexType  is ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
type HexVector is array (natural range <>) of HexType;

subtype HexString is HexVector(4 downto 1);


subtype MnemonicString is string(1 to 15);

type MnemonicTableType is array(-1 to 63) of MnemonicString;

constant MnemonicTable : MnemonicTableType := (

   -1 => "[invalid]      ",
   00 => "NOP            ",
   01 => "SLEEP          ",
   02 => "LOADI $a, imm  ",
   03 => "LOAD $a, $b    ",
   04 => "STORE $a, $b   ",
   05 => "n/a (reserved) ",
   06 => "n/a (reserved) ",
   07 => "n/a (reserved) ",
   08 => "JUMP $a        ",
   09 => "n/a (reserved) ",
   10 => "JUMPC $a       ",
   11 => "JUMPZ $a       ",
   12 => "MOVE $a, $b    ",
   13 => "n/a (reserved) ",
   14 => "n/a (reserved) ",
   15 => "n/a (reserved) ",
   16 => "AND $a, $b     ",
   17 => "OR $a, $b      ",
   18 => "XOR $a, $b     ",
   19 => "NOT $a         ",
   20 => "ADD $a, $b     ",
   21 => "ADDC $a, $b    ",
   22 => "SUB $a, $b     ",
   23 => "SUBC $a, $b    ",
   24 => "COMP $a, $b    ",
   25 => "n/a (reserved) ",
   26 => "INC $a         ",
   27 => "DEC $a         ",
   28 => "SHL $a         ",
   29 => "SHR $a         ",
   30 => "SHLC $a        ",
   31 => "SHRC $a        ",
   32 to 63 => "n/a (reserved) ");


constant opcNOP    : std_ulogic_vector(OpcodeBits-1 downto 0) := "000000";
constant opcSLEEP  : std_ulogic_vector(OpcodeBits-1 downto 0) := "000001";
constant opcLOADI  : std_ulogic_vector(OpcodeBits-1 downto 0) := "000010";
constant opcLOAD   : std_ulogic_vector(OpcodeBits-1 downto 0) := "000011";
constant opcSTORE  : std_ulogic_vector(OpcodeBits-1 downto 0) := "000100";
constant opcJUMP   : std_ulogic_vector(OpcodeBits-1 downto 0) := "001000";
constant opcJUMPC  : std_ulogic_vector(OpcodeBits-1 downto 0) := "001010";
constant opcJUMPZ  : std_ulogic_vector(OpcodeBits-1 downto 0) := "001011";
constant opcJMP    : std_ulogic_vector(OpcodeBits-1 downto 0) := "001000";
constant opcJMPC   : std_ulogic_vector(OpcodeBits-1 downto 0) := "001010";
constant opcJMPZ   : std_ulogic_vector(OpcodeBits-1 downto 0) := "001011";
constant opcMOVE   : std_ulogic_vector(OpcodeBits-1 downto 0) := "001100";
constant opcAND    : std_ulogic_vector(OpcodeBits-1 downto 0) := "010000";
constant opcOR     : std_ulogic_vector(OpcodeBits-1 downto 0) := "010001";
constant opcXOR    : std_ulogic_vector(OpcodeBits-1 downto 0) := "010010";
constant opcNOT    : std_ulogic_vector(OpcodeBits-1 downto 0) := "010011";
constant opcADD    : std_ulogic_vector(OpcodeBits-1 downto 0) := "010100";
constant opcADDC   : std_ulogic_vector(OpcodeBits-1 downto 0) := "010101";
constant opcSUB    : std_ulogic_vector(OpcodeBits-1 downto 0) := "010110";
constant opcSUBC   : std_ulogic_vector(OpcodeBits-1 downto 0) := "010111";
constant opcCOMP   : std_ulogic_vector(OpcodeBits-1 downto 0) := "011000";
constant opcINC    : std_ulogic_vector(OpcodeBits-1 downto 0) := "011010";
constant opcDEC    : std_ulogic_vector(OpcodeBits-1 downto 0) := "011011";
constant opcSHL    : std_ulogic_vector(OpcodeBits-1 downto 0) := "011100";
constant opcSHR    : std_ulogic_vector(OpcodeBits-1 downto 0) := "011101";
constant opcSHLC   : std_ulogic_vector(OpcodeBits-1 downto 0) := "011110";
constant opcSHRC   : std_ulogic_vector(OpcodeBits-1 downto 0) := "011111";


procedure Inc(Arg : inout integer);
procedure Dec(Arg : inout integer);

function IsValid(Arg : in std_ulogic_vector) return boolean;

function ToInteger(Arg : in std_ulogic_vector) return integer;
function ToInteger(Arg : in std_ulogic) return integer;
function ToInteger(Hex : in HexVector) return integer;

function ToDecString(Arg : in integer) return string;
function ToDecString(Arg, n : in integer) return string;
function ToString(Arg : in integer; Len : in integer := 3) return string;
function ToString(Arg : in std_ulogic_vector) return string;
function ToString(Arg : in HexVector) return string;
-- synopsys synthesis_off
function ToString(Arg : in time) return string;
-- synopsys synthesis_on

function ToBitChar(Arg : in std_ulogic) return character;
function ToBitString(Arg : in std_ulogic_vector) return string;
function ToHexString(Arg : in integer) return string;
function ToHexString(Arg : in integer; Len : in integer) return string;
function ToHexString(Arg : in std_ulogic_vector; Len : in integer := 2) return string;

function ToBin(Bool : in boolean) return std_ulogic;
function ToBin(Int : in integer; Len : in integer := DataVec'length) return std_ulogic_vector;
function ToBin(Hex : in HexVector) return DataVec;
function ToHex(Int : in integer) return HexString;
function ToHex(Arg : in DataVec) return HexString;

function ResolveMnemonic(Arg : in DataVec) return string;

end mem_pack;


---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
package body mem_pack is

---------------------------------------------------------------------------------------------------
procedure Inc(Arg : inout integer) is
begin
  Arg:=Arg+1;
end;


---------------------------------------------------------------------------------------------------
procedure Dec(Arg : inout integer) is
begin
  Arg:=Arg-1;
end;


---------------------------------------------------------------------------------------------------
function IsValid(Arg : in std_ulogic_vector) return boolean is
begin
for i in Arg'range loop
  if (Arg(i)/='0') and (Arg(i)/='1') then return(false); end if;
end loop;
return(true);
end;


---------------------------------------------------------------------------------------------------
function ToInteger(Arg : in std_ulogic) return integer is
begin
  return CONV_INTEGER(Arg);
end;


---------------------------------------------------------------------------------------------------
function ToInteger(Arg : in std_ulogic_vector) return integer is
begin
if IsValid(Arg)
  then return CONV_INTEGER(unsigned(Arg));
  else return -1; -- needed as indicator of possible "conversion error(s)"
  end if;
end;


---------------------------------------------------------------------------------------------------
function ToInteger(Hex : in HexVector) return integer is
  type TableType is array(HexType) of integer;
  constant Table : TableType := (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15);
  variable Int : Integer;
begin
  Int := 0;
  for i in Hex'range loop
    Int := Int * 16 + Table(Hex(i));
  end loop;
  return(Int);
end;


---------------------------------------------------------------------------------------------------
function ToString(Arg : in integer; Len : in integer := 3) return string is
constant Digits : string(1 to 10) := "0123456789";
variable a : integer;
variable s : string(Len downto 1);
begin
  a := Arg;
  for i in s'reverse_range loop
    s(i) := Digits((a mod 10)+1);
    a := a / 10;
  end loop;
  return s;
end ToString;


---------------------------------------------------------------------------------------------------
function ToDecString(Arg : in integer) return string is
  constant Digits : string(1 to 10) := "0123456789";
  variable a : integer;
  variable s : string(1 to 99);
  variable l : integer;

begin
  if (Arg<0) then return("?"); end if;
  a:=Arg;
  l:=0;
  for i in s'reverse_range loop
    s(i):=Digits((a mod 10)+1);
    a:=a/10;
    l:=l+1;
    exit when (a=0);
  end loop;
  return(s(s'high-l+1 to s'high));
end ToDecString;


---------------------------------------------------------------------------------------------------
function ToDecString(Arg, n: in integer) return string is
  constant Digits : string(1 to 10) := "0123456789";
  variable a : integer;
  variable s : string(1 to 99);
  variable l : integer;

begin
  if (Arg<0) then return(1 to n=>'?'); end if;
  a:=Arg;
  l:=0;
  for i in s'reverse_range loop
    s(i):=Digits((a mod 10)+1);
    a:=a/10;
    l:=l+1;
    exit when (a=0);
  end loop;
  for i in s'high-l downto s'high-n+1 loop
    s(i) := ' ';
  end loop;
  return(s(s'high-n+1 to s'high));
end ToDecString;


---------------------------------------------------------------------------------------------------
function ToString(Arg : in std_ulogic_vector) return string is
begin
  return ToString(CONV_INTEGER(unsigned(Arg)));
end ToString;


---------------------------------------------------------------------------------------------------
function ToString(Arg : in HexVector) return string is
  type TableType is array(HexType) of character;
  constant Table : TableType := ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
  variable s : string(Arg'range);
begin
  for i in Arg'range loop
    s(i):=Table(Arg(i));
  end loop;
  return s;
end ToString;

---------------------------------------------------------------------------------------------------
-- synopsys synthesis_off
function ToString(Arg : in time) return string is
  constant Digits : string(1 to 10) := "0123456789";
  variable s : string(1 to 99);
  variable l : integer;
  variable t : integer;

begin
  t:=time'pos(Arg) / 1000000;
  l:=0;
  for i in s'reverse_range loop
    s(i):=Digits((t mod 10)+1);
    t:=t/10;
    l:=l+1;
    exit when (t=0);
  end loop;
  s(s'high-l-2 to s'high-3) := s(s'high-l+1 to s'high);
  s(s'high-2 to s'high) := " ns";
  return(s(s'high-l-2 to s'high));
end ToString;
-- synopsys synthesis_on


---------------------------------------------------------------------------------------------------
function ToBitChar(Arg : in std_ulogic) return character is
  type TableType is array(std_ulogic) of character;
  constant Table : TableType := ('U','X','0','1','Z','W','L','H','-');
begin
  return Table(Arg);
end;


---------------------------------------------------------------------------------------------------
  function ToBitString(Arg : in std_ulogic_vector) return string is
    type     TableType is array(std_ulogic) of character;
    constant Table : TableType := ('U', 'X', '0', '1', 'Z', 'W', 'L', 'H', '-');
    variable s     : string(Arg'length downto 1);
  begin
    for i in Arg'length downto 1 loop
      s(i) := Table(Arg(Arg'low + i - 1));
    end loop;
    return s;
  end;

---------------------------------------------------------------------------------------------------
function ToHexString(Arg : in integer) return string is
-- This function returns a hexadecimal string of appropriate length;
  constant Digits : string(1 to 16) := "0123456789ABCDEF";
  variable Result : string(1 to 10);
  variable a : integer;
begin
  if (Arg<0) then
    return string'("?");
  else
    a:=Arg;
    for i in Result'reverse_range loop
      Result(i):=Digits((a mod 16)+1);
      a:=a/16;
      if (a=0) then return Result(i to Result'high); end if;
    end loop;
    return string'("?"); -- integer Arg too big for string conversion
  end if;
end;


---------------------------------------------------------------------------------------------------
function ToHexString(Arg : in integer; Len : in integer) return string is
-- This function returns a hexadecimal string of the specified length (Len);
  constant Digits : string(1 to 16) := "0123456789ABCDEF";
  variable s : string(Len downto 1);
  variable a : integer;
begin
  if (Arg<0) then
    s:=(others=>'?');
  else
    a:=Arg;
    for i in s'reverse_range loop
      s(i):=Digits((a mod 16)+1);
      a:=a/16;
    end loop;
  end if;
  return s;
end;


---------------------------------------------------------------------------------------------------
function ToHexString(Arg : in std_ulogic_vector; Len : in integer := 2) return string is
  constant InvalidArg : string(Len downto 1) := (others => 'X');
begin
  if IsValid(Arg)
    then return(ToHexString(ToInteger(Arg), Len));
    else return(InvalidArg);
  end if;
end;


---------------------------------------------------------------------------------------------------
function ToBin(Bool : in boolean) return std_ulogic is
begin
  if Bool then return('1'); else return('0'); end if;
end;


---------------------------------------------------------------------------------------------------
function ToBin(Int : in integer; Len : in integer := DataVec'length) return std_ulogic_vector is
  variable Result : std_ulogic_vector(Len-1 downto 0);
begin
  Result := To_StdULogicVector(CONV_STD_LOGIC_VECTOR(Int,Len));
  return Result;
end;


---------------------------------------------------------------------------------------------------
function ToBin(Hex : in HexVector) return DataVec is
begin
  return ToBin(ToInteger(Hex));
end;


---------------------------------------------------------------------------------------------------
function ToHex(Int : in integer) return HexString is
  type TableType is array(0 to 15) of HexType;
  constant Table : TableType := ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
  variable h : HexString;
begin
  h(1) := Table(Int mod 16);
  h(2) := Table((Int / 16) mod 16);
  h(3) := Table((Int / 16*16) mod 16);
  h(4) := Table((Int / 16*16*16) mod 16);
  return h;
end;


---------------------------------------------------------------------------------------------------
function ToHex(Arg : in DataVec) return HexString is
begin
  return ToHex(ToInteger(Arg));
end;


---------------------------------------------------------------------------------------------------
function ResolveMnemonic(Arg : in DataVec) return string is
  variable Result        : string(1 to MnemonicString'length+7);
  variable MacroString   : MnemonicString;
  variable MacroDetected : boolean;
  variable pos           : integer;

begin
  Result(1 to 2):=ToHexString(Arg(OpcodeRange),2);
  Result(3 to 5):=" = ";
  pos:=6;
  if not(IsValid(Arg)) then
    Result(pos to pos+MnemonicString'length-1):=MnemonicTable(-1);
    pos:=pos+MnemonicString'length;
  else
    MacroString:=MnemonicTable(ToInteger(Arg(OpcodeRange)));
    MacroDetected:=false;
    for i in MnemonicString'range loop
      if (MacroString(i)='$') then
        MacroDetected:=true;-- start of macro sequence
        Result(pos):='R'; pos:=pos+1;
      else
        if MacroDetected then
          case MacroString(i) is
            when 'a'    => Result(pos to pos+1):=ToString(ToInteger(Arg(RaRange)), 2); pos:=pos+2;
            when 'b'    => Result(pos to pos+1):=ToString(ToInteger(Arg(RbRange)), 2); pos:=pos+2;
            when others =>
              -- pragma synthesis_off
              assert false report "Invalid macro sequence detected: $" & MacroString(i);
              -- pragma synthesis_on
          end case;
          MacroDetected:=false;
        else
          Result(pos):=MacroString(i); pos:=pos+1;
        end if;
      end if;
    end loop;
  end if;
  for i in pos to Result'high loop Result(i):=' '; end loop;
  return(Result);
end;


---------------------------------------------------------------------------------------------------

end mem_pack;


---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
--  1997, Thomas KLAUS 9256340 / 880, Johannes Kepler University, Austria
---------------------------------------------------------------------------------------------------
--  VHDL description of an Assembler for CPU PROL 16
--  VHDL version: IEEE 1076-1993
--  Filename: memory.vhd contains entity memory and architecture of memory
--  Purpose:  assembles an assembler-program and make a logfile (errors, addresses, ...)
--            stores the program-code in a static RAM
--            simulates a 16 bit static RAM which can be connected to a CPU
--            creates a memdump-file if a startaddress is stored to RAM-address 0000hex
---------------------------------------------------------------------------------------------------
--  1.00  10.Nov.96  first version
--  2.00  11.Feb.98  second version remodeling memory access behavior with 3 processes
--  2.01  16.Feb.98  set MemIOData to DataOut after tACCmax or tCOmax
--                   check buscontention in process CheckTiminIOData
--                   print invalid memdump address in procedure WriteMemDump
--  2.02  20.Feb.98  check bus contention when Enable='0' and MemCE='1'
--  2.03  25.Feb.98  procedure WriteMemory: 
--                     print register R.. with function ToDecString to logfile
--                     also some spaces are needed if more than 8 registers are used
---------------------------------------------------------------------------------------------------
--  memory  ---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- entity memory
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use STD.textio.all;

library work;
use work.mem_pack.all;

entity Memory_impl is
  generic (Assfilename : string := "main.ass"; -- Assembler-Source File
           Logfilename : string := "main.log"; -- Logfile containing errors,...
           Memfilename : string := "main.hex"; -- MemoryDumpFile part of memory-contents
           ROMstart    : natural:= 00000;      -- Code ROM
           ROMend      : natural:= 32767;      -- from 0x0000 to 0x7fff;
           RAMstart    : natural:= 32768;      -- Working RAM
           RAMend      : natural:= 65534;      -- from 0x8000 to 0xfffe);
           MemDumpAddr : natural:= 65535);     -- Memory Dump Address 0xffff
  port    (MemAddr     : in     DataVec;       -- Address Inputs
           MemIOData   : inout  IODataVec;     -- Data Input/Output
           MemRW       : in  std_ulogic;       -- Read/Write Control Input 1=read, 0=write
           MemOE       : in  std_ulogic;       -- Output  Enable Input low  active
           MemCE       : in  std_ulogic);      -- CE Chip Enable Input high active
end Memory_impl;

-------------------------------------------------------------------------------
-- architecure of memory
-------------------------------------------------------------------------------

architecture Memory_arch of Memory_impl is

  constant MemoryMax   :  integer := (2**BitWidth);
  subtype  MemoryRange is integer range 0 to (MemoryMax - 1);
  type     MemoryType  is array (MemoryRange) of DataVec;
  subtype  ProgAdrType is integer range -1 to DataMax;
  type     MemType     is (MemROM, MemRAM, MemFixup);
  constant ZeroAddr    :  DataVec := (others => '0');

-------------------------------------------------------------------------------
-- time constants : Ta = 0 ~ 70 C, Vdd = 5V +- 10%
-------------------------------------------------------------------------------
  
  constant t       : natural := 70;  -- 55  => 55 ns  static RAM
                                     -- 70  => 70 ns  static RAM
                                     -- 85  => 85 ns  static RAM
                                     -- 100 => 100 ns static RAM

  -------- read cycle -----------------
  constant tRCmin  : time :=  1 ns * t;             -- Read Cycle Time
  constant tACCmax : time :=  1 ns * t;             -- Address Access Time
  constant tCOmax  : time :=  1 ns * t;             -- Chip   Enable CE Access Time
  constant tOEmax  : time := 30 ns + 1 ns*(t-55)/3; -- Output Enable OE to Output in Valid
  constant tCOEmin : time := 10 ns;                 -- Chip   Enable CE to Output in Low-Z
  constant tOEEmin : time :=  5 ns;                 -- Output Enable OE to Output in Low-Z
  constant tODmax  : time := 20 ns + 1 ns*(t-55)/3; -- Chip   Enable CE to Output in High-Z
  constant tODOmax : time := 20 ns + 1 ns*(t-55)/3; -- Output Enable OE to Output in High-Z        
  constant tOHmin  : time := 10 ns;                 -- Output Data Hold Time                    

  -------- write cycle ----------------
  constant tWCmin  : time :=  1 ns * t;             -- Write Cycle Time
  constant tWPmin  : time :=  1 ns * t - 20 ns;     -- Write Pulse Width
  constant tCWmin  : time :=  1 ns * t - 10 ns;     -- Chip Selection to End of Write
  constant tASmin  : time :=  0 ns;                 -- Address Setup Time
  constant tWRmin  : time :=  0 ns;                 -- Write Recovery Time
  constant tODWmax : time := 20 ns + 1 ns*(t-55)/3; -- R/W to Output in High-Z
  constant tOEWmin : time :=  5 ns;                 -- R/W to Output in Low-Z
  constant tDSmin  : time := 25 ns + 1 ns*(t-55)/3; -- Data Setup Time 
  constant tDHmin  : time :=  0 ns;                 -- Data Hold Time  

-------------------------------------------------------------------------------
-- Assembler 
-------------------------------------------------------------------------------
procedure InitMemory (memo: inout MemoryType) is

-------------------------------------------------------------------------------
-- global variables and datatypes
-------------------------------------------------------------------------------

  file assfile: text open read_mode  is  Assfilename;
  file logfile: text open write_mode is  Logfilename;
  file stdfile: text open write_mode is  "STD_OUTPUT";

  variable stdline     :  line;
  variable logline     :  line;

-------------------------------------------------------------------------------

  constant EndofFile   : character := etx;
  constant EndofLine   : character := nul;
  constant Comment     : character := ';';
  constant Separator   : character := ',';
  constant Labelsep    : character := ':';
  constant Assertion   : character := '=';

  type     SignTableType is array ('a' to 'z') of character;
  constant SignTable : SignTableType := 
            ('A','B','C','D','E','F','G','H','I','J','K','L','M',
             'N','O','P','Q','R','S','T','U','V','W','X','Y','Z');

-------------------------------------------------------------------------------

  variable assline     :  line := null;
  variable linenum     :  integer range 0 to 99999 := 0;
  variable oldlinenum  :  integer range 0 to 99999 := 0;
  variable linecol     :  integer range 1 to 500   := 1;
  variable charcol     :  integer range 1 to 500   := 1;
  variable oldcol      :  integer range 1 to 500   := 1;
  variable nextchar    :  character := endofline;

  type     ValType is (Bin, Dec, Hex, noType);

-------------------------------------------------------------------------------

  constant MaxName     : integer := 100;    -- number of names
  constant MaxLength   : integer := 20;     -- length of one name
  constant MaxString   : integer := 100;    -- length of all strings

  subtype  Name        is string (1 to MaxLength);
  type     NameList    is array  (1 to MaxName) of Name;
  type     DataList    is array  (1 to MaxName) of DataVec;
  type     IdentType   is ('-','c','l','m','n');      -- constant, label, macro, none
  type     IdentList   is array  (1 to MaxName) of IdentType;
  subtype  LenList     is integer range 0 to MaxName;
  subtype  MnemoSymbol is integer range -1 to OpcodeMax;
  subtype  SpixType    is integer range -1 to MaxName;
  type     NameType    is record
                  Name :  NameList;
                  Data :  DataList;
                  Ident:  IdentList;
                  Len  :  LenList;
  end record;  

  variable names: NameType := (
                  Name => (1 to MaxName => (others => ' ')),
                  Data => (1 to MaxName => (others => '0')),
                  Ident=> (1 to MaxName => '-'),
                  Len  => 0);
  variable uniqName   :  boolean     := true;
  variable mnemosy     :  MnemoSymbol := -1; 
  variable macrosy     :  MnemoSymbol := -1;
  variable spix        :  SpixType    := 0;
  variable lastspix    :  integer     := 1;

-------------------------------------------------------------------------------

  constant MaxCharBuf  :  integer := 2*BitWidth+5;
  variable number      :  DataVec     := (others => '0');
  variable intval      :  integer     := 0;   -- reading number in integer-format
  variable charbuf     :  string (1 to MaxCharBuf); -- number in string-format
  variable charbuflen  :  integer range 0 to MaxCharBuf := 0; -- length of buffer

-------------------------------------------------------------------------------

  constant FixUpMax    :  integer := 20;    -- size of FixUpBuffer
  type     FixLabelBuf is array (1 to FixUpMax) of SpixType;
  type     FixAdrBuf   is array (1 to FixUpMax) of ProgAdrType;
  type     FixUpType   is record
               LabelNr :  FixLabelBuf;
               Adr     :  FixAdrBuf;
  end record;

  variable fixup: FixUpType := (
               LabelNr => (others => -1),
               Adr     => (others => 0));

-------------------------------------------------------------------------------

  subtype  StringMemo   is string (1 to MaxString);
  subtype  StringLength is integer range 0 to MaxString;
  variable strings      :  StringMemo  := (others => ' ');
  variable stringslen   :  StringLength := 0;
  variable stringsfull  :  boolean;

-------------------------------------------------------------------------------

  type Symbol          is  (NumberSy, IdentSy, StringSy,
                            MnemonicSy, RegisterSy, AssemblerSy,
                            SeparatorSy, LabelsepSy, CommentSy,
                            EndofLineSy, EndofFileSy, ErrorSy);
  variable newsym      :  Symbol := EndofLineSy;
  variable labelbuf    :  Name         := (others => ' ');

-------------------------------------------------------------------------------

  variable lastcmd     :  string(1 to 12) := "            ";
  variable nrErrors    :  integer := 0;
  variable nrWarnings  :  integer := 0;
  variable detectError :  boolean := false;
  variable detectWarning: boolean := false;
  variable success     :  boolean := true;

-------------------------------------------------------------------------------

  variable progadr     :  ProgAdrType := 0;
  variable opcode      :  OpCodeVec;
  variable regcode     :  std_ulogic_vector(RegFileBits-1 downto 0); -- RegFileVec;
  variable codesize    :  ProgAdrType := 0;

-------------------------------------------------------------------------------
  
  constant MacroMemoryMax : integer := 256; -- memory of macros = 256 DataVec
  subtype  MacroMemoryRange is integer range 0 to (MacroMemoryMax - 1);
  type     MacroMemoryType  is array (MacroMemoryRange) of DataVec;
  type     AdrList          is array (1 to MaxName) of ProgAdrType;
  type     MacroType   is record
              StartAdr :  AdrList;
              EndAdr   :  AdrList;
              Len      :  MacroMemoryRange;
  end record;  

  variable macromemo      : MacroMemoryType;
  variable macroprogadr   : ProgAdrType := 0;
  variable macroSequence  : Boolean := false;
  variable macros: MacroType := (
              StartAdr => (1 to MaxName => 0),
              EndAdr   => (1 to MaxName => 0),
              Len      => 0);

  constant MacroFixUpMax  : integer := 100; -- number of label-address to fixup in macro
  type     MacroFixUpBuf  is array (1 to MacroFixUpMax) of ProgAdrType;
  variable macroFixup     : MacroFixUpBuf := (others => -1);
  variable macroFixupPos  : integer := 1;

-------------------------------------------------------------------------------
--  How to expanding the Mnemonic-Set with a new mnemonic-instruction:
-------------------------------------------------------------------------------
--        a) Set MnemonicMax to number of all mnemonic-instruction (default=24)
--        b) Insert a new mnemonic-structure into MnemonicSet
--           1. Code     : Hex-Code in integer of the instruction
--           2. Mnemonic : Mnemonic-String max. 8 characters
--           3. Operand1 : first  operand of the instruction
--           4. Operand2 : second operand of the instruction
--                         Operand1 and Operand2 could be:
--                         none = no operand
--                         reg  = register operand
--                         imm  = immediate operand (number in bin, dec, hex)
--        c) Now the assembler can work with the new Mnemonic-Set
-------------------------------------------------------------------------------
--  To select another Mnemonic-Set change constant MnemoSet (default=1)
-------------------------------------------------------------------------------

  constant MnemonicStringMax : integer := 8;
  constant MnemoSet          : integer := 1;
  constant MnemonicMax1      : integer := 24;
  constant MnemonicMax2      : integer := 46;

  subtype  MnemoIndexType is integer range -1 to MnemonicMax2;
  type     OperandType    is (none, reg, imm);
  type     MnemonicType   is record
                 Code     : integer range 0 to (2**OpcodeBits-1);
                 Mnemonic : string (1 to MnemonicStringMax);
                 Operand1 : OperandType;
                 Operand2 : OperandType;
  end record;  
  type MnemonicSetType1   is array (1 to MnemonicMax1) of MnemonicType;
  type MnemonicSetType2   is array (1 to MnemonicMax2) of MnemonicType;
  
  constant MnemonicSet1 : MnemonicSetType1 := (
      (00, "NOP     ", none, none),
      (01, "SLEEP   ", none, none),
      (02, "LOADI   ", reg,  imm),
      (03, "LOAD    ", reg,  reg),
      (04, "STORE   ", reg,  reg),
      (08, "JUMP    ", reg,  none),
      (10, "JUMPC   ", reg,  none),
      (11, "JUMPZ   ", reg,  none),
      (12, "MOVE    ", reg,  reg),
      (16, "AND     ", reg,  reg),
      (17, "OR      ", reg,  reg),
      (18, "XOR     ", reg,  reg),
      (19, "NOT     ", reg,  none),
      (20, "ADD     ", reg,  reg),
      (21, "ADDC    ", reg,  reg),
      (22, "SUB     ", reg,  reg),
      (23, "SUBC    ", reg,  reg),
      (24, "COMP    ", reg,  reg),
      (26, "INC     ", reg,  none),
      (27, "DEC     ", reg,  none),
      (28, "SHL     ", reg,  none),
      (29, "SHR     ", reg,  none),
      (30, "SHLC    ", reg,  none),
      (31, "SHRC    ", reg,  none));

  constant MnemonicSet2 : MnemonicSetType2 := (
      (00, "NOP     ", none, none),
      (01, "SLEEP   ", none, none),
      (02, "LOADI   ", reg,  imm),
      (03, "LOAD    ", reg,  reg),
      (04, "STORE   ", reg,  reg),
      (06, "PUSH    ", reg,  none),
      (07, "POP     ", reg,  none),
      (08, "JMP     ", reg,  none),
      (10, "JMPC    ", reg,  none),
      (11, "JMPZ    ", reg,  none),
      (12, "MOVE    ", reg,  reg),
      (13, "DJNZ    ", reg,  reg),
      (14, "JMPNC   ", reg,  none),
      (15, "JMPNZ   ", reg,  none),
      (16, "AND     ", reg,  reg),
      (17, "OR      ", reg,  reg),
      (18, "XOR     ", reg,  reg),
      (19, "NOT     ", reg,  none),
      (20, "ADD     ", reg,  reg),
      (21, "ADDC    ", reg,  reg),
      (22, "SUB     ", reg,  reg),
      (23, "SUBC    ", reg,  reg),
      (24, "COMP    ", reg,  reg),
      (26, "INC     ", reg,  none),
      (27, "DEC     ", reg,  none),
      (28, "SHL     ", reg,  none),
      (29, "SHR     ", reg,  none),
      (30, "SHLC    ", reg,  none),
      (31, "SHRC    ", reg,  none),
      (32, "SETC    ", none, none),
      (33, "SETZ    ", none, none),
      (34, "CLRC    ", none, none),
      (35, "CLRZ    ", none, none),
      (40, "JMPI    ", imm,  none),
      (42, "JMPIC   ", imm,  none),
      (43, "JMPIZ   ", imm,  none),
      (46, "JMPINC  ", imm,  none),
      (47, "JMPINZ  ", imm,  none),
      (48, "CALL    ", imm,  none),
      (49, "RET     ", none, none),
      (50, "READP1  ", reg,  none),
      (51, "READP2  ", reg,  none),
      (52, "WRITEP1 ", reg,  none),
      (53, "WRITEP2 ", reg,  none),
      (54, "WRCP1   ", reg,  none),
      (55, "WRCP2   ", reg,  none));

  variable mnix          : MnemoIndexType := 0; -- index in MnemonicSet
  variable nrOfMnemonic  : MnemoIndexType := 0;
  variable mnemonicMax   : MnemoIndexType := 0; -- max number of mnemonic-instruction

-------------------------------------------------------------------------------
--  How to expanding the Assembler-Set with a new assembler-instruction:
-------------------------------------------------------------------------------
--        a) Set AssemblerMax to number of all assembler-instruction (default=5)
--        b) Insert a new assembler-structure into AssemblerSet
--           1. Code     : Hex-Code in integer of the instruction
--           2. Assembler: Assembler-String max. 8 characters
--           3. Operand1 : first  operand of the instruction
--                         Operand1 could be:
--                         none = no operand
--                         imm  = immediate operand (number in bin, dec, hex)
--                         word = word operand (datawords like "abc", 'a', 127, ...)
--                         const= constant operand (identifier)
--                         macro= macro operand (identifier)
--           4. Operand2 : second operand of the instruction
--                         Operand2 could be:
--                         none = no operand
--                         imm  = immediate operand (number in bin, dec, hex)
--                         seq  = sequence operand (sequence of mnemonic-instructions)
--        c) Procedure ReadAssembler must be adapted to the new instructions ! !
-------------------------------------------------------------------------------
 
  constant AssemblerStringMax : integer := 8;
  constant AssemblerMax       : integer := 5;

  type Operand1Type is (none, imm, word, const, macro);
  type Operand2Type is (none, imm, seq);

  type AssemblerType is record
    Code     : integer range 0 to (2**OpcodeBits-1);
    Assembler: string (1 to AssemblerStringMax);
    Operand1 : Operand1Type;
    Operand2 : Operand2Type;
  end record;  
  type AssemblerSetType is array (1 to AssemblerMax) of AssemblerType;

  constant AssemblerSet : AssemblerSetType := (
      (00, "ORG     ", imm,   none),
      (01, "DB      ", word,  none),
      (02, "EQU     ", const, imm),
      (03, "MACRO   ", macro, seq),
      (04, "ENDM    ", none,  none));

  variable asix : integer range -1 to AssemblerMax; -- Index in AssemblerSet

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- procedures and functions
-------------------------------------------------------------------------------

  procedure GetNextChar;
  procedure SkipComment;
  procedure SkipComment2;
  procedure ReadName;
  procedure ReadNumber;
  procedure ReadString;
  procedure ReadNewSym;
  procedure ReadMnemonic;
  procedure ReadAssembler;
  procedure ReadLabel;
  procedure InsertMacro;
  procedure Recover;
  procedure StoreToMemory (mem: MemType; adr: ProgAdrType; vec: DataVec);
  procedure WriteLog;
  procedure WriteSummary;
  procedure WriteMemory;
  procedure LexError    (nr: integer);
  procedure SyntError   (nr: integer);
  procedure Warning     (nr: integer; adr: ProgAdrType);
  procedure CheckNumberType  (ch: character; vtype: ValType; ok: inout boolean);
  procedure CheckMnemonic    (newname: inout Name; ok: inout boolean);
  procedure CheckName        (newname: inout Name; ok: inout boolean);
  procedure CheckRegister    (newname: inout Name; ok: inout boolean);
  procedure CheckAssembler   (newname: inout Name; ok: inout boolean);
  procedure PutFixupLabel;
  procedure GetFixupLabel;
  procedure CheckFixUpLabel;
  procedure ReadData;
  procedure StringToInt (charval: string (1 to BitWidth);
                         len   : integer range 0 to BitWidth;
                         vtype : inout ValType;
                         intval: inout Integer);
  function  CharToInt    (ch: character) return integer;
  procedure IncProgAdr;
  procedure IncMacroProgAdr;
  procedure ChooseMnemonicSet;
  function  GetMnemonicSet (index : integer) return MnemonicType;

  function  IsNotBin       (ch: character) return boolean;
  function  IsNotDec       (ch: character) return boolean;
  function  IsNotHex       (ch: character) return boolean;
  function  IsNotSpace     (ch: character) return boolean;
  function  IsNotEnd       (ch: character) return boolean;
  function  IsNotComment   (ch: character) return boolean;
  function  IsNotSeparator (ch: character) return boolean;
  function  IsSign         (ch: character) return boolean;
  function  IsDigit        (ch: character) return boolean;
  function  IsSignDigit    (ch: character) return boolean;
  function  IsApostroph    (ch: character) return boolean;
  function  IsRegister     (ch: character) return boolean;
  function  IsSlash        (ch: character) return boolean;
  function  IsStar         (ch: character) return boolean;
  function  UpperCase      (ch: character) return character;
  function  IntToDataVec   (data: integer) return DataVec;
  function  DataVecToInt   (data: DataVec) return Integer;
  function  CharToDataVec  (ch: character) return DataVec;

-------------------------------------------------------------------------------
procedure ChooseMnemonicSet is
begin
  case MnemoSet is
    when 1 => mnemonicMax := MnemonicMax1;
    when 2 => mnemonicMax := MnemonicMax2;
    when others => mnemonicMax := MnemonicMax2;
  end case;
end;

-------------------------------------------------------------------------------
function GetMnemonicSet (index: integer) return MnemonicType is
begin
  case MnemoSet is
    when 1 => return MnemonicSet1(index);
    when 2 => return MnemonicSet2(index);
    when others => return MnemonicSet2(index);
  end case;  
end;

-------------------------------------------------------------------------------
function IsNotBin (ch: character) return boolean is
begin
  return ((ch < '0') or (ch  > '1'));
end;
 
-------------------------------------------------------------------------------
function IsNotDec (ch: character) return boolean is
begin
  return ((ch < '0') or (ch  > '9'));
end;

-------------------------------------------------------------------------------
function IsNotHex (ch: character) return boolean is
begin
  return (((ch < '0') or (ch  > '9')) and
          ((ch < 'A') or (ch  > 'F')) and
          ((ch < 'a') or (ch  > 'f')));
end;

-------------------------------------------------------------------------------
function IsNotSpace (ch: character) return boolean is
begin
  return ((ch /= ' ') and (ch /= ht));   -- blank and tab
end;

-------------------------------------------------------------------------------
function IsNotEnd (ch: character) return boolean is
begin
  return ((ch /= EndofLine) and (ch /= EndofFile));
end;

-------------------------------------------------------------------------------
function IsNotComment (ch: character) return boolean is
begin
  return (ch /= ';');
end;

-------------------------------------------------------------------------------
function IsNotSeparator (ch: character) return boolean is
begin
  return (ch /= ',');
end;

-------------------------------------------------------------------------------
function IsLetter (ch: character) return boolean is
begin
  return not ((ch<'A' or ch>'Z') and (ch<'a' or ch>'z'));
end;

-------------------------------------------------------------------------------
function IsSign (ch: character) return boolean is
begin
  return (IsLetter(ch) or (ch='_'));
end;

-------------------------------------------------------------------------------
function IsDigit (ch: character) return boolean is
begin
  return not (ch<'0' or ch>'9');
end;

-------------------------------------------------------------------------------
function IsSignDigit (ch: character) return boolean is
begin
  return (IsSign(ch) or IsDigit(ch));
end;

-------------------------------------------------------------------------------
function IsApostroph (ch: character) return boolean is 
begin
  return (ch='"' or ch=''');
end;

-------------------------------------------------------------------------------
function IsRegister (ch: character) return boolean is 
begin
  return (ch='R' or ch='r');
end;

-------------------------------------------------------------------------------
function IsSlash (ch: character) return boolean is 
begin
  return (ch='/');
end;

-------------------------------------------------------------------------------
function IsStar (ch: character) return boolean is 
begin
  return (ch='*');
end;

-------------------------------------------------------------------------------
function UpperCase (ch: character) return character is
begin
  if (ch>='a' and ch<='z') then
    return SignTable(ch);
  else 
    return ch;
  end if;
end;

-------------------------------------------------------------------------------
-- Converts a Hex-character into Integer-value
-------------------------------------------------------------------------------
function CharToInt (ch: character) return integer is
begin
  case ch is
    when '0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9' => return character'pos(ch)-48;
    when 'a'|'A' => return 10;
    when 'b'|'B' => return 11;
    when 'c'|'C' => return 12;
    when 'd'|'D' => return 13;
    when 'e'|'E' => return 14;
    when 'f'|'F' => return 15;
    when others  => return 1;
  end case;
end;

-------------------------------------------------------------------------------
-- Converts a Integer-value into 16 bit DataVector
-------------------------------------------------------------------------------
function  IntToDataVec (data: integer) return DataVec is
  variable d: DataVec;
  variable val: integer;
begin
  val := data;
  for i in 0 to DataVec'High loop
    if (val mod 2) = 1 then
      d(i) := '1';
    else
      d(i) := '0';
    end if;
    val := val / 2;
  end loop;
  return d;
end;

-------------------------------------------------------------------------------
-- Converts a 16 bit DataVector into Integer-value
-------------------------------------------------------------------------------
function  DataVecToInt (data: DataVec)  return Integer is
  variable val: integer := 0;
begin
  for i in DataVec'High downto 0 loop
    if (data(i) = '1') then
      val := val + 2**i;
    end if;
  end loop;
  return val;
end;

-------------------------------------------------------------------------------
-- Converts a ASCII-character into 16 bit DataVector
-------------------------------------------------------------------------------
function  CharToDataVec(ch: character) return DataVec is
begin
  return IntToDataVec (character'pos(ch));
end;

-------------------------------------------------------------------------------
-- Read a new character into nextchar from the assembler line.
-- If the assembler line is empty, a new assembler line will be 
-- read from the assembler file and written to the logfile.
-------------------------------------------------------------------------------
procedure GetNextChar is
  variable ok: boolean;
begin 
  if (nextchar=EndofLine) then
    if (not endfile(assfile)) then
      Readline (assfile, assline);
      Inc (linenum);
      WriteLog;
      linecol:=1;
      charcol:=6;
      Read (assline, nextchar, ok);
    else
      nextchar:=EndofFile;
    end if;
  else
    Inc (charcol);
    Inc (linecol);
    if (assline'length > 0) then
      Read (assline, nextchar, ok);
    else
      nextchar:=EndofLine;
    end if;
  end if;
end;

-------------------------------------------------------------------------------
-- Recover from a syntax error by searching the next valid
-- character in the next new line.
-------------------------------------------------------------------------------
procedure Recover is
begin
  while (IsnotEnd(nextchar)) loop
    GetNextChar;
  end loop;
  if (nextchar = EndofLine) then
    while (not (IsNotSpace(nextchar))) loop
      GetNextChar;
    end loop;
  end if;
end;

-------------------------------------------------------------------------------
-- Skip a comment by ignoring the rest of a line
-------------------------------------------------------------------------------
procedure SkipComment is
begin
  while IsNotEnd(nextchar) loop
    GetNextChar;
  end loop;
  if (nextchar = EndofLine) then
    GetNextChar;
  end if;
end;

-------------------------------------------------------------------------------
-- Skip a comment by ignoring all between /* and */
-------------------------------------------------------------------------------
procedure SkipComment2 is
  variable numCom: integer := 1;
begin
  GetNextChar;
  while (numCom > 0) and (nextchar /= EndofFile) loop
    if IsStar(nextchar) then
      GetNextChar;
      if IsSlash(nextchar) then
        Dec(numCom);
      end if;
    else 
      if IsSlash(nextchar) then
        GetNextChar;
        if IsStar(nextchar) then
          Inc(numCom);
        end if;
      end if;
    end if;
    GetNextChar;
  end loop;
  if (nextchar = EndofLine) then
    GetNextChar;
  end if;
  if (numCom > 0) and (nextchar = EndofFile) then
    LexError(50);
  end if;
end;


-------------------------------------------------------------------------------
-- Build a new name with connected characters (signs or digits)
-- if the name is valid like a mnemonic-command, register, 
-- assembler-command or identifier, newsym will be set. 
-------------------------------------------------------------------------------
procedure ReadName is
  variable newname: Name := (others => ' ');
  variable i: integer;
  variable valid: boolean;
begin
  i:=1;
  lastcmd(1 to 12) := "'           ";
  while (IsSignDigit(nextchar)) loop
    if (i<11) then
      lastcmd(i+1) := nextchar;
    end if;
    newname(i) := Uppercase (nextchar);
    Inc (i);
    if (i=MaxLength) then
      LexError(21);
      while (IsSignDigit(nextchar)) loop
        GetNextChar;
      end loop;
    else
      GetNextChar;
    end if;
  end loop;
  if (i<12) then
    lastcmd(i+1):=''';
  elsif (i>=12) then
    lastcmd(12):=''';
  end if;

  CheckMnemonic (newname, valid);
  if (valid) then
    newsym := MnemonicSy;
  else CheckRegister (newname, valid);
    if (valid) then
      newsym := RegisterSy;
    else CheckAssembler (newname, valid);
      if (valid) then
        newsym := AssemblerSy;
      else CheckName (newname, valid);
        newsym := IdentSy;
        labelbuf := newname;
        uniqName := valid;
      end if;
    end if;
  end if;
end;

-------------------------------------------------------------------------------
-- Build a new number with connected digits like d_dd_ddd_...
-- following by signs like B, D, H, BIN, DEC, HEX.
-- If the number is valid the value will be stored in intval
-- and newsym is set to NumberSy.
-------------------------------------------------------------------------------
procedure ReadNumber is
  variable charval : string (1 to BitWidth);
  variable pos     : integer range 0 to BitWidth := 1;
  variable col,len : integer range 0 to 2*BitWidth+5 := 1;
  variable vtype   : ValType := Bin;
  variable ch      : character;
  variable ok      : boolean := true;
begin
  charbuf(col):=nextchar;
  GetNextChar; 
  while (IsSignDigit(nextchar) and col<MaxCharBuf)  loop
    Inc (col);
    charbuf(col):= UpperCase (nextchar);
    GetNextChar;
  end loop;
  charbuflen:=col;
  if (col>=MaxCharBuf) then     -- number has to many digits
    LexError(31);
    newsym := ErrorSy;
    return;
  end if;
  if      (charbuf(col)='B') then vtype:=Bin; len:=col-1;
    elsif (charbuf(col)='D') then vtype:=Dec; len:=col-1;
    elsif (charbuf(col)='H') then vtype:=Hex; len:=col-1;
    elsif IsDigit(charbuf(col)) then vtype:=Dec; len:=col;
    elsif (col>3) then
      if (charbuf(col-2 to col)="BIN") then vtype:=Bin; len:=col-3;
      elsif (charbuf(col-2 to col)="DEC") then vtype:=Dec; len:=col-3;
      elsif (charbuf(col-2 to col)="HEX") then vtype:=Hex; len:=col-3;
      else  vtype:=noType; LexError(15);
      end if;
    else  vtype:=noType; LexError(15);
  end if;
  col:=1;
  pos:=0;
  while (col<=len and pos<BitWidth and ok) loop
    if (charbuf(col) = '_') then 
      Inc (col);
    end if;
    CheckNumberType (charbuf(col), vtype, ok);
    if (ok) then
      Inc(pos);
      charval(pos) := charbuf(col);
      Inc(col);
    end if;
  end loop;
  if (col<=len and pos>=BitWidth) then -- number has to many digits
    LexError(31);
    ok := false;
  end if;
  if (ok) then
    StringToInt (charval, pos, vtype, intval);
    newsym := NumberSy;
  else
    newsym := ErrorSy;
  end if;
end;

-------------------------------------------------------------------------------
-- Check if the type of the number is valid.
-------------------------------------------------------------------------------
procedure CheckNumberType   (ch: character;
                             vtype: ValType;
                             ok: inout boolean) is
begin
  ok:=true;
  case vtype is
    when Bin => if IsNotBin(ch) then
                  LexError(11); ok:=false; 
                end if;
    when Dec => if IsNotDec(ch) then
                  LexError(12); ok:=false;
                end if;
    when Hex => if IsNotHex(ch) then
                  LexError(13); ok:=false;
                end if;
    when others => null;
  end case;
end;

-------------------------------------------------------------------------------
-- Build a new string with characters between apostrophs.
-- The string will be stored in the buffer strings.
-------------------------------------------------------------------------------
procedure ReadString is
  variable apost : character;
  variable spos  : integer range 1 to MaxString := 1;
begin
  stringslen:=0;
  apost:=nextchar;
  GetNextChar;
  while ((nextchar/=apost) and IsNotEnd(nextchar) and (spos<MaxString)) loop
    strings(spos) := nextchar;
    Inc (spos);
    Inc (stringslen);
    GetNextChar;
  end loop;
  if ((nextchar=apost) and (stringslen/=0)) then
    GetNextChar;
    newsym := StringSy;
  else
    if (stringslen=0) then
      LexError(25);
      GetNextChar;
    elsif ((spos>=MaxString) and (not stringsfull)) then
      LexError(26);
      stringsfull:=true;
    elsif (nextchar/=apost) then
      SyntError(111);
    end if;
    newsym := ErrorSy;
  end if;
end;

-------------------------------------------------------------------------------
-- Write the assembler line to the logfile.
-------------------------------------------------------------------------------
procedure WriteLog is
  variable col: integer range 0 to 500 := 1;
begin
  Write (logline, linenum, right, 4);
  Write (logline, string'("  "));
  while ((col <= assline'length)) loop
    Write (logline, assline(col));
    Inc (col);
  end loop;
  Writeline (logfile, logline);
end;

-------------------------------------------------------------------------------
-- Write number of errors, all labels with their address and
-- all constants with their value to the logfile.
-------------------------------------------------------------------------------
procedure WriteSummary is
  variable pos: integer;
  variable s  : string (1 to 4);
begin
  Writeline (stdfile, stdline);
  Write (stdline, string'(" Assembling ") & ToString (linenum,4));
  Write (stdline, string'(" lines complete, code & data size "));
  Write (stdline, ToString(codesize,5) & string'(" words"));
  Writeline (stdfile, stdline);
  Writeline (logfile, logline);
  Writeline (logfile, logline);
  Write (logline, string'("      Assembling complete : found "));
  Write (logline, ToString (nrErrors,3));
  Write (logline, string'(" Errors"));
  Writeline (logfile, logline);
  Write (logline, string'("                            found "));
  Write (logline, ToString (nrWarnings,3));
  Write (logline, string'(" Warnings"));
  Writeline (logfile, logline);
  Writeline (logfile, logline);
  Write (logline, string'("      Labels              Address"));
  Writeline (logfile, logline);
  Write (logline, string'("      ---------------------------"));
  Writeline (logfile, logline);
  for pos in 1 to names.Len loop
    if (names.Ident(pos) = 'l') then
      Write (logline, "      " & names.Name(pos));
      s := ToString (ToHex( ToInteger (names.Data(pos))));
      Write (logline, s & 'h');
      Writeline (logfile, logline);
    end if;
  end loop;
  Writeline (logfile, logline);
  Write (logline, string'("      Constants           Value  "));
  Writeline (logfile, logline);
  Write (logline, string'("      ---------------------------"));
  Writeline (logfile, logline);
  for pos in 1 to names.Len loop
    if (names.Ident(pos) = 'c') then
      Write (logline, "      " & names.Name(pos));
      s := ToString (ToHex (ToInteger (names.Data(pos))));
      Write (logline, s & 'h');		   
      Writeline (logfile, logline);
    end if;
  end loop;
end;

-------------------------------------------------------------------------------
-- Write a lexical error to standard output and to the logfile.
-- Set detectError and increment number of found errors.
-------------------------------------------------------------------------------
procedure LexError    (nr: integer) is
  variable ernum, erline : string (4 downto 1);
  variable i : integer;
  variable s1: string (1 to 46);
  variable s2: string (1 to 30);
begin
  ernum  := ToString (nr,4);
  erline := ToString (linenum,4);
  s1 := "ERROR " & ernum & " at Line " & 
         erline & " : near " & lastcmd & " : ";
  case nr is
    when 10 => s2 := "Illegal Number                ";
    when 11 => s2 := "Is not Binary Number          ";
    when 12 => s2 := "Is not Decimal Number         ";
    when 13 => s2 := "Is not Hex Number             ";
    when 15 => s2 := "Unknown Type of Number        ";
    when 21 => s2 := "Name is to long               ";
    when 22 => s2 := "Name is double                ";
    when 25 => s2 := "Empty String                  ";
    when 26 => s2 := "String is to long             ";
    when 27 => s2 := "Name buffer is full           ";
    when 28 => s2 := "Label-FixUp buffer is full    ";
    when 30 => s2 := "Number is to large            ";
    when 31 => s2 := "Number has to many digits     ";
    when 40 => s2 := "Program Memory is full        ";
    when 41 => s2 := "Macro Memory is full          ";
    when 42 => s2 := "Macro-FixUp buffer is full    ";
    when 50 => s2 := "Comment /* */ must be closed  ";
    when 90 => s2 := "Unknown Symbol                ";
    when others => s2 := "Undefined Error !             ";
  end case;
  Write (stdline, s1);
  if (nr=10 or nr=11 or nr=12 or nr=13 or nr=15 or nr=30 or nr=31) then
    for i in 1 to charbuflen loop
      Write (stdline, charbuf(i));
    end loop;
    Write (stdline, string'(" (0000h-") & ToHexString(DataMax, HexDigits) & string'("h) "));
  end if;
  Write (stdline, string'(" ") & s2);
  Writeline (stdfile, stdline);
  Write (logline, string'("****"));
  for i in 1 to oldcol-4 loop
    Write (logline, string'(" "));
  end loop;
  Write (logline, string'("| Lexical ERROR : "));
  if (nr=10 or nr=11 or nr=12 or nr=13 or nr=15 or nr=30 or nr=31) then
    for i in 1 to charbuflen loop
      Write (logline, charbuf(i));
    end loop;
    Write (logline, string'(" (0000h-") & ToHexString(DataMax, HexDigits) & string'("h) "));
  end if;
  Write (logline, string'(" ") & s2);
  Writeline (logfile, logline);
  detectError := true;
  Inc (nrErrors);
end;

-------------------------------------------------------------------------------
-- Write a syntax error to standard output and to the logfile.
-- Set detectError and increment number of found errors.
-------------------------------------------------------------------------------
procedure SyntError    (nr: integer) is
  variable ernum, erline : string (4 downto 1);
  variable i,l : integer;
  variable s1  : string (1 to 56);
  variable s2  : string (1 to 30);
  variable r   : string (2 downto 1);
begin
  ernum  := ToString (nr,4);
  erline := ToString (linenum,4);
  r      := ToString  (SizeOfRegFile-1,2);
  s1 := "ERROR " & ernum & " at Line " & 
         erline & " : near " & lastcmd & " : expecting ";
  case nr is 
    when 100 => s2 := "Register R0 to R" & r & "            ";
    when 110 => s2 := "','                           ";
    when 111 => s2 := "Apostroph                     ";
    when 120 => s2 := "Number or Identifier          ";
    when 121 => s2 := "Number                        ";
    when 130 => s2 := "Identifier                    ";
    when 131 => s2 := "String                        ";
    when 132 => s2 := "Number or String              ";
    when 140 => s2 := "Label Separator ':'           ";
    when 150 => s2 := "'ENDM'                        ";
    when 151 => s2 := "'MACRO'                       ";
    when 160 => s2 := "';' or End of Line            ";
    when others => s2 := "Undefined Error !             ";
  end case;
  Write (stdline, s1 & s2);
  Writeline (stdfile, stdline);
  Write (logline, string'("****"));
  for i in 1 to oldcol-4 loop
    Write (logline, string'(" "));
  end loop;
  Write (logline, string'("| Syntax ERROR : expecting " & s2));
  Writeline (logfile, logline);
  Recover;
  detectError := true;
  Inc (nrErrors);
end;

-------------------------------------------------------------------------------
-- Write a warning to standard output and to the logfile.
-- Set detectWarning and increment number of found warnings.
-------------------------------------------------------------------------------
procedure Warning      (nr: integer; adr: ProgAdrType) is
  variable wrnum, wrline, wradr : string (HexDigits downto 1);
  variable i   : integer;
  variable s1  : string (1 to 48);
  variable s2  : string (1 to 55);
begin
 if (linenum /= oldlinenum) then
  wrnum  := ToString (nr,4);
  wrline := ToString (linenum,4);
  wradr  := ToHexString (adr,HexDigits);
  s1 := "WARNING " & wrnum & " at Line " & 
         wrline & " : near " & lastcmd & " : ";
  case nr is 
    when 200 => s2 := "Memory-address " & wradr & "h contains already data             ";
    when 210 => s2 := "Memory-address " & wradr & "h is out of ROM " &
                ToHexString (ROMstart,HexDigits) & "h - " & ToHexString (ROMend,HexDigits) & "h       ";
    when 220 => s2 := "Memory-address " & wradr & "h is out of RAM " &
                ToHexString (RAMstart,HexDigits) & "h - " & ToHexString (RAMend,HexDigits) & "h       ";
    when others => s2 := "bad address " & wradr & "h                                      ";
  end case;
  Write (stdline, s1 & s2);
  Writeline (stdfile, stdline);
  Write (logline, string'("****  "));
  Write (logline, string'("WARNING : ") & s2);
  Writeline (logfile, logline);
  detectWarning := true;
  Inc (nrWarnings);
  oldlinenum := linenum;
 end if;
end;

-------------------------------------------------------------------------------
-- Write content of memory program- and data-code to logfile.
-- Program-code will be disassembled, data-code will be written
-- to logfile in hex and decimal.   
-------------------------------------------------------------------------------
procedure WriteMemory is
  variable adr          : ProgAdrType := 0;
  variable uvector      : DataVec := (others => 'U');
  variable op, data     : DataVec := (others => '0');
  variable ra, rb       : std_ulogic_vector(RegFileBits-1 downto 0);
  variable code         : integer range 0 to OpCodeMax := 0;
  variable rega, regb   : integer := 0;
  variable index, s     : integer;
  variable mnemonic     : MnemonicType;
  variable newBlock     : Boolean := false;
begin
  Writeline (logfile, logline);
  Writeline (logfile, logline);
  Write (logline, string'("      Contents of Memory: Program-Code ROM"));
  Writeline (logfile, logline);
  Write (logline, string'("      ------------------------------------"));
  Writeline (logfile, logline);
  Writeline (logfile, logline);
  if (sizeOfRegFile < 10) 
    then s := 1;
    else s := 2; 
  end if;
  while (adr < ROMend) loop
    data := memo(adr);
    if (data /= uvector) then
      if newBlock then
        Writeline (logfile, logline);
        newBlock := false;
      end if;     
      op(OpCodeBits-1 downto 0) := data(OpCodeRange);
      ra := data(2*RegFileBits-1 downto RegFileBits);
      rb := data(RegFileBits-1 downto 0);
      index := 1;
      mnemonic := GetMnemonicSet(index);
      code := DataVecToInt(op);
      while (mnemonic.Code /= code) and (index < mnemonicMax) loop
        Inc(index);
        mnemonic := GetMnemonicSet(index);
      end loop;
      Write (logline, ToHexString(adr,HexDigits) & "hex  " & mnemonic.Mnemonic);
      if (mnemonic.Operand1 = reg) then
        rega := ToInteger(ra);
        Write (logline, "R" & ToDecString(rega));
        if ((s = 2) and (rega < 10)) then
          Write (logline, string'(" "));
        end if;
        if (mnemonic.Operand2 = reg) then
          regb := ToInteger(rb);
          Write (logline, ", R" & ToDecString(regb));
          Write (logline, string'("     "));
        elsif (mnemonic.Operand2 = imm) then
          Inc(adr);
          data := memo(adr);
          Write (logline, ", " & ToHexString(data,HexDigits) & "hex");
        else
          Write (logline, string'("         "));
        end if;
        if ((s = 2) and (((mnemonic.Operand2 = reg) and (regb < 10)) or
                          (mnemonic.Operand2 /= reg))) then
          Write (logline, string'(" "));
        end if;
      elsif (mnemonic.Operand1 = imm) then
        Inc(adr);
        data := memo(adr);
        Write (logline, ToHexString(data,HexDigits) & "hex    ");
      else
        Write (logline, string'("           "));
      end if;
      if ((s = 2) and (mnemonic.Operand1 /= reg)) then
        Write (logline, string'("  "));
      end if;
      Write (logline, string'("            "));
      Write (logline, ToBitString(op(OpCodeBits-1 downto 0)) & '_' );
      Write (logline, ToBitString(ra) & '_' & ToBitString(rb));
      if ((mnemonic.Operand1 = imm) or (mnemonic.Operand2 = imm)) then
        Write (logline, "  " & ToBitString(data));
      end if;
      Writeline (logfile, logline);
    else
      newBlock := true;
    end if;
    Inc(adr);
  end loop;
  newBlock := false;
  Writeline (logfile, logline);
  Writeline (logfile, logline);
  Write (logline, string'("      Contents of Memory: Working RAM"));
  Writeline (logfile, logline);
  Write (logline, string'("      ---------------------------------"));
  Writeline (logfile, logline);
  Writeline (logfile, logline);
  while (adr < RAMend) loop
    data := memo(adr);
    if (data /= uvector) then
      if newBlock then
        Writeline (logfile, logline);
        newBlock := false;
      end if;     
      Write (logline, ToHexString(adr,HexDigits) & "hex  " & ToBitString(data));
      Writeline (logfile, logline);
    else
      newBlock := true;
    end if;
    Inc(adr);
  end loop;
end;

-------------------------------------------------------------------------------
-- Convert a value-string with length len into a integer value.
-- The value-string contains characters for a bin, dec or hex number, which
-- valuetype is shown by vtype.
-------------------------------------------------------------------------------
procedure StringToInt (charval: string (1 to BitWidth);
                       len   : integer range 0 to BitWidth;
                       vtype : inout ValType;
                       intval: inout Integer) is
  variable a : integer := 0;
  variable base,i : integer range 1 to Bitwidth;
begin
  case vtype is
    when Bin => base:=2;
    when Dec => base:=10;
    when Hex => base:=16;
    when others => base:=1;
  end case;
  intval := 0;
  for i in 0 to len-1 loop
    a := CharToInt (charval(len-i));
    if (intval > (DataMax - a*(base**i))) then
      LexError(30); exit;
    end if;
    intval := intval + a*(base**i);
  end loop;
end;

-------------------------------------------------------------------------------
-- Build from a mnemonic-command a new datacode like opCode, operand1 and operand2.
-- If syntax is ok, normal-datacode will be stored into normal memory,
-- macro-datacode will be stored in macro-memory.
-------------------------------------------------------------------------------
procedure ReadMnemonic is
  variable mnemonic : MnemonicType;
  variable data     : DataVec := (others => '0');
  variable datapos  : integer := DataVec'high-OpCodeBits;
  variable immediate, labelnotdefined: boolean := false;
begin
  detectError := false;
  mnemonic := GetMnemonicSet(mnix);
  data(DataVec'high downto DataVec'high-OpCodeBits+1) := opCode;

  if (mnemonic.Operand1 = reg) then
    ReadNewSym;
    if (newsym = RegisterSy) then
      data(datapos downto datapos-RegFileBits+1) := regcode;
    else
      SyntError(100);
    end if;
  end if;
  if (mnemonic.Operand1 = imm) then
    ReadNewSym;
    if ((newsym = NumberSy) or (newsym = IdentSy)) then
      immediate := true;
      if (newsym = IdentSy) then
        labelnotdefined := (names.Ident(spix) = 'n');
        number := names.Data(spix);  -- label, constant
      end if;
      data(datapos downto datapos-RegFileBits+1) := ToBin(0, RegFileBits);
    else
      SyntError(120);
    end if;
  end if;
  if (((mnemonic.Operand2 = reg) or (mnemonic.Operand2 = imm)) and not detectError) then
    ReadNewSym;
    if (newsym = SeparatorSy) then
      datapos := datapos - RegFileBits;
    else
      SyntError(110);
    end if;
  end if;
  if ((mnemonic.Operand2 = reg) and not detectError) then
    ReadNewSym;
    if (newsym = RegisterSy) then
      data(datapos downto datapos-RegFileBits+1) := regcode;
    else
      SyntError(100);
    end if;
  end if;
  if ((mnemonic.Operand2 = imm) and not detectError) then
    ReadNewSym;
    if ((newsym = NumberSy) or (newsym = IdentSy)) then
      immediate := true;
      if (newsym = IdentSy) then
        labelnotdefined := (names.Ident(spix) = 'n');
        number := names.Data(spix);  -- label, constant
      end if;
      data(datapos downto datapos-RegFileBits+1) := ToBin(0, RegFileBits);
    else
      SyntError(120);
    end if;
  end if;

  if (((mnemonic.Operand1 = imm) or (mnemonic.Operand2 = imm)) and detectError) then
    number := (others => '0');
    immediate := true;         -- store immediate number 0 if error detected
  end if;

  if (not macroSequence) then  -- normal code
    StoreToMemory (MemROM, progadr, data);     --  memo(progadr) := data;
    IncProgAdr;
    if immediate then
      StoreToMemory (MemROM, progadr, number); --  memo(progadr) := number;
      if (labelnotdefined) then
        PutFixupLabel;
        labelnotdefined := false;
      end if;
      IncProgAdr;
    end if;
  else                         -- macro code
    macromemo(macroProgadr) := data;
    IncMacroProgAdr;
    if immediate then
      macromemo(macroProgadr) := number;
      if (newsym=Identsy and (names.Ident(spix) = 'l' or labelnotdefined)) then
        macroFixup(macroFixupPos) := macroProgadr;
        Inc (macroFixupPos);
        if (macroFixupPos > MacroFixUpMax) then
          LexError (42);
        end if;
      end if;
      if (labelnotdefined) then
        PutFixupLabel;
        labelnotdefined := false;
      end if;
      IncMacroProgAdr;
    end if;
  end if;

--  if ((mnemonic.Operand1 = none) and (mnemonic.Operand2 = none)) then
--    ReadNewSym;                 -- Mnemonic without op
--  end if;
--  detectError := false;
end;

-------------------------------------------------------------------------------
-- Execute a assembler-command like
--    ORG   : load the current Programaddress with a new Number or Constant
--    DB    : read datawords and store it into memory
--    EQU   : store name-Identifier 'c', overread ',' and store value of constant
--    MACRO : store name-Identifier 'm', store Macronumber, 
--            store Startaddress of macro in macro-memory
--    ENDM  : store Endaddress of macro in macro-memory
-------------------------------------------------------------------------------
procedure ReadAssembler is
  variable assembler: AssemblerType;
begin
  detectError := false;
  assembler := AssemblerSet(asix);

  if (assembler.Operand1 = const) then                     -- EQU
    ReadNewSym;
    if (newsym = IdentSy) then
      names.Ident(spix) := 'c';                            -- constant
    else
      SyntError(130);
    end if;
  elsif (assembler.Operand1 = macro) then                  -- MACRO
    ReadNewSym;
    if (newsym = IdentSy) then
      names.Ident(spix) := 'm';                            -- macro
    else
      SyntError(130);
    end if;
  elsif (assembler.Operand1 = word) then                   -- DB
    ReadData;
  elsif (assembler.Operand1 = imm) then    
    ReadNewSym;
    if (macrosy = 0) then                                  -- ORG
      if (newsym = NumberSy)then
        progadr := DataVecToInt(number);
      elsif ((newsym = IdentSy) and (names.Ident(spix) /= 'n')) then
        progadr := DataVecToInt(names.Data(spix));
      else
        SyntError(120);
      end if;
    end if;
  elsif ((assembler.Operand1 = none) and (macrosy = 04)) then
    if (macroSequence) then                                -- ENDM
      macros.EndAdr(macros.Len) := macroProgadr - 1;
      macroSequence := false;
    else
      SyntError(151);
    end if;
  end if;

  if ((assembler.Operand2 = imm) and not detectError) then -- EQU
    ReadNewSym;
    if (newsym /= SeparatorSy) then
      SyntError(110);
    end if;
  end if;

  if ((assembler.Operand2 = imm) and not detectError) then -- EQU
    ReadNewSym;
    if (macrosy = 2) then
      if (newsym = NumberSy) then
        names.Data(spix) := number;
      else
        SyntError(121);
      end if;
    end if;
  elsif ((assembler.Operand2 = seq) and not detectError) then -- MACRO
    if (not macroSequence) then
      Inc (macros.Len);
      names.Data(spix) := IntToDataVec(macros.Len);
      macros.StartAdr(macros.Len) := macroProgadr;
      macroSequence := true;
      ReadNewSym;
    else
      SyntError(150);
    end if;
  end if;

  --if ((assembler.Operand1 = none) and (assembler.Operand2 = none)) then
  --  ReadNewSym;                 -- Assembler command without op
  --end if;
  --detectError := false;
end;

-------------------------------------------------------------------------------
-- Read new data-codes like 10011b, 1234d, 5678Hex, "abcd", 'abcd', ...
-- and store it into the memory.
-------------------------------------------------------------------------------
procedure ReadData is
  variable needSep : boolean := false;
  variable pos : Integer;
begin
  ReadNewSym;
  while ((newsym/=EndOfLineSy) and (newsym/=EndOfFileSy) and (newsym /=CommentSy)) loop
    if (needSep) then
      if (newsym = SeparatorSy) then 
        ReadNewSym;
        needSep := false;
      else
        SyntError(110); exit;
    end if;
    else
      if (newsym=NumberSy) then
        StoreToMemory (MemRAM, progadr, number);  -- memo(progadr) := number;
        IncProgAdr;
        ReadNewSym;
        needSep := true;
      elsif (newsym=StringSy) then
        for pos in 1 to stringslen loop
          StoreToMemory (MemRAM, progadr, CharToDataVec(strings(pos)));
          -- memo(progadr) := CharToDataVec(strings(pos));
          IncProgAdr;
        end loop;
        ReadNewSym;
        needSep := true;
      else
        SyntError(132); exit;
      end if;
    end if;
  end loop;
end;

-------------------------------------------------------------------------------
-- Start a new label by storing 
-- name-Identifier 'l', program- or  macroprogram-address.
------------------------------------------------------------------------------
procedure ReadLabel is
  variable valid : boolean;
begin
  if (nextchar=Labelsep) then
    if (uniqName or (names.Ident(spix) = 'n')) then
      newsym := LabelsepSy;
      names.Ident(spix) := 'l';
      if (not macroSequence) then
        names.Data(spix) := IntToDataVec(progadr);
      else
        names.Data(spix) := IntToDataVec(macroProgadr);
      end if;    
      GetFixUpLabel;
      --GetNextChar;
    else
      LexError(22);
      uniqName := true;
      Recover;
    end if;
  else
    SyntError(140);
  end if;
end;


-------------------------------------------------------------------------------
-- Find a free fixup for a not defined label in the fixup-buffer.
-- Store the index of the labelname and the program- or macroprogram-address.
-------------------------------------------------------------------------------
procedure PutFixUpLabel  is
  variable pos: integer := 1;
begin
  while ((pos<=FixUpMax) and (fixup.LabelNr(pos)/=-1)) loop
    Inc (pos);
  end loop;
  if (pos>FixUpMax) then
    LexError(28);
  else
    fixup.LabelNr(pos) := spix;
    if (not macroSequence) then
      fixup.Adr(pos) := progadr;
    else
      fixup.Adr(pos) := macroProgadr;
    end if;
  end if;
end;

-------------------------------------------------------------------------------
-- Check if the current labelname must be fixed up, and store the address 
-- of the label into the fixup-address of the memory or macro-memory.
-------------------------------------------------------------------------------
procedure GetFixUpLabel  is
  variable pos: integer := 1;
begin
  while (pos<=FixUpMax) loop
    if (fixup.LabelNr(pos)=spix) then
      if (not macroSequence) then
        StoreToMemory (MemFixup, fixup.Adr(pos), names.Data(spix));
        -- memo(fixup.Adr(pos)) := names.Data(spix);
      else
        macromemo(fixup.Adr(pos)) := names.Data(spix);
      end if;
      fixup.LabelNr(pos) := -1;
      fixup.Adr(pos)   := 0;
    end if;
    Inc(pos);
  end loop;
end;

-------------------------------------------------------------------------------
-- Insert a macrocode from startadr to endadr into the memory.
-- If the codesequence contains jump-commands, a new jumpaddress will be
-- calculated and stored into the memory.
-------------------------------------------------------------------------------
procedure InsertMacro is
  variable startadr, endadr, jumpadr: Integer;
  variable pos: integer := 1;
begin
  startadr := macros.StartAdr(DataVecToInt(names.Data(spix)));
  endadr   := macros.EndAdr  (DataVecToInt(names.Data(spix)));
  while ((startadr>macroFixup(pos)) and (pos<macroFixupPos)) loop
    Inc (pos);
  end loop;
  for adr in startadr to endadr loop
    if (adr = macroFixup(pos)) then
      jumpadr := progadr - adr + DataVecToInt(macromemo(adr));
      StoreToMemory (MemROM, progadr, IntToDataVec(jumpadr)); 
      -- memo(progadr) := IntToDataVec(jumpadr);
      Inc (pos);
    else
      StoreToMemory (MemROM, progadr, macromemo(adr)); 
      -- memo(progadr) := macromemo(adr);
    end if;
    IncProgAdr;
  end loop;
end;

-------------------------------------------------------------------------------
-- Check if all Labels or Constants are defined.
-------------------------------------------------------------------------------
procedure CheckFixUpLabel  is
  variable pos: integer := 1;
  variable s1 : string (1 to 65);
begin
  while (pos<=FixUpMax) loop
    if (fixup.LabelNr(pos)/=-1) then
      s1 := "ERROR : Label or Constant '" & names.Name(fixup.LabelNr(pos)) 
            & "' is not defined !";
      Write (stdline, s1);
      Writeline (stdfile, stdline);
      Inc (nrErrors);
    end if;
    Inc(pos);
  end loop;
end;

-------------------------------------------------------------------------------
-- Check if newname already exists, if no store name-Identifier 'n', so it
-- could be a new label or constant.
-------------------------------------------------------------------------------
procedure CheckName   (newname: inout Name;
                       ok: inout boolean) is
  variable i,index : integer;
begin
  ok:=true;
  for index in 1 to names.Len loop
    if (newname = names.Name(index)) then
      ok := false;
      i  := index; exit;
    end if;
  end loop;

  lastspix:=spix;
  if (ok) then                         -- new name
    if (names.Len<MaxName) then
      Inc (names.Len);
      names.Name(names.Len) := newname;
      names.Ident(names.Len) := 'n';
      spix    := names.Len;
      mnemosy := -1;                   -- name
    else
      LexError(27);
    end if;
  else                                 -- double name
    spix    := i;
    mnemosy := -1;
  end if;
end;

-------------------------------------------------------------------------------
-- Check if newname is a register-name and calculate the register-number.
-------------------------------------------------------------------------------
procedure CheckRegister (newname: inout Name;
                         ok: inout boolean) is
  variable pos: integer := 1;
  variable n:   integer := 0;
begin
  ok:=false;
  if (IsRegister(newname(pos))) then
    Inc (pos);
    while ((pos<=MaxLength) and (IsDigit(newname(pos)))) loop
      n := n*10 + CharToInt (newname(pos));
      Inc(pos);
    end loop;
    if (n<SizeOfRegFile and pos>2) then
      regCode:=ToBin(n, RegFileBits);
      ok:=true;
    end if;
  end if;
end;

-------------------------------------------------------------------------------
-- Check if newname is a mnemonic-keyword.
-------------------------------------------------------------------------------
procedure CheckMnemonic (newname: inout Name;
                         ok: inout boolean) is
  variable index    : integer;
  variable mnemonic : MnemonicType;
begin
  ok:=false;
  for index in 1 to mnemonicMax loop
    mnemonic := GetMnemonicSet(index);
    if (mnemonic.Mnemonic = newname(1 to MnemonicStringMax)
    and newname(MnemonicStringMax + 1) = ' ') then
      mnemosy := mnemonic.Code;
      macrosy := mnemonic.Code;
      spix    := -1;           -- mnemonic keyword
      mnix    := index;
      asix    := -1;
      opCode  := ToBin(mnemosy, OpCodeBits);
      ok      := true; exit;
    end if;      
  end loop;
end;

-------------------------------------------------------------------------------
-- Check if newname is a assembler-keyword.
-------------------------------------------------------------------------------
procedure CheckAssembler (newname: inout Name;
                          ok: inout boolean) is
  variable index    : integer;
  variable assembler: AssemblerType;
begin
  ok:=false;
  for index in 1 to AssemblerMax loop
    assembler := AssemblerSet(index);
    if (assembler.Assembler = newname(1 to AssemblerStringMax) 
    and newname(AssemblerStringMax + 1) = ' ') then
      mnemosy := assembler.Code;
      macrosy := assembler.Code;
      spix    := -1;            -- assembler keyword
      mnix    := -1;
      asix    := index;
      ok:=true; exit;
    end if;
  end loop;
end;

-------------------------------------------------------------------------------
-- Increment Memory-ProgramAddress
-------------------------------------------------------------------------------
procedure IncProgAdr is
begin
  if (progadr < MemoryMax) then
    Inc (progadr);
    Inc (codesize);
  else
    LexError(40);
  end if;
end;

-------------------------------------------------------------------------------
-- Increment MacroMemory-ProgramAddress
-------------------------------------------------------------------------------
procedure IncMacroProgAdr is
begin
  if (macroprogadr < MacroMemoryMax) then
    Inc (macroprogadr);
  else
    LexError(41);
  end if;
end;

-------------------------------------------------------------------------------
-- Store data on adr of memory
-------------------------------------------------------------------------------
procedure StoreToMemory  (mem: MemType; adr: ProgAdrType; vec: DataVec) is
  variable uvector      : DataVec := (others => 'U');
begin
  if (mem /= MemFixup and memo(adr) /= uvector) then
    Warning(200, adr);
  end if;
  case mem is 
    when MemROM => if (adr < ROMstart or adr > ROMend) then
                      Warning(210, adr); end if;
    when MemRAM => if (adr < RAMstart or adr > RAMend) then
                      Warning(220, adr); end if;
    when MemFixup =>  
  end case;
  memo(adr) := vec;
end;

-------------------------------------------------------------------------------
-- Read a new Symbol: EndofFile, EndofLine, Comment, Separator, 
--                    Name(Identifier, Constant), String, Number ...
-------------------------------------------------------------------------------
procedure ReadNewSym is
begin
  oldcol := charcol;
  if (nextchar = EndofFile) then
    newsym := EndofFileSy;
  elsif (nextchar = EndofLine) then
    newsym := EndofLineSy;
    GetNextChar;
  elsif (nextchar = Comment) then
    SkipComment;
    newsym:=CommentSy;
  elsif IsSlash(nextchar) then
    GetNextChar;
    if IsStar(nextchar) then
      SkipComment2;
      newsym:=CommentSy;
    else
      LexError(90);
      Recover;
    end if;
  else
    if (nextchar = Separator) then
      newsym:=SeparatorSy;
      GetNextChar;
    elsif (nextchar = LabelSep) then  -- new
      GetNextChar;
    elsif IsSign(nextchar) then
      ReadName;
    elsif IsApostroph (nextchar) then
      ReadString;
    elsif not IsNotDec(nextchar) then
      ReadNumber;
      number := IntToDataVec(intval);
    elsif (IsNotSpace(nextchar) and IsNotEnd(nextchar)) then
      LexError(90);
      Recover;
    end if;

    while (not (IsNotSpace(nextchar))) loop
      GetNextChar;
    end loop;
  end if;
end;

-------------------------------------------------------------------------------
-- Main of InitMemory
-------------------------------------------------------------------------------
begin
  ChooseMnemonicSet;
  ReadNewSym;
  while (newsym /= EndofFileSy) loop
    if (newsym=MnemonicSy) then
      ReadMnemonic;
      if (newsym /= ErrorSy) then
        ReadNewSym;
      end if;
      if ((newsym /= CommentSy) and (newsym /= EndofLineSy) and 
          (newsym /= EndofFileSy) and (newsym /= ErrorSy)) then
        SyntError(160);
      end if;
    elsif (newsym = AssemblerSy) then
      ReadAssembler;
      if ((newsym /= ErrorSy) and (macrosy /= 1)) then -- no DB instruction
        ReadNewSym;
      end if;
      if ((newsym /= CommentSy) and (newsym /= EndofLineSy) and 
          (newsym /= EndofFileSy) and (newsym /= ErrorSy)) then
        SyntError(160);
      end if;
    elsif (newsym = IdentSy) then
      if (names.Ident(spix) = 'm') then
        InsertMacro;
        ReadNewSym;
      else
        ReadLabel;
        if (newsym /= ErrorSy) then
          ReadNewSym;
        end if;
      end if;
    else
      ReadNewSym;
    end if;
    --if (nextchar = EndofLine) then
    --  GetNextChar;
    --end if;
  end loop;
  CheckFixUpLabel;
  WriteSummary;
  WriteMemory;
end;  

-------------------------------------------------------------------------------
-- Write the contents of the memory memo beginning from startAdr ending by
-- startAdr+countAdr to a memfile.
-------------------------------------------------------------------------------
procedure WriteMemDump(memo: in MemoryType; startAdr, countAdr: in ProgAdrType) is
  variable dumpAdr, adr, nAdr : ProgAdrType;
  constant MaxColumn          : integer := 8;
  variable column, i          : integer;
  variable sadr               : string (1 to HexDigits);
  variable scount             : string (1 to MemDumpDigits);
  variable memline, stdline   : line;
  file memfile      : text open write_mode is  Memfilename;
  file stdfile      : text open write_mode is  "STD_OUTPUT";
begin
  if (startAdr < 0) then
    Write (stdline, string'("Write Memory Dump File is impossible because wrong address "));
    Write (stdline, ToBitString (To_stdulogicvector(MemIOData)) & 'b');
    Writeline (stdfile, stdline);
    return;
  end if;
  sadr  := ToHexString (startAdr,HexDigits);
  scount:= ToString (countAdr,MemDumpDigits);
  Write (stdline, string'("Write Memory Dump File: from address ") & sadr & "h");
  Write (stdline, string'(" size ") & scount & string'(" words"));
  Writeline (stdfile, stdline);
  dumpAdr := startAdr;
  adr  := dumpAdr;
  nAdr := countAdr;
  while (dumpAdr < memo'high) and (nAdr > 0) loop
    if (nAdr mod 128)=0 then 
      Writeline (memfile, memline); 
    end if;
    Write (memline, ToHexString(adr, HexDigits) & "hex ");
    i := 1;
    adr  := dumpAdr;
    while (i <= MaxColumn) and (adr < memo'high) loop
      Write (memline, " " & ToHexString(memo(adr), HexDigits));
      Inc(adr);
      Inc(i);
    end loop;
    Write (memline, string'("  "));
    i := 1;
    adr  := dumpAdr;
    while (i <= MaxColumn) and (adr < memo'high) loop
      if (ToInteger(memo(adr)) /= -1) then
        Write (memline, " " & ToDecString(ToInteger(memo(adr)), HexDigits+HexDigits/4));
      else
        Write (memline, " " & ToDecString(0, HexDigits+HexDigits/4));
      end if;
      Inc(adr);
      Inc(i);
    end loop;
    dumpAdr := dumpAdr + MaxColumn;
    nAdr    := nAdr - MaxColumn;
    Writeline (memfile, memline);
  end loop;      
end;


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

  constant HighZ                : IODataVec := (others => 'Z');
  constant Uninitialized        : IODataVec := (others => 'U');
  constant Unknown              : IODataVec := (others => 'X');
  constant DontCare             : DataVec   := (others => '-');


  type   timingR is (readcycle,  readhold, none);
  type   timingW is (writecycle, writehold, none);

  signal DataOut                : IODataVec;        -- data written to MemIOData
  signal Enable                 : std_ulogic;       -- enable output of memory
  signal dataValid              : boolean := false; -- MemIOData valid
  shared variable start, start2 : time    := 0 ns;
  shared variable tRW           : time    := 0 ns;
  shared variable checkTimingR  : timingR := none;
  shared variable checkTimingW  : timingW := none;

begin

-------------------------------------------------------------------------------
-- Memory-Access-Behavior
-------------------------------------------------------------------------------

  CheckTimingIOData: process (MemIOData)
  begin
    if ((MemIOData /= HighZ) and (MemIOData /= Unknown) and 
          (MemIOData /= Uninitialized) and (Enable='1')) then
      assert (((MemCE'last_value='0' or MemCE'last_value='U' or MemCE'last_value='X')
            and MemCE'last_event<=tCOmax) or (MemCE='1' and MemCE'last_event>tCOmax))
        report "Memory: CE Access Time t(CO) is greater than " & ToString(tCOmax);
      assert (((MemOE'last_value='1' or MemOE'last_value='U' or MemOE'last_value='X')
            and MemOE'last_event<=tOEmax) or (MemOE='0' and MemOE'last_event>tOEmax))
        report "Memory: OE to Output in Valid t(OE) is greater than " & ToString(tOEmax);
      assert (MemAddr'last_event<=tACCmax or MemAddr'last_event>=MemCE'last_event 
           or MemAddr'last_event>=MemOE'last_event)
        report "Memory: Address Access Time t(ACC) is greater than " & ToString(tACCmax);
      dataValid <= true;
    else
      dataValid <= false;
    end if;
    if ((checkTimingR = readhold) and (not dataValid) and (Enable='0')) then
      assert ((MemCE='0' and MemCE'last_event<=tODmax) or
              (MemCE='1' and MemCE'last_event>tODmax))
        report "Memory: CE to Output in High-Z t(OD) is greater than " & ToString(tODmax);
      assert ((MemOE='1' and MemOE'last_event<=tODOmax) or
              (MemOE='0' and MemOE'last_event>tODOmax))
        report "Memory: OE to Output in High-Z t(ODO) is greater than " & ToString(tODOmax);
      checkTimingR := none;
    elsif (checkTimingW = writehold) then
        assert (MemRW'last_event>=tDHmin)  --(MemIOData'stable(tDHmin))
          report "Memory: Data Hold Time t(DH) is lesser than " & ToString(tDHmin);
      checkTimingW := none;
    end if;
    if (Enable='1') then
      assert ((MemIOData=DataOut) or (MemIOData=HighZ) or (MemIOData=Uninitialized) or (MemIOData=Unknown))
        report "Memory: bus contention because writing " & ToBitString (To_stdulogicvector(DataOut)) &
               " but data bus is " & ToBitString (To_stdulogicvector(MemIOData));
    elsif (Enable='0'and MemCE='1'and MemRW='0') then
      assert (IsValid(To_stdulogicvector(MemIOData)) or (MemIOData=HighZ) or (MemIOData=Unknown))
        report "Memory: bus contention because reading " & ToBitString (To_stdulogicvector(MemIOData));
    end if;
  end process CheckTimingIOData;


  OutputBehavior: process (Enable, DataOut)
  begin
    if (Enable='1' and Enable'event) then
      if (MemAddr /= DontCare) then
        if (MemCE'last_event >= MemOE'last_event) then
          MemIOData <= (others => 'X') after tOEEmin,
                       DataOut         after tOEmax;
        else
          MemIOData <= (others => 'X') after tCOEmin,
                       DataOut         after tCOmax;
        end if;
      end if;
      tRW := now;
    elsif (Enable='1') then
      MemIOData <= (others => 'X') after tOHmin,
                   DataOut         after tACCmax;
    elsif (Enable='0' and Enable'event) then
      MemIOData <= (others => 'X') after tOHmin,
                   (others => 'Z') after tODmax;
--  elsif (Enable='0') then
--    MemIOData <= (others => 'Z');
    end if;
  end process OutputBehavior; 


  MemoryBehavior: process (MemAddr, MemCE, MemRW, MemOE)
    variable memo          : MemoryType;
    variable init, startRW : boolean := false;
    variable writeaddr     : Integer := 0;
    variable waitReadEnd, waitWriteEnd    : boolean := false;

  begin

      if not init then 
        initmemory(memo);
        init := true; 
      end if;

      if (MemAddr'event) then
        if (ToInteger(MemAddr) /= -1) then
          writeAddr := ToInteger(MemAddr);
          DataOut <= To_stdlogicvector(memo(ToInteger(MemAddr)));
        else
          writeAddr := 0;
          DataOut <= (others => '0');
        end if;
        if (start2 /= now) then
          start  := start2;
          start2 := now;
        end if;
        if ((checkTimingR = readcycle) and (start/=0 ns)) then
          assert ((now-start)>=tRCmin)
            report "Memory: Read Cycle Time t(RC) is lesser than " & ToString(tRCmin);
          assert ((MemRW'last_event>=(now-tRW)) or (MemRW'last_event=0 ns))
            report "Memory: R/W must be High for Read Operation at least " & ToString(tRCmin);
          checkTimingR := none;
        end if;
        if ((checkTimingW = writecycle) and (start/=0 ns)) then
          assert ((now-MemRW'last_event)>=tWRmin or (MemRW'last_event=0 ns))
            report "Memory: Write Recovery Time t(WR) is lesser than " & ToString(tWRmin);
          assert ((now-start)>=tWCmin)
            report "Memory: Write Cycle Time t(WC) is lesser than " & ToString(tWCmin);
          checkTimingW := none;
        end if;
      end if;
             
      ------------------ read cycle ------------------

      if ((not waitReadEnd) and (not waitWriteEnd)) then
        if (MemRW='1' and MemCE='1' and MemOE='0') then
          if (checkTimingR = readcycle) then
            assert ((now-start)>=tRCmin)
              report "Memory: Read Cycle Time t(RC) is lesser than " & ToString(tRCmin);
	      end if;
          checkTimingR := readcycle;
          waitReadEnd  := true;
        end if;
      elsif (waitReadEnd and dataValid) then
        if (MemAddr'event) then
          if (MemRW='1' and MemCE='1' and MemOE='0') then
            checkTimingR := readcycle;
          else
            checkTimingR := readhold;
          end if;
          waitReadEnd := (MemRW='1' and MemCE='1' and MemOE='0');
        end if;
      end if;

      ------------------ write cycle ------------------

      if (MemRW='0' and MemRW'event) then
        startRW := true;
        tRW := now;
      end if;

      if (not waitWriteEnd) then
        if (startRW and MemCE='1' and MemOE='1') then
          assert (now-start-MemRW'last_event>=tASmin)
            report "Memory: Address Setup Time t(AS) is lesser than " & ToString(tASmin);
          DataOut <= (others => 'Z') after tODWmax;
          checkTimingW := writecycle;
          waitWriteEnd := true;
        end if;
      else
        assert (MemRW='1' or (MemRW='0' and MemOE'last_event>=(now-tRW)))
          report "Memory: OE must be High for Write Operation at least " & ToString(tWCmin);
        
        if (MemRW='1' and MemRW'event) then

          assert (now-tRW >= tWPmin)
            report "Memory: Write Pulse Width t(WP) is lesser than " & ToString(tWPmin);
          assert (MemCE='1' or MemCE='U' or MemCE'last_event>=tCWmin)
            report "Memory: CE to End of Write t(CW) is lesser than " & ToString(tCWmin);
          assert (MemIOData'stable(tDSmin) or (MemIOData'last_event=0 ns))
            report "Memory: Data Setup Time t(DS) is lesser than " & ToString(tDSmin);

          memo(writeAddr) := To_stdulogicvector(MemIOData);
          if (writeAddr = MemDumpAddr) then
            WriteMemDump (memo, ToInteger(To_stdulogicvector(MemIOData)), MemDumpWords);
          end if;

          assert ((writeAddr>=RAMstart and writeAddr<=RAMend) or (writeAddr=MemDumpAddr))
            report "Memory-address " & ToHexString (writeAddr,HexDigits) & "h is out of RAM " &
                ToHexString (RAMstart,HexDigits) & "h - " & ToHexString (RAMend,HexDigits) & "h";
          assert (MemOE='1' or (MemOE'last_event=0 ns))
            report "Memory: OE must be High for Write Operation at least " & ToString(tWCmin);

          checkTimingW := writehold;
          waitWriteEnd := false;
          startRW := false;

        end if;          
      end if;

  end process MemoryBehavior;

  Enable <= ((not MemOE) and MemRW and MemCE);  -- enable output of memory

end architecture Memory_arch; 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--------

----------------------------------------------------------------------
-- memory wrapper

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.mem_pack.all;

entity memory is
  generic (
    file_base_g : string := "main"); -- base name for assember, log and dump file
  port (
    mem_addr_i : in    std_ulogic_vector(15 downto 0);      -- address input
    mem_dat_io : inout std_logic_vector(15 downto 0);       -- data i/o
    mem_ce_ni  : in    std_ulogic;      -- chip enable (low active)
    mem_oe_ni  : in    std_ulogic;      -- output enable (low active)
    mem_we_ni  : in    std_ulogic);     -- write enable (low active)

end memory;

architecture beh of memory is

  component Memory_impl
    generic (
      Assfilename : string;
      Logfilename : string;
      Memfilename : string;
      ROMstart    : natural;
      ROMend      : natural;
      RAMstart    : natural;
      RAMend      : natural;
      MemDumpAddr : natural);
    port (
      MemAddr   : in    DataVec;
      MemIOData : inout IODataVec;
      MemRW     : in    std_ulogic;
      MemOE     : in    std_ulogic;
      MemCE     : in    std_ulogic);
  end component;

  signal mem_addr : DataVec;
  signal mem_dat  : IODataVec;
  signal mem_ce   : std_ulogic;
begin  -- beh

  memory_impl_inst: Memory_impl
    generic map (
        Assfilename => file_base_g & ".ass",
        Logfilename => file_base_g & ".log",
        Memfilename => file_base_g & ".hex",
        ROMstart    => 00000,
        ROMend      => 32767,
        RAMstart    => 32768,
        RAMend      => 65534,
        MemDumpAddr => 65535)
    port map (
        MemAddr   => mem_addr,
        MemIOData => mem_dat,
        MemRW     => mem_we_ni,
        MemOE     => mem_oe_ni,
        MemCE     => mem_ce);

  mem_addr   <= DataVec(mem_addr_i);
  mem_dat    <= (others => 'Z') when is_x(mem_dat_io) else
                IODataVec(mem_dat_io);
  mem_dat_io <= std_logic_vector(mem_dat);
  mem_ce     <= not mem_ce_ni;
  
end beh;

