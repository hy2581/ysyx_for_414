#!/bin/bash
# ysyxSoCFull 综合与时序分析
# 需要 yosys-sta 仓库，或使用 ./run_synth_ysyxSoCFull.sh 进行本地综合
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$(cd "$SCRIPT_DIR" && pwd)"
RTL_FILES="$WORKSPACE/ysyxSoC/build/ysyxSoCFull.v $(find "$WORKSPACE/ysyxSoC/perip" -name "*.v" | tr '\n' ' ') $WORKSPACE/npc/vsrc/ysyx_00000000.v $(find "$WORKSPACE/npc/vsrc/core" -name "*.v" | tr '\n' ' ')"
if [ -d "$WORKSPACE/../yosys-sta" ]; then
  make -C "$WORKSPACE/../yosys-sta" sta \
    DESIGN=ysyxSoCFull \
    SDC_FILE="$WORKSPACE/ysyxSoCFull.sdc" \
    RTL_FILES="$RTL_FILES" \
    VERILOG_INCLUDE_DIRS="$WORKSPACE/npc/vsrc/core $WORKSPACE/npc/vsrc/perip" \
    CLK_FREQ_MHZ=500
else
  echo "未找到 yosys-sta 仓库。请将 yosys-sta 放在 $WORKSPACE/../ 下，"
  echo "或使用 ./run_synth_ysyxSoCFull.sh 进行本地 Yosys 综合。"
  exit 1
fi
