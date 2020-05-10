#!/bin/bash
set -eux

QT_VERSION_MAJOR=5
QT_VERSION_MINOR=13
QT_VERSION_PATCH=2

QT_MAJOR_MINOR_VERSION=${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}
QT_FULL_VERSION=${QT_MAJOR_MINOR_VERSION}.${QT_VERSION_PATCH}

QT_ARCHIVE_FILE=qt-everywhere-src-${QT_FULL_VERSION}.tar.xz
QT_ARCHIVE_URL=http://download.qt.io/official_releases/qt/${QT_MAJOR_MINOR_VERSION}/${QT_FULL_VERSION}/single/${QT_ARCHIVE_FILE}

ANDROID_SDK_ROOT=${HOME}/Android/Sdk
ANDROID_NDK_ROOT=${HOME}/opt/android-ndk-r21b

INSTALL_DIR=${HOME}/opt/Qt-${QT_FULL_VERSION}-android

if [ ! -f ${QT_ARCHIVE_FILE} ]; then
  wget ${QT_ARCHIVE_URL}
fi

if [ ! -d ./qt-everywhere-src-${QT_FULL_VERSION} ]; then
  tar xvf ${QT_ARCHIVE_FILE}
fi

pushd ./qt-everywhere-src-${QT_FULL_VERSION}
{
  export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
  export PATH=$PATH:$JAVA_HOME/bin

  ./configure \
    -xplatform android-clang \
    --disable-rpath \
    -nomake tests \
    -nomake examples \
    -android-ndk ${ANDROID_NDK_ROOT} \
    -android-sdk ${ANDROID_SDK_ROOT} \
    -no-warnings-are-errors \
    -opensource -confirm-license \
    -prefix ${INSTALL_DIR}

  make -j$(nproc)
  make INSTALL_ROOT=${INSTALL_DIR} install
}
popd
