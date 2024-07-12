#!/bin/bash

:
# cSpell:ignore bashprofile
# shellcheck disable=SC2139
alias bashprofile="$EDITOR $0"

# shellcheck disable=SC1091
. "$HOME"/.dotfiles_paths.sh
# shellcheck disable=SC1091
. "$DOTFILES_INCLUDES"/env.sh

