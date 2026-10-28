#!/bin/sh
# 用底包的 recovery.img 和内核打一个 lmi 的 skyward 镜像
set -e
STOCK=${1:?用法: ./build.sh <recovery.img> <boot.img 或 Image>}
KERNEL=${2:?用法: ./build.sh <recovery.img> <boot.img 或 Image>}

NDK=${ANDROID_NDK_HOME:?需要设置 ANDROID_NDK_HOME}
export CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER="$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android34-clang"

cargo build --release --target aarch64-linux-android -p skyward
cargo build --release -p skyward-pack

# 内核那份传 boot.img 时整颗换掉（连同 dtb），传 Image 时只换内核本体
case "$KERNEL" in
  *.img) KERNEL_ARGS="--kernel $KERNEL --keep-cmdline" ;;
  *)     KERNEL_ARGS="--kernel-blob $KERNEL" ;;
esac

./target/release/skyward-pack recovery \
  --stock "$STOCK" \
  --custom-ramdisk \
  $KERNEL_ARGS \
  --binary target/aarch64-linux-android/release/skyward \
  --config devices/lmi.toml \
  --font resources/fonts/MiSansVF.ttf \
  --mono resources/fonts/KirkMono-Regular.ttf \
  --mono-license resources/fonts/KirkMono-OFL.txt \
  --out skyward-lmi.img
