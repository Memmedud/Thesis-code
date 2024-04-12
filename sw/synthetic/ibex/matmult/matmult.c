// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "simple_system_common.h"
#include "matrix_common.h"
#include  <stdlib.h>

//#define USE_PEXT
#define WIDTH32

#if defined(USE_PEXT)
#include <rvp_intrinsic.h>
#endif

#define n_len 128
#define m_len 128
#define p_len 128

volatile int32_t C[n_len * p_len];
volatile int32_t C_ref[n_len * p_len];
#if defined(WIDTH8)
  volatile int8_t  A[n_len * m_len];
  volatile int8_t  B[m_len * p_len];
#elif defined(WIDTH16)
  volatile int16_t  A[n_len * m_len];
  volatile int16_t  B[m_len * p_len];
#elif defined(WIDTH32)
  volatile int32_t  A[n_len * m_len];
  volatile int32_t  B[m_len * p_len];
#endif

#if defined(WIDTH8)
  // 8-bit matrix mult
  #if defined(USE_PEXT)   // n, m and p must be a multiple of 4
    // C = AB with A = [n x m], B = [m x p], C = [n x p]
    void matmul(int32_t* c, const int8_t* a, const int8_t* b) {

      // Need to tranpose b first
      // b_T is of shape p*m
      int8_t b_T[p_len * m_len];
      for (int i = 0; i < m_len; ++i) {
        for (int j = 0; j < p_len; ++j) {
          b_T[j * m_len + i] = b[i * p_len + j];
        }
      }

      for (int i = 0; i < n_len; i++) {
        for (int j = 0; j < p_len; j++) {
          int32_t sum = 0;
          for (int k = 0; k < m_len; k+=4) {       // I know this is ugly, but its very efficient
            sum = __rv_smaqa(sum, *((int32_t *)(&a[i * n_len + k])), *((int32_t *)(&b_T[j * p_len  + k])));
          }
          c[i * p_len + j] = sum;
        }
      }
    }
  #else
    // C = AB with A = [n x m], B = [m x p], C = [n x p]
    void matmul(int32_t* c, const int8_t* a, const int8_t* b) {
      for (int i = 0; i < n_len; ++i) {
        for (int j = 0; j < p_len; ++j) {
          int32_t sum = 0;
          for (int k = 0; k < m_len; ++k) {
            sum += a[i * m_len + k] * b[k * p_len + j];
          }
          c[i * p_len + j] = sum;
        }
      }
    }
  #endif
#elif defined(WIDTH16)
  // 16-bit matrix mult
  #if defined(USE_PEXT)
    // C = AB with A = [n x m], B = [m x p], C = [n x p]
    void matmul(int32_t* c, const int16_t* a, const int16_t* b) {

      // Need to tranpose b first
      // b_T is of shape p*m
      int16_t b_T[p_len * m_len] __attribute__ ((aligned(8)));
      for (int i = 0; i < m_len; ++i) {
        for (int j = 0; j < p_len; ++j) {
          b_T[j * m_len + i] = b[i * p_len + j];
        }
      }

      for (int i = 0; i < n_len; ++i) {
        for (int j = 0; j < p_len; ++j) {
          int sum = 0;
          for (int k = 0; k < m_len; k += 2) {       // I know this is ugly, but its very efficient
            sum = __rv_kmada(sum, *((int *)(&a[i * n_len + k])), *((int *)(&b_T[j * p_len  + k])));
          }
          c[i * n_len + j] = sum;
        }
      }
    }
  #else
    // C = AB with A = [n x m], B = [m x p], C = [n x p]
    void matmul(int32_t* c, const int16_t* a, const int16_t* b) {
      for (int i = 0; i < n_len; ++i) {
        for (int j = 0; j < p_len; ++j) {
          int32_t sum = 0;
          for (int k = 0; k < m_len; ++k) {
            sum += a[i * m_len + k] * b[k * p_len + j];
          }
          c[i * p_len + j] = sum;
        }
      }
    }
  #endif
#elif defined(WIDTH32)
  // 32-bit matrix mult
  #if defined(USE_PEXT)
    // C = AB with A = [n x m], B = [m x p], C = [n x p]
    void matmul(int32_t *c, const int32_t *a, const int32_t *b) {
      for (int i = 0; i < n_len; ++i) {
        for (int j = 0; j < p_len; ++j) {
          int32_t sum = 0;
          for (int k = 0; k < m_len; ++k) {
            sum += a[i * m_len + k] * b[k * p_len + j];
          }
          c[i * p_len + j] = sum;
        }
      }
    }
  #else
    // C = AB with A = [n x m], B = [m x p], C = [n x p]
    void matmul(int32_t* c, const int32_t* a, const int32_t* b) {
      for (int i = 0; i < n_len; ++i) {
        for (int j = 0; j < p_len; ++j) {
          int32_t sum = 0;
          for (int k = 0; k < m_len; ++k) {
            sum += a[i * m_len + k] * b[k * p_len + j];
          }
          c[i * p_len + j] = sum;
        }
      }
    }
  #endif
#endif


int main(int argc, char **argv) {
  pcount_enable(0);
  pcount_reset();

  puts("Hello simple system\n");
  puthex(0xDEADBEEF);
  putchar('\n');
  puthex(0xBAADF00D);
  putchar('\n');
  
  puts("Initializing matrices...\n");
  uint8_t val = 1;
  for (int i = 0; i < n_len; ++i) {
    for (int j = 0; j < m_len; ++j) {
      A[i * m_len + j] = val;
      B[i * p_len + j] = val;
      if (val > 64)
        val = 1;
      else
        val++;
    }
  }
  //print_matrix_word(&A, n_len, m_len);
  //print_matrix_word(&B, m_len, p_len);

  //puts("Generating reference result...\n");
  //matmul_ref(&C_ref, &A, &B, n_len, m_len, p_len);

  //puts("Running MatMult benchmark...\n");
  pcount_enable(1);
  matmul(&C, &A, &B);
  pcount_enable(0);

  //puts("Result: \n");
  //is_equal(&C, &C_ref, n_len, p_len);
  //print_matrix_word(&C, n_len, p_len);
  //print_matrix_word(&C_ref, n_len, p_len);

  return 0;
}