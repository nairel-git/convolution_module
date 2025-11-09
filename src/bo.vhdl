library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.convolution_pack.all;

entity bo is
    generic(
        -- obrigatório ---
        img_width       : positive := 256; -- número de valores numa linha de imagem
        img_height      : positive := 256; -- número de linhas de valores na imagem
        bits_per_pixel  : positive := 8  -- número de bits por pixel
    );

    port(
        clk            : in  std_logic; -- clock
        rst_counter_w, rst_counter_h, rst_counter_i : in  std_logic; -- reset
        en_counter_w, en_counter_h, en_counter_i : in  std_logic; -- iniciar

        sample_address : out unsigned(address_length(img_width, img_height) - 1 downto 0);

        invalid : out std_logic;

        done_counter_w, done_counter_h, done_counter_i : out std_logic
    );
end entity bo;

architecture arch of bo is


    signal count_w : unsigned(log2_ceil(img_width) - 1 downto 0);
    signal count_h : unsigned(log2_ceil(img_height) - 1 downto 0);
    signal count_i : unsigned(3 downto 0);

    signal offset_x : unsigned(log2_ceil(img_width) - 1 downto 0);
    signal offset_y : unsigned(log2_ceil(img_height) - 1 downto 0);

begin
    

    Counter_Width: entity work.generic_counter
        generic map(
            G_NBITS     => log2_ceil(img_width),
            G_MAX_COUNT => img_width
        )
        port map(
            clock  => clk,
            reset  => rst_counter_w,
            enable => en_counter_w,
            count  => count_w,
            done   => done_counter_w
        );
    
    Counter_Height: entity work.generic_counter
        generic map(
            G_NBITS     => log2_ceil(img_height),
            G_MAX_COUNT => img_height
        )
        port map(
            clock  => clk,
            reset  => rst_counter_h,
            enable => en_counter_h,
            count  => count_h,
            done   => done_counter_h
        );

    Counter_Index: entity work.generic_counter
        generic map(
            G_NBITS     => 4,
            G_MAX_COUNT => 8
        )
        port map(
            clock  => clk,
            reset  => rst_counter_i,
            enable => en_counter_i,
            count  => count_i,
            done   => done_counter_i
        );
    
    Offset_Indexer: entity work.offset_indexer
        generic map(
            img_width  => img_width,
            img_height => img_height
        )
        port map(
            in_x    => count_w,
            in_y    => count_h,
            out_x   => offset_x,
            out_y   => offset_y,
            index   => count_i,
            invalid => invalid
        );
    

    Add_Calc: entity work.address_calculator
        generic map(
            img_width  => img_width,
            img_height => img_height
        )
        port map(
            in_x     => offset_x,
            in_y     => offset_y,
            out_addr => sample_address
        );
    
end architecture;
