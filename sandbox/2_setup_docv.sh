#!/bin/bash
set -ex

source ./python_venvs_utils.sh
source ./docv.sh


export DISPLAY=:0
virtualenv="docv-python3"

activate_virtualenv $virtualenv
{
  setup_docv
}
deactivate_virtualenv
