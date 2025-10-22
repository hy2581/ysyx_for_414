#include <am.h>
#include <riscv/riscv.h>
#include <klib.h>

static Context* (*user_handler)(Event, Context*) = NULL;

Context* __am_irq_handle(Context *c) {
  if (user_handler) {
    Event ev = {0};
    // 根据 mcause 识别自陷 (ecall)，其它认为错误或忽略
    // RISC-V: mcause 为异常号，ecall-from-M 为 11；AM 的 yield 使用 ecall 并在 a7 传 -1
    // 这里识别自陷，打包为 EVENT_YIELD
    switch (c->mcause) {
      case 11: // ecall from M-mode
        ev.event = EVENT_YIELD;
        ev.cause = c->mcause;
        break;
      default:
        ev.event = EVENT_ERROR;
        ev.cause = c->mcause;
        break;
    }

    c = user_handler(ev, c);
    assert(c != NULL);
  }

  return c;
}

extern void __am_asm_trap(void);

bool cte_init(Context*(*handler)(Event, Context*)) {
  // initialize exception entry
  asm volatile("csrw mtvec, %0" : : "r"(__am_asm_trap));

  // register event handler
  user_handler = handler;

  return true;
}

Context *kcontext(Area kstack, void (*entry)(void *), void *arg) {
  return NULL;
}

void yield() {
#ifdef __riscv_e
  asm volatile("li a5, -1; ecall");
#else
  asm volatile("li a7, -1; ecall");
#endif
}

bool ienabled() {
  return false;
}

void iset(bool enable) {
}
