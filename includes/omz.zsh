alias omzrc='$EDITOR "$DOTFILES_INCLUDES"/omz.zsh' # cSpell:ignore omzrc

omz_path=~/.oh-my-zsh

# Handled by .functions#update_and_backup
zstyle ':omz:update' mode disabled

# Using `lsd` now. `ls` is occasionally used as a scripting tool.
export DISABLE_LS_COLORS='true'

# fzf-tab needs to be the last https://github.com/Aloxaf/fzf-tab#compatibility-with-other-plugins
OMZ_PLUGINS+=(fzf-tab)
# shellcheck disable=SC2034
plugins=("${OMZ_PLUGINS[@]}")

# https://github.com/zsh-users/zsh-completions/issues/603
# $ZSH_CUSTOM doesn't work here, since it's not defined yet
fpath+=("$omz_path"/custom/plugins/zsh-completions/src)

# https://github.com/jeffreytse/zsh-vi-mode?tab=readme-ov-file#system-clipboard
export ZVM_SYSTEM_CLIPBOARD_ENABLED=true

# shellcheck disable=SC1091
source "$omz_path"/oh-my-zsh.sh

unset omz_path

# `cd -1` from .oh-my-zsh/lib/directories.zsh
# Messes up with typing, e.g., VAR=1 :)
unalias 1

# Why mkdir? Because this might need to run before OMZ installation itself:
# 1. dotfiles, 2. OMZ, 3. this => OMZ complains for missing plugins and theme
# 1. OMZ, 2. dotfiles, 3. this => OMZ complains for missing plugins and theme
# 1. this => Impossible without installing dotfiles first
# 1. dotfiles, 2. this, 3. OMZ => ✅
function omz_install_custom() {
  (
    local zsh_custom=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

    local zsh_custom_plugins="$zsh_custom"/plugins
    mkdir -p "$zsh_custom_plugins" || return
    cd "$zsh_custom_plugins" || return

    git clone https://github.com/Aloxaf/fzf-tab
    git clone https://github.com/jeffreytse/zsh-vi-mode
    git clone https://github.com/lincheney/fzf-tab-completion
    git clone https://github.com/lukechilds/zsh-nvm
    git clone https://github.com/wfxr/forgit.git
    git clone https://github.com/zsh-users/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-completions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting
  )
}

function omz_update_custom() {
  (
    cd "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}" || return

    local dry_run_str=''
    if [[ ${DRY_RUN:-} ]]; then
      dry_run_str='DRY_RUN=1'
    fi
    DRY_RUN='' CMD_TO_SHOW="git_pull_all\n" \
      for_each_dir $dry_run_str CMD_TO_SHOW='' git_pull_all
  )
}
