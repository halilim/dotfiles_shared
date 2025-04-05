alias envshc='$EDITOR "$DOTFILES_CUSTOM"/includes/env.sh' # cSpell:ignore envshc

export ADMINER_DIR="$HOME/code/tools/adminer"
export CODE_ROOT=~/code
export ESHEAD_DIR="$HOME/code/tools/elasticsearch-head"
export FOO_PORT=8087 # Custom local app, start its dev server with this port too
export GPG_KEY=123ABC # gpg --list-keys > The hex number below "pub"
export JS_PM=bun # bun|npm
export JS_PMX=bunx # bunx|npx
# Replace ld_client with your LaunchDarkly client, or the whole command
export LAUNCH_DARKLY_KEYS_CMD=(bin/rails runner 'puts ld_client.all_features.keys')
# %s will be replaced with the flag key
export LAUNCH_DARKLY_URL='https://app.launchdarkly.com/projects/default/flags/%s/targeting?env=production&env=development&selected-env=development'
export RUBY_CMD_PREFIX='bin/'

DOTFILES_INCLUDE_LIBS+=(example_lib gpg)
OMZ_PLUGINS+=(bun mise npm)
UPDATE_BACKUP_CMDS=(pre_update_cmd "${UPDATE_BACKUP_CMDS[@]}") # Prepend
UPDATE_BACKUP_CMDS+=(gpg_check_key update_foo backup_bar) # Append
