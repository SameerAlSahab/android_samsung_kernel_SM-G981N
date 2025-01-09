#!/bin/bash
# Copy right by zetaxbyte
# Contact: t.me/@zetaxbyte

# Define colors for output
cyan="\033[96m"
green="\033[92m"
red="\033[91m"
blue="\033[94m"
yellow="\033[93m"
reset="\033[0m"

# Install necessary packages
echo -e "$blue[INFO] Installing dependencies...$reset"
sudo apt-get update && sudo apt-get install -y \
  clang lld llvm gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu \
  python3-clang

# Check if the Proton Clang directory exists
PROTON_CLANG_DIR="$(pwd)/proton-clang"
if [ -d "$PROTON_CLANG_DIR" ]; then
  echo -e "$green[INFO] Proton Clang directory found.$reset"
else
  echo -e "$yellow[WARNING] Proton Clang directory not found. Cloning...$reset"
  git clone --depth=1 https://gitlab.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-r536225 "$PROTON_CLANG_DIR"
  echo -e "$green[INFO] Cloning completed.$reset"
fi

# Set environment variables
export KBUILD_BUILD_USER="Sudoooo"
export KBUILD_BUILD_HOST="Dark-Angel"
export TC_DIR="$PROTON_CLANG_DIR"
export PATH="$TC_DIR/bin:$PATH"

# Clone GCC toolchain for ARM32 support
echo -e "$blue[INFO] Cloning GCC toolchain for ARM32 support...$reset"
if [ ! -d "$(pwd)/gcc" ]; then
  git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 gcc
fi
export CROSS_COMPILE_ARM32=$(pwd)/gcc/bin/arm-linux-androideabi-
export CROSS_COMPILE=$(pwd)/gcc/bin/aarch64-linux-android-

# Kernel configuration
DEFCONFIG="vendor/x1q_kor_singlex_defconfig"

echo -e "$blue[INFO] Starting kernel compilation...$reset"
mkdir -p out
make O=out ARCH=arm64 "$DEFCONFIG"

# Compile the kernel
make -j$(nproc) O=out ARCH=arm64 \
  CC=clang AR=llvm-ar NM=llvm-nm \
  OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump \
  STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu- \
  CROSS_COMPILE_ARM32=arm-linux-gnueabi- KCFLAGS=-w 2>&1 | tee log.txt

# Check if the compilation was successful
if [ -f out/arch/arm64/boot/Image ]; then
  echo -e "$cyan[INFO] Kernel compiled successfully!$reset"
else
  echo -e "$red[ERROR] Compilation failed. Check log.txt for details.$reset"
  exit 1
fi
