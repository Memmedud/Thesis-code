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

#define ROWS 32
#define COLS 32
#define FILTER_SIZE 3

/*

# Load input matrix and filter into vector registers
lv.v v0, 0(a0)           # Load input matrix into vector register v0
lv.v v1, 0(a1)           # Load filter into vector register v1

# Initialize loop counters
li t2, 0                 # Initialize row counter
li t3, 0                 # Initialize column counter

outer_loop:
    li t3, 0             # Reset column counter

    inner_loop:
        # Load 3x3 matrix from input into vector registers
        lv.w v2, (t2 * COLS + t3)(a0)

        # Multiply-accumulate: multiply corresponding elements of v2 and v1, and accumulate the results into v3
        vmac.vv v3, v2, v1

        addi t3, t3, 1     # Increment column counter
        blt t3, FILTER_SIZE, inner_loop  # Check if column counter < FILTER_SIZE
    # End of inner loop

    # Store the result back to memory
    sv.w v3, (t2 * COLS)(a2)

    addi t2, t2, 1         # Increment row counter
    blt t2, ROWS, outer_loop   # Check if row counter < ROWS
# End of outer loop*/


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

