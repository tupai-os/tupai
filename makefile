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

# Configurable

TARGET_FAMILY = x86
TARGET_ARCH = i386

KERNEL_SRC_ROOT = $(SRC_ROOT)/kernel

# Non-configurable

BUILD_DIRS = $(BUILD_ROOT) $(BUILD_ROOT)/kernel
MAKE_KERNEL_ARGS = BUILD_ROOT=$(BUILD_ROOT)/kernel

# Rules

.PHONY: all
all: kernel

.PHONY: clean
clean:
	@cd $(KERNEL_SRC_DIR) && $(MAKE) clean $(MAKE_KERNEL_ARGS)

$(BUILD_DIRS):
	@mkdir -p $@

.PHONY: kernel
kernel: $(BUILD_DIRS)
	@echo "[`date "+%H:%M:%S"`] Building kernel..."
	@cd $(KERNEL_SRC_ROOT) && $(MAKE) all $(MAKE_KERNEL_ARGS)
	@echo "[`date "+%H:%M:%S"`] Built kernel."