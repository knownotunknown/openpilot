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
  # Add pyenv initializer to the shell startup file
  {
    echo 'export PATH="$HOME/.pyenv/bin:$PATH"'
    echo 'eval "$(pyenv init --path)"'
    echo 'eval "$(pyenv virtualenv-init -)"'
  } >> "${RC_FILE}"
fi

# Apply pyenv initializer to current shell session
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
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

# Initialize poetry using its full path. The path might vary based on the installation method and environment.
POETRY_PATH=$(which poetry)
if [ -z "$POETRY_PATH" ]; then
  echo "Poetry was not found in the PATH."
  exit 1
fi

# Configure poetry settings and install plugins using the full path to poetry
$POETRY_PATH config virtualenvs.prefer-active-python true --local
$POETRY_PATH config virtualenvs.in-project true --local
$POETRY_PATH self add poetry-dotenv-plugin@^0.1.0

# Install project dependencies using poetry
$POETRY_PATH install --no-cache --no-root

# Rehash pyenv shims after installation
pyenv rehash
