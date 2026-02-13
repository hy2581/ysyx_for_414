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

# 检查 yosys 是否可用
if ! command -v yosys &> /dev/null; then
    echo "错误: 未找到 yosys。请安装: sudo apt install yosys"
    exit 1
fi

# 预处理：Yosys 0.33 不支持 "automatic logic"，替换为 "logic"
SYNTH_V="npc/vsrc/ysyxSoCFull_synth_input.v"
sed 's/automatic logic/logic/g' ysyxSoC/build/ysyxSoCFull.v > "$SYNTH_V"

echo "开始综合 ysyxSoCFull..."
echo "注意: ysyxSoCFull 由 Chisel/Firtool 生成，包含 SystemVerilog 2012 语法。"
echo "      Yosys 0.33 可能无法完全解析，建议使用 Yosys 0.36+ 或 run-sta.sh 中的 yosys-sta。"
# 使用预处理后的文件进行综合
yosys -s npc/scripts/synth_ysyxSoCFull.ys

echo ""
echo "综合完成！输出文件："
echo "  - npc/scripts/synth_output/ysyxSoCFull_synth.v       (行为网表)"
echo "  - npc/scripts/synth_output/ysyxSoCFull_structural.v (结构网表，可用于 STA)"
