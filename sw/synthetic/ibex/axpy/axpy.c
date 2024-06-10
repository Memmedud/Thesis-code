// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "simple_system_common.h"
#include <stdlib.h>
#include <time.h>

//#define USE_PEXT
#define WIDTH32

#if defined(USE_PEXT)
#include <rvp_intrinsic.h>
#endif

#define N 8192     // Size of the vectors
#define A 3        // Scalar value

#if defined(WIDTH8)
  volatile int8_t  x[N];
  volatile int8_t  y[N];
#elif defined(WIDTH16)
  volatile int16_t  x[N];
  volatile int16_t  y[N];
#elif defined(WIDTH32)
  volatile int32_t  x[N];
  volatile int32_t  y[N];
#endif

#if defined(WIDTH8)
  // 8-bit AXPY
  #if defined(USE_PEXT)
    void axpy(const int8_t *x, int32_t *y, int a, int n) {
      int32_t simd_a;
      simd_a = (a << 24) | (a << 16) | (a << 8) | (a << 0);

      for (int i = 0; i < N; i += 4) {
        y[i] = __rv_smaqa(y[i], simd_a, *((int32_t *)(&x[i])));
      }
    }
  #else
    void axpy(const int8_t *x, int32_t *y, int a, int n) {
      for (int i = 0; i < N; i++) {
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

      for (int i = 0; i < N; i += 2) {
        y[i] = __rv_kmada(y[i], simd_a, *((int *)(&x[i])));
      }
    }
  #else
    void axpy(const int16_t *x, int32_t *y, int a, int n)  {
        for (int i = 0; i < N; i++) {
            y[i] += a * x[i];
        }
    }
  #endif
#elif defined(WIDTH32)
  // 32-bit AXPY
  #if defined(USE_PEXT)
    void axpy(const uint32_t *x, uint32_t *y, int a, int n) {
        for (int i = 0; i < N; i++) {
            y[i] = __rv_maddr32(y[i], a, x[i]);
        }
    }
  #else
    void axpy(const uint32_t *x, uint32_t *y, int a, int n) {
        for (int i = 0; i < N; i++) {
            y[i] += a * x[i];
        }
    }
  #endif
#endif

int main() {

  // Need to to this to stop GCC optimizing the value
  int volatile a = A;

  pcount_enable(0);
  pcount_reset();

  /*puts("Hello simple system\n");
  puthex(0xDEADBEEF);
  putchar('\n');
  puthex(0xBAADF00D);
  putchar('\n');*/

  // Initialize Vectors
  puts("Initializing vectors...\n");
  int val = 1;
  for (int i = 0; i < N; ++i) {
    x[i] = val;
    y[i] = val + 1;
    if (val > 64)
      val = 1;
    else
      val++;
  }

  // Perform AXPY operation
  //puts("Running AXPY benchmark...\n");
  pcount_enable(1);
  axpy(x, y, a, N);
  pcount_enable(0);

  // Print first and last elements of new vector to verify
  /*puts("( ");
  for (int i = 0; i < 4; ++i) {
    putbyte(y[i]);
    puts(" ");
  }
  puts("... ");
  for (int i = N-4; i < N; ++i) {
    putbyte(y[i]);
    puts(" ");
  }
  puts(") \n");*/

  return 0;
}