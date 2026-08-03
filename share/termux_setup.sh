#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

pkg update
pkg upgrade -y

pkg install -y \
  bat \
  curl \
  dnsutils \
  fd \
  fzf \
  git \
  git-delta \
  jq \
  lsd \
  nodejs-lts \
  openssh \
  python \
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

vim -c 'exe "normal iPaste SSH public key here\<Esc>"' ~/.ssh/id_ed25519.pub
vim -c 'exe "normal iPaste SSH private key here and replace spaces with newlines\<Esc>"' ~/.ssh/id_ed25519

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
