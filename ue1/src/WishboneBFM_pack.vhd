library ieee;
use ieee.std_logic_1164.all;


package WishboneBFM_pack is
    --
    -- Constants
    --

    constant cDataWidth : integer := 32;
    constant cAddrWidth : integer := 8;



    --
    -- Types
    --

    type aBusIn is record
        dat_i : std_ulogic_vector(cDataWidth-1 downto 0);
        adr_i : std_ulogic_vector(cAddrWidth-1 downto 0);
        sel_i : std_ulogic_vector(cDataWidth/8-1 downto 0);
        cyc_i : std_ulogic;
        stb_i : std_ulogic;
        we_i  : std_ulogic;
    end record;

    type aBusOut is record
        dat_o : std_ulogic_vector(cDataWidth-1 downto 0);
        ack_o : std_ulogic;
    end record;



    --
    -- Functions and procedures
    --

    procedure busWrite (
        constant addr    : in  std_ulogic_vector(cAddrWidth-1 downto 0);
        constant data    : in  std_ulogic_vector(cDataWidth-1 downto 0);
        signal   fromBus : in  aBusOut;
        signal   toBus   : out aBusIn
    );

    procedure busRead (
        constant addr    : in  std_ulogic_vector(cAddrWidth-1 downto 0);
        signal   fromBus : in  aBusOut;
        signal   toBus   : out aBusIn;
        variable data    : out std_ulogic_vector(cDataWidth-1 downto 0)
    );
end package;


package body WishboneBFM_pack is

    procedure busWrite (
        constant addr    : in  std_ulogic_vector(cAddrWidth-1 downto 0);
        constant data    : in  std_ulogic_vector(cDataWidth-1 downto 0);
        signal   fromBus : in  aBusOut;
        signal   toBus   : out aBusIn
    ) is
    begin
        -- TODO: implement
    end procedure;

    procedure busRead (
        constant addr    : in  std_ulogic_vector(cAddrWidth-1 downto 0);
        signal   fromBus : in  aBusOut;
        signal   toBus   : out aBusIn;
        variable data    : out std_ulogic_vector(cDataWidth-1 downto 0)
    ) is
    begin
        -- TODO: implement
    end procedure;

end package body;
