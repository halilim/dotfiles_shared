#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

pkg update
pkg upgrade -y

pkg install -y \
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

pip install pre-commit

# https://wiki.termux.com/wiki/Termux-setup-storage
termux-setup-storage

read -r -p 'SSH key: create new (n) or use existing (e)? ' 'REPLY'
if [[ $REPLY =~ ^[Ee]$ ]]; then
  read -r -p 'Press any key to continue after saving the SSH key (public and private)...'
elif [[ $REPLY =~ ^[Nn]$ ]]; then
  ssh-keygen -t ed25519 -C 't.halil.im'
fi

# shellcheck disable=SC1090
set +e && . ~/../usr/libexec/source-ssh-agent.sh && set -e # termux_prepare_ssh

chsh -s zsh

if [[ $SHELL != */zsh ]]; then
  zsh
fi

if [[ ! -d ~/.oh-my-zsh ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

dotfiles_dir=~/dotfiles
mkdir -p $dotfiles_dir

shared_dir=$dotfiles_dir/shared
if [[ ! -d $shared_dir ]]; then
  git clone --recurse-submodules git@github.com:halilim/dotfiles_shared.git $shared_dir
fi

custom_dir=$dotfiles_dir/custom
if [[ ! -d $custom_dir ]]; then
  # shellcheck disable=SC2162
  read 'REPLY?Install personal dotfiles? '
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    git clone --recurse-submodules git@github.com:halilim/dotfiles_personal.git $custom_dir
  fi
fi

dotfiles/shared/setup

notes_dir=~/storage/shared/notes
if [[ ! -d $notes_dir ]]; then
  # shellcheck disable=SC2162
  read 'REPLY?Install notes? '
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    git clone --recurse-submodules git@github.com:halilim/notes.git $notes_dir
  fi
fi

# https://github.com/shellspec/shellspec?tab=readme-ov-file#automatic-installation-
curl -fsSL https://git.io/shellspec | sh -s -- --yes
