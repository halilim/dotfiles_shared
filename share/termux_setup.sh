#!/bin/sh

pkg install \
  bat \
  curl \
  eza \
  fd \
  fzf \
  git-delta \
  git \
  nodejs-lts \
  python \
  ripgrep \
  speedtest-go \
  traceroute \
  vim \
  whois \
  zsh

chsh -s zsh
zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

mkdir dotfiles
git clone --recurse-submodules https://github.com/halilim/dotfiles_shared.git dotfiles/shared

# shellcheck disable=SC2162
read 'REPLY?Install personal dotfiles? '
if [[ $REPLY =~ ^[Yy]$ ]]; then
  git clone --recurse-submodules https://github.com/halilim/dotfiles_personal.git dotfiles/custom
fi

dotfiles/shared/setup
omz_install_custom
