# Custom environment variables and setup

export ESHEAD_DIR="$HOME/code/tools/elasticsearch-head"
export GPG_KEY=123ABC # gpg --list-keys > The hex number below "pub"
export ITERM2_COLOR_SCHEMES=~/code/tools/iTerm2-Color-Schemes
export RUBY_CMD_PREFIX='bin/'
DOTFILES_INCLUDE_LIBS+=(gpg)
OMZ_PLUGINS+=(rbenv)
UPDATE_BACKUP_CMDS=(pre_update_cmd "${UPDATE_BACKUP_CMDS[@]}") # Prepend
UPDATE_BACKUP_CMDS+=(gpg_check_key update_foo backup_bar) # Append
