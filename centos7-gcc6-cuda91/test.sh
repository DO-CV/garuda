#!/bin/bash
set -ex

command=$1

xhost +

NV_GPU='0' nvidia-docker run -it --rm \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v ${PWD}/scripts:/scripts \
  -e DISPLAY=$DISPLAY \
  --name centos-test \
  mirriad-centos7-gcc6-cuda91:latest ${command}
