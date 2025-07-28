alias env_i='$EDITOR "$DOTFILES_INCLUDES"/env_interactive.sh'

if [[ -n "${ZSH_VERSION-}" && ${HOMEBREW_PREFIX:-} ]]; then
  # https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
  FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions:${FPATH}"
fi

function color_mode() {
  if [[ $OSTYPE == darwin* ]]; then
    [[ $(defaults read -g AppleInterfaceStyle 2>&1) == 'Dark' ]] && echo dark || echo light
  elif [[ $OSTYPE == linux* ]]; then
    # TODO: Implement
    :
  fi
}

export COLOR_MODE
COLOR_MODE=${COLOR_MODE:-$(color_mode)}

export FZF_DEFAULT_OPTS
FZF_DEFAULT_OPTS="--cycle --reverse --color=$(color_mode)"
# https://github.com/junegunn/fzf#respecting-gitignore
export FZF_DEFAULT_COMMAND='fd --type f --follow --hidden' # Ignore list is in ~/.ignore
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
