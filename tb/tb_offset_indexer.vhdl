library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.convolution_pack.all;

entity tb_offset_indexer is
end entity;

architecture sim of tb_offset_indexer is
    -- Parâmetros da imagem
    constant IMG_W : positive := 4;
    constant IMG_H : positive := 3;

    -- Sinais do DUT
    signal in_x, in_y   : unsigned(address_length(IMG_W, IMG_H) downto 0) := (others => '0');
    signal out_x, out_y : unsigned(address_length(IMG_W, IMG_H) downto 0);
    signal index        : unsigned(4 downto 0)                            := (others => '0');
    signal invalid      : std_logic;

begin
    -- Instancia o DUT
    dut : entity work.offset_indexer
        generic map(
            img_width  => IMG_W,
            img_height => IMG_H
        )
        port map(
            in_x    => in_x,
            in_y    => in_y,
            out_x   => out_x,
            out_y   => out_y,
            index   => index,
            invalid => invalid
        );

    -- Processo de estímulos
    stim_proc : process
    begin
        report "===== INICIO DO TESTE =====";

        -- Percorre alguns pontos dentro da imagem
        for y in 0 to IMG_H - 1 loop
            for x in 0 to IMG_W - 1 loop
                in_x <= to_unsigned(x, in_x'length);
                in_y <= to_unsigned(y, in_y'length);

                for i in 0 to 8 loop
                    index <= to_unsigned(i, index'length);
                    wait for 10 ns;

                    report "x=" & integer'image(x) & " y=" & integer'image(y) & " idx=" & integer'image(i) & " => out_x=" & integer'image(to_integer(out_x)) & " out_y=" & integer'image(to_integer(out_y)) & " invalid=" & std_logic'image(invalid);
                end loop;
            end loop;
        end loop;

        report "===== FIM DO TESTE =====";
        wait;
    end process;
end architecture;
