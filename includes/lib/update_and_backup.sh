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
$(color green '2. Dark Reader > More > All settings > Advanced > Export Settings')
$(color green '3. User JavaScript and CSS > Settings > Download JSON & chrome_user_js_css_prettier')"
}

function update_open_tabs() {
  iterm_tab "$DOTFILES_SHARED" '# git add/commit/push'
  iterm_tab "$DOTFILES_CUSTOM" '# git add/commit/push'
}

function update_bat_syntaxes() {
  local bat_syntax_dir
  bat_syntax_dir="$(bat --config-dir)/syntaxes"

  git_clone_or_pull https://github.com/fnando/sublime-procfile.git "$bat_syntax_dir/procfile"

  bat cache --build
}
