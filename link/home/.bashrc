alias bashrc='$EDITOR ~/.bashrc'

# shellcheck disable=SC1091
. "$HOME"/.dotfiles_bootstrap.sh
# shellcheck disable=SC1091
. "$DOTFILES_INCLUDES"/bash_shared.sh
# shellcheck disable=SC1091
. "$DOTFILES_INCLUDES"/env_interactive.sh

if [[ ${HOMEBREW_PREFIX:-} ]]; then
  # shellcheck source=/dev/null
  . "$HOMEBREW_PREFIX"/etc/bash_completion.d/git-prompt*
fi

alias DR='DRY_RUN=1'

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# cSpell:ignore apaache
# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
shopt -s cdspell

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

export PS1='\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\[\033[32m\]$(__git_ps1)\n\$ '

source_custom .bashrc

# shellcheck disable=SC1091
. "$DOTFILES_SHARED"/post_init_hooks.sh
