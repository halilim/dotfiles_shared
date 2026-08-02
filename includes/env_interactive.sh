alias env_i='$EDITOR "$DOTFILES_INCLUDES"/env_interactive.sh'

export FZF_DEFAULT_OPTS='--cycle --reverse'
# https://github.com/junegunn/fzf#respecting-gitignore
export FZF_DEFAULT_COMMAND='fd --type f --follow --hidden' # Ignore list is in ~/.ignore
# Apparently, shared storage can't use ~/.ignore https://wiki.termux.com/wiki/Termux-setup-storage
if [[ -v TERMUX_VERSION ]]; then
  FZF_DEFAULT_COMMAND+=' --exclude .git'
fi
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
