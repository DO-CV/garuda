#!/bin/bash
set -eux

QT_VERSION_MAJOR=5
QT_VERSION_MINOR=15
QT_VERSION_PATCH=0

QT_MAJOR_MINOR_VERSION=${QT_VERSION_MAJOR}.${QT_VERSION_MINOR}
QT_FULL_VERSION=${QT_MAJOR_MINOR_VERSION}.${QT_VERSION_PATCH}

QT_ARCHIVE_FILE=qt-everywhere-src-${QT_FULL_VERSION}.tar.xz
QT_ARCHIVE_URL=http://download.qt.io/official_releases/qt/${QT_MAJOR_MINOR_VERSION}/${QT_FULL_VERSION}/single/${QT_ARCHIVE_FILE}

INSTALL_DIR=${HOME}/opt/Qt-${QT_FULL_VERSION}-amd64

if [ ! -f ${QT_ARCHIVE_FILE} ]; then
  wget ${QT_ARCHIVE_URL}
fi

if [ ! -d ./qt-everywhere-src-${QT_FULL_VERSION} ]; then
  tar xvf ${QT_ARCHIVE_FILE}
fi

# Make sure all of these are installed.
# sudo apt-get install '^libxcb.*-dev' libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev

pushd ./qt-everywhere-src-${QT_FULL_VERSION}
{
  ./configure \
    -nomake tests \
    -nomake examples \
    -ccache \
    -xcb \
    -opensource -confirm-license \
    -prefix ${INSTALL_DIR}

  make -j$(nproc)
  make INSTALL_ROOT=${INSTALL_DIR} install
}
popd
