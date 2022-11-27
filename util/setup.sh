#!/usr/local/bin/bash

# This script should only be run via bootstrap.sh. This will fail if it isn't.
cd "$MAC"/util || exit 1

source print.sh

# Move all files that will be destroyed to the backups folder so they are not overwritten
source backup_or_delete.sh
while IFS= read -r file; do
    backup_or_delete ~/"$file"
done < "$MAC"/state/linked_files.txt
backup_or_delete "$HOME/Library/Application Support/Code/User/settings.json"
print_green "Deleted existing linked files so they can be freshly created"

# Install Homebrew packages
while IFS= read -r package; do
    brew install "$package"
done < "$MAC"/state/brew_packages.txt
print_green "Installed Homebrew packages"

brew tap homebrew/cask-versions  # Supplies firefox-developer-edition

# Install Homebrew casks
while IFS= read -r cask; do
    brew install --cask "$cask"
done < "$MAC"/state/brew_casks.txt
print_green "Installed Homebrew casks"

# ColorSlurp color picker - get any color on screen
mas install 1287239339
print_green "Installed Mac App Store apps"

# Install VSCode extensions. View current with `code --list-extensions`
while IFS= read -r extension; do
    code --install-extension "$extension"
done < "$MAC"/state/vscode_extensions.txt
print_green "Installed VSCode extensions"

# Get rid of default Zsh config so it can be replaced with the custom config
rm -f ~/.zshrc

# Copy templates for customization files if they do not already exist
while IFS= read -r file; do
    if [ -e ~/"$2" ]
    then
        print_green "A ~/$file file already exists. If you'd like to replace it please \
do so manually."
    else
        cp "$MAC/copied/$file" ~/
    fi
done < "$MAC"/state/copied_files.txt

# Link custom settings to that they are updated automatically when changes are pulled
while IFS= read -r file; do
    ln -s "$DOTFILES/$file" ~/
done < "$MAC"/state/linked_files.txt
ln -s "$DOTFILES"/settings.json ~/Library/Application\ Support/Code/User/

# Install custom Firefox settings
FIREFOX_FOLDER="$HOME/Library/Application Support/Firefox/Profiles"
FIREFOX_PROFILE=$(find "$FIREFOX_FOLDER" -name '*.dev-edition-default')
if [ -z "$FIREFOX_PROFILE" ]
then
    print_green "Could not find Firefox profile folder. Skipping Firefox settings..."
else
    backup_or_delete "$FIREFOX_PROFILE"/user.js
    ln -s "$DOTFILES"/user.js "$FIREFOX_PROFILE"
fi

print_green "Copied and linked required files"

# Pyenv configuration
# shellcheck disable=SC1090
source ~/.bash_profile
LATEST_PYTHON=$(pyenv install --list | grep --extended-regexp "^\s*[0-9][0-9.]*[0-9]\s*$" | tail -1)
pyenv install "$LATEST_PYTHON"
pyenv global "$LATEST_PYTHON"
pip install --upgrade pip

pip install \
bandit \  # Python code security
beautysh \  # Bash code formatting
black \  # Python code formatting
flake8 \  # Python linting
isort \  # Sort Python imports
pre-commit \  # Run multilingual commands before git commits

print_green "Completed Python installs"

# Install Zsh plugin manager
if command -v omz; then
    print_green "Oh My Zsh is already installed. Checking for updates..."
    omz update
else
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

ZSH_PLUGINS=~/.oh-my-zsh/custom/plugins

# Adding custom Zsh plugin for syntax highlighting
if [ -d $ZSH_PLUGINS/zsh-syntax-highlighting ]; then
    print_green "Zsh syntax highlighting already installed. Checking for updates..."
    git -C $ZSH_PLUGINS/zsh-syntax-highlighting pull
else
    git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_PLUGINS/zsh-syntax-highlighting
fi

# Autosuggestions when typing in Zsh. Right arrow to autocomplete.
if [ -d $ZSH_PLUGINS/zsh-autosuggestions ]; then
    print_green "Zsh autosuggestions already installed. Checking for updates..."
    git -C $ZSH_PLUGINS/zsh-autosuggestions pull
else
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_PLUGINS/zsh-autosuggestions
fi
print_green "Finished Zsh configuration"

# Poetry autocompletion
mkdir -p "$ZSH"/plugins/poetry
poetry completions zsh > "$ZSH"/plugins/poetry/_poetry

# Setup Node Version Manager (NVM) for local JavaScript
mkdir -p ~/.nvm
# shellcheck disable=SC1090
nvm install --lts

print_green "Completed installs. Now configuring settings..."

# Configures the operating system on import
source configure_macos.sh

print_green "Please follow the instructions in $MAC/MANUAL_STEPS.md and then reboot \
your computer." "AUTOMATED CONFIGURATION COMPLETE"
