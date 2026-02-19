alias env_i='$EDITOR "$DOTFILES_INCLUDES"/env_interactive.sh'

export FZF_DEFAULT_OPTS
FZF_DEFAULT_OPTS='--cycle --reverse'
# https://github.com/junegunn/fzf#respecting-gitignore
export FZF_DEFAULT_COMMAND='fd --type f --follow --hidden' # Ignore list is in ~/.ignore
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
