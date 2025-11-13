library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generic_counter is
    generic(
        G_NBITS     : positive := 8;    -- Define o tamanho do contador (número de bits)
        G_MAX_COUNT : natural  := 255   -- Valor máximo que o contador vai contar (em inteiro)
    );
    port(
        clock  : in  std_logic;
        reset  : in  std_logic;         -- Assíncrono ativo alto
        enable : in  std_logic;         -- Habilita a contagem

        count  : out unsigned(G_NBITS - 1 downto 0);
        done   : out std_logic
    );
end entity generic_counter;

architecture rtl of generic_counter is
    signal s_count : unsigned(G_NBITS - 1 downto 0) := (others => '0');
begin

    process(clock, reset)
    begin
        if reset = '1' then
            s_count <= (others => '0');

        elsif rising_edge(clock) then
            if enable = '1' then
                if to_integer(s_count) < G_MAX_COUNT then
                    s_count <= s_count + 1;
                end if;
            end if;
        end if;
    end process;

    count <= s_count;
    done  <= '1' when to_integer(s_count) = G_MAX_COUNT else '0';

end architecture rtl;
