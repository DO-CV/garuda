#!/bin/bash
set -ex

yum install -y centos-release-scl
yum install -y rh-python36

echo 'source scl_source enable rh-python36' >> /etc/profile.d/python36.sh
