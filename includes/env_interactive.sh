# Interactive mode setup

:
# shellcheck disable=SC2139
alias env_i="$EDITOR $0"

if [ -n "${ZSH_VERSION-}" ]; then
  # https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
  FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions:${FPATH}"
fi

export FZF_DEFAULT_OPTS
FZF_DEFAULT_OPTS="--cycle --reverse --color=$(terminal_color_mode)"
# https://github.com/junegunn/fzf#respecting-gitignore
export FZF_DEFAULT_COMMAND='fd --type f --follow --hidden' # Ignore list is in ~/.ignore
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
