#!/bin/bash
set -ex

# Install gcc-6 to support C++14.
yum install -y centos-release-scl
yum install -y devtoolset-6

echo 'source scl_source enable devtoolset-6' >> /etc/profile.d/gcc-6.sh
