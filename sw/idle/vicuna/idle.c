// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "lib/runtime.h"
#include "lib/uart.h"
#include "lib/simple_system_common.h"
#include "riscv_vector.h"

int main(int argc, char **argv) {

  pcount_enable(0);
  pcount_reset();
  uart_printf("%x\n", get_pcount());
  pcount_enable(1);
  uart_printf("Hello from Vicuna!\n");
  pcount_enable(0);
  uart_printf("%x\n", get_pcount());

  // Forever idle
  while (1) {
  }

  return 0;
}
