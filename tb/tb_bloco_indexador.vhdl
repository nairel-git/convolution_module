library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.convolution_pack.all;

entity tb_bloco_indexador is
end entity;

architecture sim of tb_bloco_indexador is

    -- parâmetros da imagem
    constant IMG_W : positive := 8;
    constant IMG_H : positive := 8;

    -- sinais do DUT
    signal clk            : std_logic := '0';
    signal rst_counter_w  : std_logic := '0';
    signal rst_counter_h  : std_logic := '0';
    signal rst_counter_i  : std_logic := '0';
    signal en_counter_w   : std_logic := '0';
    signal en_counter_h   : std_logic := '0';
    signal en_counter_i   : std_logic := '0';
    signal sample_address : unsigned(address_length(IMG_W, IMG_H) - 1 downto 0);
    signal done_counter_w : std_logic;
    signal done_counter_h : std_logic;
    signal done_counter_i : std_logic;
    signal invalid        : std_logic;

begin

    --------------------------------------------------------------------
    -- DUT (Design Under Test)
    --------------------------------------------------------------------
    uut : entity work.bo
        generic map(
            img_width  => IMG_W,
            img_height => IMG_H
        )
        port map(
            clk            => clk,
            rst_counter_w  => rst_counter_w,
            rst_counter_h  => rst_counter_h,
            rst_counter_i  => rst_counter_i,
            en_counter_w   => en_counter_w,
            en_counter_h   => en_counter_h,
            en_counter_i   => en_counter_i,
            sample_address => sample_address,
            invalid        => invalid,
            done_counter_w => done_counter_w,
            done_counter_h => done_counter_h,
            done_counter_i => done_counter_i
        );

    --------------------------------------------------------------------
    -- Clock
    --------------------------------------------------------------------
    clk <= not clk after 10 ns;

    --------------------------------------------------------------------
    -- Estímulos
    --------------------------------------------------------------------
    process
    begin
        ----------------------------------------------------------------
        -- Reset inicial
        ----------------------------------------------------------------
        rst_counter_w <= '1';
        rst_counter_h <= '1';
        rst_counter_i <= '1';
        en_counter_w  <= '0';
        en_counter_h  <= '0';
        en_counter_i  <= '0';
        wait for 40 ns;

        rst_counter_w <= '0';
        rst_counter_h <= '0';
        rst_counter_i <= '0';
        wait for 20 ns;

        ----------------------------------------------------------------
        -- Habilita contador de índices
        ----------------------------------------------------------------

        report "activated " severity note;
        
        en_counter_i <= '1';
        wait for 300 ns;                -- tempo para o contador rodar
        ----------------------------------------------------------------
        -- Fim da simulação
        ----------------------------------------------------------------
        wait;
    end process;

    --------------------------------------------------------------------
    -- Monitor
    --------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            report "clk " & " done_i=" & std_logic'image(done_counter_i) & " invalid=" & std_logic'image(invalid) & " sample_addr=" & integer'image(to_integer(sample_address));
        end if;
    end process;

end architecture;
