#!/bin/bash
set -ex

CUDNN_INSTALL_PATH=/usr/local/cuda-9.1

aws s3 cp s3://chub-apps-eu-west-1/libs/linux/cudnn-9.1-linux-x64-v7.tgz .
tar xvzf cudnn-9.1-linux-x64-v7.tgz
cp -r --preserve=links ./cuda/include/* ${CUDNN_INSTALL_PATH}/include
cp -r --preserve=links ./cuda/lib64/* ${CUDNN_INSTALL_PATH}/include
rm -r ./cuda
