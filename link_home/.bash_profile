#!/bin/bash

alias bashprofile='$EDITOR ~/.bash_profile' # cSpell:ignore bashprofile

# shellcheck disable=SC1091
. "$HOME"/.dotfiles_bootstrap.sh

# shellcheck disable=SC1091
. "$DOTFILES_INCLUDES"/bash_shared.sh
