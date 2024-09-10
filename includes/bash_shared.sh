#!/bin/bash

shopt -s extdebug globstar nocaseglob nullglob

# shellcheck source=/dev/null
. "$DOTFILES_INCLUDES"/env.sh

# shellcheck source=/dev/null
. "$DOTFILES_SHARED"/includes.sh

# shellcheck source=/dev/null
. "$DOTFILES_INCLUDES"/aliases.sh
