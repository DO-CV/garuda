#!/bin/bash
set -ex

AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)
AWS_DEFAULT_REGION=eu-west-1

options="--build-arg aws_secret_access_key=${AWS_SECRET_ACCESS_KEY} "
options+="--build-arg aws_access_key_id=${AWS_ACCESS_KEY_ID} "
options+="--build-arg aws_default_region=${AWS_DEFAULT_REGION}"

cat /etc/machine-id > machine-id

NV_GPU='0' nvidia-docker build -t docv-centos7-gcc6-cuda91:latest ${options} .
