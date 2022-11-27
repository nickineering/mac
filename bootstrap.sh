#!/bin/bash
# Run this script to setup a new Mac
# ! It is not meant to be run on Macs that have already been setup!

# Print optional str $2 as bold green text
# Print str $1 on new line as normal green text
# Finally print time
print_green () {
    local GREEN='\033[0;32m'
    local BOLD_GREEN='\033[1;32m'
    local NO_COLOR='\033[0m'
    if (( $# >= 2 ))
    then
        local now
        now=$(date)
        printf "Time: %s" "$now"
        echo -e "\n${BOLD_GREEN}$2${NO_COLOR}"
    fi
    echo -e "${GREEN}$1${NO_COLOR}"
}

print_green "Please leave everything closed and wait for your Mac to be configured. \
This will take a while." "AUTOMATICALLY CONFIGURING MAC"

# Abort on error
set -e

# Print commands that are run as they are run
set -v

# Make a projects directory and clone the repo into it
mkdir -p ~/projects
cd ~/projects
brew install git # Use Homebrew so that updates are easy
git clone https://github.com/nferrara100/mac.git
MAC=~/projects/mac
cd $MAC # Enter newly cloned repo
DOTFILES=$MAC/linked

print_green "Cloned repo into projects directory"

# Link custom settings to that they are updated automatically when changes are pulled
ln -s $DOTFILES/.bash_profile ~/
ln -s $DOTFILES/.profile.sh ~/
cp copied/.env.sh ~/
cp copied/.gitconfig ~/
ln -s $DOTFILES/.vimrc ~/
ln -s $DOTFILES/.tmux.conf ~/

print_green "Copied required files"

# Install Homebrew, a Mac package manager
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Homebrew formulas
brew install \
awscli \  # Amazon Web Services CLI
bash \  # Mac comes with Bash 3.2, but we want the latest
bash-completion \  # Autocomplete for Git
chroma \  # Syntax highlighting utility. Required by ZSH-Colorize
deno \  # TypeScript native Node alternative written in Rust
fig \  # IDE style terminal autocompletion
gh \  # Github CLI
git-lfs \  # Better handling of large files by Git
jupyterlab \  # Interactive code editing notebook
mas \  # Install Mac App Store apps
nvm \  # local JavaScript runtime
postgresql \  # Database for local development
pyenv-virtualenvwrapper \  # The easiest way to manage Python environments
rust \  # Rust programming language
shellcheck \  # Linting for shell scripts
thefuck \  # Type "fuck" after misspelling terminal commands to autocorrect
tmux \  # Terminal multitasking
watchman \
zsh  # Use the most up to date version of Zsh, the default shell

# Get rid of default Zsh config and replace with custom
rm -f ~/.zshrc
ln -s $DOTFILES/.zshrc ~/
print_green "Using custom .zshrc settings"

brew tap homebrew/cask-versions  # Required to install dev edition of Firefox
brew install --cask firefox-developer-edition  # Web browser with added dev tools

# Install Homebrew casks
brew install --cask \
1password \  # Password manager
1password-cli \  # Use password manager in terminal
boop \  # Scratchpad for developers with text wrangling tools
cheatsheet \  # Easily see keyboard shortcuts for the current app
docker \  # Code containerisation
google-chrome \  # Web browser
gpg-suite \  # GPG key generator
iterm2 \  # Terminal emulator
kindle \  # Read Kindle books on desktop
microsoft-edge \  # Major browser
nordvpn \  # Paid VPN for privacy and security
openinterminal \  # Open any folder in the terminal or an editor
paragon-ntfs \  # Use NTFS hard drives - cross platform and journaled
postgres \  # Local database
postman \  # API builder and debugger
raycast \  # Extendable app launcher and clipboard history
shottr \  # Screenshots and on screen OCR
signal \  # Secure messaging
skype \  # Video calling
spotify \  # Music streaming
the-unarchiver \  # File compression utility
tiles \  # Windows style windows that snap into place
visual-studio-code \  # Graphical code editor
vlc \  # Multimedia viewer
whatsapp \  # Secure messaging
zoom  # Video calling

# ColorSlurp color picker - get any color on screen
mas install 1287239339

print_green "Completed main app installs"

# Install Pyenv to run multiple versions of python at the same time
brew install pyenv
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
pygments  # Dependency of Zsh colorize

print_green "Completed Python installs"

# Install VSCode extensions. View current with `code --list-extensions`
vscode_extensions=(
    aaron-bond.better-comments
    adpyke.codesnap
    batisteo.vscode-django
    bungcip.better-toml
    christian-kohler.path-intellisense
    davidanson.vscode-markdownlint
    denoland.vscode-deno
    docsmsft.docs-markdown
    eamodio.gitlens
    esbenp.prettier-vscode
    formulahendry.auto-rename-tag
    GitHub.vscode-pull-request-github
    hbenl.vscode-test-explorer
    littlefoxteam.vscode-python-test-adapter
    markis.code-coverage
    ms-python.python
    ms-toolsai.jupyter
    ms-toolsai.jupyter-keymap
    ms-toolsai.jupyter-renderers
    ms-vscode-remote.remote-containers
    ms-vscode.makefile-tools
    ms-vscode.test-adapter-converter
    ms-vsliveshare.vsliveshare
    redhat.vscode-yaml
    rust-lang.rust-analyzer
    stackbreak.comment-divider
    streetsidesoftware.code-spell-checker
    timonwong.shellcheck
    ue.alphabetical-sorter
    visualstudioexptteam.intellicode-api-usage-examples
    visualstudioexptteam.vscodeintellicode
    withfig.fig
)

for extension in "${vscode_extensions[@]}"; do
    code --install-extension "$extension"
done

# Add custom VSCode settings
ln -s $DOTFILES/settings.json ~/Library/Application\ Support/Code/User/
print_green "Completed VSCode installs"

# Install Zsh plugin manager
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Adding custom Zsh plugin for syntax highlighting
mkdir -p ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Autosuggestions when typing in Zsh. Right arrow to autocomplete.
git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:=~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions

# Poetry package manager for Python
brew install poetry
mkdir -p "$ZSH"/plugins/poetry
poetry completions zsh > "$ZSH"/plugins/poetry/_poetry

# Setup Node Version Manager (NVM) for local JavaScript
mkdir -p ~/.nvm
# shellcheck disable=SC1090
source ~/.zshrc
nvm install --lts

# Install JavaScript globals
npm install -g renovate  # Dependency upgrades

print_green "Completed installs. Now configuring settings..."

# Install custom Firefox settings
FIREFOX_FOLDER="$HOME/Library/Application Support/Firefox/Profiles"
FIREFOX_PROFILE=$(find "$FIREFOX_FOLDER" -name '*.dev-edition-default')
if [ -z "$FIREFOX_PROFILE" ]
then
    print_green "Could not find Firefox profile folder. Skipping Firefox settings..."
else
    ln -s $DOTFILES/user.js "$FIREFOX_PROFILE"
fi

# Disable screensaver
defaults -currentHost write com.apple.screensaver idleTime 0

# Hide the spotlight icon in the menu bar
defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1

# Show keyboard layout selection on login screen
defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool TRUE

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Dock defaults require subsequent `killall Dock`

# Place the Dock on the left of the screen
defaults write com.apple.dock "orientation" -string "left"

# Autohide the Dock
defaults write com.apple.dock autohide -bool true

# Unhide the Dock instantly. To undo set back to 0.5
defaults write com.apple.dock autohide-delay -float 0

# Open files by droping them on an icon in the Dock
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Remove all apps kept in Dock by default
defaults write com.apple.dock persistent-apps -array

# Don't show recent apps not presently open in the dock
defaults write com.apple.dock show-recents -bool FALSE

# Hidden apps are grayed out in Dock so they are obvious
defaults write com.apple.Dock showhidden -bool TRUE

# Clear bottom left hotcorner where create note is enabled by default
defaults write com.apple.dock wvous-br-corner -int 0

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Show the home folder instead of recents when opening a new Finder window
defaults write com.apple.finder NewWindowTarget -string "PfHm"

# Allow text selection in quick look
defaults write com.apple.finder QLEnableTextSelection -bool true

# Show path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true

# Press fn key to show emoji picker
defaults write com.apple.HIToolbox AppleFnUsageType -int 2

# Make iTerm open new tabs by default
defaults write com.googlecode.iterm2 OpenFileInNewWindows -bool false

# Use keyboard navigation
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

add_to_dock () {
    # Add $1 to the Mac dock
    # $1 == the string name of an app without the file extension
    # $2 == "System" if an Apple app; unset otherwise

    local location="/Applications/"
    # If it's a system app use a different location
    if [ -n "$2" ]
    then
        location="/System/Applications/"
    fi
    defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>'$location"$1"'.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
}

# Add the following applications to the Mac dock
add_to_dock "1Password"
add_to_dock "Boop"
add_to_dock "Firefox Developer Edition"
add_to_dock "Google Chrome"
add_to_dock "iTerm"
add_to_dock "Notes" "System"
add_to_dock "Photo Booth" "System"
add_to_dock "Reminders" "System"
add_to_dock "Spotify"
add_to_dock "Utilities/Activity Monitor" "System"
add_to_dock "Visual Studio Code"
# Required to make changes to the dock take effect
killall Dock

# Add directories to Finder favorites
brew install --cask mysides
mysides add "Macintosh HD" file:///
mysides add "$USER" file:///Users/"$USER"/
mysides add Projects file:///Users/"$USER"/projects/
brew remove mysides

print_green "Please follow the manual instructions in the readme and then reboot your \
computer." "AUTOMATED CONFIGURATION COMPLETE"
