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

ifndef TARGET
  $(error No target defined, pass TARGET=<name>)
endif

# Configurable

KERNEL_SRC_ROOT = $(SRC_ROOT)/kernel

TOOL_GRUB_MKRESCUE = grub-mkrescue

# Non-configurable

GRUB_SRC_DIR = $(SRC_ROOT)/grub
GRUB_BUILD_ROOT = $(BUILD_ROOT)/grub
GRUB_DIRS = $(GRUB_BUILD_ROOT)/isodir/boot/grub $(GRUB_BUILD_ROOT)/isodir/mod

KERNEL_ELF = $(BUILD_ROOT)/kernel/tupai.elf
KERNEL_IMG = $(BUILD_ROOT)/kernel/tupai.img
KERNEL_MAKE_ARGS = BUILD_ROOT=$(BUILD_ROOT)/kernel TARGET=$(TARGET)

ISO = $(BUILD_ROOT)/tupai.iso

BUILD_DIRS = $(BUILD_ROOT) $(BUILD_ROOT)/kernel $(GRUB_DIRS)

# Build rules

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
	@cp $(KERNEL_ELF) $(GRUB_BUILD_ROOT)/isodir/boot/.
	@cp $(GRUB_SRC_DIR)/grub.cfg $(GRUB_BUILD_ROOT)/isodir/boot/grub/
	@$(TOOL_GRUB_MKRESCUE) -o $(ISO) $(GRUB_BUILD_ROOT)/isodir

.PHONY: flatten
flatten: kernel
	@echo "[`date "+%H:%M:%S"`] Flattening kernel..."
	@$(TOOL_OBJCOPY) $(KERNEL_ELF) -O binary $(KERNEL_IMG)
