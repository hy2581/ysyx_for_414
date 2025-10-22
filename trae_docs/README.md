# YSYX Workbench 项目文档

本文档对YSYX Workbench项目进行全面解析，帮助理解整个系统的架构和各个组件的作用。

## 项目概述

YSYX Workbench是一个完整的计算机系统教学平台，包含了从处理器设计到系统软件的完整工具链。主要包括以下几个核心组件：

- **NEMU** - 全系统模拟器，用于模拟完整的计算机系统
- **NPC** - 处理器核心设计，基于Verilog的CPU实现
- **Abstract Machine** - 抽象机器层，提供统一的硬件抽象接口
- **AM Kernels** - 基于抽象机器的内核和应用程序
- **FCEUX-AM** - NES模拟器移植，展示系统能力
- **NVBoard** - FPGA开发板支持库

## 文档结构

```
trae_docs/
├── README.md                    # 项目总览（本文档）
├── overview/                    # 系统架构概述
│   ├── system_architecture.md  # 整体系统架构
│   ├── component_relations.md  # 组件关系图
│   └── build_system.md        # 构建系统说明
├── nemu/                       # NEMU模拟器文档
│   ├── README.md              # NEMU概述
│   ├── core/                  # 核心模块
│   ├── isa/                   # 指令集实现
│   ├── devices/               # 设备模拟
│   └── monitor/               # 监视器和调试器
├── npc/                       # NPC处理器文档
│   ├── README.md              # NPC概述
│   ├── verilog/               # Verilog模块
│   └── csrc/                  # C++测试代码
├── abstract-machine/          # 抽象机器文档
│   ├── README.md              # AM概述
│   ├── am/                    # AM接口实现
│   └── klib/                  # 内核库
├── am-kernels/                # AM内核文档
│   ├── README.md              # 内核概述
│   ├── tests/                 # 测试程序
│   ├── kernels/               # 内核程序
│   └── benchmarks/            # 性能测试
├── fceux-am/                  # FCEUX模拟器文档
│   ├── README.md              # FCEUX概述
│   └── src/                   # 源码分析
├── nvboard/                   # NVBoard文档
│   ├── README.md              # NVBoard概述
│   └── src/                   # 源码分析
└── tools/                     # 工具和脚本文档
    ├── build_tools.md         # 构建工具
    └── debug_tools.md         # 调试工具
```

## 快速导航

### 核心组件
- [NEMU模拟器](./nemu/README.md) - 全系统模拟器，支持多种指令集
- [NPC处理器](./npc/README.md) - Verilog实现的RISC-V处理器
- [Abstract Machine](./abstract-machine/README.md) - 硬件抽象层
- [AM Kernels](./am-kernels/README.md) - 系统软件和应用程序

### 扩展组件
- [FCEUX-AM](./fceux-am/README.md) - NES模拟器移植
- [NVBoard](./nvboard/README.md) - FPGA开发板支持

### 系统架构
- [整体架构](./overview/system_architecture.md) - 系统整体设计
- [组件关系](./overview/component_relations.md) - 各组件间的关系
- [构建系统](./overview/build_system.md) - 构建和配置系统

## 学习路径

### 初学者路径
1. 阅读[系统架构概述](./overview/system_architecture.md)
2. 学习[NEMU模拟器](./nemu/README.md)基础使用
3. 了解[Abstract Machine](./abstract-machine/README.md)抽象层
4. 运行[AM Kernels](./am-kernels/README.md)中的测试程序

### 进阶路径
1. 深入学习[NEMU内部实现](./nemu/core/)
2. 学习[NPC处理器设计](./npc/README.md)
3. 分析[FCEUX移植](./fceux-am/README.md)过程
4. 使用[NVBoard](./nvboard/README.md)进行FPGA开发

## 常用命令

### 构建命令
```bash
# 构建NEMU
cd nemu && make menuconfig && make

# 构建NPC
cd npc && make

# 构建AM程序
cd am-kernels && make ARCH=nemu

# 构建FCEUX
cd fceux-am && make ARCH=nemu
```

### 运行命令
```bash
# 运行NEMU
cd nemu && make run

# 运行NPC仿真
cd npc && make run

# 运行AM测试
cd am-kernels && make ARCH=nemu run

# 运行FCEUX
cd fceux-am && make ARCH=nemu run
```

## 贡献指南

本文档持续更新中，欢迎贡献：
1. 发现错误或不准确的地方
2. 添加缺失的文档
3. 改进文档结构和可读性
4. 添加更多示例和教程

## 版本信息

- 文档版本：v1.0
- 最后更新：2024年
- 维护者：YSYX项目组