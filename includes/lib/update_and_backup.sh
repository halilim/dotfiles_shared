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

    local submodules=(
      'link/home/.config/bat/syntaxes/st2-zonefile|master'
      'link/home/.config/bat/syntaxes/sublime-procfile|main'
    )

    local submodule submodule_path branch
    for submodule in "${submodules[@]}"; do
      submodule_path=$(cut -d '|' -f 1 <<< "$submodule")
      branch=$(cut -d '|' -f 2 <<< "$submodule")
      git submodule set-branch -b "$branch" "$submodule_path"
      git -C "$submodule_path" checkout --quiet "$branch"
    done

    git submodule foreach --recursive git pull --prune --quiet
  )

  bat_rebuild_syntaxes
}

function update_completions() {
  if command -v docker > /dev/null 2>&1; then
    # shellcheck disable=SC2154
    docker completion zsh > "${fpath[1]}/_docker"
  fi
}

function update_vim() {
  $VIM_PATH +'PlugUpgrade | PlugUpdate'
}
