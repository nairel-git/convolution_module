library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_generic_counter is
end entity tb_generic_counter;

architecture sim of tb_generic_counter is
    constant CLK_PERIOD : time := 10 ns;

    -- parâmetros de teste
    constant G_NBITS     : positive := 4;
    constant G_MAX_COUNT : natural  := 9;

    signal clk   : std_logic := '0';
    signal rst   : std_logic := '0';
    signal en    : std_logic := '1';
    signal count : unsigned(G_NBITS - 1 downto 0);
    signal done  : std_logic;

begin
    -- DUT (Device Under Test)
    dut : entity work.generic_counter
        generic map(
            G_NBITS     => G_NBITS,
            G_MAX_COUNT => G_MAX_COUNT
        )
        port map(
            clock  => clk,
            reset  => rst,
            enable => en,
            count  => count,
            done   => done
        );

    -- Clock
    clk_process : process
    begin
        while now < 500 ns loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

  
    -- Monitor
    monitor_proc : process(clk)
    begin
        if rising_edge(clk) then
            report "Tempo: " & time'image(now) & " | count = " & integer'image(to_integer(count)) & " | done = " & std_logic'image(done);
        end if;
    end process;
end architecture sim;
