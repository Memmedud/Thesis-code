// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "simple_system_common.h"
#include "matrix_common.h"
#include  <stdlib.h>

#define USE_PEXT
#define WIDTH8

#if defined(USE_PEXT)
#include <rvp_intrinsic.h>
#endif

#define ROWS 64
#define COLS 64

#if defined(WIDTH8)
  volatile int8_t  input [ROWS*COLS];
  volatile int32_t  output[ROWS*COLS];
#elif defined(WIDTH16)
  volatile int16_t  input [ROWS*COLS];
  volatile int32_t  output[ROWS*COLS];
#elif defined(WIDTH32)
  volatile int32_t  input [ROWS*COLS];
  volatile int32_t  output[ROWS*COLS];
#endif

#if defined(WIDTH8)
  // 8-bit conv
  #if defined(USE_PEXT)
    void convolution(const uint8_t *input, uint32_t *output, uint32_t *filter) {
       for (int i = 1; i < ROWS-1; i++) {
        for (int j = 1; j < COLS-1; j++) {
          int sum = 0;
          if (i > 0)
            sum = __rv_smaqa(sum, (*((int32_t *)(input[(i-1) * COLS + j-1]))& 0xffffff00), 0x00ff0000);

          sum = __rv_smaqa(sum, (*((int32_t *)(input[i * COLS + j-1]))& 0xffffff00), 0xff05ff00);
          sum = __rv_smaqa(sum, (*((int32_t *)(input[(i+1) * COLS + j-1]))& 0xffffff00), 0x00ff0000);

          output[i * COLS + j] = sum;
        }
      }
    }
  #else
    void convolution(const uint8_t *input, uint32_t *output, uint32_t *filter) {
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
    void convolution(const uint16_t *input, uint32_t *output) {
      
    }
  #else
    void convolution(const uint16_t *input, uint32_t *output, uint32_t *filter) {
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
#elif defined(WIDTH32)
  // 32-bit conv
  #if defined(USE_PEXT)
    void convolution(const uint32_t *input, uint32_t *output) {
      
    }
  #else
    void convolution(const uint32_t *input, uint32_t *output, uint32_t *filter) {
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
#endif

int main() {

  volatile uint32_t filter[9] = { 0, -1,  0, 
                                 -1,  5, -1, 
                                 -0, -1,  0};

  pcount_enable(0);
  pcount_reset();

  puts("Hello simple system\n");
  puthex(0xDEADBEEF);
  putchar('\n');
  puthex(0xBAADF00D);
  putchar('\n');

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
  convolution(input, output, filter);
  pcount_enable(0);

  // Print the result
  puts("Result of 3x3 convolution:\n");
  for (int i = 0; i < ROWS; i++) {
      for (int j = 0; j < COLS; j++) {
          puthex(output[i*COLS+j]);
          puts(", ");
      }
      puts("\n");
  }

  return 0;
}