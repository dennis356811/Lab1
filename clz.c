#include <stdint.h>
#include <stdio.h>

static inline int clz(uint32_t x) {
    int count = 0;
    for (int i = 31; i >= 0; --i) {
        if (x & (1U << i))
            break;
        count++;
    }
    return count;
}

int clz_bs(uint32_t x) {
    int count = 0;
    if (x == 0) {
        return 32;
    }
    if (x <= 0x0000FFFF) {
        count += 16;
        x <<= 16;
    }
    if (x <= 0x00FFFFFF) {
        count += 8;
        x <<= 8;
    }
    if (x <= 0x0FFFFFFF) {
        count += 4;
        x <<= 4;
    }
    if (x <= 0x3FFFFFFF) {
        count += 2;
        x <<= 2;
    }
    if (x <= 0x7FFFFFFF) {
        count += 1;
    }
    return count;
}

int main() {
    const int size = 8;
    uint32_t arr[size] = {64,         128, 1584367,    2147483647,
                          4294967295, 300, 878780422, 920105};
    int error = 0;
    printf("test original clz\n");
    for (int i = 0; i < size; i++) {
        printf("answer: %d, your result: %d", __builtin_clz(arr[i]),
               clz(arr[i]));
        if (__builtin_clz(arr[i]) == clz(arr[i])) {
            printf(" ,pass !\n");
        } else {
            printf(" ,wrong !\n");
            error++;
        }
    }
    printf("test binary search clz\n");
    for (int i = 0; i < size; i++) {
        printf("answer: %d, your result: %d", __builtin_clz(arr[i]),
               clz_bs(arr[i]));
        if (__builtin_clz(arr[i]) == clz_bs(arr[i])) {
            printf(" ,pass !\n");
        } else {
            printf(" ,wrong !\n");
            error++;
        }
    }
    if (error != 0) {
        printf("Total has %d error !\n", error);
    } else {
        printf("All pass !\n");
    }
}