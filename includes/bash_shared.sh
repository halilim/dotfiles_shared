#!/bin/bash

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
