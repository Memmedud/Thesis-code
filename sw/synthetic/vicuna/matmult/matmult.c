// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "simple_system_common.h"
#include "matrix_common.h"
#include  <stdlib.h>

#define WIDTH8

#define n_len 8
#define m_len 8
#define p_len 8

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


/*# Load matrices A and B into vector registers
lv.v v0, 0(a0)     # Load matrix A from memory into v0
lv.v v1, 0(a1)     # Load matrix B from memory into v1

# Initialize loop counters
li t0, 0           # Initialize i loop counter
li t1, 0           # Initialize j loop counter
li t2, 0           # Initialize k loop counter

outer_loop:
    li t1, 0       # Reset j loop counter
    li t2, 0       # Reset k loop counter

    inner_loop:
        # Load vector from matrix A
        lv.v v2, (t0 * N + t2)(a0)

        # Load vector from matrix B
        lv.v v3, (t2 * K + t1)(a1)

        # Multiply-accumulate: multiply corresponding elements of v2 and v3, and accumulate the results into v4
        vmacc.vv v4, v2, v3

        addi t2, t2, 1    # Increment k loop counter
        blt t2, K, inner_loop   # Check if k loop counter < K

    # Store the result back to memory
    sv.v v4, (t0 * N + t1)(a2)

    addi t1, t1, 1       # Increment j loop counter
    blt t1, N, outer_loop   # Check if j loop counter < N

    addi t0, t0, 1       # Increment i loop counter
    blt t0, M, outer_loop   # Check if i loop counter < M*/


int main(int argc, char **argv) {
  pcount_enable(0);
  pcount_reset();
  uart_printf("%x\n", get_pcount());
  uart_printf("Hello from Vicuna!\n");
  
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

  puts("Generating reference result...\n");
  //matmul_ref(&C_ref, &A, &B, n_len, m_len, p_len);

  puts("Running MatMult benchmark...\n");
  pcount_enable(1);
  matmul(&C, &A, &B, n_len, m_len, p_len);
  pcount_enable(0);

  puts("Result: \n");
  //is_equal(&C, &C_ref, n_len, p_len);
  //print_matrix_word(&C, n_len, p_len);
  //print_matrix_word(&C_ref, n_len, p_len);

  // End of sim
  while (1){
  }

  return 0;
}