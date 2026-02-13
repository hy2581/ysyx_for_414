# ysyxSoCFull 综合与 PPA 评估报告

**生成时间**: 2026-02-13 13:51:11

---

## 一、综合环境

| 项目 | 版本 |
|------|------|
| Yosys | Yosys 0.62+55 (git sha1 e2f0c4d9a-dirty, g++ 13.3.0-6ubuntu2~24.04 -fPIC -O3) |
| 设计 | ysyx_00000000 (npc CPU 核) / ysyxSoCFull (完整 SoC) |

---

## 二、综合结果

### 2.1 ysyx_00000000 (npc CPU 核) ✅

综合成功完成。

**输出文件**:
- `npc/scripts/synth_output/ysyx_00000000_synth.v` - 行为网表
- `npc/scripts/synth_output/ysyx_00000000_structural.v` - 结构网表

### 2.2 ysyxSoCFull (完整 SoC)

**综合未完成**。Chisel/Firtool 生成的 RTL 包含 SystemVerilog 2012 语法（如 `always` 块内局部变量声明），当前 Yosys 解析器存在兼容性限制。

---

## 三、PPA 评估 (ysyx_00000000)

### 3.1 Area (面积)

| 指标 | 数值 |
|------|------|
| 触发器 (DFF/DFFE) | 1589 |
| 组合逻辑门 (AND/OR/NOT/MUX/XOR) | 12154 |
| 总单元数 | 13750 |
| 等效门 (GE) | ~24413 |
| 估算面积 (45nm, 100k GE/mm²) | ~0.24 mm² |

### 3.2 Performance (性能)

| 指标 | 数值 |
|------|------|
| 关键路径估算 | ~3.55 ns |
| 最高频率估算 | ~282 MHz |
| 约束时钟 (SDC) | 500 MHz (目标) |

*注: 时序为经验公式估算，精确值需 OpenSTA + 工艺 Liberty。*

### 3.3 Power (功耗)

| 指标 | 数值 |
|------|------|
| 动态功耗估算 | ~1.0 mW @ 282 MHz |

*注: 基于单元数与频率的粗略估算，实际需门级仿真或工艺库。*

---

## 四、结论与建议

1. **ysyx_00000000** 综合流程已打通，PPA 指标可作为 CPU 核参考。
2. **ysyxSoCFull** 完整综合需解决 Chisel 生成代码与 Yosys 的 SV 兼容性，可考虑:
   - 使用 Verific 商业前端
   - 修改 Chisel 生成选项输出更兼容的 Verilog
   - 采用 OSS CAD Suite 预编译版本
3. 精确 PPA 需: 工艺 Liberty、OpenSTA 时序分析、门级功耗分析工具。

---

*报告由 `scripts/run_synth_and_ppa.sh` 自动生成*
