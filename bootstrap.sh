#!/bin/bash
# * Bash 3.2 (2007)

# Run this script to setup a new Mac
# ! It is not meant to be run on Macs that have already been setup!

# Abort on error
set -e

# Print commands that are run as they are run
set -v

# Start running the print utility first so we can update the user on progress.
# We must save the file first because we are on Bash 3.2
curl -s https://raw.githubusercontent.com/nferrara100/mac/master/util/print.sh >/tmp/print.sh
# shellcheck source=util/print.sh
source /tmp/print.sh

print_green "Please leave everything closed and wait for your Mac to be configured. \
This will take a while." "AUTOMATICALLY CONFIGURING MAC"

# Install Homebrew, a Mac package manager
if command -v brew; then
	brew upgrade
	print_green "Upgraded Homebrew packages"
else
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	print_green "Installed Homebrew"
fi

# Make a projects directory and clone the repo into it
mkdir -p ~/projects
export MAC=~/projects/mac
export DOTFILES=$MAC/linked
brew install git # Use Homebrew so that updates are easy
if [ -d "$MAC" ]; then
	cd $MAC
	git pull
	print_green "Pulled latest commits from repo"
else
	git clone https://github.com/nferrara100/mac.git
	cd $MAC # Enter newly cloned repo
	print_green "Cloned repo into projects directory"
fi

# MacOS comes with Bash 3.2, but we want the latest. Download the latest Bash and then
# continue using it.
brew install bash
source util/setup.sh
