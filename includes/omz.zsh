:
# shellcheck disable=SC2139
alias omzrc="$EDITOR $0"

omz_path=~/.oh-my-zsh

# TODO: Tab completions still eat lines...
#   [x] Remove heroku plugin
#   [x] Remove git* plugins
#   [+] Remove fzf-tab
#   [+] Remove p10k (hm... fzf-tab is probably more important than p10k)
#   [ ] Replace with simple prompt + REPORTTIME=... instead?
# shellcheck source=/dev/null
# To customize prompt, run `p10k configure` or edit .p10k*.zsh.
if [[ "$TERM_PROGRAM:l" = vscode* ]]; then
  # Using the lean style because there are spaces between triangles https://github.com/romkatv/powerlevel10k/issues/671
  . "$DOTFILES_INCLUDES"/.p10k.vscode.zsh
else
  . "$DOTFILES_INCLUDES"/.p10k.zsh
fi
# shellcheck disable=SC2139
alias p10kc="$EDITOR $DOTFILES_INCLUDES/.p10k.zsh"
# shellcheck disable=SC2139
alias p10kvc="$EDITOR $DOTFILES_INCLUDES/.p10k.vscode.zsh"
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

function omz_install_custom_plugins() {
  (
    cd "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins || return
    git clone https://github.com/Aloxaf/fzf-tab
    git clone https://github.com/lincheney/fzf-tab-completion
    git clone https://github.com/zsh-users/zsh-completions
    git clone https://github.com/lukechilds/zsh-nvm
    git clone https://github.com/zsh-users/zsh-syntax-highlighting
    git clone https://github.com/jeffreytse/zsh-vi-mode
  )
}
