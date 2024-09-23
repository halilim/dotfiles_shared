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

function open_dotfile_tabs() {
  iterm_tab "$DOTFILES_SHARED" '# git add/commit/push'
  iterm_tab "$DOTFILES_CUSTOM" '# git add/commit/push'
}

function update_bat_syntaxes() {
  local bat_syntax_dir
  bat_syntax_dir="$(bat --config-dir)/syntaxes"

  git_clone_or_pull https://github.com/fnando/sublime-procfile.git "$bat_syntax_dir/procfile"

  bat cache --build
}
