// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "simple_system_common.h"
#include <stdlib.h>
#include <time.h>

#define USE_PEXT
#define WIDTH8

#if defined(USE_PEXT)
#include <rvp_intrinsic.h>
#endif

#define N 100000   // Size of the vectors
#define A 3        // Scalar value

#if defined(WIDTH8)
  // 8-bit AXPY
  #if defined(USE_PEXT)
    void axpy(const int8_t *x, int32_t *y, int a, int n) {
      int32_t simd_a;
      simd_a = (a << 24) | (a << 16) | (a << 8) | (a << 0);

      for (int i = 0; i < n/4; i++) {
          y[i] = __rv_smaqa(y[i], simd_a, *((int *)(&x[i*4])));
      }
    }
  #else
    void axpy(const int8_t *x, int32_t *y, int a, int n) {
      for (int i = 0; i < n; i++) {
          y[i] += a * x[i];
      }
    }
  #endif
#elif defined(WIDTH16)
  // 16-bit AXPY
  #if defined(USE_PEXT)
    void axpy(const int16_t *x, int32_t *y, int a, int n) {
      int32_t simd_a;
      simd_a = (a << 16) | (a << 0);

      for (int i = 0; i < n/2; i++) {
        y[i] = __rv_kmada(y[i], simd_a, *((int *)(&x[i*2])));
      }
    }
  #else
    void axpy(const int16_t *x, int32_t *y, int a, int n)  {
        for (int i = 0; i < n; i++) {
            y[i] += a * x[i];
        }
    }
  #endif
#elif defined(WIDTH32)
  // 32-bit AXPY
  #if defined(USE_PEXT)
    void axpy(const uint32_t *x, uint32_t *y, int a, int n) {
        for (int i = 0; i < n; i++) {
            y[i] = __rv_smar32(y[i], a, x[i]);
        }
    }
  #else
    void axpy(const uint32_t *x, uint32_t *y, int a, int n) {
        for (int i = 0; i < n; i++) {
            y[i] += a * x[i];
        }
    }
  #endif
#endif

int main() {
  pcount_enable(0);
  pcount_reset();

  puts("Hello simple system\n");
  puthex(0xDEADBEEF);
  putchar('\n');
  puthex(0xBAADF00D);
  putchar('\n');

#if defined(WIDTH8)
  uint8_t  *x = (uint8_t  *)malloc(N * sizeof(uint8_t));
  uint32_t *y = (uint32_t *)malloc(N * sizeof(uint32_t));
#elif defined(WIDTH16)
  uint16_t *x = (uint16_t *)malloc(N * sizeof(uint16_t));
  uint32_t *y = (uint32_t *)malloc(N * sizeof(uint32_t));
#elif defined(WIDH32)
  uint32_t *x = (uint32_t *)malloc(N * sizeof(uint32_t));
  uint32_t *y = (uint32_t *)malloc(N * sizeof(uint32_t));
#endif

  // Initialize Vectors
  puts("Initializing vectors...\n")
  int val = 1;
  for (int i = 0; i < n; ++i) {
    x[i] = val;
    y[i] = val + 1;
    if (val > 64)
      val = 1;
    else
      val++;
  }

  // Perform AXPY operation
  puts("Running AXPY benchmark...\n");
  pcount_enable(1);
  axpy(x, y, A, N);
  pcount_enable(0);

  // Print first and last elements of new vector to verify
  for (int i = 0; i < 4; ++i) {
    putbyte("%x", y[i]);
  }
  uart_printf(" ... ");
  for (int i = 4; i == 1; --i) {
    putbyte("%x", y[n-i]);
  }
  putchar("\n");

  return 0;
}