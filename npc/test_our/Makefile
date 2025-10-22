# 以下注释结合上一次回答中关于生成 FST/VCD 波形并用 GTKWave 查看的说明
VERILATOR    ?= verilator       # 指定 verilator 命令，默认使用环境中可执行的 “verilator”，可被用户覆盖
TOP          ?= top             # 顶层模块名称，默认 top，可通过命令行或环境变量修改
SRC_V        := $(TOP).v        # Verilog 源文件，依据 TOP 变量拼出 top.v
SRC_CPP      := main.cpp        # C++ 测试驱动源文件
BUILD_DIR    := obj_dir         # Verilator 默认生成中间文件和可执行文件的目录
SIM_EXE      := $(BUILD_DIR)/V$(TOP)  # 仿真可执行文件名称，例如 obj_dir/Vtop
GTKWAVE      ?= gtkwave         # GTKWave 可执行文件名，默认 gtkwave，可被覆盖

# verilator 参数
VFLAGS       := --cc $(SRC_V) \  # 生成 C++ 模拟代码
                --exe $(SRC_CPP) \  # 编译并链接测试驱动
                --trace \           # 打开 trace 支持（可生成波形文件）
                -CFLAGS "-O2 -Wall" \  # 传给 g++ 的编译选项：O2 优化 + 显示所有警告
                --build -j 0        # 直接在 configure 后执行 make -j（auto）

.PHONY: all run wave clean     # 声明伪目标，避免与同名文件冲突

all: $(SIM_EXE)               # 默认目标：编译生成仿真可执行文件

# 生成可执行仿真程序
$(SIM_EXE): $(SRC_V) $(SRC_CPP)
	$(VERILATOR) $(VFLAGS)  # 调用 verilator，依据 VFLAGS 生成并编译代码，最终产出 obj_dir/Vtop

# 直接跑仿真
run: all
	$(SIM_EXE)              # 运行仿真可执行文件，产生 waveform.vcd（若代码里有 dump 调用）

# 打开波形
wave: run
	$(GTKWAVE) waveform.vcd  # 用 GTKWave 载入生成的 VCD 波形。注意可参考上次建议，改用 FST 格式减小文件体积

clean:
	rm -rf $(BUILD_DIR) waveform.vcd  # 删除中间编译目录和波形文件，恢复“干净”状态