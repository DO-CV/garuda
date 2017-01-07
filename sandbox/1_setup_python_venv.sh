#!/bin/bash
set -ex

source ./python_venvs_utils.sh


function setup_python_venvs()
{
  install_virtualenvwrapper
  export_virtualenvwrapper_variables
  create_workon_home_venv_dir
}

function setup_docv_python3_venv()
{
  # Create specific virtual environment for the visual recognition system.
  local virtualenv=docv-python3
  setup_python_venv ${virtualenv} 3

  # Now install the Python packages.
  source ${WORKON_HOME}/${virtualenv}/bin/activate
  pip install -U pip
  pip install -r ./python_requirements.txt

  # Update the Python packages if necessary.
  pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip install -U
}


setup_python_venvs
setup_docv_python3_venv
