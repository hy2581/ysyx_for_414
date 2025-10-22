# "一生一芯"工程项目

这是"一生一芯"的工程项目. 通过运行
```bash
bash init.sh subproject-name
```
进行初始化, 具体请参考[实验讲义][lecture note].

[lecture note]: https://ysyx.oscc.cc/docs/

compiledb -n make run
孩子们 bear -- make真的有用

目前的问题：nemu没法读取npc运行的程序
TODO：先让nemu可以make的时候可以加载IMG
然后在npu的makefile中实现先make一下

am的nemu和nemu本身的makefile有什么区别？？

make ARCH=riscv32-nemu ALL=dummy run

本来想用git记录的，但是有点懒，就不用了，下一个项目再加进去吧
9.6：之前出的问题是串口没有输出，其实本质上是npu的putch没有写，还有lbu写的有问题（之后仔细看看）

10.16 今天又看了下，发现AM只是为了生成镜像以供NEMU调用。具体如何生成镜像我还没懂，下次再看。

10.18 之前那么久没有解决串口问题，今天换AI了全部解决😀


AM + NEMU RISC-V32 Yield/CTE 全流程解析

目标
- 解释从 `yield()` 被调用到返回的完整路径，覆盖 AM 与 NEMU 的协作细节。
- 明确 `__am_irq_handle(Context *c)` 中 `c` 的来源、结构布局与成员赋值位置。
- 串联四者关系：`$ISA-nemu.h`（平台绑定）、`trap.S`（陷阱入口）、讲义的 CTE 流程、NEMU 对 RISC-V 的 `ecall/mret/CSR` 支持。

相关文件与角色
- `abstract-machine/am/src/riscv/nemu/trap.S`：陷阱入口 `__am_asm_trap`，保存/恢复通用寄存器与 CSR，调用 `__am_irq_handle`，最后 `mret`。
- `abstract-machine/am/src/riscv/nemu/cte.c`：`cte_init()` 设置 `mtvec`，`__am_irq_handle()` 根据 `mcause` 打包 `Event`（识别 `EVENT_YIELD`）。
- `abstract-machine/am/include/arch/riscv.h`：`Context` 结构体定义（成员顺序需与 `trap.S` 的保存顺序一致：GPR → `mcause` → `mstatus` → `mepc` → `pdir`）。
- `abstract-machine/am/src/platform/nemu/include/nemu.h`：NEMU 平台绑定，AM 在 NEMU 上的环境。
- `am-kernels/tests/am-tests/src/tests/intr.c`：测试用例，注册回调并循环调用 `yield()`，在 `EVENT_YIELD` 时打印 `y`。
- `nemu/src/isa/riscv32/include/isa-def.h`：RISC-V32 的最小 CSR 集（`mepc/mstatus/mcause/...`）定义与解释器支持。

Context 的来源与成员赋值
- 来源：`Context *c` 并非预先存在的全局结构体，而是 `trap.S` 在陷入时在栈上按 `Context` 布局依次保存形成的“栈帧块”，随后把该块的起始地址当作 `Context*` 传给 C 函数。
- 成员赋值位置：
  - `c->gpr[0..31]`：`trap.S` 进入后按固定顺序用 `sw` 保存所有 GPR（`x1`=ra, `x2`=sp, … `x31`）。
  - `c->mcause`：`csrr t0, mcause; sw t0, [c+offset]`，由 `trap.S` 从 CSR 读取后保存。
  - `c->mstatus`：`csrr mstatus` 读取后保存，返回前再 `csrw mstatus` 恢复。
  - `c->mepc`：`csrr mepc` 读取后保存；若 `mcause==11`（M 模式 ecall），对“保存的 `mepc`”执行 `+4`，保证 `mret` 落到 `ecall` 的下一条；返回前 `csrw mepc, c->mepc`。
  - `c->pdir`：由 AM/VME 在地址空间切换（如 `protect()/__am_switch()`）时设置，陷入过程中不赋值；`trap.S` 仅保持其槽位。

从 yield() 到返回：逐步旅程
- 测试侧（`intr.c`）调用 `yield()`；测试初始化注册了异常回调 `simple_trap(Event e, Context *c)`，在 `EVENT_YIELD` 中 `putch('y')`。
- `yield()` 触发：AM 的 RISC-V 实现通过内联汇编发出 `ecall`（自陷）。
- NEMU（硬件侧）解释 `ecall`：设置 `mcause=11`、更新 `mepc/mstatus` 等 CSR，读取 `mtvec` 跳转到 `__am_asm_trap`。
- `trap.S` 执行：
  - 建栈帧，依次 `sw` 保存所有 GPR；`csrr` 读取 `mcause/mstatus/mepc` 并保存到 `Context` 对应槽位。
  - 若 `mcause==11`，对“栈帧中的 `mepc`”执行 `+4`（确保返回到 `ecall` 的下一条）。
  - 将栈帧地址作为 `Context *c` 调用 C 函数 `__am_irq_handle(c)`。
- `__am_irq_handle(c)`：
  - 读取 `c->mcause`，当为 11 时将 `Event.event` 设为 `EVENT_YIELD`，否则为 `EVENT_ERROR`。
  - 调用用户注册的回调（测试中打印 `y`），可选择返回新的上下文（本测试不更换，原地返回）。
- 返回路径：`trap.S` 用 `lw` 读取 `c->mstatus/mepc` 并 `csrw` 写回；用 `lw` 恢复所有 GPR；执行 `mret`，根据 `mepc` 返回到 `yield()` 的下一条指令。
- NEMU 的 `serial` MMIO 将 `putch('y')` 映射到主机终端，看到连续的 `y` 输出代表多次自陷-返回循环正常。

四部分的联系
- `trap.S` 是 AM（C 端）与 NEMU（硬件端）的桥梁：把 CSR/GPR 现场“打包”为 `Context`，供 C 端处理，再按 `Context` 恢复现场并 `mret`。
- `$ISA-nemu.h`/`nemu.h` 负责平台/ISA 绑定，使 `cte_init()` 能将 `mtvec` 指到我们的 `__am_asm_trap`。
- 讲义抽象的 CTE 流程（注册→陷入→打包→用户处理→恢复→返回）在本实现中分别落到上述文件。
- NEMU 对 RISC-V 的 `ecall/mret/CSR` 支持是硬件语义的基石，AM 借此实现 `yield()` 自陷与返回。

项目修改汇总（已完成）
- `abstract-machine/am/include/arch/riscv.h`
  - 重排 `Context` 成员顺序为：GPR → `mcause` → `mstatus` → `mepc` → `pdir`，保证与 `trap.S` 保存顺序一致。
- `abstract-machine/am/src/riscv/nemu/cte.c`
  - 更新 `__am_irq_handle()`：将 `mcause==11` 分类为 `EVENT_YIELD`，其它默认 `EVENT_ERROR`。
- `abstract-machine/am/src/riscv/nemu/trap.S`
  - 在保存 `mcause/mstatus/mepc` 后，若 `mcause==11`，对“栈帧中的 `mepc`”执行 `+4`；返回前据 `Context` 恢复 `mstatus/mepc` 与 GPR，最后 `mret`。
- （测试侧可选调整）`am-kernels/tests/am-tests/src/tests/intr.c`
  - 为更易观察，将忙等缩短或在读取输入配置后更频繁调用 `yield()`，可看到连续 `y`。

构建与验证
- 交互模式：
  - `make ARCH=riscv32-nemu mainargs=i run`
  - 在 `(nemu)` 输入 `c` 让程序继续运行（打印 `Hello, AM World @ riscv32` 后程序自身会打印 `y`）；输入 `q` 退出。
- 快速 GOOD TRAP：
  - `make ARCH=riscv32-nemu mainargs=y run`
  - 观察到 “HIT GOOD TRAP”。
- 日志：`am-kernels/tests/am-tests/build/nemu-log.txt` 可查看设备映射与指令统计。

常见问题与注意
- `Context` 布局与 `trap.S` 的保存顺序必须一致，否则 `c->mcause/mstatus/mepc` 读写错位导致异常处理混乱。
- `ecall` 返回地址必须加 4，否则会在同一条指令反复陷入导致死循环。
- 监控器命令与程序内交互不同：`(nemu)` 的 `c/q` 等是监控器命令，`t/d/y` 是程序内提示，不是监控器命令。

参考路径
- AM：`abstract-machine/am/src/riscv/nemu/{trap.S, cte.c}`，`abstract-machine/am/include/arch/riscv.h`。
- 测试：`am-kernels/tests/am-tests/src/tests/intr.c`。
- NEMU：`nemu/src/isa/riscv32/include/isa-def.h`（CSR 定义）、`nemu/src/monitor`（监控器）、`nemu/src/device/io/mmio.c`（设备映射）。