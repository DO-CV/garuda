#!/bin/bash
set -eux

#----------------------------------------------------------------------------------
# map ABI to toolset name (following "using clang :") used in user-config.jam
toolset_for_abi_name() {
  local abi_name=$1

  case "$abi_name" in
    arm64-v8a)      echo "arm64v8a"
      ;;
    armeabi-v7a)    echo "armeabiv7a"
      ;;
    x86)            echo "x86"
      ;;
    x86_64)         echo "x8664"
      ;;
  esac
}

#----------------------------------------------------------------------------------
# map abi to {NDK_DIR}/toolchains/llvm/prebuilt/linux-x86_64/bin/*-clang++
clang_triple_for_abi_name() {
  local abi_name=$1

  case "$abi_name" in
    arm64-v8a)      echo "aarch64-linux-android21"
      ;;
    armeabi-v7a)    echo "armv7a-linux-androideabi16"
      ;;
    x86)            echo "i686-linux-android16"
      ;;
    x86_64)         echo "x86_64-linux-android21"
      ;;
  esac
}

#----------------------------------------------------------------------------------
# map abi to {NDK_DIR}/toolchains/llvm/prebuilt/linux-x86_64/bin/*-ranlib etc
tool_triple_for_abi_name() {
  local abi_name=$1

  case "$abi_name" in
    arm64-v8a)      echo "aarch64-linux-android"
      ;;
    armeabi-v7a)    echo "arm-linux-androideabi"
      ;;
    x86)            echo "i686-linux-android"
      ;;
    x86_64)         echo "x86_64-linux-android"
      ;;
  esac
}

abi_for_abi_name() {
  local abi_name=$1

  case "$abi_name" in
    arm64-v8a)      echo "aapcs"
      ;;
    armeabi-v7a)    echo "aapcs"
      ;;
    x86)            echo "sysv"
      ;;
    x86_64)         echo "sysv"
      ;;
  esac
}

arch_for_abi_name() {
  local abi_name=$1

  case "$abi_name" in
    arm64-v8a)      echo "arm"
      ;;
    armeabi-v7a)    echo "arm"
      ;;
    x86)            echo "x86"
      ;;
    x86_64)         echo "x86"
      ;;
  esac
}

address_model_for_abi_name() {
  local abi_name=$1

  case "$abi_name" in
    arm64-v8a)      echo "64"
      ;;
    armeabi-v7a)    echo "32"
      ;;
    x86)            echo "32"
      ;;
    x86_64)         echo "64"
      ;;
  esac
}

compiler_flags_for_abi_name() {
  local abi_name=$1

  COMMON_FLAGS="" #-fno-integrated-as -Wno-long-long"
  local ABI_FLAGS
  case "$abi_name" in
    armeabi-v7a)
      ABI_FLAGS="-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp"
      ;;
    arm64-v8a|x86|x86_64)
      ;;
    *)
      echo "ERROR: Unknown ABI : $ABI" 1>&2
      exit 1
  esac

  echo "$COMMON_FLAGS $ABI_FLAGS"
}

linker_flags_for_abi_name() {
  local abi_name=$1

  COMMON_FLAGS=""
  local ABI_FLAGS
  case "$abi_name" in
    armeabi-v7a)
      ABI_FLAGS="-Wl,--fix-cortex-a8"
      ;;
    arm64-v8a|x86|x86_64)
      ;;
    *)
      echo "ERROR: Unknown ABI : $ABI" 1>&2
      exit 1
  esac

  echo "$COMMON_FLAGS $ABI_FLAGS"
}


# My device.
ANDROID_DEVICE_ABI=$(adb shell getprop ro.product.cpu.abi)

# SDK, NDK
ANDROID_SDK_ROOT=${HOME}/Android/Sdk
ANDROID_NDK_ROOT=${HOME}/opt/android-ndk-r21b
ANDROID_VERSION=29

ANDROID_TOOLCHAIN_TRIPLE=$(tool_triple_for_abi_name ${ANDROID_DEVICE_ABI})
ANDROID_TOOLCHAIN_ARCH=$(arch_for_abi_name ${ANDROID_DEVICE_ABI})
# ANDROID_TOOLCHAIN_ROOT=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/${ANDROID_TOOLCHAIN_TRIPLE}
ANDROID_TOOLCHAIN_ROOT=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64
ANDROID_SYSROOT=${ANDROID_NDK_ROOT}/platforms/android-${ANDROID_VERSION}/arch-${ANDROID_TOOLCHAIN_ARCH}

ANDROID_BASE_CFLAGS=$(compiler_flags_for_abi_name ${ANDROID_DEVICE_ABI})
ANDROID_BASE_LDFLAGS=$(compiler_flags_for_abi_name ${ANDROID_DEVICE_ABI})


INSTALL_DIR=${HOME}/opt/android-armeabi-v7a
