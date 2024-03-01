#!/usr/bin/env bash
set -e

# Check for virtual environment path argument
if [ -z "$1" ]; then
  echo "Usage: $0 <path-to-virtual-environment>"
  exit 1
fi
VENV_PATH="$1"

# Determine the shell RC file
if [ "$(uname)" == "Darwin" ] && [ "$SHELL" == "/bin/bash" ]; then
  RC_FILE="$HOME/.bash_profile"
elif [ -n "$ZSH_VERSION" ]; then
  RC_FILE="$HOME/.zshrc"
else
  RC_FILE="$HOME/.bashrc"
fi

# Install and initialize pyenv if not already installed
if ! command -v "pyenv" > /dev/null 2>&1; then
  echo "Installing pyenv..."
  curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
  echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> "${RC_FILE}"
  echo 'eval "$(pyenv init --path)"' >> "${RC_FILE}"
  echo 'eval "$(pyenv virtualenv-init -)"' >> "${RC_FILE}"
fi

export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Navigate to the root directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ROOT=$DIR/../
cd $ROOT

# Read the desired Python version and install if not available
PYENV_PYTHON_VERSION=$(cat .python-version)
if ! pyenv versions | grep -q "$PYENV_PYTHON_VERSION"; then
  CONFIGURE_OPTS="--enable-shared" pyenv install -f "$PYENV_PYTHON_VERSION"
fi
pyenv local "$PYENV_PYTHON_VERSION"

# Update pip and install poetry
pip install pip==23.3
pip install poetry==1.6.1

# Configure poetry
poetry config virtualenvs.prefer-active-python true --local
poetry config virtualenvs.in-project true --local
poetry self add poetry-dotenv-plugin@^0.1.0

# Install project dependencies using poetry
poetry install --no-cache --no-root

# Rehash pyenv shims after installation
pyenv rehash

# Deactivate the script environment (if using non-GitHub Actions environments)
# deactivate
