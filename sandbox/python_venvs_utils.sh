#!/bin/bash
set -ex


DOCV_VENV_WORKON_HOME=${HOME}/sandbox/third_party/virtualenvs


function install_virtualenvwrapper()
{
  echo "Install virtualenvwrapper with pip..."
  pip install virtualenvwrapper
}

function export_virtualenvwrapper_variables()
{
  echo "Export variables for virtual environments..."
  export WORKON_HOME=${DOCV_VENV_WORKON_HOME}
  export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
  export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv
  source /usr/local/bin/virtualenvwrapper.sh
}

function create_workon_home_venv_dir()
{
  echo "Creating '${WORKON_HOME}' directory if necessary..."
  if [ ! -d "${WORKON_HOME}" ]; then
    mkdir ${WORKON_HOME}
  fi
}

function setup_python_venv()
{
  local virtualenv=$1
  local python_version=$2

  echo "Setting up virtual env '${virtualenv}'..."
  if [ ! -d "${WORKON_HOME}/${virtualenv}" ]; then
    mkvirtualenv --python=$(which python${python_version}) ${virtualenv}
  fi

  local postactivate_file=${WORKON_HOME}/${virtualenv}/bin/postactivate
  if [ -f "${postactivate_file}" ]; then
    rm ${postactivate_file}
  fi

  echo "Creating postactivate file..."
  echo "#!/bin/bash" >> ${postactivate_file}

  echo "Export CUDA for virtual env '${virtualenv}'..."
  echo "export LD_LIBRARY_PATH=/usr/local/cuda/lib64" \
    >> ${postactivate_file}
}

function activate_virtualenv()
{
  export_virtualenvwrapper_variables
  local virtual_env=$1
  source ${WORKON_HOME}/${virtualenv}/bin/activate
}

function deactivate_virtualenv()
{
  deactivate
}
