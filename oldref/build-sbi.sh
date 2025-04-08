#!/usr/bin/env bash

# SPDX-License-Identifier: MIT

# OLD STUFF, LEFT IN FOR REFERENCE

set -euxo pipefail

VER=v1.6
SOURCE_REPO=https://github.com/riscv-software-src/opensbi.git

TARGET_DIR=${1:-opensbi}

if [ ! -d "$TARGET_DIR" ]; then
  git clone --depth 1 -b $VER $SOURCE_REPO "$TARGET_DIR"
fi

cd "$TARGET_DIR"

make -j$(nproc) PLATFORM=generic CROSS_COMPILE=riscv64-linux-gnu-
