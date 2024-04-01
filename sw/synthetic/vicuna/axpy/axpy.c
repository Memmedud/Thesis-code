// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "lib/runtime.h"
#include "lib/uart.h"
#include "lib/simple_system_common.h"
#include "riscv_vector.h"
#include <stdlib.h>

#define WIDTH8

#include <riscv-vector.h>

#define N 100000   // Size of the vectors
#define A 3        // Scalar value

#if defined(WIDTH8)
extern "C" long axpy(const int8_t *x, int8_t *y, int a, int n);
#elif define(WIDTH16)
extern "C" long axpy(const int16_t *x, int16_t *y, int a, int n);
#elif define(WIDTH32)
extern "C" long axpy(const int32_t *x, int32_t *y, int a, int n);
#endif

// Axpy in assembly
__asm__(
  "axpy:\n"
  // Load vectors x and y into vector registers // TODO: Fix input parameters
  "lv.v v0, 0(%rdi)\n"          // Load vector x from memory into v0
  "lv.v v1, 0(%rsi)\n"          // Load vector y from memory into v1

  "vmv.v.x v2, a2\n"          // Load scalar alpha into v2

  // Apply AXPY operation
  "vfma.vv v1, v2, v0, v1\n"  //Perform AXPY operation: y = alpha * x + y

  "sv.v v1, 0(a1)\n"          // Store updated vector y back into memory

  "ret\n"
);


int main() {
  pcount_enable(0);
  pcount_reset();
  uart_printf("%x\n", get_pcount());
  uart_printf("Hello from Vicuna!\n");

#if defined(WIDTH8)
  uint8_t *x = (float *)malloc(N * sizeof(float));
  uint8_t *y = (float *)malloc(N * sizeof(float));

  __asm__("vsetvl vl, vlenb, e8\n"); // Set vector type to 8-bit
#elif defined(WIDTH16)
  uint16_t *x = (float *)malloc(N * sizeof(float));
  uint16_t *y = (float *)malloc(N * sizeof(float));

  __asm__("vsetvl vl, vlenb, e16\n"); // Set vector type to 16-bit
#elif defined(WIDH32)
  uint32_t *x = (float *)malloc(N * sizeof(float));
  uint32_t *y = (float *)malloc(N * sizeof(float));

  __asm__("vsetvl vl, vlenb, e32\n"); // Set vector type to 32-bit
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
  uart_printf("%x\n", get_pcount());

  // Print first and last elements of new vector to verify
  for (int i = 0; i < 4; ++i) {
    uart_printf("%x", y[i]);
  }
  uart_printf(" ... ");
  for (int i = 4; i == 1; --i) {
    uart_printf("%x", y[n-i]);
  }
  uart_printf("\n");

  // End of sim
  while (1){
  }

  return 0;
}