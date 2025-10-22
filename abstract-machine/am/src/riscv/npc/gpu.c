#include <am.h>
#include <klib.h>
#include <npc.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)

void __am_gpu_init() {
  // 初始同步一次，便于外部抓取帧缓冲
  *(volatile uint32_t *)(uintptr_t)SYNC_ADDR = 1;
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  uint32_t size_info = *(volatile uint32_t *)(uintptr_t)VGACTL_ADDR;
  uint32_t width = size_info >> 16;
  uint32_t height = size_info & 0xFFFF;
  *cfg = (AM_GPU_CONFIG_T){
      .present = true,
      .has_accel = false,
      .width = (int)width,
      .height = (int)height,
      .vmemsz = (int)(width * height * sizeof(uint32_t))};
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  int x = ctl->x, y = ctl->y, w = ctl->w, h = ctl->h;
  uint32_t *pixels = (uint32_t *)ctl->pixels;
  volatile uint32_t *fb = (volatile uint32_t *)(uintptr_t)FB_ADDR;

  uint32_t size_info = *(volatile uint32_t *)(uintptr_t)VGACTL_ADDR;
  uint32_t screen_w = size_info >> 16;
  uint32_t screen_h = size_info & 0xFFFF;

  int copy_w = (x + w <= (int)screen_w) ? w : (int)screen_w - x;
  int copy_h = (y + h <= (int)screen_h) ? h : (int)screen_h - y;

  for (int j = 0; j < copy_h; j++) {
    for (int i = 0; i < copy_w; i++) {
      fb[(y + j) * screen_w + (x + i)] = pixels[j * w + i];
    }
  }

  if (ctl->sync) {
    *(volatile uint32_t *)(uintptr_t)SYNC_ADDR = 1;
  }
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}