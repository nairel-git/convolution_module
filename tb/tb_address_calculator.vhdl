library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Assumindo que seu 'package' está compilado na 'work'
use work.convolution_pack.all;

-- A entidade do testbench é sempre vazia
entity tb_address_calculator is
end entity;

architecture sim of tb_address_calculator is

    -- =================================================================
    -- 1. Constantes de Configuração do Teste
    -- =================================================================

    constant TB_IMG_WIDTH  : positive := 5; -- 5 pixels de largura
    constant TB_IMG_HEIGHT : positive := 6; -- 6 pixels de altura

    -- Calcula as larguras dos vetores (bits) USANDO AS SUAS FUNÇÕES
    -- log2_ceil(5) = 3. O vetor 'in_x' será (2 downto 0).
    constant C_X_NBITS    : natural := log2_ceil(TB_IMG_WIDTH);
    -- log2_ceil(6) = 3. O vetor 'in_y' será (2 downto 0).
    constant C_Y_NBITS    : natural := log2_ceil(TB_IMG_HEIGHT);
    -- address_length(5, 6) = log2_ceil(30) = 5. O vetor 'out_addr' será (4 downto 0).
    constant C_ADDR_NBITS : natural := address_length(TB_IMG_WIDTH, TB_IMG_HEIGHT);

    -- =================================================================
    -- 2. Sinais de Conexão com o DUT
    -- =================================================================

    signal s_in_x     : unsigned(C_X_NBITS - 1 downto 0);
    signal s_in_y     : unsigned(C_Y_NBITS - 1 downto 0);
    signal s_out_addr : unsigned(C_ADDR_NBITS - 1 downto 0);

    -- Componente (deve bater com a 'entity' do seu 'address_calculator')
    component address_calculator
        generic(
            img_width  : positive;
            img_height : positive
        );
        port(
            in_x     : in  unsigned(log2_ceil(img_width) - 1 downto 0);
            in_y     : in  unsigned(log2_ceil(img_height) - 1 downto 0);
            out_addr : out unsigned(address_length(img_width, img_height) - 1 downto 0)
        );
    end component;

begin

    -- =================================================================
    -- 3. Instanciação do DUT
    -- =================================================================

    DUT : address_calculator
        generic map(
            img_width  => TB_IMG_WIDTH,
            img_height => TB_IMG_HEIGHT
        )
        port map(
            in_x     => s_in_x,
            in_y     => s_in_y,
            out_addr => s_out_addr
        );

    -- =================================================================
    -- 4. Processo de Estímulo e Verificação
    -- =================================================================

    stim_proc : process
        -- Variáveis para o loop
        variable expected_addr : unsigned(C_ADDR_NBITS - 1 downto 0);

        -- Variáveis para o relatório final
        variable error_count   : natural := 0;
        variable success_count : natural := 0;
        variable total_cases   : natural := 0;

    begin
        report "========================================";
        report "Iniciando Testbench (Imagem 5x6)";
        report "========================================";

        -- Loop para testar todos os 30 pixels (5x6)
        for y in 0 to TB_IMG_HEIGHT - 1 loop
            for x in 0 to TB_IMG_WIDTH - 1 loop

                -- 1. Aplicar estímulo
                s_in_x <= to_unsigned(x, C_X_NBITS);
                s_in_y <= to_unsigned(y, C_Y_NBITS);

                -- 2. Calcular o valor esperado
                expected_addr := to_unsigned(y * TB_IMG_WIDTH + x, C_ADDR_NBITS);

                -- 3. Esperar a lógica combinacional propagar
                wait for 10 ns;

                -- 4. Verificar o resultado e contar
                total_cases := total_cases + 1;

                if s_out_addr = expected_addr then
                    success_count := success_count + 1;
                else
                    error_count := error_count + 1;
                    -- Reporta a falha IMEDIATAMENTE
                    report "FALHA: (x=" & integer'image(x) & ", y=" & integer'image(y) & ")" & " Esperado=" & integer'image(to_integer(expected_addr)) & " Obtido=" & integer'image(to_integer(s_out_addr))
                    severity error;
                end if;

            end loop;
        end loop;

        -- =================================================================
        -- 5. Relatório Final (Erros / Acertos)
        -- =================================================================


        report "Total de Casos Testados: " & integer'image(total_cases);
        report "Acertos: " & integer'image(success_count);
        report "Erros:   " & integer'image(error_count);
        report "========================================";

        -- Para o simulador (e falha se houver erros)
        if error_count > 0 then
            report "Simulação falhou com " & integer'image(error_count) & " erro(s)." severity failure;
        else
            report "Simulação passou em todos os testes!" severity note;
        end if;

        wait;
    end process;

end architecture sim;
