#!/bin/bash

sudo apt-get install clang-format clang-tidy clang-tools clang clangd libc++-dev libc++1 libc++abi-dev libc++abi1 libclang-dev libclang1 liblldb-dev libllvm-ocaml-dev libomp-dev libomp5 lld lldb llvm-dev llvm-runtime llvm python3-clang
sudo apt update
sudo apt install python2
sudo apt-get install gcc-aarch64-linux-gnu

git clone  https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 gcc
git clone --depth=1 https://gitlab.com/LeCmnGend/clang.git -b clang-18 clang-18 
export ARCH=arm64
mkdir out

export BUILD_CROSS_COMPILE=$(pwd)/gcc/bin/aarch64-linux-android-
export KERNEL_LLVM_BIN=$(pwd)/clang-18/bin/clang
CLANG_TRIPLE=aarch64-linux-gnu-
KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE vendor/x1q_kor_singlex_defconfig
make -j8 -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE
 
cp out/arch/arm64/boot/Image $(pwd)/arch/arm64/boot/Image
