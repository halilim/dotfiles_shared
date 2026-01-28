export ZPROFILE_LOADED=1

alias zprofile='$EDITOR ~/.zprofile'

export BUILTIN_URL='https://zsh.sourceforge.io/Doc/Release/Shell-Builtin-Commands.html'
export ARRAY_START=1

setopt NULL_GLOB

if [[ -v TERMUX_VERSION ]]; then
  # https://github.com/jeffreytse/zsh-vi-mode/issues/159#issuecomment-1871335866
  setopt re_match_pcre
fi

# shellcheck disable=SC1091
. "$HOME"/.dotfiles_bootstrap.sh

# shellcheck disable=SC1091
. "$DOTFILES_INCLUDES"/env.sh

# shellcheck disable=SC1091
. "$DOTFILES_SHARED"/includes.sh

# Make Homebrew > mise > LSPs, etc. available to Vim
if [[ $- != *i* ]]; then
  brew_activate
  mise_activate
fi
