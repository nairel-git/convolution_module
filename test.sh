#!/bin/bash
set -e

echo "🔧 Compilando blocos..."
ghdl -a src/convolution_pack.vhdl
ghdl -a src/generic_counter.vhdl
ghdl -a src/offset_indexer.vhdl
ghdl -a src/address_calculator.vhdl
ghdl -a src/bloco_indexador.vhdl
ghdl -a tb/tb_bloco_indexador.vhdl

echo "⚙️  Ligando entidades..."
ghdl -e tb_bloco_indexador

echo "🚀 Rodando simulação..."
ghdl -r tb_bloco_indexador --stop-time=1000ns --vcd=wave.vcd

echo "✅ Simulação completa. Arquivo gerado: wave.vcd"
