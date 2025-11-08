library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.convolution_pack.all;

entity base_address is
    generic(
        img_width  : positive;
        img_height : positive
    );
    port(
        in_x  : in  unsigned(address_length(img_width, img_height) downto 0);
        in_y  : in  unsigned(address_length(img_width, img_height) downto 0);
        out_addr : out unsigned(address_length(img_width, img_height) - 1 downto 0)
    );
end entity base_address;

architecture rtl of base_address is
    signal base_address_signal : unsigned(address_length(img_width, img_height) - 1 downto 0);
    
begin
    

    process(in_x, in_y)
    begin
        base_address_signal <= in_y(address_length(img_width, img_height) - 1 downto 0) * to_unsigned(img_width, address_length(img_width, img_height)) +
                               in_x(address_length(img_width, img_height) - 1 downto 0);
    end process;

    out_addr <= base_address_signal;


end architecture rtl;
