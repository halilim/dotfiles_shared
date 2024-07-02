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

function update_iterm2_color_schemes() {
  if [[ -d "$ITERM2_COLOR_SCHEMES" ]]; then
    git --git-dir="$ITERM2_COLOR_SCHEMES"/.git pull --prune
  else
    mkdir -p "$(dirname "$ITERM2_COLOR_SCHEMES")"
    git clone https://github.com/mbadolato/iTerm2-Color-Schemes.git "$ITERM2_COLOR_SCHEMES"
  fi

  "$ITERM2_COLOR_SCHEMES"/tools/import-scheme.sh "$ITERM2_COLOR_SCHEMES"/schemes/*
}
