#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>
#include <stdbool.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

int printf(const char *fmt, ...) {
  static char buf[4096];
  va_list ap;
  va_start(ap, fmt);
  int ret = vsnprintf(buf, sizeof(buf), fmt, ap);
  va_end(ap);
  putstr(buf);
  // printf 的返回值应为实际输出的字符数（不含终止符）。
  // vsnprintf 返回“将要写入”的字符数；若发生截断，ret 会大于缓冲区大小。
  if (ret < 0) return ret;
  int printed = ret < (int)sizeof(buf) ? ret : (int)sizeof(buf) - 1;
  return printed;
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  // 保存原始输出缓冲区的起始位置，用于最后计算写入的字符数
  char *original_out = out;
  char c;  // 用于存储当前处理的格式字符串中的字符
  
  // 循环遍历格式字符串中的每个字符
  while ((c = *fmt++)) {  // 获取当前字符并将格式字符串指针向后移动
    if (c != '%') {  // 如果不是格式说明符的开始符号'%'
      *out++ = c;    // 直接将该字符复制到输出缓冲区，并移动输出指针
      continue;      // 继续处理下一个字符
    }
    
    // 处理格式说明符 - 已经确认遇到了'%'
    c = *fmt++;      // 获取'%'后面的字符（格式类型）并移动指针
    if (c == '\0') break; // 防止格式字符串以'%'结尾导致越界访问
    
    // 根据格式类型字符处理不同的数据格式
    switch (c) {
      case 's': {  // 字符串格式：%s
        // 从参数列表获取一个字符串指针
        char *s = va_arg(ap, char *);
        if (!s) s = "(null)";  // 如果指针为NULL，显示"(null)"
        // 将字符串内容复制到输出缓冲区
        while (*s) {
          *out++ = *s++;
        }
        break;
      }
      case 'd': case 'i': {  // 有符号整数格式：%d 或 %i
        // 从参数列表获取一个整数
        int num = va_arg(ap, int);
        unsigned int u;
        if (num < 0) {
          *out++ = '-';
          u = (unsigned int)(-(long long)num);
        } else {
          u = (unsigned int)num;
        }
        if (u == 0) {
          *out++ = '0';
          break;
        }
        char temp[16];
        int i = 0;
        while (u > 0) {
          temp[i++] = '0' + (u % 10);
          u /= 10;
        }
        while (i > 0) {
          *out++ = temp[--i];
        }
        break;
      }
      case 'x': case 'X': {  // 十六进制整数格式：%x（小写）或 %X（大写）
        unsigned int num = va_arg(ap, unsigned int);
        if (num == 0) {
          *out++ = '0';
          break;
        }
        char temp[16];
        int i = 0;
        while (num > 0) {
          int digit = num % 16;  // 取16的余数（0-15之间）
          if (digit < 10)
            temp[i++] = '0' + digit;  // 0-9用数字字符表示
          else
            temp[i++] = (c == 'x' ? 'a' : 'A') + (digit - 10);
          num /= 16;  // 去掉最低位
        }
        while (i > 0) {
          *out++ = temp[--i];
        }
        break;
      }
      case 'c': {  // 字符格式：%c
        char ch = (char)va_arg(ap, int);
        *out++ = ch;  // 直接输出该字符
        break;
      }
      case 'u': {  // 无符号整数格式：%u
        unsigned int num = va_arg(ap, unsigned int);
        if (num == 0) {
          *out++ = '0';
          break;
        }
        char temp[16];
        int i = 0;
        while (num > 0) {
          temp[i++] = '0' + (num % 10);  // 转换为字符
          num /= 10;  // 去掉个位数字
        }
        while (i > 0) {
          *out++ = temp[--i];
        }
        break;
      }
      case 'p': {  // 指针格式：%p（输出为十六进制）
        *out++ = '0';  // 输出前缀"0x"
        *out++ = 'x';
        uintptr_t num = (uintptr_t)va_arg(ap, void *);
        if (num == 0) {
          *out++ = '0';
          break;
        }
        char temp[16];
        int i = 0;
        while (num > 0) {
          int digit = num % 16;
          if (digit < 10)
            temp[i++] = '0' + digit;  // 0-9用数字字符表示
          else
            temp[i++] = 'a' + (digit - 10);  // 10-15用a-f表示
          num /= 16;
        }
        while (i > 0) {
          *out++ = temp[--i];
        }
        break;
      }
      case '%': {  // 百分号：%%（输出一个%字符）
        *out++ = '%';
        break;
      }
      default:  // 未知格式说明符，直接输出该字符
        *out++ = c;
        break;
    }
  }
  
  *out = '\0';  // 在输出缓冲区末尾添加字符串结束符（空字符）
  return out - original_out;  // 返回写入的字符数（不包括结尾的空字符）
}

int sprintf(char *out, const char *fmt, ...) {
  va_list ap;
  int ret;
  
  va_start(ap, fmt);
  ret = vsprintf(out, fmt, ap);
  va_end(ap);
  
  return ret;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  va_list ap;
  int ret;
  
  va_start(ap, fmt);
  ret = vsnprintf(out, n, fmt, ap);
  va_end(ap);
  
  return ret;
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  char *dst = out;
  size_t size = n;                 // 包括终止符的总容量
  size_t written = 0;              // 期望写入的字符数（不含终止符），即返回值
  char c;

  while ((c = *fmt++)) {
    if (c != '%') {
      if (size > 0 && written + 1 < size) { *dst++ = c; }
      written++;
      continue;
    }
    c = *fmt++;
    if (c == '\0') break;
    switch (c) {
      case 's': {
        char *s = va_arg(ap, char *);
        if (!s) s = "(null)";
        while (*s) {
          if (size > 0 && written + 1 < size) { *dst++ = *s; }
          written++;
          s++;
        }
        break;
      }
      case 'd': case 'i': {
        int num = va_arg(ap, int);
        unsigned int u;
        if (num < 0) {
          if (size > 0 && written + 1 < size) { *dst++ = '-'; }
          written++;
          u = (unsigned int)(-(long long)num);
        } else {
          u = (unsigned int)num;
        }
        if (u == 0) {
          if (size > 0 && written + 1 < size) { *dst++ = '0'; }
          written++;
          break;
        }
        char temp[16];
        int i = 0;
        while (u > 0) { temp[i++] = '0' + (u % 10); u /= 10; }
        while (i > 0) {
          char ch = temp[--i];
          if (size > 0 && written + 1 < size) { *dst++ = ch; }
          written++;
        }
        break;
      }
      case 'x': case 'X': {
        unsigned int num = va_arg(ap, unsigned int);
        if (num == 0) {
          if (size > 0 && written + 1 < size) { *dst++ = '0'; }
          written++;
          break;
        }
        char temp[16];
        int i = 0;
        while (num > 0) {
          int digit = num % 16;
          char ch = (digit < 10) ? ('0' + digit) : ((c == 'x' ? 'a' : 'A') + (digit - 10));
          temp[i++] = ch;
          num /= 16;
        }
        while (i > 0) {
          char ch = temp[--i];
          if (size > 0 && written + 1 < size) { *dst++ = ch; }
          written++;
        }
        break;
      }
      case 'c': {
        char ch = (char)va_arg(ap, int);
        if (size > 0 && written + 1 < size) { *dst++ = ch; }
        written++;
        break;
      }
      case 'u': {
        unsigned int num = va_arg(ap, unsigned int);
        if (num == 0) {
          if (size > 0 && written + 1 < size) { *dst++ = '0'; }
          written++;
          break;
        }
        char temp[16];
        int i = 0;
        while (num > 0) { temp[i++] = '0' + (num % 10); num /= 10; }
        while (i > 0) {
          char ch = temp[--i];
          if (size > 0 && written + 1 < size) { *dst++ = ch; }
          written++;
        }
        break;
      }
      case 'p': {
        if (size > 0 && written + 1 < size) { *dst++ = '0'; }
        written++;
        if (size > 0 && written + 1 < size) { *dst++ = 'x'; }
        written++;
        uintptr_t num = (uintptr_t)va_arg(ap, void *);
        if (num == 0) {
          if (size > 0 && written + 1 < size) { *dst++ = '0'; }
          written++;
          break;
        }
        char temp[16];
        int i = 0;
        while (num > 0) {
          int digit = num % 16;
          char ch = (digit < 10) ? ('0' + digit) : ('a' + (digit - 10));
          temp[i++] = ch;
          num /= 16;
        }
        while (i > 0) {
          char ch = temp[--i];
          if (size > 0 && written + 1 < size) { *dst++ = ch; }
          written++;
        }
        break;
      }
      case '%': {
        if (size > 0 && written + 1 < size) { *dst++ = '%'; }
        written++;
        break;
      }
      default: {
        if (size > 0 && written + 1 < size) { *dst++ = c; }
        written++;
        break;
      }
    }
  }
  if (size > 0) {
    size_t term_index = (written < size - 1) ? written : (size - 1);
    out[term_index] = '\0';
  }
  return (int)written;
}

#endif