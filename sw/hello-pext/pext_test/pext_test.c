// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "simple_system_common.h"
#include <rvp_intrinsic.h>

int main(int argc, char **argv) {
  pcount_enable(0);
  pcount_reset();
  pcount_enable(1);

  puts("Hello simple system\n");
  puthex(0xDEADBEEF);
  putchar('\n');
  puthex(0xBAADF00D);
  putchar('\n');

  putchar('\n');
  puthex(0x01010101 + 0x01010101);
  putchar('\n');
  puthex(__rv_uradd8(0xf97f4080, 0xbf0708bf));
  putchar('\n');
  puthex(__rv_uradd16(0x00000000, 0x0a14ff60));
  putchar('\n');
  puthex(__rv_add8(0xff00ff00, 0xaa00aa00));
  putchar('\n');
  puthex(__rv_uradd8(0xaaaaaaaa, 0xffffffff));
  putchar('\n');
  puthex(__rv_ursub8(0x0000ffff, 0x01010101));
  putchar('\n');
  puthex(__rv_kadd8(0xffffffff, 0x11111111));
  putchar('\n');
  puthex(__rv_sll16(0x000000a3, 0x0000005));
  putchar('\n');
  puthex(__rv_khm16(0x000000a3, 0x0000005));
  putchar('\n');

  pcount_enable(0);

  return 0;
}
