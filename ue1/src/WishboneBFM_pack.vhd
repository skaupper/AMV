library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package WishboneBFM_pack is
    --
    -- Constants
    --

    constant cDataWidth : integer := 32;
    constant cAddrWidth : integer := 8;



    --
    -- Types
    --

    type aBfmOut is record
        dat : std_ulogic_vector(cDataWidth-1 downto 0);
        adr : std_ulogic_vector(cAddrWidth-1 downto 0);
        sel : std_ulogic_vector(cDataWidth/8-1 downto 0);
        cyc : std_ulogic;
        stb : std_ulogic;
        we  : std_ulogic;
    end record aBfmOut;

    type aBfmIn is record
        clk : std_ulogic;
        dat : std_ulogic_vector(cDataWidth-1 downto 0);
        ack : std_ulogic;
    end record aBfmIn;

    type aDataArray is array(natural range<>) of
        std_ulogic_vector(cDataWidth-1 downto 0);

    --
    -- Functions and procedures
    --

    procedure busIdle (
        signal   bfmOut  : out aBfmOut;
        signal   bfmIn   : in  aBfmIn
    );

    procedure busWrite (
        constant addr    : in  std_ulogic_vector(cAddrWidth-1 downto 0);
        constant data    : in  std_ulogic_vector(cDataWidth-1 downto 0);
        signal   bfmOut  : out aBfmOut;
        signal   bfmIn   : in  aBfmIn
    );

    procedure busRead (
        constant addr    : in  std_ulogic_vector(cAddrWidth-1 downto 0);
        signal   bfmOut  : out aBfmOut;
        signal   bfmIn   : in  aBfmIn;
        variable data    : out std_ulogic_vector(cDataWidth-1 downto 0)
    );

    procedure busWriteBlock (
        constant addr    : in  std_ulogic_vector(cAddrWidth-1 downto 0);
        constant data    : in  aDataArray;
        signal   bfmOut  : out aBfmOut;
        signal   bfmIn   : in  aBfmIn
    );

    procedure busReadBlock (
        constant addr    : in  std_ulogic_vector(cAddrWidth-1 downto 0);
        signal   bfmOut  : out aBfmOut;
        signal   bfmIn   : in  aBfmIn;
        variable data    : out aDataArray
    );
end package;


package body WishboneBFM_pack is

    procedure busIdle (
        signal   bfmOut  : out aBfmOut;
        signal   bfmIn   : in  aBfmIn
    ) is
    begin
        wait until rising_edge(bfmIn.clk);
        bfmOut.stb <= '0';
        bfmOut.cyc <= '0';
    end procedure;

    procedure busWrite (
        constant addr    : in  std_ulogic_vector(cAddrWidth-1 downto 0);
        constant data    : in  std_ulogic_vector(cDataWidth-1 downto 0);
        signal   bfmOut  : out aBfmOut;
        signal   bfmIn   : in  aBfmIn
    ) is
    begin
        wait until rising_edge(bfmIn.clk);
        bfmOut.adr <= addr;
        bfmOut.dat <= data;
        bfmOut.we  <= '1';
        bfmOut.sel <= (others => '1');
        bfmOut.stb <= '1';
        bfmOut.cyc <= '1';

        wait until rising_edge(bfmIn.clk) and bfmIn.ack = '1';
        bfmOut.stb <= '0';
        bfmOut.cyc <= '0';
    end procedure;

    procedure busRead (
        constant addr    : in  std_ulogic_vector(cAddrWidth-1 downto 0);
        signal   bfmOut  : out aBfmOut;
        signal   bfmIn   : in  aBfmIn;
        variable data    : out std_ulogic_vector(cDataWidth-1 downto 0)
    ) is
    begin
        wait until rising_edge(bfmIn.clk);
        bfmOut.adr <= addr;
        bfmOut.we  <= '0';
        bfmOut.sel <= (others => '1');
        bfmOut.stb <= '1';
        bfmOut.cyc <= '1';

        wait until rising_edge(bfmIn.clk) and bfmIn.ack = '1';
        data := bfmIn.dat;
        bfmOut.stb <= '0';
        bfmOut.cyc <= '0';
    end procedure;

    procedure busWriteBlock (
        constant addr    : in  std_ulogic_vector(cAddrWidth-1 downto 0);
        constant data    : in  aDataArray;
        signal   bfmOut  : out aBfmOut;
        signal   bfmIn   : in  aBfmIn
    ) is
        variable curr_addr : unsigned(addr'range) := unsigned(addr);
    begin
        wait until rising_edge(bfmIn.clk);

        for i in data'low to data'high loop
            bfmOut.adr <= std_ulogic_vector(curr_addr);
            bfmOut.dat <= data(i);
            bfmOut.we  <= '1';
            bfmOut.sel <= (others => '1');
            bfmOut.stb <= '1';
            bfmOut.cyc <= '1';

            wait until rising_edge(bfmIn.clk) and bfmIn.ack = '1';
            bfmOut.stb <= '0';
            bfmOut.cyc <= '0';

            curr_addr := curr_addr + 1;
        end loop;
    end procedure;

    procedure busReadBlock (
        constant addr    : in  std_ulogic_vector(cAddrWidth-1 downto 0);
        signal   bfmOut  : out aBfmOut;
        signal   bfmIn   : in  aBfmIn;
        variable data    : out aDataArray
    ) is
        variable curr_addr : unsigned(addr'range) := unsigned(addr);
    begin
        wait until rising_edge(bfmIn.clk);

        for i in data'low to data'high loop
            bfmOut.adr <= std_ulogic_vector(curr_addr);
            bfmOut.we  <= '0';
            bfmOut.sel <= (others => '1');
            bfmOut.stb <= '1';
            bfmOut.cyc <= '1';

            wait until rising_edge(bfmIn.clk) and bfmIn.ack = '1';
            data(i) := bfmIn.dat;
            bfmOut.stb <= '0';
            bfmOut.cyc <= '0';

            curr_addr := curr_addr + 1;
        end loop;
    end procedure;

end package body;
