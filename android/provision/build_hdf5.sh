#!/bin/bash
set -ex

STANDLONE_PREFIX=$HOME/opt/android-ndk-r21b
HDF5_PARENT_DIR=${HOME}/Development/HDF5-compile
HDF5_INSTALL_DIR=$HOME/opt/android-armeabi-v7a/
EMULATOR_NAME_ARM="nexus19-arm"
EMULATOR_NAME_X86="nexus19-x86"

function find_device {
  local UUID=$1
  local EMULATOR_NAME=""
  local ADB_DEVICES=(`adb devices | grep 'emulator' | cut -f1`)
  while [ 1 ]; do
    local ADB_DEVICE=${ADB_DEVICES[0]}
    adb -s ${ADB_DEVICE} wait-for-device
    local DEVICE_UUID=`adb -s ${ADB_DEVICE} shell getprop emu.uuid | tr/TR -d '\r\n'`
    if [ "${DEVICE_UUID}" == "${UUID}" ]; then
      EMULATOR_NAME=${ADB_DEVICE}
      break
    else
      unset ADB_DEVICES[0]
      ADB_DEVICES=(${ADB_DEVICES[@]})
      if [ ${#ADB_DEVICES[@]} -eq 0 ]; then
        break
      fi
    fi
  done
  echo ${EMULATOR_NAME}
}

# Cleanup
rm -rf "${HDF5_INSTALL_DIR}"

declare -a COMPILE_ARCHITECTURES=("arm" "armv7a" "x86")
for ARCH in "${COMPILE_ARCHITECTURES[@]}"
do
  COMPILER_GROUP=""
  COMPILER_PREFIX=""
  EMULATOR_NAME=""
  case ${ARCH} in
    "arm" )
      COMPILER_GROUP=arm
      EMULATOR_NAME=${EMULATOR_NAME_ARM}
      ;;
    "armv7a" )
      COMPILER_GROUP=arm
      EMULATOR_NAME=${EMULATOR_NAME_ARM}
      ;;
    "x86" )
      COMPILER_GROUP=x86
      EMULATOR_NAME=${EMULATOR_NAME_X86}
      ;;
  esac

  # Start emulator and wait for boot to complete
  echo "############## STAGE 0 ##############"
  UUID=`uuidgen`
  EMULATOR_LAUNCH_OPTIONS=( "@${EMULATOR_NAME}" "-no-window" "-no-boot-anim" "-prop" "emu.uuid=${UUID}" )
  EMULATOR_COMMAND=( "emulator" "${EMULATOR_LAUNCH_OPTIONS[@]}" )
  nohup "${EMULATOR_COMMAND[@]}" </dev/null >/dev/null 2>&1 &
  sleep 10

  SERIAL_NUMBER=$(find_device ${UUID})

  STANDALONE_TOOLCHAIN="${STANDLONE_PREFIX}-${COMPILER_GROUP}"
  STANDALONE_BIN="${STANDALONE_TOOLCHAIN}/bin"
  SYSROOT_DIR="${STANDALONE_TOOLCHAIN}/sysroot"

  export CFLAGS=""
  export LDFLAGS=""
  case ${ARCH} in
    "arm" )
      ABI_NAME=armeabi
      COMPILER_PREFIX=arm-linux-androideabi
      ;;
    "armv7a" )
      ABI_NAME=armeabi-v7a
      COMPILER_PREFIX=arm-linux-androideabi
      CFLAGS="${CFLAGS} -march=armv7-a -mfpu=neon -mfloat-abi=softfp -mthumb"
      LDFLAGS="-march=armv7-a -Wl,--fix-cortex-a8"
      ;;
    "x86" )
      ABI_NAME=x86
      COMPILER_PREFIX=i686-linux-android
      CFLAGS="${CFLAGS} -march=i686 -mtune=intel -mssse3 -mfpmath=sse -m32"
      ;;
  esac

  export CC=${STANDALONE_BIN}/${COMPILER_PREFIX}-gcc
  export CPP=${STANDALONE_BIN}/${COMPILER_PREFIX}-cpp
  export CXX=${STANDALONE_BIN}/${COMPILER_PREFIX}-g++
  export LD=${STANDALONE_BIN}/${COMPILER_PREFIX}-ld
  export AR=${STANDALONE_BIN}/${COMPILER_PREFIX}-ar
  export AS=${STANDALONE_BIN}/${COMPILER_PREFIX}-as
  export RANLIB=${STANDALONE_BIN}/${COMPILER_PREFIX}-ranlib
  export STRIP=${STANDALONE_BIN}/${COMPILER_PREFIX}-strip

  sleep 1
  echo "############## STAGE 1 ##############"
  echo "Unzipping"
  rm -rf hdf5-1.8.18/
  tar xvfj hdf5-1.8.18.tar.bz2
  pushd hdf5-1.8.18/
  cp ../config.{guess,sub} bin/
  sed -i '' 's/.*TEST_SCRIPT = testerror.sh.*/TEST_SCRIPT =/' test/Makefile.in
  sed -i '' '/testlinks_env.sh $(am__append_1)/d' test/Makefile.in
  sed -i '' '/.*as_fn_exit $as_status/d' configure

  echo "---- Compiling for ${ARCH}"
  ./configure --host="${COMPILER_PREFIX}" --prefix="${HDF5_INSTALL_DIR}/${ABI_NAME}" --enable-cxx --with-sysroot=${SYSROOT_DIR}
  make -j8

  sleep 1
  echo "############## STAGE 2 ##############"
  # Delete H5_HAVE_GETPWUID
  sed -i '' '/H5_HAVE_GETPWUID/d' src/H5pubconf.h
  make -j8

  sleep 1
  echo "############## STAGE 3 ##############"
  # Run H5make_libsettings in the emulator
  ADB_OPTIONS=( "-s" "${SERIAL_NUMBER}" )
  SHELL_BOOT_OPTIONS=( "shell" "getprop" "sys.boot_completed" )
  while [ 1 ]; do
    BOOT_COMMAND=( adb "${ADB_OPTIONS[@]}" "${SHELL_BOOT_OPTIONS[@]}" )
    BOOT_RESULTS="$( ${BOOT_COMMAND[@]} | tr -d '\r\n' )"
    if [ -n "${BOOT_RESULTS}" ] && [ "${BOOT_RESULTS}" == "1" ]; then
      break
    elif [ -n "${BOOT_RESULTS}" ]; then
      echo "${BOOT_RESULTS}"
    fi
    sleep 1
  done
  DEVICE_BUILD_DIR=/storage/sdcard/hdf5
  adb "${ADB_OPTIONS[@]}" shell mount -o rw,remount rootfs
  adb "${ADB_OPTIONS[@]}" shell rm -rf "${DEVICE_BUILD_DIR}"
  adb "${ADB_OPTIONS[@]}" shell mkdir "${DEVICE_BUILD_DIR}"
  adb "${ADB_OPTIONS[@]}" push src/H5make_libsettings "${DEVICE_BUILD_DIR}"
  adb "${ADB_OPTIONS[@]}" push src/libhdf5.settings "${DEVICE_BUILD_DIR}"
  adb "${ADB_OPTIONS[@]}" shell chmod 755 "${DEVICE_BUILD_DIR}/H5make_libsettings "
  adb "${ADB_OPTIONS[@]}" shell "cd ${DEVICE_BUILD_DIR}; ./H5make_libsettings" > src/H5lib_settings.c
  make -j8

  sleep 1
  echo "############## STAGE 4 ##############"
  # Run H5detect in the emulator
  adb "${ADB_OPTIONS[@]}" push src/H5detect "${DEVICE_BUILD_DIR}"
  adb "${ADB_OPTIONS[@]}" shell chmod 755 "${DEVICE_BUILD_DIR}/H5detect"
  adb "${ADB_OPTIONS[@]}" shell "cd ${DEVICE_BUILD_DIR}; ./H5detect" > src/H5Tinit.c
  make -j8

  sleep 1
  echo "############## STAGE 5 ##############"
  # Rename a variable
  sed -i '' 's/minor/tminor/' test/tcheck_version.c
  sed -i '' 's/major/tmajor/' test/tcheck_version.c
  make -j8

  sleep 1
  echo "############## STAGE 6 ##############"
  # Delete H5_HAVE_IOCTL
  sed -i '' '/H5_HAVE_IOCTL/d' src/H5pubconf.h
  make -j8

  sleep 1
  echo "############## STAGE 7 ##############"
  # Run H5make_libsettings in the emulator again
  adb "${ADB_OPTIONS[@]}" shell rm "${DEVICE_BUILD_DIR}/H5make_libsettings"
  adb "${ADB_OPTIONS[@]}" shell rm "${DEVICE_BUILD_DIR}/libhdf5.settings"
  adb "${ADB_OPTIONS[@]}" push src/H5make_libsettings "${DEVICE_BUILD_DIR}"
  adb "${ADB_OPTIONS[@]}" push src/libhdf5.settings "${DEVICE_BUILD_DIR}"
  adb "${ADB_OPTIONS[@]}" shell chmod 755 "${DEVICE_BUILD_DIR}/H5make_libsettings"
  adb "${ADB_OPTIONS[@]}" shell "cd ${DEVICE_BUILD_DIR}; ./H5make_libsettings" > src/H5lib_settings.c
  make -j8

  sleep 1
  echo "############## STAGE 8 ##############"
  # Run H5detect in the emulator again
  adb "${ADB_OPTIONS[@]}" shell rm "${DEVICE_BUILD_DIR}/H5detect"
  adb "${ADB_OPTIONS[@]}" push src/H5detect "${DEVICE_BUILD_DIR}"
  adb "${ADB_OPTIONS[@]}" shell chmod 755 "${DEVICE_BUILD_DIR}/H5detect"
  adb "${ADB_OPTIONS[@]}" shell "cd ${DEVICE_BUILD_DIR}; ./H5detect" > src/H5Tinit.c
  make -j8

  echo "############## STAGE 9 ##############"
  adb "${ADB_OPTIONS[@]}" emu kill

  echo "############## STAGE 10 ##############"
  make install
  popd
done
