alias envshc='$EDITOR "$DOTFILES_CUSTOM"/includes/env.sh' # cSpell:ignore envshc

export DOCKER_PROVIDER='docker-desktop' # colima | docker-desktop
export GIT_LARGE_REPOS="/code/foo:$HOME/bar/baz" # For periodic cleanup
export GPG_KEY=123ABC # gpg --list-keys > The hex number below "pub"
export JS_UPDATE_GLOBALS_EXCLUDE_PATTERN='@company/large-repo'
export JS_PM=bun # bun|npm
export JS_PMX=bunx # bunx|npx
export PGGSSENCMODE='disable' # https://github.com/ged/ruby-pg/issues/538
export RUBY_CMD_PREFIX='bin/'

# shellcheck disable=SC2016
POST_INIT_HOOKS+=(
  # Set GIT_LARGE_REPOS here if it depends on other env vars, etc.
  # 'export GIT_LARGE_REPOS="$PROJECT_DIR" # For periodic cleanup'
)

DOTFILES_INCLUDE_LIBS+=(
  example_lib
  gpg
  launch_darkly
)

OMZ_PLUGINS+=(
  "$JS_PM"
)

UPDATE_BACKUP_CMDS=(
  # Prepend
  'dotfiles update'
  pre_update_cmd

  "${UPDATE_BACKUP_CMDS[@]}"

  # Append
  gpg_check_key
  update_foo
  'backup bar'
 )
