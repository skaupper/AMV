library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.WishboneBFM_pack.all;


entity WishboneBFM_tb is
end entity;

architecture tb of WishboneBFM_tb is
    constant cClockFreq   : integer := 100e6;
    constant cClockPeriod : time := 1 sec / cClockFreq;

    constant cEndAddress  : natural := 2**cAddrWidth-1;


    signal clk      : std_ulogic;
    signal rst      : std_ulogic;

    signal bfmOut   : aBfmOut;
    signal bfmIn    : aBfmIn;


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
            wait for cClockPeriod / 2;
            clk <= not clk;
        end loop;
    end process;

    RST_GEN_proc : process is
    begin
        rst <= '1';

        wait until rising_edge(clk);
        wait for cClockPeriod * 15.7;

        rst <= '0';
        wait;
    end process;


    --
    -- Actual test cases
    --

    bfmIn.clk <= clk;

    STIMULUS_proc: process is
        variable rdata : std_ulogic_vector(cDataWidth-1 downto 0);
        variable wdataArr : aDataArray(0 to cEndAddress);
        variable rdataArr : aDataArray(0 to cEndAddress);
    begin
        wait until rising_edge(clk);

        -- TODO: checks while DUT is in reset

        wait until falling_edge(rst);

        for i in 0 to cEndAddress loop
            busWrite(std_ulogic_vector(to_unsigned(i, cAddrWidth)),
                     std_ulogic_vector(to_unsigned(i, cDataWidth)),
                     bfmOut, bfmIn);
            busRead(std_ulogic_vector(to_unsigned(i, cAddrWidth)),
                    bfmOut, bfmIn, rdata);

            assert rdata = std_ulogic_vector(to_unsigned(i, cDataWidth))
                report "(AMV) Read wrong data." severity error;
        end loop;

        busIdle(bfmOut, bfmIn);
        wait for 200 * cClockPeriod;

        -- Initialize data array
        for i in wdataArr'range loop
            wdataArr(i) := std_ulogic_vector(to_unsigned(i*4, cDataWidth));
        end loop;

        busWriteBlock(std_ulogic_vector(to_unsigned(0, cAddrWidth)),
                      wdataArr, bfmOut, bfmIn);
        busReadBlock(std_ulogic_vector(to_unsigned(0, cAddrWidth)),
                     bfmOut, bfmIn, rdataArr);

        for i in wdataArr'range loop
            assert rdataArr(i) = wdataArr(i)
            report "(AMV) Read wrong data in array." severity error;
        end loop;

        finished <= '1';
        wait;
    end process;

end architecture tb;
