#!/bin/bash

CUDA_VERSION=7.5
CUDA_INSTALLER_FILE=cuda_${CUDA_VERSION}.18_linux.run
CUDA_INSTALLER_FILEPATH=/tmp/${CUDA_INSTALLER_FILE}

CUDA_BASE_URL=http://developer.download.nvidia.com/compute/cuda
CUDA_LOCAL_INSTALLER_URL=${CUDA_BASE_URL}/${CUDA_VERSION}/Prod/local_installers/${CUDA_INSTALLER_FILE}


function download_cuda()
{
  if [ ! -f "${CUDA_INSTALLER_FILEPATH}" ]; then
    echo "Downloading CUDA installer file: `${CUDA_INSTALLER_FILE}`..."
    curl -O ${CUDA_LOCAL_INSTALLER_URL}
    mv ${CUDA_INSTALLER_FILE} /tmp
  else
    echo "CUDA installer file: ${CUDA_INSTALLER_FILE} is already downloaded!"
  fi
}

function install_cuda_prerequisites()
{
  yum install -y kernel-devel kernel-headers
}

function install_cuda()
{
  local cuda_install_options="--silent --toolkit --samples --verbose"
  if [ -z ${VAGRANT_VM+x} ]; then
    cuda_install_options+=" --driver"
  fi

  #if [ ! -f "/usr/local/cuda-${CUDA_VERSION}/bin/nvcc" ]; then
    echo "Running CUDA installer..."
    sh ${CUDA_INSTALLER_FILEPATH} ${cuda_install_options}
  #else
  #  echo "CUDA is already installed!"
  #fi
}

function setup_cuda()
{
  download_cuda
  install_cuda_prerequisites
  install_cuda
}
