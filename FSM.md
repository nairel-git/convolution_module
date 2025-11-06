- bloco offset_calc(base_addr, index, img_width, img_height) 
- registrador r_reg (row) 
- registrador c_reg (column)

## S_IDLE (Estado "Pronto")

    Função: Ponto de partida. Espera o sinal de enable para começar.

    Ações (no clock):
        ready <= '1' (Sinaliza que está pronto para começar)
        done <= '0' (Sinaliza que o trabalho não está feito)
        r_reg <= 0 (Prepara para começar na linha 0, não pulando a borda)
        c_reg <= 0 (Prepara para começar na coluna 0, não pulando a borda)

    Transição:
        Se enable = '1', vai para S_INICIA_PIXEL.
        Senão, fica em S_IDLE.

## S_INICIA_PIXEL (Estado "Prepara e Pede 0")

    Função: Prepara os registros para um novo pixel de saída. Faz o cálculo "caro" (r*B+c) e já pede o primeiro pixel da janela (index=0).

    Ações (no clock):

        ready <= '0' (Sinaliza que está ocupado)
        index_reg <= 0 (Reseta o contador do loop da janela)
        acumulador_reg <= 0 

        //Endereço Base do Pixel atual, calculo transformando linha coluna em index continuo
        // isso pode ser feito com bit_shift caso seja uma potencia de 2
        calculo_addr_base = (r_reg * G_IMG_WIDTH) + c_reg
        
        //carrega o calculo num registrador para uso no S_LOOP_CALCULA
        addr_base_reg <= calculo_addr_base

        // Note que a entrada não pode ser a saida de addr_base_reg já q a saida só aparece no prox ciclo
        window_addr = offset_calc(calculo_addr_base, 0, G_IMG_WIDTH, G_IMG_HEIGHT)

        //Lê o valor do endereço window_addr para usar no proximo ciclo
        samples_mem_addr <= window_addr

    Transição:

        Vai para S_LOOP_CALCULA.

## S_LOOP_CALCULA

    Função: O coração do loop. Roda 9 vezes (para index_reg de 0 a 8).

    Ações (no clock):

        //rom_sample é o valor lido anteriormente da memoria
        rom_sample <= (ele é um sinal vindo direto da memoria)

        //cada valor do kernel estará salvo em 9 registradores indexados via mux com o sinal index_reg
        produto = rom_sample * kernel[index] (Calcula usando o pixel salvo e o kernel[index] instantâneo).

        //Bota o resultado no Acomulador (aqui temos que tomar cuidado com a quantidade de bits para evitar overflow)
        acumulador_reg <= acumulador_reg + produto (Acumula o resultado).

        //Calcula o end do proximo sample da janela
        window_addr = offset_calc(addr_base_reg, index_reg + 1, G_IMG_WIDTH, G_IMG_HEIGHT)

        //Lê o valor do endereço window_addr para usar no proximo ciclo
        samples_mem_addr <= window_addr

        //incrementa o index em um
        index_reg <= index_reg + 1

    Transição:

        Se index_reg < 8 fica em S_LOOP_CALCULA.

        Se index_reg = 8 (significa que acabamos de pedir o último pixel, o 8), vai para S_FINALIZA_E_ESCREVE.

## S_FINALIZA_E_ESCREVE (Estado "Calcula 8 e Escreve")

    Função: O loop de 8 ciclos acabou. O 9º (e último) pixel chegou. Este estado faz o último cálculo e escreve o resultado na RAM de saída.

    Ações (no clock):

        //rom_sample é o valor lido anteriormente da memoria
        rom_sample <= (ele é um sinal vindo direto da memoria)

        produto_final = rom_sample * kernel_mem[index_reg] (Cálculo final. index_reg agora é 8).

        resultado_bruto = acumulador_reg + produto_final (Soma final, combinacional).

        resultado_final = clip(resultado_bruto >> N) (Normaliza/Clipa, combinacional).

        ram_saida_addr <= addr_base_reg (O endereço de saída é o (r*B+c) que já salvamos).

        ram_saida_data <= resultado_final (Coloca o dado na porta de saída).

    Transição:

        Vai para S_PROXIMO_PIXEL.

## S_PROXIMO_PIXEL (Estado "Avança")

    Função: move os contadores r_reg e c_reg para o próximo pixel de saída, respeitando as bordas

    Ações (no clock):

        if c_reg < (G_IMG_WIDTH - 1) then
            c_reg <= c_reg + 1
        else
            c_reg <= 0

            if r_reg < (G_IMG_HEIGHT - 1) then
                r_reg <= r_reg + 1
            else
                done <= '1'

    Transição:

        Se done = '1' (foi o último pixel), vai para S_IDLE.
        Senão, vai para S_INICIA_PIXEL (para começar o próximo pixel).