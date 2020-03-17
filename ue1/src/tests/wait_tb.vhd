library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Wait_tb is
end entity;

architecture tb of Wait_tb is
    constant C_CLOCK_FREQ   : integer := 100e6;
    constant C_CLOCK_PERIOD : time := 1 sec / C_CLOCK_FREQ;

    signal clk          : std_ulogic;
    signal rst          : std_ulogic;
    signal ack          : std_ulogic;
begin

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
        variable before : time;
    begin
        wait until rising_edge(clk);
        wait until falling_edge(rst);

        wait until rising_edge(clk);
        assert clk = '1' severity failure;


        --
        -- wait until clk = '1'
        --

        -- if clk is already '1' wait for the next rising_edge
        before := now;
        wait until clk = '1';
        assert now - before = C_CLOCK_PERIOD severity failure;

        wait until falling_edge(clk);
        assert clk = '0' severity failure;

        -- if clk is '0' at the moment, the next rising edge ends the wait
        before := now;
        wait until clk = '1';
        assert now - before = C_CLOCK_PERIOD/2 severity failure;
        assert clk = '1' severity failure;


        --
        -- wait on clk until ack = '1';
        --

        wait until rising_edge(clk);
        assert clk = '1' severity failure;

        -- if ack goes '1' at a falling edge of clk, the wait statement ends (wait on waits for any event!)
        ack <= '0' after 0 ns,
               '1' after C_CLOCK_PERIOD / 2;

        before := now;
        wait on clk until ack = '1';
        assert now - before = C_CLOCK_PERIOD / 2 severity failure;
        assert clk = '0' and ack = '1' severity failure;


        -- if there are clock events where ack is not '1', the wait goes on
        ack <= '0' after 0 ns,
               '1' after C_CLOCK_PERIOD + 1 ps; -- avoid the clock edge!

        before := now;
        wait on clk until ack = '1';
        assert now - before = C_CLOCK_PERIOD + C_CLOCK_PERIOD/2 severity failure;
        assert clk = '1' and ack = '1' severity failure;



        assert false report "Finished successfully" severity failure;
        wait;
    end process;

end architecture tb;
