#include <am.h>
#include <npc.h>

#define KEYDOWN_MASK 0x8000

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
  uint32_t kbd_code = *(volatile uint32_t *)(uintptr_t)KBD_ADDR;
  kbd->keydown = (kbd_code & KEYDOWN_MASK) ? true : false;
  kbd->keycode = (int)(kbd_code & ~KEYDOWN_MASK);
  if (kbd_code == 0) {
    kbd->keycode = AM_KEY_NONE;
  }
}
