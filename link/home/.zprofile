export ZPROFILE_LOADED=1

alias zprofile='$EDITOR ~/.zprofile'

export BUILTIN_URL='https://zsh.sourceforge.io/Doc/Release/Shell-Builtin-Commands.html'
export ARRAY_START=1

setopt NULL_GLOB

# shellcheck disable=SC1091
. "$HOME"/.dotfiles_bootstrap.sh

# shellcheck disable=SC1091
. "$DOTFILES_INCLUDES"/env.sh

# shellcheck disable=SC2016
UPDATE_BACKUP_CMDS+=(
  '$ZSH/tools/upgrade.sh -v silent' # https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#how-do-i-update-oh-my-zsh
  omz_update_custom
)

# shellcheck disable=SC1091
. "$DOTFILES_SHARED"/includes.sh
