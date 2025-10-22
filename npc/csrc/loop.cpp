#include "sim.h"
#include "Vtop.h"
#include "verilated_vcd_c.h"
#include <cstdio>

void execute_first_instruction(Vtop *top, uint32_t currentPC, VerilatedVcdC *tfp, uint64_t &sim_time) {
    // 设置第一条指令
    top->op = pc_inst[currentPC];
    top->sdop_en = 1;

    // 时钟上升沿
    top->clk = !top->clk;
    top->eval();
    tfp->dump(sim_time++);

    // 时钟下降沿
    top->clk = !top->clk;
    top->eval();
    tfp->dump(sim_time++);

    // 清除指令有效信号
    top->sdop_en = 0;
}

bool process_one_cycle(Vtop *top, uint32_t &currentPC, bool &sdop_en_state, VerilatedVcdC *tfp, uint64_t &sim_time) {
    if (top->rdop_en) {
        currentPC = top->dnpc;
        auto it = pc_inst.find(currentPC);
        if (it != pc_inst.end()) {
            top->op = it->second;
        } else {
            printf("警告: PC=0x%08x 处没有指令\n", currentPC);
            return false;
        }
        top->sdop_en = 1;
        sdop_en_state = true;
    } else if (sdop_en_state) {
        top->sdop_en = 0;
        sdop_en_state = false;
    }

    // 时钟上升沿
    top->clk = !top->clk;
    top->eval();
    tfp->dump(sim_time++);

    bool end_flag = top->end_flag;

    // 时钟下降沿
    top->clk = !top->clk;
    top->eval();
    tfp->dump(sim_time++);

    return !end_flag;
}