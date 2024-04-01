// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "simple_system_common.h"
#include "matrix_common.h"
#include  <stdlib.h>

//#define USE_PEXT
#define WIDTH8

#if defined(USE_PEXT)
#include <rvp_intrinsic.h>
#endif

#define ROWS 32
#define COLS 32

#if defined(WIDTH8)
  // 8-bit conv
  #if defined(USE_PEXT)
    void convolution(const uint8_t *input, uint8_t *output) {
 
    }
  #else
    void convolution(const uint8_t *input, uint8_t *output) {
      int filter[9] = { 1,  2,  1, 
                        0,  0,  0, 
                       -1, -2, -1};
        
      for (int i = 0; i < ROWS; i++) {
        for (int j = 0; j < COLS; j++) {
          int sum = 0;
          for (int m = -1; m <= 1; m++) {
            for (int n = -1; n <= 1; n++) {
              // Check boundaries
              if (i + m >= 0 && i + m < ROWS && j + n >= 0 && j + n < COLS) {
                sum += input[((i + m) * COLS) + j + n] * filter[(m + 1) * 3 + n + 1];
              }
            }
          }
          output[i * COLS + j] = sum;
        }
      }
    }
  #endif
#elif defined(WIDTH16)
  // 16-bit conv
  #if defined(USE_PEXT)
    void convolution(const uint16_t *input, uint16_t *output) {
      
    }
  #else
    void convolution(const uint16_t *input, uint16_t *output) {
      
    }
  #endif
#elif defined(WIDTH32)
  // 32-bit conv
  #if defined(USE_PEXT)
    void convolution(const uint32_t *input, uint32_t *output) {
      
    }
  #else
    void convolution(const uint32_t *input, uint32_t *output) {
      
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
  uint8_t  *input  = (uint8_t  *)malloc(ROWS*COLS * sizeof(uint8_t));
  uint32_t *output = (uint32_t *)malloc(ROWS*COLS * sizeof(uint32_t));
#elif defined(WIDTH16)
  uint16_t *input  = (uint16_t *)malloc(ROWS*COLS * sizeof(uint16_t));
  uint32_t *output = (uint32_t *)malloc(ROWS*COLS * sizeof(uint32_t));
#elif defined(WIDH32)
  uint32_t *input  = (uint32_t *)malloc(ROWS*COLS * sizeof(uint32_t));
  uint32_t *output = (uint32_t *)malloc(ROWS*COLS * sizeof(uint32_t));
#endif

  puts("Initializing input...\n");
  int val = 1;
  for (int i = 0; i < ROWS * COLS; i++) {
    input[i] = val;
    if (val > 64)
      val = 1;
    else
      val++;
  }

  // Perform convolution
  puts("Running convolution benchmark...\n");
  pcount_enable(1);
  convolution(input, output);
  pcount_enable(0);

  // Print the result
  puts("Result of 3x3 convolution:\n");
  for (int i = 0; i < ROWS; i++) {
      for (int j = 0; j < COLS; j++) {
          putbyte(output[i*COLS+j]);
      }
      puthex("\n");
  }

  return 0;
}