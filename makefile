# file : makefile
#
#  Copyright (C) 2018  Joshua Barretto <joshua.s.barretto@gmail.com>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Non-configurable

SRC_ROOT = $(abspath .)
BUILD_ROOT ?= $(SRC_ROOT)/build

GRUB_SRC_DIR = $(SRC_ROOT)/grub
GRUB_BUILD_ROOT = $(BUILD_ROOT)/grub
GRUB_DIRS = $(GRUB_BUILD_ROOT)/isodir/boot/grub $(GRUB_BUILD_ROOT)/isodir/mod

BUILD_DIRS = $(BUILD_ROOT) $(BUILD_ROOT)/kernel $(GRUB_DIRS)

# Configurable

KERNEL_SRC_ROOT = $(SRC_ROOT)/kernel

# Non-configurable

ifndef CFG_arch_base
  $(error CFG_arch_base must be defined)
endif
ifndef CFG_arch_isa
  $(error CFG_arch_isa must be defined)
endif
ifndef CFG_drivers_ttyout
  $(error CFG_drivers_ttyout must be defined)
endif
ifndef CFG_drivers_ttyin
  $(error CFG_drivers_ttyin must be defined)
endif
ifndef CFG_drivers_tags
  $(error CFG_drivers_tags must be defined)
endif

KERNEL_EXE = $(BUILD_ROOT)/kernel/tupai.elf
KERNEL_MAKE_ARGS = BUILD_ROOT=$(BUILD_ROOT)/kernel \
  CFG_arch_base=$(CFG_arch_base) \
  CFG_arch_isa=$(CFG_arch_isa) \
  CFG_drivers_ttyout=$(CFG_drivers_ttyout) \
  CFG_drivers_ttyin=$(CFG_drivers_ttyin) \
  CFG_drivers_tags=$(CFG_drivers_tags)

TOOL_GRUB_MKRESCUE = grub-mkrescue

ISO = $(BUILD_ROOT)/tupai.iso

TOOL_QEMU = qemu-system-$(CFG_arch_isa)
QEMU_ARGS = --no-reboot --no-shutdown -m 256M
QEMU_ARGS_DEBUG = -s -S
ifeq ($(CFG_arch_base), x86)
  QEMU_ARGS += -cdrom $(ISO)
endif
ifeq ($(CFG_arch_base), arm)
  ifeq ($(CFG_arch_isa), armv7)
    TOOL_QEMU = qemu-system-arm
    QEMU_ARGS += -M raspi2 -kernel $(KERNEL_EXE)
  endif
  ifeq ($(CFG_arch_isa), armv8)
    TOOL_QEMU = qemu-system-aarch64
    QEMU_ARGS += -M raspi3
  endif
endif

TOOL_BOCHS = bochs

# Build rules

.PHONY: all
all: iso

.PHONY: clean
clean:
	@rm -r -f $(BUILD_DIRS)
	@cd $(KERNEL_SRC_ROOT) && $(MAKE) clean $(KERNEL_MAKE_ARGS)

$(BUILD_DIRS):
	@mkdir -p $@

.PHONY: check
check: $(BUILD_DIRS)
	@echo "[`date "+%H:%M:%S"`] Checking kernel..."
	@cd $(KERNEL_SRC_ROOT) && $(MAKE) check $(KERNEL_MAKE_ARGS)
	@echo "[`date "+%H:%M:%S"`] Checked kernel."

.PHONY: kernel
kernel: $(BUILD_DIRS)
	@echo "[`date "+%H:%M:%S"`] Building kernel..."
	@cd $(KERNEL_SRC_ROOT) && $(MAKE) all $(KERNEL_MAKE_ARGS)
	@echo "[`date "+%H:%M:%S"`] Built kernel."

.PHONY: iso
iso: kernel
	@cp $(KERNEL_EXE) $(GRUB_BUILD_ROOT)/isodir/boot/.
	@cp $(GRUB_SRC_DIR)/grub.cfg $(GRUB_BUILD_ROOT)/isodir/boot/grub/
	@$(TOOL_GRUB_MKRESCUE) -o $(ISO) $(GRUB_BUILD_ROOT)/isodir

# Testing rules

.PHONY: qemu
qemu: iso
	@$(TOOL_QEMU) $(QEMU_ARGS)

.PHONY: qemu_debug
qemu_debug: iso
	@echo "Now debugging with QEMU..."
	@$(TOOL_QEMU) $(QEMU_ARGS) $(QEMU_ARGS_DEBUG)

.PHONY: bochs
bochs: iso
	@$(TOOL_BOCHS)
