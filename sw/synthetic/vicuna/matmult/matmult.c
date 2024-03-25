// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "simple_system_common.h"
#include "matrix_common.h"
#include  <stdlib.h>

//#define USE_PEXT
//#define USE_VEXT

#if defined(USE_PEXT)
#include <rvp_intrinsic.h>
#elif defined(USE_VEXT)
#include <riscv_vector.h>
#endif

#define n_len 8
#define m_len 8
#define p_len 8

volatile int32_t C[n_len][p_len];
volatile int32_t C_ref[n_len][p_len];
volatile int16_t  A[n_len][m_len];
volatile int16_t  B[m_len][p_len];


// 8-bit matrix mult
#if defined(USE_PEXT)   // n, m and p must be a multiple of 4
  // C = AB with A = [n x m], B = [m x p], C = [n x p]
  void matmul_int8(int32_t* c, const int8_t* a, const int8_t* b,
                  const unsigned long int n, const unsigned long int m,
                  const unsigned long int p) {

    // Need to tranpose b first
    // b_T is of shape p*m
    int8_t b_T[p * m];
    for (int i = 0; i < m; ++i) {
      for (int j = 0; j < p; ++j) {
        b_T[j * m + i] = b[i * p + j];
      }
    }

    for (int i = 0; i < n; ++i) {
      for (int j = 0; j < p; ++j) {
        int sum = 0;
        for (int k = 0; k < m/4; ++k) {       // I know this is ugly, but its very efficient
          sum = __rv_smaqa(sum, *((int *)(&a[i * n + k * 4])), *((int *)(&b_T[j * p  + k * 4])));
        }
        c[i * n + j] = sum;
      }
    }
  }
#elif defined(USE_VEXT)   // TODO
    // C = AB with A = [n x m], B = [m x p], C = [n x p]
  void matmul_int8(int32_t* c, const int8_t* a, const int8_t* b,
                  const unsigned long int n, const unsigned long int m,
                  const unsigned long int p) {
    for (int i = 0; i < n; ++i) {
      for (int j = 0; j < p; ++j) {
        int32_t sum = 0;
        for (int k = 0; k < m; ++k) {
          sum += a[i * m + k] * b[k * p + j];
        }
        c[i * p + j] = sum;
      }
    }
  }
#else
  // C = AB with A = [n x m], B = [m x p], C = [n x p]
  void matmul_int8(int32_t* c, const int8_t* a, const int8_t* b,
                  const unsigned long int n, const unsigned long int m,
                  const unsigned long int p) {
    for (int i = 0; i < n; ++i) {
      for (int j = 0; j < p; ++j) {
        int32_t sum = 0;
        for (int k = 0; k < m; ++k) {
          sum += a[i * m + k] * b[k * p + j];
        }
        c[i * p + j] = sum;
      }
    }
  }
#endif


// 16-bit matrix mult
#if defined(USE_PEXT)
  // C = AB with A = [n x m], B = [m x p], C = [n x p]
  void matmul_int16(int32_t* c, const int16_t* a, const int16_t* b,
                  const unsigned long int n, const unsigned long int m,
                  const unsigned long int p) {

    // Need to tranpose b first
    // b_T is of shape p*m
    int16_t b_T[p * m] __attribute__ ((aligned(8)));
    for (int i = 0; i < m; ++i) {
      for (int j = 0; j < p; ++j) {
        b_T[j * m + i] = b[i * p + j];
      }
    }

    for (int i = 0; i < n; ++i) {
      for (int j = 0; j < p; ++j) {
        int sum = 0;
        for (int k = 0; k < m/2; ++k) {       // I know this is ugly, but its very efficient
          sum = __rv_kmada(sum, *((int *)(&a[i * n + k * 2])), *((int *)(&b_T[j * p  + k * 2])));
        }
        c[i * n + j] = sum;
      }
    }
  }
#elif defined(USE_VEXT)   // TODO
  // C = AB with A = [n x m], B = [m x p], C = [n x p]
  void matmul_int16(int32_t* c, const int16_t* a, const int16_t* b,
                  const unsigned long int n, const unsigned long int m,
                  const unsigned long int p) {
    for (int i = 0; i < n; ++i) {
      for (int j = 0; j < p; ++j) {
        int32_t sum = 0;
        for (int k = 0; k < m; ++k) {
          sum += a[i * m + k] * b[k * p + j];
        }
        c[i * p + j] = sum;
      }
    }
  }
#else
  // C = AB with A = [n x m], B = [m x p], C = [n x p]
  void matmul_int16(int32_t* c, const int16_t* a, const int16_t* b,
                  const unsigned long int n, const unsigned long int m,
                  const unsigned long int p) {
    for (int i = 0; i < n; ++i) {
      for (int j = 0; j < p; ++j) {
        int32_t sum = 0;
        for (int k = 0; k < m; ++k) {
          sum += a[i * m + k] * b[k * p + j];
        }
        c[i * p + j] = sum;
      }
    }
  }
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
  generate_matrices(&A, &B, n_len, m_len, p_len);
  //print_matrix_byte(&A, n_len, m_len);
  //print_matrix_byte(&B, m_len, p_len);

  puts("Generating reference result...\n");
  //matmul_int8_ref(&C_ref, &A, &B, n_len, m_len, p_len);

  puts("Running MatMult benchmark...\n");
  pcount_enable(1);
  matmul_int16(&C, &A, &B, n_len, m_len, p_len);
  pcount_enable(0);

  puts("Result: \n");
  //is_equal(&C, &C_ref, n_len, p_len);
  //print_matrix_word(&C, n_len, p_len);
  //print_matrix_word(&C_ref, n_len, p_len);

  return 0;
}