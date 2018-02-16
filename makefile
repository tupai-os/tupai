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

TARGET_FAMILY = x86
TARGET_ARCH = i386

KERNEL_SRC_ROOT = $(SRC_ROOT)/kernel

# Non-configurable

KERNEL_EXE = $(BUILD_ROOT)/kernel/tupai.elf
KERNEL_MAKE_ARGS = BUILD_ROOT=$(BUILD_ROOT)/kernel

TOOL_GRUB_MKRESCUE = grub-mkrescue

ISO = $(BUILD_ROOT)/tupai.iso

TOOL_QEMU = qemu-system-$(TARGET_ARCH)
QEMU_ARGS = -d guest_errors --no-reboot --no-shutdown -m 256M

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
	@$(TOOL_QEMU) $(QEMU_ARGS) -cdrom $(ISO)

.PHONY: bochs
bochs: iso
	@$(TOOL_BOCHS)
