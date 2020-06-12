#!/bin/bash
#
# This script configures and build FFmpeg with CUDA acceleration.
set -eux

THIS_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)
source ${THIS_DIR}/common.sh


GIT_MASTER_REPOSITORY_PATH=${PWD}
REPOSITORY_URLS=https://git.ffmpeg.org/ffmpeg.git
FFMPEG_VERSION=4.2.2

function url_basename()
{
  local url=$1
  local url_name=$(basename ${url})
  local url_basename=${url_name%.*}
  echo ${url_basename}
}

function repo_dirpath()
{
  local url=$1
  echo ${GIT_MASTER_REPOSITORY_PATH}/$(url_basename ${url})
}


if [ ! -d ffmpeg ]; then
  git clone ${REPOSITORY_URLS}
fi

# FFmpeg
ffmpeg_dirpath=$(repo_dirpath ${REPOSITORY_URLS})
pushd ${ffmpeg_dirpath}
{
  git fetch origin --prune
  git checkout n${FFMPEG_VERSION}

  ffmpeg_options+="--prefix=${INSTALL_DIR} "

  # Cross-compilation information
  ffmpeg_options+="--enable-cross-compile "
  ffmpeg_options+="--cross-prefix=${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_TRIPLE}- "
  ffmpeg_options+="--toolchain=clang-usan "
  ffmpeg_options+="--target-os=android "
  ffmpeg_options+="--arch=${ANDROID_TOOLCHAIN_ARCH} "
  ffmpeg_options+="--cpu=${ANDROID_TOOLCHAIN_ARCH} "
  ffmpeg_options+="--sysroot=${ANDROID_SYSROOT} "
  ffmpeg_options+="--cc=${ANDROID_TOOLCHAIN_ROOT}/bin/clang "
  ffmpeg_options+="--cxx=${ANDROID_TOOLCHAIN_ROOT}/bin/clang++ "
  ffmpeg_options+="--ld=${ANDROID_TOOLCHAIN_ROOT}/bin/ld.gold "
  ffmpeg_options+="--as=${ANDROID_TOOLCHAIN_ROOT}/bin/as "
  ffmpeg_options+="--ar=${ANDROID_TOOLCHAIN_ROOT}/bin/ar "
  # ffmpeg_options+="--extra-ldflags=\"-shared ${ANDROID_BASE_LDFLAGS} \" "
  # ffmpeg_options+="--extra-cflags=\"-fPIE -fPIC -ffast-math -funroll-loops ${ANDROID_BASE_CFLAGS} \" "
  #ffmpeg_options+="--strip=${ANDROID_TOOLCHAIN}//${CROSS}-strip "

  # Hardware acceleration.
  ffmpeg_options+="--enable-hwaccels "
  ffmpeg_options+="--enable-x86asm "
  ffmpeg_options+="--enable-neon "
  ffmpeg_options+="--enable-pic "

  ffmpeg_options+="--enable-shared "
  ffmpeg_options+="--enable-nonfree  "
  ffmpeg_options+="--enable-gpl "

  ffmpeg_options+="--enable-avdevice "
  ffmpeg_options+="--enable-avresample "
  ffmpeg_options+="--enable-ffmpeg "
  ffmpeg_options+="--enable-postproc "

  ffmpeg_options+="--enable-protocol=concat "
  ffmpeg_options+="--enable-protocol=file "
  ffmpeg_options+="--enable-muxer=mp4 "
  ffmpeg_options+="--enable-demuxer=mpegts "
  ffmpeg_options+="--enable-jni "

  ffmpeg_options+="--disable-static "
  ffmpeg_options+="--disable-doc "
  ffmpeg_options+="--disable-ffplay "
  ffmpeg_options+="--disable-ffprobe "
  ffmpeg_options+="--disable-doc "
  ffmpeg_options+="--disable-symver "

  # Disable stripping for debug information.
  ffmpeg_options+="--disable-stripping "

  ffmpeg_options+="--enable-mediacodec "
  ffmpeg_options+="--enable-decoder=h264_mediacodec "
  ffmpeg_options+="--enable-hwaccel=h264_mediacodec "
  ffmpeg_options+="--enable-decoder=hevc_mediacodec "
  ffmpeg_options+="--enable-decoder=mpeg4_mediacodec "
  ffmpeg_options+="--enable-decoder=vp8_mediacodec "
  ffmpeg_options+="--enable-decoder=vp9_mediacodec "

  ./configure ${ffmpeg_options}
  make -j$(nproc)
  make install
}
popd
