# 个人学习使用的简化版Makefile（保留基本Git功能）

# 项目根目录
YSYX_HOME = $(shell pwd)

# 子项目列表(根据您的实际项目结构可能需要修改)
SUBPROJECTS = nemu am navy

# 默认目标
default:
	@echo "请在子项目目录下运行make命令"
	@echo "可用子项目: $(SUBPROJECTS)"


# 提供在子项目中构建的快捷方式
$(SUBPROJECTS):
	@if [ -d "$@" ]; then \
		echo "在 $@ 中构建"; \
		$(MAKE) -C $@; \
	else \
		echo "子项目 $@ 不存在"; \
	fi

# 简化的git提交功能
git-commit:
	@read -p "提交信息: " msg; \
	git add . -A --ignore-errors && \
	git commit -m "$$msg"

# 显示git状态
git-status:
	@git status

# ysyxSoCFull 综合（需先 cd ysyxSoC && make verilog 生成 RTL）
synth-ysyxSoCFull:
	@./run_synth_ysyxSoCFull.sh

# 综合与 PPA 评估（使用最新 Yosys，生成报告）
synth-ppa:
	@./scripts/run_synth_and_ppa.sh

# 生成 ysyxSoCFull Verilog（需 mill）
verilog-ysyxSoCFull:
	@cd ysyxSoC && PATH="$(shell pwd):$$PATH" make verilog

.PHONY: default $(SUBPROJECTS) git-commit git-status synth-ysyxSoCFull synth-ppa verilog-ysyxSoCFull
