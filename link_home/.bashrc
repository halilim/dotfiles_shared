export BUILTIN_URL='https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html'

# shellcheck disable=SC2139
alias bashrc="$EDITOR $0"

alias read_array='read -ra'

# shellcheck disable=SC1091
. "$HOME"/.dotfiles_paths.sh
# shellcheck disable=SC1091
. "$DOTFILES"/shared/includes/env.sh
# shellcheck disable=SC1091
. "$DOTFILES_INCLUDES"/env_interactive.sh

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# Use case-insensitive filename globbing
shopt -s nocaseglob

# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
shopt -s cdspell

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# shellcheck source=/dev/null
. "$DOTFILES_SHARED"/includes.sh

# shellcheck source=/dev/null
. "$HOMEBREW_PREFIX"/etc/bash_completion.d/git-prompt.sh

export PS1='\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\[\033[32m\]$(__git_ps1)\n\$ '

source_custom .bashrc
