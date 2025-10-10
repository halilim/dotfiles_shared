#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

pkg update
pkg upgrade

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
  openssh \
  python \
  qemu-user-aarch64 \
  ripgrep \
  speedtest-go \
  traceroute \
  vim \
  whois \
  zoxide \
  zsh

mkdir -p ~/.ssh
touch ~/.ssh/id_ed25519{,.pub}
chmod 600 ~/.ssh/id_ed25519
vim ~/.ssh/id_ed25519
# shellcheck disable=SC1090
set +e && . ~/../usr/libexec/source-ssh-agent.sh && set -e # termux_prepare_ssh

chsh -s zsh
zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

mkdir dotfiles
git clone --recurse-submodules git@github.com:halilim/dotfiles_shared.git dotfiles/shared

# shellcheck disable=SC2162
read 'REPLY?Install personal dotfiles? '
if [[ $REPLY =~ ^[Yy]$ ]]; then
  git clone --recurse-submodules git@github.com:halilim/dotfiles_personal.git dotfiles/custom
fi

# https://wiki.termux.com/wiki/Termux-setup-storage
termux-setup-storage

# shellcheck disable=SC2162
read 'REPLY?Install notes? '
if [[ $REPLY =~ ^[Yy]$ ]]; then
  git clone --recurse-submodules git@github.com:halilim/notes.git ~/storage/shared/notes
fi

dotfiles/shared/setup
omz_install_custom
pip install pre-commit

# https://github.com/shellspec/shellspec?tab=readme-ov-file#automatic-installation-
curl -fsSL https://git.io/shellspec | sh -s -- --yes
