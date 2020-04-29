#!/bin/bash
set -eux

VERSION_MAJOR=1
VERSION_MINOR=73
VERSION_PATCH=0
VERSION=${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}

ARCHIVE_FILENAME=boost_${VERSION_MAJOR}_${VERSION_MINOR}_${VERSION_PATCH}.tar.bz2
ARCHIVE_URL=https://dl.bintray.com/boostorg/release/${VERSION}/source/${ARCHIVE_FILENAME}


ANDROID_NDK_ROOT=${HOME}/Android/Sdk/ndk-bundle

ABI_NAME=$(adb shell getprop ro.product.cpu.abi)
TOOLCHAIN=${PWD}/toolchain


if [[ ! -f ${ARCHIVE_FILENAME} ]]; then
  echo "Downloading boost libraries: $ARCHIVE_URL"
  wget $ARCHIVE_URL
else
  echo "Boost libraries already downloaded"
fi

if [[ ! -d boost_${VERSION_MAJOR}_${VERSION_MINOR}_${VERSION_PATCH} ]]; then
  echo "Extracting archive..."
  tar xvf ${ARCHIVE_FILENAME}
fi


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


if [ ! -d "${TOOLCHAIN}" ]; then
  echo "Building toolchain..."
  ${ANDROID_NDK_ROOT}/build/tools/make-standalone-toolchain.sh \
    --arch=$(arch_for_abi_name $ABI_NAME) \
    --platform=android-$(adb shell getprop ro.build.version.sdk) \
    --install-dir="${TOOLCHAIN}" \
    --toolchain=arm-linux-androideabi-clang \
    --use-llvm \
    --stl=libc++
else
  echo "Toolchain already built"
fi


pushd boost_${VERSION_MAJOR}_${VERSION_MINOR}_${VERSION_PATCH}
{
  echo "Generating config..."
  USER_CONFIG=tools/build/src/user-config.jam
  rm -f ${USER_CONFIG}
  cat <<EOF > ${USER_CONFIG}
import os ;

using clang
  : android
  : ${TOOLCHAIN}/bin/clang++
    <cxxflags>-std=c++17
  ;
EOF

  echo "Bootstrapping..."
  ./bootstrap.sh

  echo "Building boost ${VERSION}..."
  ./b2 -j$(nproc) \
    --with-atomic \
    --with-chrono \
    --with-container \
    --with-context \
    --with-contract \
    --with-coroutine \
    --with-date_time \
    --with-exception \
    --with-fiber \
    --with-filesystem \
    --with-graph \
    --with-graph_parallel \
    --with-headers \
    --with-iostreams \
    --with-locale \
    --with-log \
    --with-math \
    --with-mpi \
    --with-nowide \
    --with-program_options \
    --with-random \
    --with-regex \
    --with-serialization \
    --with-stacktrace \
    --with-system \
    --with-test \
    --with-thread \
    --with-timer \
    --with-type_erasure \
    --with-wave \
    --user-config=${USER_CONFIG} \
    --layout=versioned \
    binary-format=elf \
    address-model=$(address_model_for_abi_name $ABI_NAME) \
    architecture=$(arch_for_abi_name $ABI_NAME) \
    abi=$(abi_for_abi_name $ABI_NAME) \
    link=shared \
    runtime-link=shared \
    target-os=android \
    toolset=clang-android \
    threading=multi \
    threadapi=pthread \
    variant=release \
    install --prefix=$HOME/opt/android-$ABI_NAME

  echo "Done!"
}
popd
