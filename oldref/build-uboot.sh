#!/usr/bin/env bash

# SPDX-License-Identifier: MIT

# OLD STUFF, LEFT IN FOR REFERENCE

set -euxo pipefail

VER=v2025.01
SOURCE_REPO=https://source.denx.de/u-boot/u-boot.git

TARGET_DIR=${1:-"u-boot"}
OPENSBI_BIN=${2:-"../opensbi/build/platform/generic/firmware/fw_dynamic.bin"}

if [ ! -d "$TARGET_DIR" ]; then
  git clone --depth 1 -b $VER $SOURCE_REPO "$TARGET_DIR"
fi

cd "$TARGET_DIR"

make qemu-riscv64_spl_defconfig
make -j$(nproc) \
  CROSS_COMPILE=riscv64-linux-gnu- \
  OPENSBI="$OPENSBI_BIN"
