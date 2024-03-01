#!/usr/bin/env bash
set -e

# Assuming the script runs in the root of the checked-out repo
ROOT="$GITHUB_WORKSPACE"
cd $ROOT

# Install and initialize pyenv
if ! command -v "pyenv" > /dev/null 2>&1; then
  echo "Installing pyenv..."
  curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv virtualenv-init -)"
fi

PYENV_PYTHON_VERSION=$(cat .python-version)
if ! pyenv versions | grep -q "$PYENV_PYTHON_VERSION"; then
  echo "Installing Python $PYENV_PYTHON_VERSION ..."
  CONFIGURE_OPTS="--enable-shared" pyenv install -f "$PYENV_PYTHON_VERSION"
fi

# Set the local Python version
pyenv local "$PYENV_PYTHON_VERSION"

# Update pip and install poetry
pip install pip==23.3
pip install poetry==1.6.1

# Configure poetry
poetry config virtualenvs.prefer-active-python true --local
poetry config virtualenvs.in-project true --local
poetry self add poetry-dotenv-plugin@^0.1.0

# Install dependencies
echo "Installing pip packages..."
poetry install --no-cache --no-root

# Rehash pyenv shims after installation
pyenv rehash
