#!/bin/sh

pkg install \
  bat \
  curl \
  eza \
  fzf \
  git-delta \
  git \
  nodejs-lts \
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
dotfiles/shared/setup
omz_install_custom
