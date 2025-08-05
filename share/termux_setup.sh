#!/bin/sh

pkg install \
  bat \
  curl \
  dnsutils \
  eza \
  fd \
  fzf \
  git-delta \
  git \
  jq \
  nodejs-lts \
  python \
  qemu-user-aarch64 \
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
pip install pre-commit

# https://github.com/shellspec/shellspec?tab=readme-ov-file#automatic-installation-
curl -fsSL https://git.io/shellspec | sh -s -- --yes
