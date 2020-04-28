#!/bin/bash
set -ex

# CUDA requires DKMS which is available from the EPEL repo.
yum install -y epel-release

# Install awscli.
pip install awscli

# Install CUDA version 9.1.
aws s3 cp \
  s3://chub-apps-eu-west-1/libs/linux/cuda-repo-rhel7-9-1-local-9.1.85-1.x86_64.rpm \
  .
rpm -i cuda-repo-rhel7-9-1-local-9.1.85-1.x86_64.rpm
yum clean all
yum install -y cuda
