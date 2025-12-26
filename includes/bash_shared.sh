#!/bin/bash

export BUILTIN_URL='https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html'
export ARRAY_START=0

shopt -s nocaseglob nullglob
if shopt > /dev/null 2>&1 | grep globstar; then
  shopt -s globstar
fi
if [[ $- = *i* ]]; then
  shopt -s extdebug
fi

# shellcheck source=/dev/null
. "$DOTFILES_INCLUDES"/env.sh

# shellcheck source=/dev/null
. "$DOTFILES_SHARED"/includes.sh

# shellcheck source=/dev/null
. "$DOTFILES_INCLUDES"/aliases.sh

brew_bin=/opt/homebrew/bin/brew
if [[ -e "$brew_bin" ]]; then
  eval "$($brew_bin shellenv)"
fi
unset brew_bin

if command -v mise > /dev/null 2>&1; then
  eval "$(mise activate bash)"
fi
