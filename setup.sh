#!/usr/bin/env bash
#install brew
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

#install nvm
#curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

# Install some other useful utilities like `sponge`.
brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed --with-default-names
# Install a modern version of Bash.
brew install bash
brew install bash-completion2
brew install bash-git-prompt

# Switch to using brew-installed bash as default shell
if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells;
  chsh -s "${BREW_PREFIX}/bin/bash";
fi;

# Install `wget` with IRI support.
brew install wget
brew install htop

# Install GnuPG to enable PGP-signing commits.
brew install gnupg
brew install neofetch git jq kubernetes-cli k9s tmux fzf
brew tap ankitpokhrel/jira-cli
brew install jira-cli
# add neovim and vim-plug
brew install neovim --HEAD
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
pip3 install --user --upgrade neovim-remote

#install sdkman
curl -s "https://get.sdkman.io" | bash

#install sourcetree
brew install --cask sourcetree

rm -rf ~/.aliases
rm -rf ~/.bash_profile
rm -rf ~/.exports
rm -rf ~/.gitconfig
rm -rf ~/.hushlogin
rm -rf ~/.vimrc
rm -rf ~/.vim
rm -rf ~/tmux.conf

ln -s ~/dotfiles/.aliases ~/.aliases
ln -s ~/dotfiles/.bash_profile ~/.bash_profile
ln -s ~/dotfiles/.bash_profile ~/.bashrc
ln -s ~/dotfiles/.exports ~/.exports
ln -s ~/dotfiles/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/.hushlogin ~/.hushlogin
ln -s ~/dotfiles/.vimrc ~/.vimrc
ln -s ~/dotfiles/.vimrc ~/.config/nvim/init.vim
ln -s ~/dotfiles/.vim ~/.vim
ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
