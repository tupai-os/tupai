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

TOOL_GRUB_MKRESCUE = grub-mkrescue

KERNEL_SRC_ROOT = $(SRC_ROOT)/kernel
INITRD_SRC_ROOT = $(SRC_ROOT)/initrd
GRUB_SRC_ROOT = $(SRC_ROOT)/grub

# Non-configurable

KERNEL_BUILD_ROOT = $(BUILD_ROOT)/kernel
KERNEL_ELF = $(KERNEL_BUILD_ROOT)/tupai.elf
KERNEL_IMG = $(KERNEL_BUILD_ROOT)/tupai.img
KERNEL_MAKE_ARGS = BUILD_ROOT=$(KERNEL_BUILD_ROOT) TARGET=$(TARGET)

INITRD_BUILD_ROOT=$(BUILD_ROOT)/initrd
INITRD_TAR = $(INITRD_BUILD_ROOT)/initrd.tar
INITRD_MAKE_ARGS = BUILD_ROOT=$(INITRD_BUILD_ROOT) INITRD_TAR=$(INITRD_TAR) TARGET=$(TARGET)

GRUB_BUILD_ROOT = $(BUILD_ROOT)/grub
GRUB_DIRS = $(GRUB_BUILD_ROOT)/isodir/boot/grub $(GRUB_BUILD_ROOT)/isodir/mod
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

.PHONY: initrd
initrd: $(BUILD_DIRS)
	@echo "[`date "+%H:%M:%S"`] Building initrd..."
	@cd $(INITRD_SRC_ROOT) && $(MAKE) all $(INITRD_MAKE_ARGS)
	@echo "[`date "+%H:%M:%S"`] Built initrd."

.PHONY: iso
iso: kernel initrd
	@cp $(KERNEL_ELF) $(GRUB_BUILD_ROOT)/isodir/boot/.
	@cp $(INITRD_TAR) $(GRUB_BUILD_ROOT)/isodir/mod/.
	@cp $(GRUB_SRC_ROOT)/grub.cfg $(GRUB_BUILD_ROOT)/isodir/boot/grub/
	@$(TOOL_GRUB_MKRESCUE) -o $(ISO) $(GRUB_BUILD_ROOT)/isodir

.PHONY: flatten
flatten: kernel
	@echo "[`date "+%H:%M:%S"`] Flattening kernel..."
	@$(TOOL_OBJCOPY) $(KERNEL_ELF) -O binary $(KERNEL_IMG)
