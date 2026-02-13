#!/bin/bash
# ysyxSoCFull 综合入口脚本
# 从 workspace 根目录运行，调用 Yosys 对 ysyxSoCFull 进行逻辑综合

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR" && pwd)"
cd "$WORKSPACE_ROOT"

# 检查 ysyxSoCFull.v 是否存在
if [ ! -f "ysyxSoC/build/ysyxSoCFull.v" ]; then
    echo "错误: ysyxSoCFull.v 不存在。请先运行: cd ysyxSoC && make verilog"
    exit 1
fi

# 优先使用最新版 Yosys（若已编译）
if [ -f "$WORKSPACE_ROOT/yosys-latest/yosys" ]; then
    YOSYS="$WORKSPACE_ROOT/yosys-latest/yosys"
    echo "使用最新版 Yosys: $($YOSYS --version 2>/dev/null | head -1)"
elif command -v yosys &> /dev/null; then
    YOSYS="yosys"
else
    echo "错误: 未找到 yosys。请安装: sudo apt install yosys 或编译 yosys-latest"
    exit 1
fi

# 预处理 RTL 以支持综合
SYNTH_V="npc/vsrc/ysyxSoCFull_synth_input.v"
sed 's/automatic logic/logic/g' ysyxSoC/build/ysyxSoCFull.v > "$SYNTH_V"
# 替换 DPI-C（仅仿真用）为综合兼容的 MROMHelper 实现
sed -i 's/import "DPI-C" function void mrom_read(input int raddr, output int rdata);/\/\/ DPI removed for synthesis/' "$SYNTH_V"
sed -i 's/if (ren) mrom_read(raddr, rdata);/if (ren) rdata = 32'"'"'h0; \/\/ DPI stub/' "$SYNTH_V"

echo "开始综合 ysyxSoCFull..."
$YOSYS -s npc/scripts/synth_ysyxSoCFull.ys

echo ""
echo "综合完成！输出文件："
echo "  - npc/scripts/synth_output/ysyxSoCFull_synth.v       (行为网表)"
echo "  - npc/scripts/synth_output/ysyxSoCFull_structural.v (结构网表，可用于 STA)"
