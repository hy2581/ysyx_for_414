# ysyxSoCFull 综合说明

## 概述

本目录包含对 **ysyxSoCFull** 完整 SoC 设计进行逻辑综合的脚本。ysyxSoCFull 由 Chisel/Firtool 生成，包含 npc CPU 核及 ysyxSoC 外设（UART、SPI、SDRAM、PSRAM、GPIO、VGA 等）。

## 前置条件

1. **生成 ysyxSoCFull.v**：
   ```bash
   cd ysyxSoC && make verilog
   ```
   需要 mill 和 Java（ysyxSoC 目录下有 mill 包装脚本）。

2. **安装 Yosys**：
   ```bash
   sudo apt install yosys
   ```
   注意：系统自带的 Yosys 0.33 对 Chisel 生成的 SystemVerilog 支持有限（如 `logic [n][m]`、`automatic logic` 等）。若综合失败，建议使用 **Yosys 0.36+** 或通过 `run-sta.sh` 使用 yosys-sta 仓库。

## 运行综合

从 **workspace 根目录** 运行：

```bash
./run_synth_ysyxSoCFull.sh
```

或：

```bash
make synth-ysyxSoCFull
```

## 输出文件

综合成功后，输出位于 `npc/scripts/synth_output/`：

- `ysyxSoCFull_synth.v`：行为级网表，适合仿真
- `ysyxSoCFull_structural.v`：结构网表，可用于 OpenSTA 时序分析

## 文件说明

| 文件 | 说明 |
|------|------|
| `synth_ysyxSoCFull.ys` | Yosys 综合脚本 |
| `run_synth_ysyxSoCFull.sh` | 综合入口脚本（在 workspace 根目录） |

## 时序分析 (STA)

若需时序分析，可使用 `run-sta.sh`（需 yosys-sta 仓库），或参考 `docs/综合与时序分析学习讲义.md` 配置 OpenSTA。
