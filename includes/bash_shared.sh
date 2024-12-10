#!/bin/bash

shopt -s globstar nocaseglob nullglob
if [[ $- = *i* ]]; then
  shopt -s extdebug
fi

# shellcheck source=/dev/null
. "$DOTFILES_INCLUDES"/env.sh

# shellcheck source=/dev/null
. "$DOTFILES_SHARED"/includes.sh

# shellcheck source=/dev/null
. "$DOTFILES_INCLUDES"/aliases.sh
