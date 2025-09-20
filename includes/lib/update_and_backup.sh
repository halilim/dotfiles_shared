function chrome_user_js_css_prettier() {
  $JS_PMX --yes prettier -w "$DOTFILES_CUSTOM"/backup/chrome/exts/user-js-css.json
}

function update_and_backup() {
  (
    cd "$HOME" || return 1

    local cmd
    for cmd in "${UPDATE_BACKUP_CMDS[@]}"; do
      echo_eval "$cmd"
      printf '\n'
    done
  )
}

function update_chrome_notes() {
  FORCE_COLOR=1 echo "Chrome backup directory: $(color yellow "$DOTFILES_CUSTOM"/backup/chrome)
$(color green '1. Bookmark Manager (⌥⌘B) > ⋮ > Export bookmarks > Go to dir (⇧⌘G) > ⌘V')
$(color green '2. Dark Reader > More > All settings > Advanced > Export Settings')"
}

function update_open_tabs() {
  iterm_tab "$DOTFILES_SHARED" '# git add/commit/push'
  iterm_tab "$DOTFILES_CUSTOM" '# git add/commit/push'
}

function update_bat_syntaxes() {
  (
    cd "$DOTFILES_SHARED" || return
    git submodule foreach --recursive git pull --prune
  )

  bat_rebuild_syntaxes
}

function update_completions() {
  # shellcheck disable=SC2154
  docker completion zsh > "${fpath[1]}/_docker"
}

function update_vim() {
  $VIM_PATH +'PlugUpgrade | PlugUpdate'
}
