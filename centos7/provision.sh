#!/bin/bash
set -e

source ./provision/ius.sh
source ./provision/cuda.sh
source ./provision/python_virtualenvs.sh


function setup_dev_env()
{
  # Install GCC toolchain.
  yum groupinstall -y 'Development Tools'

  # Install Python 3.5.
  yum install -y \
    python35u python35u-devel python35-libs \
    python35u-pip

  # Install dependencies.
  yum install -y \
    rpm-build \
    git \
    cmake \
    libjpeg-turbo-devel libpng-devel \
    qt5-qtbase-devel
}


add_ius_rpm_package_repo

setup_dev_env
setup_cuda
setup_python_virtualenvs


# Setup python virtual environment.
source ${DOCV_PYENV_PROFILE_PATH}
docv_pyenv_name=docv-pyenv
setup_python_venv ${docv_pyenv_name}
