alias zprofile='$EDITOR ~/.zprofile'

setopt NULL_GLOB

# shellcheck disable=SC1091
. "$HOME"/.dotfiles_bootstrap.sh

# shellcheck disable=SC1091
. "$DOTFILES_INCLUDES"/env.sh

# shellcheck disable=SC1091
. "$DOTFILES_SHARED"/includes.sh
