TOPNAME = top
# 头文件名称
NXDC_FILES = constr/top.nxdc
INC_PATH ?=
IMG ?=
# 定义一个可选的头文件搜索变量
GTKWAVE      ?= gtkwave         

VERILATOR = verilator
VERILATOR_CFLAGS += -MMD --build -cc  \
                --trace \
                -O3 --x-assign fast --x-initial fast --noassert

BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(TOPNAME)

default: $(BIN)

all: $(BIN)

$(shell mkdir -p $(BUILD_DIR))

# rules for NVBoard
include $(NVBOARD_HOME)/scripts/nvboard.mk
SRC_AUTO_BIND = $(abspath $(BUILD_DIR)/auto_bind.cpp)
# 把 build/auto_bind.cpp 的绝对路径保存在 SRC_AUTO_BIND 中
$(SRC_AUTO_BIND): $(NXDC_FILES)
	python3 $(NVBOARD_HOME)/scripts/auto_pin_bind.py $^ $@

# project source
VSRCS = $(shell find $(abspath ./vsrc) -name "*.v")
CSRCS = $(shell find $(abspath ./csrc) -name "*.c" -or -name "*.cc" -or -name "*.cpp")
# CSRCS += $(SRC_AUTO_BIND) 等到需要nvboard再加上

# rules for verilator
INCFLAGS = $(addprefix -I, $(INC_PATH))
# SDL2 flags (via pkg-config; fallback to common defaults)
SDL2_CFLAGS := $(shell pkg-config --cflags sdl2 2>/dev/null)
SDL2_LDFLAGS := $(shell pkg-config --libs sdl2 2>/dev/null)
ifeq ($(strip $(SDL2_CFLAGS)),)
SDL2_CFLAGS := -I/usr/include/SDL2
SDL2_LDFLAGS := -lSDL2
endif

# 添加C++11标准支持 + AM头文件
CXXFLAGS += $(INCFLAGS) -DTOP_NAME="\"V$(TOPNAME)\"" -std=c++11 -I$(AM_HOME)/am/include $(SDL2_CFLAGS)
# 添加-lrt用于时间函数 + pthread用于键盘线程 + SDL2
LDFLAGS += -ldl -lrt -lpthread $(SDL2_LDFLAGS)

$(BIN): $(VSRCS) $(CSRCS) $(NVBOARD_ARCHIVE)
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
        --top-module $(TOPNAME) $^ \
        --trace \
        $(addprefix -CFLAGS , $(CXXFLAGS)) $(addprefix -LDFLAGS , $(LDFLAGS)) \
        --Mdir $(OBJ_DIR) --exe -o $(abspath $(BIN))

# 波形文件路径
WAVE_FILE = $(BUILD_DIR)/dump.vcd

all: default

run: $(BIN)
	@if [ -n "$(IMG)" ]; then \
        echo "Running NPC with program: $(IMG)"; \
        $(BIN) $(IMG); \
	else \
        echo "Running NPC without program specified"; \
        $(BIN); \
	fi

# 添加 wave 目标 - 运行仿真并查看波形
wave: $(BIN)
	@echo "Running simulation with wave tracing enabled..."
	@$(BIN)
	@echo "Opening waveform viewer..."
	@if [ -f $(WAVE_FILE) ]; then \
        $(GTKWAVE) $(WAVE_FILE); \
	else \
        echo "Warning: Expected wave file not found at $(WAVE_FILE)"; \
        echo "Searching for VCD files in $(BUILD_DIR)..."; \
        FOUND_VCD=$$(find $(BUILD_DIR) -name "*.vcd"); \
        if [ -n "$$FOUND_VCD" ]; then \
            echo "Found VCD file: $$FOUND_VCD"; \
            $(GTKWAVE) $$FOUND_VCD; \
        else \
            echo "Error: No VCD files found in $(BUILD_DIR)."; \
            echo "Check your testbench code to ensure it's generating waveform data."; \
            exit 1; \
        fi; \
	fi

# 添加 help 目标 - 显示可用命令
help:
	@echo "NPC Makefile 帮助"
	@echo "================="
	@echo "可用目标："
	@echo "  default, all   : 构建仿真可执行文件"
	@echo "  run            : 运行仿真"
	@echo "  wave           : 启用波形跟踪运行仿真并打开 GTKWave"
	@echo "  clean          : 清除所有构建产物"
	@echo "  help           : 显示此帮助信息"

clean:
	rm -rf $(BUILD_DIR)

.PHONY: default all clean run wave help iverilog