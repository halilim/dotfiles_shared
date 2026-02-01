alias envshc='$EDITOR "$DOTFILES_CUSTOM"/includes/env.sh' # cSpell:ignore envshc

export DOCKER_PROVIDER='docker-desktop' # colima | docker-desktop
export GIT_LARGE_REPOS="/code/foo:$HOME/bar/baz" # For periodic cleanup
export GPG_KEY=123ABC # gpg --list-keys > The hex number below "pub"
export JS_PM=bun # bun|npm
export JS_PMX=bunx # bunx|npx
# Replace ld_client with your LaunchDarkly client, or the whole command
export LAUNCH_DARKLY_KEYS_CMD=(bin/rails runner 'puts ld_client.all_features.keys')
export RUBY_CMD_PREFIX='bin/'

# shellcheck disable=SC2016
POST_INIT_HOOKS+=(
  # %s will be replaced with the flag key
  # LAUNCH_DARKLY_PROJECT can be customized per project (by mise, direnv, etc.),
  #   but it needs to be set after they are loaded.
  'export LAUNCH_DARKLY_URL="https://app.launchdarkly.com/projects/${LAUNCH_DARKLY_PROJECT:-default}/flags/%s/targeting?env=production&env=development&selected-env=production"'
)

DOTFILES_INCLUDE_LIBS+=(example_lib gpg)
OMZ_PLUGINS+=(bun npm)

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
