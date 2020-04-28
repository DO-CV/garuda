#!/bin/bash
set -ex

NCCL_INSTALL_PATH=/usr/local/cuda-9.1

aws s3 cp s3://chub-apps-eu-west-1/libs/linux/nccl_2.1.4-1+cuda9.1_x86_64.txz .
tar xvf nccl_2.1.4-1+cuda9.1_x86_64.txz

cd nccl_2.1.4-1+cuda9.1_x86_64
{
  cp -r --preserve=links ./include/* ${NCCL_INSTALL_PATH}/include
  cp -r --preserve=links ./lib/* ${NCCL_INSTALL_PATH}/lib64
}
cd ..
rm -r nccl_2.1.4-1+cuda9.1_x86_64 nccl_2.1.4-1+cuda9.1_x86_64.txz
