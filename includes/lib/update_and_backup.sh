function chrome_user_js_css_prettier() {
  $JS_PMX --yes prettier -w "$DOTFILES_CUSTOM"/backup/chrome/exts/user-js-css.json
}

function update_and_backup() {
  (
    cd "$HOME" || return 1

    local cmd last_ret
    for cmd in "${UPDATE_BACKUP_CMDS[@]}"; do
      echo_eval "_safe_$cmd"
      last_ret=$?
      printf '\n'
    done
    return $last_ret
  )
}

function chrome_backup_notes() {
  # These are mostly manual, and can be backed up less frequently
  local chrome_bookmarks_backup=$CHROME_BACKUP_DIR/bookmarks.html threshold='60 days'
  if [[ -e $chrome_bookmarks_backup ]] && ! last_mod_older_than "$chrome_bookmarks_backup" "$threshold"; then
    color >&2 gray 'Chrome backups are not older than '"$threshold"', skipping... '
    return
  fi
  printf %s "$CHROME_BACKUP_DIR" | "${CLIP[*]}"
  iterm_tab . chrome_backup_notes_msg
}

function chrome_backup_notes_msg() {
  FORCE_COLOR=1 echo "Chrome backup directory: $(color yellow "$CHROME_BACKUP_DIR")
$(color green '1. Bookmark Manager (⌥⌘B) > ⋮ > Export bookmarks > Go to dir (⇧⌘G) > ⌘V')
$(color green '2. Dark Reader > More > All settings > Advanced > Export Settings')
$(color green '3. uBlock Origin Lite > Settings > Back up')
$(color green '4. User JavaScript and CSS > ⬢ > Download JSON')
$(color green '5. $ chrome_user_js_css_prettier')"
}

function update_mise() {
  if ! command -v mise > /dev/null 2>&1; then
    return
  fi

  mise plugin up --quiet
  mise up
}

function update_bat_syntaxes() {
  (
    DRY_RUN='' echo_eval cd "$DOTFILES_SHARED" || return

    local submodules=(
      'link/home/.config/bat/syntaxes/st2-zonefile|master'
      'link/home/.config/bat/syntaxes/sublime-procfile|main'
    )

    local submodule submodule_path branch
    for submodule in "${submodules[@]}"; do
      submodule_path=$(cut -d '|' -f 1 <<< "$submodule")
      branch=$(cut -d '|' -f 2 <<< "$submodule")
      echo_eval git submodule set-branch -b "$branch" "$submodule_path"
      echo_eval git -C "$submodule_path" checkout -q "$branch"
    done

    echo_eval git submodule foreach -q --recursive git pull -q --prune
  )

  bat_rebuild_syntaxes
}

function update_ruby_bundler_and_system() {
  (
    # When mise upgrades Ruby, this tries to update the system Ruby, and fails
    # (mise activation is temporarily disabled?) Trying `cd "$HOME"`
    cd "$HOME" || return

    if command -v ruby > /dev/null 2>&1; then
      echo_eval gem update bundler --quiet
      echo_eval gem update --system --quiet
    fi
  )
}
