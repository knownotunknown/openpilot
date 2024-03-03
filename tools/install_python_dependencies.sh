#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ROOT=$DIR/../
cd $ROOT

if ! command -v "pyenv" > /dev/null 2>&1; then
  echo "pyenv not found in PATH. Installing pyenv..."
  if [ ! -d "$HOME/.pyenv" ]; then
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
  else
    echo "Found existing .pyenv directory. Skipping pyenv installation."
  fi
  # Directly export PATH changes to ensure they are applied in the current shell session
  export PATH="$HOME/.pyenv/bin:$HOME/.pyenv/shims:$PATH"
else
  echo "pyenv is already installed."
fi

# Initialize pyenv in the current script
export PYENV_ROOT="$HOME/.pyenv"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

export MAKEFLAGS="-j$(nproc)"

PYENV_PYTHON_VERSION=$(cat $ROOT/.python-version)
if ! pyenv prefix ${PYENV_PYTHON_VERSION} &> /dev/null; then
  echo "python ${PYENV_PYTHON_VERSION} install ..."
  CONFIGURE_OPTS="--enable-shared" pyenv install -f ${PYENV_PYTHON_VERSION}
fi

pip install pip==23.3

poetry config virtualenvs.prefer-active-python true --local
poetry config virtualenvs.in-project true --local

echo "PYTHONPATH=${PWD}" > $ROOT/.env
if [[ "$(uname)" == 'Darwin' ]]; then
  echo "# msgq doesn't work on mac" >> $ROOT/.env
  echo "export ZMQ=1" >> $ROOT/.env
  echo "export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES" >> $ROOT/.env
fi

poetry self add poetry-dotenv-plugin@^0.1.0

echo "pip packages install..."
poetry install --no-cache --no-root
pyenv rehash

[ -n "$POETRY_VIRTUALENVS_CREATE" ] && RUN="" || RUN="poetry run"

if [ "$(uname)" != "Darwin" ] && [ -e "$ROOT/.git" ]; then
  echo "pre-commit hooks install..."
  $RUN pre-commit install
  $RUN git submodule foreach pre-commit install
fi
