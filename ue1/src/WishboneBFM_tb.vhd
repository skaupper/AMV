library ieee;
use ieee.std_logic_1164.all;

library work;
use work.WishboneBFM_pack.all;


entity WishboneBFM_tb is
end entity;

architecture tb of WishboneBFM_tb is
    constant C_CLOCK_FREQ   : integer := 100e6;
    constant C_CLOCK_PERIOD : time := (1 / C_CLOCK_FREQ) * 1 sec;


    signal clk      : std_ulogic;
    signal rst      : std_ulogic;

    signal bfmOut : aBfmOut;
    signal bfmIn  : aBfmIn;

    -- used as exit condition by simulation script
    signal finished : std_ulogic := '0';

begin
    --
    -- Instantiate entities
    --

    DUT_RAM_inst: entity work.RAM generic map (
        gDataWidth => cDataWidth,
        gAddrWidth => cAddrWidth
    ) port map (
        clk_i => clk,
        rst_i => rst,
        adr_i => bfmOut.adr,
        dat_i => bfmOut.dat,
        sel_i => bfmOut.sel,
        cyc_i => bfmOut.cyc,
        stb_i => bfmOut.stb,
        we_i  => bfmOut.we,
        dat_o => bfmIn.dat,
        ack_o => bfmIn.ack
    );


    --
    -- Clock and reset generators
    --

    CLOCK_GEN_proc : process is
    begin
        clk <= '0';

        loop
            wait for C_CLOCK_PERIOD / 2;
            clk <= not clk;
        end loop;
    end process;

    RST_GEN_proc : process is
    begin
        rst <= '1';

        wait until rising_edge(clk);
        wait for C_CLOCK_PERIOD * 15.7;

        rst <= '0';
        wait;
    end process;


    --
    -- Actual test cases
    --

    STIMULUS_proc: process is
    begin
        wait until rising_edge(clk);

        -- TODO: checks while DUT is in reset

        wait until falling_edge(rst);

        -- TODO: checks after DUT has been started

        finished <= '1';
        wait;
    end process;

end architecture tb;
