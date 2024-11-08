# Custom environment variables and setup

export ADMINER_DIR="$HOME/code/tools/adminer"
# $ php -r 'echo password_hash("<Password manager: adminer passwordless password>", PASSWORD_DEFAULT);'
# shellcheck disable=SC2016
export ADMINER_HASH='...'
export ESHEAD_DIR="$HOME/code/tools/elasticsearch-head"
export GPG_KEY=123ABC # gpg --list-keys > The hex number below "pub"
# Replace ld_client with your LaunchDarkly client, or the whole command
export LAUNCH_DARKLY_KEYS_CMD=(bin/rails runner 'puts ld_client.all_features.keys')
# %s will be replaced with the flag key
export LAUNCH_DARKLY_URL='https://app.launchdarkly.com/projects/default/flags/%s/targeting?env=production&env=development&selected-env=development'
export PHP_ROOT=~/code
export RUBY_CMD_PREFIX='bin/'

DOTFILES_INCLUDE_LIBS+=(gpg example_lib)
OMZ_PLUGINS+=(rbenv)
UPDATE_BACKUP_CMDS=(pre_update_cmd "${UPDATE_BACKUP_CMDS[@]}") # Prepend
UPDATE_BACKUP_CMDS+=(gpg_check_key update_foo backup_bar) # Append
