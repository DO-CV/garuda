#!/bin/bash

DOCV_PYENV_PROFILE_PATH=/etc/profile.d/docv-pyenv.sh


function setup_virtualenvwrapper()
{
  echo "Install virtualenvwrapper with pip..."
  pip install virtualenvwrapper
}

function setup_virtualenvwrapper_variables()
{
  echo "Export variables for virtual environments..."
  export WORKON_HOME=/usr/local/share/virtualenvs
  export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python2
  export VIRTUALENVWRAPPER_VIRTUALENV=/usr/bin/virtualenv
  source /usr/bin/virtualenvwrapper.sh
}

function setup_systemwide_venvs_dir()
{
  echo "Creating '${WORKON_HOME}' directory if necessary..."
  if [ ! -d "${WORKON_HOME}" ]; then
    mkdir ${WORKON_HOME}
  fi
  chmod a+rw ${WORKON_HOME}
}

function setup_python_venv()
{
  local virtualenv=$1
  local python_version=$2

  echo "Setting up virtual env '${virtualenv}'..."

  if [ ! -d "${WORKON_HOME}/${virtualenv}" ]; then
    mkvirtualenv -p $(which python${python_version}) ${virtualenv}
  fi
}

function create_systemwide_venv_config()
{
  echo "Creating system bash profile '${DOCV_PYENV_PROFILE_PATH}'..."

  if [ ! -f "${DOCV_PYENV_PROFILE_PATH}" ]; then
    touch ${DOCV_PYENV_PROFILE_PATH}
    echo "export WORKON_HOME=/usr/local/share/virtualenvs" \
      >> ${DOCV_PYENV_PROFILE_PATH}
    echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python2.7" \
      >> ${DOCV_PYENV_PROFILE_PATH}
    echo "export VIRTUALENVWRAPPER_VIRTUALENV=/usr/bin/virtualenv" \
      >> ${DOCV_PYENV_PROFILE_PATH}
    echo "source /usr/bin/virtualenvwrapper.sh" \
      >> ${DOCV_PYENV_PROFILE_PATH}
  fi
}

function setup_python_virtualenvs()
{
  setup_virtualenvwrapper
  setup_virtualenvwrapper_variables
  setup_systemwide_venvs_dir
  create_systemwide_venv_config
}
