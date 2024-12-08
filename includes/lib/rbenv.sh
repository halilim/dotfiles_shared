UPDATE_BACKUP_CMDS+=(rbenv_update_plugins)

function rbenv_install_plugins() {
  local rbenv_plugins
  rbenv_plugins=$(rbenv root)/plugins
  mkdir -p "$rbenv_plugins"
  cd_or_fail "$rbenv_plugins" 'rbenv plugins directory' || return

  git clone https://github.com/tpope/rbenv-ctags
  rbenv ctags

  git clone https://github.com/rbenv/rbenv-default-gems
}

function rbenv_update_plugins() {
  cd_or_fail "$(rbenv root)"/plugins 'rbenv plugins directory' || return

  for_each_dir "git pull --prune"
}
