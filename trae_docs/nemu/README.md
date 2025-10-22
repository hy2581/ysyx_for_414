# NEMU (NJU Emulator) 文档

## 概述

NEMU是南京大学开发的一个简单但完整的全系统模拟器，专为教学目的设计。它能够模拟完整的计算机系统，包括CPU、内存、设备等组件，支持多种指令集架构。

## 主要特性

### 支持的指令集架构
- **x86**: 支持32位x86指令集（不支持实模式和x87浮点指令）
- **RISC-V**: 支持RV32IM和RV64IM
- **MIPS32**: 支持基本MIPS32指令集（不支持CP1浮点指令）
- **LoongArch32R**: 支持龙芯架构

### 核心功能
- **CPU模拟**: 完整的指令执行引擎
- **内存系统**: 物理内存和虚拟内存管理
- **设备模拟**: 串口、定时器、键盘、VGA、音频等设备
- **调试器**: 简单但功能完整的调试器
- **差分测试**: 与参考实现（如QEMU）进行对比测试

## 项目结构

```
nemu/
├── Makefile                 # 主构建文件
├── Kconfig                  # 配置系统定义
├── README.md               # 项目说明
├── include/                # 头文件目录
│   ├── common.h           # 通用定义
│   ├── debug.h            # 调试相关
│   ├── isa.h              # 指令集抽象
│   ├── macro.h            # 宏定义
│   ├── utils.h            # 工具函数
│   ├── cpu/               # CPU相关头文件
│   ├── device/            # 设备相关头文件
│   └── memory/            # 内存相关头文件
├── src/                    # 源代码目录
│   ├── nemu-main.c        # 主入口文件
│   ├── cpu/               # CPU实现
│   ├── isa/               # 指令集实现
│   ├── memory/            # 内存系统
│   ├── device/            # 设备模拟
│   ├── monitor/           # 监视器和调试器
│   ├── engine/            # 执行引擎
│   └── utils/             # 工具函数
├── tools/                  # 构建和测试工具
├── scripts/               # 构建脚本
├── configs/               # 预定义配置
└── build/                 # 构建输出目录
```

## 文档导航

### 核心模块
- [程序入口](./core/nemu-main.md) - 程序启动和初始化流程
- [CPU执行引擎](./core/cpu-exec.md) - 指令执行的核心循环
- [内存系统](./core/memory.md) - 物理内存和虚拟内存管理
- [监视器](./monitor/monitor.md) - 系统监控和调试功能

### 指令集实现
- [x86指令集](./isa/x86.md) - x86架构的实现细节
- [RISC-V指令集](./isa/riscv.md) - RISC-V架构的实现细节
- [MIPS32指令集](./isa/mips32.md) - MIPS32架构的实现细节
- [LoongArch32R指令集](./isa/loongarch32r.md) - 龙芯架构的实现细节

### 设备模拟
- [串口设备](./devices/serial.md) - 串行通信设备
- [定时器](./devices/timer.md) - 系统定时器
- [键盘](./devices/keyboard.md) - 键盘输入设备
- [VGA显示](./devices/vga.md) - 图形显示设备
- [音频设备](./devices/audio.md) - 音频输出设备

### 调试和工具
- [简单调试器](./monitor/sdb.md) - 内置调试器功能
- [差分测试](./tools/difftest.md) - 与参考实现对比
- [表达式求值](./monitor/expr.md) - 表达式解析和计算
- [监视点](./monitor/watchpoint.md) - 内存监视功能

### 构建系统
- [主Makefile](./build/main-makefile.md) - 主构建文件分析
- [配置系统](./build/kconfig.md) - Kconfig配置系统
- [构建脚本](./build/scripts.md) - 构建相关脚本

## 快速开始

### 编译NEMU
```bash
cd nemu
make menuconfig  # 配置NEMU
make            # 编译NEMU
```

### 运行NEMU
```bash
make run        # 运行NEMU
make gdb        # 使用GDB调试NEMU
```

### 常用配置
- 选择目标指令集架构
- 配置调试和跟踪选项
- 设置设备支持
- 配置差分测试

## 学习路径

### 初学者
1. 阅读[程序入口](./core/nemu-main.md)了解启动流程
2. 学习[CPU执行引擎](./core/cpu-exec.md)理解指令执行
3. 了解[内存系统](./core/memory.md)的基本概念
4. 使用[简单调试器](./monitor/sdb.md)进行调试

### 进阶学习
1. 深入学习特定[指令集实现](./isa/)
2. 理解[设备模拟](./devices/)的工作原理
3. 学习[差分测试](./tools/difftest.md)的使用
4. 分析[构建系统](./build/)的设计

### 高级应用
1. 添加新的指令支持
2. 实现新的设备模拟
3. 优化模拟器性能
4. 扩展调试功能

## 设计理念

### 教学导向
- 代码结构清晰，便于理解
- 丰富的注释和文档
- 模块化设计，便于学习

### 完整性
- 支持完整的系统模拟
- 从CPU到设备的全覆盖
- 真实的系统行为模拟

### 可扩展性
- 支持多种指令集架构
- 模块化的设备接口
- 灵活的配置系统

### 调试友好
- 内置调试器支持
- 丰富的跟踪信息
- 差分测试验证

## 常见问题

### 编译问题
- 确保安装了必要的依赖
- 检查配置是否正确
- 查看编译错误信息

### 运行问题
- 检查镜像文件是否正确
- 验证配置参数
- 使用调试器定位问题

### 性能问题
- 关闭不必要的跟踪功能
- 优化编译选项
- 使用性能分析工具

## 贡献指南

欢迎为NEMU项目贡献代码和文档：
1. 报告bug和问题
2. 提交功能改进
3. 完善文档内容
4. 添加测试用例

## 相关资源

- [NEMU官方仓库](https://github.com/NJU-ProjectN/nemu)
- [指令集手册](https://riscv.org/specifications/)
- [系统编程教程](https://nju-projectn.github.io/ics-pa-gitbook/)
- [计算机系统基础课程](https://nju-sicp.bitbucket.io/)