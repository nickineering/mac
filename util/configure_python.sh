#!/usr/local/bin/bash

# Configure pyenv and install the latest Python version and set the global to that
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
MATCHING_PY=$(pyenv install --list | grep --extended-regexp "^\s*[0-9][0-9.]*[0-9]\s*$")
LATEST_PY=$(echo "$MATCHING_PY" | tail -1 | xargs)
# Must check if we already have the latest to prevent pyenv error
HAS_LATEST=$(pyenv versions | grep "$LATEST_PY")
if [ ! "$HAS_LATEST" ]; then
    pyenv install "$LATEST_PY"
fi
pyenv global "$LATEST_PY"
pyenv shell "$LATEST_PY"
pip install --upgrade pip

# Delete any existing pip packages
FROZEN_PACKAGES=$(pip freeze)
if [ "$FROZEN_PACKAGES" ]; then
    echo "$FROZEN_PACKAGES" | xargs pip uninstall -y
fi

# Install shell completions for ruff - requires code in .zshrc
ruff generate-shell-completion zsh >~/.zfunc/_ruff
