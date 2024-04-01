# Copyright TU Wien
# Licensed under the Solderpad Hardware License v2.1, see LICENSE.txt for details
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1


# Generic Makefile for RV32IMV applications
# Specify program name with PROG, object files with OBJ

SW_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

RISCV_CC            := /home/mats/masteroppgave/Thesis-code/toolchain/riscv-gcc-main/bin/riscv32-unknown-elf-gcc
RISCV_DUMP          := /home/mats/masteroppgave/Thesis-code/toolchain/riscv-gcc-main/bin/riscv32-unknown-elf-objdump
RISCV_OBCP          := /home/mats/masteroppgave/Thesis-code/toolchain/riscv-gcc-main/bin/riscv32-unknown-elf-objcopy
ARCH                := rv32imc_zve32x_zicsr
LD_SCRIPT           := $(SW_DIR)/link.ld

RISCV_FLAGS := -march=$(ARCH) -mabi=ilp32 -static -mcmodel=medany             \
               -fvisibility=hidden -nostdlib -nostartfiles -Wall              \
               $(CC_SPECIFIC_OPTIONS)

CFLAGS := $(CFLAGS) -I$(SW_DIR)/lib/

PROG ?= axpy
OBJ  ?= axpy.c

# add crt0 to object files
RISCV_OBJ := $(SW_DIR)/crt0.o $(OBJ) $(SW_DIR)/lib/uart.o $(SW_DIR)/lib/simple_system_common.o $(SW_DIR)/lib/runtime.o

all: $(PROG).vmem

dump: $(PROG).elf
	$(RISCV_DUMP) -D $<

$(PROG).elf: $(RISCV_OBJ) $(LD_SCRIPT)
	$(RISCV_CC) $(RISCV_FLAGS) -T $(LD_SCRIPT) $(LDFLAGS) $(RISCV_OBJ) -o $@

%.o: %.c
	$(RISCV_CC) $(RISCV_FLAGS) $(CFLAGS) -c -o $@ $<

%.o: %.S
	$(RISCV_CC) $(RISCV_FLAGS) $(ASFLAGS) -c -o $@ $<

# currently unusable due to problems with byte order
# (see https://github.com/riscv/riscv-tools/issues/168#issuecomment-554973539)
#%.vmem: %.elf
#	$(OBJCOPY) -O verilog --verilog-data-width 4 $^ $@

# workaround (requires srecord):
# note: start address must be reset manually because it is lost in bin file
%.vmem: %.bin
	srec_cat $^ -binary -offset 0x0000 -byte-swap 4 -o $@ -vmem
%.bin: %.elf
	$(RISCV_OBCP) -O binary $^ $@

clean:
	rm -f *.o *.elf *.bin *.vmem
