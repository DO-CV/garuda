FROM centos:7

MAINTAINER "David OK" <david.ok8@gmail.com>

ARG aws_access_key_id
ARG aws_secret_access_key
ARG aws_default_region

ENV AWS_ACCESS_KEY_ID=${aws_access_key_id}
ENV AWS_SECRET_ACCESS_KEY=${aws_secret_access_key}
ENV AWS_DEFAULT_REGION=${aws_default_region}

# Needed to test GUI applications (in particular our Qt5 applications).
COPY machine-id /etc/machine-id

RUN mkdir /provision
WORKDIR /provision

# GCC 6.3.1 for C++14.
COPY ./provision/install_gcc6.sh /provision/install_gcc6.sh
RUN bash /provision/install_gcc6.sh

# Python 3.6.
COPY ./provision/install_python36.sh /provision/install_python36.sh
RUN bash /provision/install_python36.sh

# CUDA 9.1 to support Volta GPU in AWS EC2.
COPY ./provision/install_cuda91.sh /provision/install_cuda91.sh
RUN bash -c "source /etc/profile; bash install_cuda91.sh"

# CUDNN 7.
COPY ./provision/install_cuda91_cudnn7.sh /provision/install_cuda91_cudnn7.sh
RUN bash -c "source /etc/profile; bash install_cuda91_cudnn7.sh"

# NCCL 2.1.
COPY ./provision/install_cuda91_nccl21.sh /provision/install_cuda91_nccl21.sh
RUN bash -c "source /etc/profile; bash install_cuda91_nccl21.sh"
