alias omzrc='$EDITOR "$DOTFILES_INCLUDES"/omz.zsh' # cSpell:ignore libm

omz_path=~/.oh-my-zsh

# TODO: Tab completions still eat lines...
#   [x] Remove heroku plugin
#   [x] Remove git* plugins
#   [+] Remove fzf-tab
#   [+] Remove p10k (hm... fzf-tab is probably more important than p10k)
#   [ ] Replace with simple prompt + REPORTTIME=... instead?

# shellcheck source=/dev/null
# To customize prompt, run `p10k configure` or edit .p10k*.zsh.
. "$DOTFILES_INCLUDES"/.p10k.zsh

alias p10kc='$EDITOR "$DOTFILES_INCLUDES"/.p10k.zsh'

export ZSH_THEME=powerlevel10k/powerlevel10k

export DISABLE_AUTO_UPDATE="true" # Handled by .functions#update_and_backup

# fzf-tab needs to be the last https://github.com/Aloxaf/fzf-tab#compatibility-with-other-plugins
OMZ_PLUGINS+=(fzf-tab)
# shellcheck disable=SC2034
plugins=("${OMZ_PLUGINS[@]}")

# https://github.com/zsh-users/zsh-completions/issues/603
# $ZSH_CUSTOM doesn't work here, since it's not defined yet
fpath+=("$omz_path"/custom/plugins/zsh-completions/src)

# shellcheck disable=SC1091
source "$omz_path"/oh-my-zsh.sh

unset omz_path

# `cd -1` from .oh-my-zsh/lib/directories.zsh messes up with ENV_VAR=1 :)
unalias 1 2>/dev/null || true

# Yank to the system clipboard
# https://github.com/jeffreytse/zsh-vi-mode/issues/19#issuecomment-1009256071
# cSpell:ignore CUTBUFFER
function zvm_vi_yank() {
	zvm_yank
	printf '%s' "$CUTBUFFER" | pbcopy
	zvm_exit_visual_mode
}

function omz_install_custom_plugins() {
  (
    cd "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins || return
    git clone https://github.com/Aloxaf/fzf-tab
    git clone https://github.com/jeffreytse/zsh-vi-mode
    git clone https://github.com/lincheney/fzf-tab-completion
    git clone https://github.com/lukechilds/zsh-nvm
    git clone https://github.com/zsh-users/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-completions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting
  )
}

function omz_update_custom() {
  (
    cd "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}" || return
    for_each_dir 'for_each_dir "git pull --prune"'
  )
}
