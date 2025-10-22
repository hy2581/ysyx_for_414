#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

size_t strlen(const char *s) {
    const char *p = s;
    while (*p) {
        p++;
    }
    return (size_t)(p - s);
}

char *strcpy(char *dst, const char *src) {
    char *p = dst;
    while ((*p++ = *src++) != '\0') {
        ;  // 复制直到遇到 '\0'
    }
    return dst;
}

char *strncpy(char *dst, const char *src, size_t n) {
    size_t i;
    for (i = 0; i < n; i++) {
        if (src[i] != '\0') {
            dst[i] = src[i];
        } else {
            break;
        }
    }
    // 如果提前结束，需要将剩余位置填 '\0'
    for (; i < n; i++) {
        dst[i] = '\0';
    }
    return dst;
}

char *strcat(char *dst, const char *src) {
    char *p = dst;
    // 找到 dst 末尾
    while (*p) {
        p++;
    }
    // 从末尾开始复制 src（包括 '\0'）
    while ((*p++ = *src++) != '\0') {
        ;
    }
    return dst;
}

int strcmp(const char *s1, const char *s2) {
    while (*s1 && (*s1 == *s2)) {
        s1++;
        s2++;
    }
    // 注意要转换为 unsigned char 再比较，以免字符符号影响
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
}

int strncmp(const char *s1, const char *s2, size_t n) {
    size_t i;
    for (i = 0; i < n; i++) {
        if (s1[i] != s2[i] || s1[i] == '\0') {
            return (int)((unsigned char)s1[i] - (unsigned char)s2[i]);
        }
    }
    return 0;
}

void *memset(void *s, int c, size_t n) {
    unsigned char *p = (unsigned char *)s;
    unsigned char uc = (unsigned char)c;
    while (n--) {
        *p++ = uc;
    }
    return s;
}

void *memmove(void *dst, const void *src, size_t n) {
    unsigned char *d = (unsigned char *)dst;
    const unsigned char *s = (const unsigned char *)src;
    if (d < s) {
        while (n--) {
            *d++ = *s++;
        }
    } else if (d > s) {
        // 从尾部开始复制
        d += n;
        s += n;
        while (n--) {
            *--d = *--s;
        }
    }
    return dst;
}

void *memcpy(void *out, const void *in, size_t n) {
    unsigned char *d = (unsigned char *)out;
    const unsigned char *s = (const unsigned char *)in;
    while (n--) {
        *d++ = *s++;
    }
    return out;
}

int memcmp(const void *s1, const void *s2, size_t n) {
    const unsigned char *p1 = (const unsigned char *)s1;
    const unsigned char *p2 = (const unsigned char *)s2;
    while (n--) {
        if (*p1 != *p2) {
            return (int)(*p1 - *p2);
        }
        p1++;
        p2++;
    }
    return 0;
}

#endif
