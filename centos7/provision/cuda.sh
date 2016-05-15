#!/bin/bash
set -e


PROVISION_DIR=$(pwd)/provision

CUDA_VERSION=7.5
CUDA_INSTALLER_FILE=cuda_${CUDA_VERSION}.18_linux.run
CUDA_INSTALLER_FILEPATH=${PROVISION_DIR}/${CUDA_INSTALLER_FILE}

CUDA_BASE_URL=http://developer.download.nvidia.com/compute/cuda
CUDA_LOCAL_INSTALLER_URL=${CUDA_BASE_URL}/${CUDA_VERSION}/Prod/local_installers/${CUDA_INSTALLER_FILE}


function download_cuda()
{
  if [ ! -f "${CUDA_INSTALLER_FILEPATH}" ]; then
    echo "Downloading CUDA installer file: `${CUDA_INSTALLER_FILE}`..."
    curl -O ${CUDA_LOCAL_INSTALLER_URL} -o ${PROVISION_DIR}/${CUDA_INSTALLER_FILE}
  else
    echo "CUDA installer file: ${CUDA_INSTALLER_FILE} is already downloaded!"
  fi
}

function install_cuda()
{
  if [ ! -f "/usr/local/cuda-${CUDA_VERSION}/bin/nvcc" ]; then
    echo "Running CUDA installer..."
    sh ${CUDA_INSTALLER_FILEPATH} --silent --driver --toolkit --samples --verbose
  else
    echo "CUDA is already installed!"
  fi
}

function setup_cuda()
{
  download_cuda
  install_cuda
}
