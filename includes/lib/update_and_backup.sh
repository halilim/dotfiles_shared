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

function update_notify_chrome() {
  local chrome_backup_dir=$DOTFILES_CUSTOM/backup/chrome
  echo "$chrome_backup_dir" | $CLIP
  osascript_dialog "$(cat <<SH
$chrome_backup_dir is copied to clipboard. In Chrome:
1. Bookmark Manager (⌥⌘B) > ⋮ > Export bookmarks > Go to dir (⇧⌘G) > ⌘V
2. Dark Reader > More > All settings > Advanced > Export Settings
3. uBlock Origin > Backup up to file
4. User JavaScript and CSS > Settings > Download JSON & chrome_user_js_css_prettier
SH
)"
}

function update_open_tabs() {
  iterm_tab "$DOTFILES_SHARED" '# git add/commit/push'
  iterm_tab "$DOTFILES_CUSTOM" '# git add/commit/push'
}

function update_bat_syntaxes() {
  local bat_syntax_dir
  bat_syntax_dir="$(bat --config-dir)/syntaxes"

  git_clone_or_pull https://github.com/fnando/sublime-procfile.git "$bat_syntax_dir/procfile"

  $BAT_CMD cache --build
}
