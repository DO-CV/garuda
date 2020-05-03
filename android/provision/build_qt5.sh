#!/bin/bash
set -eux

QT_VERSION=v5.14.2

ANDROID_DEVICE_ABI=$(adb shell getprop ro.product.cpu.abi)
ANDROID_SDK_ROOT=${HOME}/Android/Sdk
ANDROID_NDK_ROOT=${HOME}/opt/android-ndk-r21b

INSTALL_DIR=${HOME}/opt/android-armeabi-v7a

if [ ! -d qt5 ]; then
  git clone git://code.qt.io/qt/qt5.git qt5
  perl init-repository
fi

pushd qt5
{
  git checkout ${QT_VERSION}
  git submodule update --recursive

  export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
  export PATH=$PATH:$JAVA_HOME/bin

  ./configure \
    -xplatform android-clang \
    --disable-rpath \
    -nomake tests \
    -nomake examples \
    -android-ndk ${ANDROID_NDK_ROOT} \
    -android-sdk ${ANDROID_SDK_ROOT} \
    -android-abis ${ANDROID_DEVICE_ABI} \
    -no-warnings-are-errors \
    -opensource -confirm-license \
    -prefix ${INSTALL_DIR}

  make -j$(nproc)
  make install
}
popd
