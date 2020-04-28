#!/bin/bash
set -ex


source ./provision/install_gcc6.sh
source ./provision/install_cuda91.sh
source ./provision/install_cuda91_cudnn7.sh
source ./provision/install_cuda91_nccl21.sh
