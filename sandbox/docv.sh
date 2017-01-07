#!/bin/bash
set -ex

source ./git_utils.sh


# Be careful: the order in which libraries are built matters.
DOCV_LIBRARIES=("sara" "shakti")
DOCV_DIR=${HOME}/GitHub/DO-CV
DOCV_INSTALL_DIR=${HOME}/sandbox


function build_library()
{
  local library=$1
  local cmake_options=$2

  echo "Build library ${library}..."

  make_clean_build_dir ${library}

  # Run CMake.
  cd "${library}-build"
  {
    echo "Running CMake for ${package} with:"
    echo "  ${cmake_options}"
    cmake ${cmake_options} ../${library}

    # Build the library.
    make -j`nproc`

    # Run C++ unit tests.
    ctest --output-on-failure

    # Run Python unit tests.
    make pytest
  }
  cd ..
}

function install_library()
{
  local library=$1

  cd ${library}-build
  {
    sudo make install
  }
  cd ..
}

function export_docv_library_paths()
{
  local site_packages=lib/python3.5/site-packages
  local docv_python_site_packages=${DOCV_INSTALL_DIR}/${site_packages}
  echo "export PYTHONPATH=${docv_python_site_packages}:\$PYTHONPATH" \
    >> ${VIRTUAL_ENV}/bin/postactivate
}

function setup_docv()
{
  export CMAKE_PREFIX_PATH=${DOCV_INSTALL_DIR}

  local current_dir=$(pwd)

  if [ ! -d ${DOCV_DIR} ]; then
    mkdir ${DOCV_DIR}
  fi

  cd ${DOCV_DIR}
  {
    for library in "${DOCV_LIBRARIES[@]}"; do

      if [ ! -d ${library} ]; then
        git clone https://github.com/DO-CV/${library}
      fi

      clean_git_repo $library origin

      # Activate all the build options.
      local cmake_options="-DCMAKE_BUILD_TYPE=Release "
      cmake_options+="-D${library^^}_BUILD_PYTHON_BINDINGS=ON "
      cmake_options+="-D${library^^}_BUILD_SHARED_LIBS=ON "
      cmake_options+="-D${library^^}_BUILD_TESTS=ON "
      cmake_options+="-D${library^^}_BUILD_SAMPLES=ON "

      # Installation settings.
      cmake_options+="-DCMAKE_INSTALL_PREFIX=${DOCV_INSTALL_DIR} "
      cmake_options+="-D${library^^}_SELF_CONTAINED_INSTALLATION=ON "

      # We need CUDA for this library.
      if [ "$library" = "shakti" ]; then
        cmake_options+="-DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda "
      fi

      echo ${cmake_options}
      build_library ${library} "$cmake_options"
      install_library ${library}

    done
  }

  export_docv_library_paths

  cd ${current_dir}
}
