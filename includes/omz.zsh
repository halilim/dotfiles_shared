alias omzrc='$EDITOR "$DOTFILES_INCLUDES"/omz.zsh' # cSpell:ignore omzrc

omz_path=~/.oh-my-zsh

# TODO: Tab completions still eat lines...
#   [x] Remove heroku plugin
#   [x] Remove git* plugins
#   [+] Remove fzf-tab
#   [+] Remove p10k (hm... fzf-tab is probably more important than p10k)
#   [ ] Replace with simple prompt + REPORTTIME=... instead?

# https://github.com/ohmyzsh/ohmyzsh/wiki/themes
export ZSH_THEME
if [[ -v TERMUX_VERSION ]]; then
  # powerlevel10k on Termux: gitstatus (gitstatusd) fails to initialize. It would be too heavy anyway
  ZSH_THEME=sunaku
else
  # shellcheck source=/dev/null
  # To customize prompt, run `p10k configure` or edit .p10k*.zsh.
  . "$DOTFILES_INCLUDES"/.p10k.zsh
  alias p10kc='$EDITOR "$DOTFILES_INCLUDES"/.p10k.zsh'
  ZSH_THEME=powerlevel10k/powerlevel10k
fi

# Handled by .functions#update_and_backup
zstyle ':omz:update' mode disabled

# With eza, ls is used as a scripting tool
export DISABLE_LS_COLORS='true'

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

# `cd -1` from .oh-my-zsh/lib/directories.zsh
# Messes up with typing, e.g., VAR=1 :)
unalias 1

# Yank to the system clipboard
# https://github.com/jeffreytse/zsh-vi-mode/issues/19#issuecomment-1009256071
# cSpell:ignore CUTBUFFER
function zvm_vi_yank() {
	zvm_yank
	printf '%s' "$CUTBUFFER" | pbcopy
	zvm_exit_visual_mode
}

function omz_install_custom() {
  (
    local zsh_custom=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

    cd_or_fail "$zsh_custom"/plugins 'Oh My Zsh custom plugins directory' || return

    git clone https://github.com/Aloxaf/fzf-tab
    git clone https://github.com/jeffreytse/zsh-vi-mode
    git clone https://github.com/lincheney/fzf-tab-completion
    git clone https://github.com/lukechilds/zsh-nvm
    git clone https://github.com/zsh-users/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-completions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting

    if [[ ! -v TERMUX_VERSION ]]; then
      cd_or_fail "$zsh_custom"/themes 'Oh My Zsh custom themes directory' || return
      git clone --depth=1 https://github.com/romkatv/powerlevel10k
    fi
  )
}

function omz_update_custom() {
  (
    cd_or_fail "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}" 'Oh My Zsh custom directory' || return

    for_each_dir 'for_each_dir "git pull --prune"'
  )
}
