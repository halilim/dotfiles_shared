alias env_i='$EDITOR "$DOTFILES_INCLUDES"/env_interactive.sh'

if [[ -n "${ZSH_VERSION-}" && ${HOMEBREW_PREFIX:-} ]]; then
  # https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
  FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions:${FPATH}"
fi

export FZF_DEFAULT_OPTS
FZF_DEFAULT_OPTS='--cycle --reverse'
# https://github.com/junegunn/fzf#respecting-gitignore
export FZF_DEFAULT_COMMAND='fd --type f --follow --hidden' # Ignore list is in ~/.ignore
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
