export VIM_CMD=mvim
export OPEN_CMD='open'
export BAT_CMD=bat
export CLIP='pbcopy'

export GNU_DATE=gdate
export GNU_FIND=gfind
export GNU_NUMFMT=gnumfmt
export GNU_REALPATH=grealpath
export GNU_SED=gsed
export GNU_STAT=gstat
export GNU_TOUCH=gtouch
export GNU_XARGS=gxargs

export HOMEBREW_NO_AUTO_UPDATE=1 # Covered by update_and_backup ($UPDATE_BACKUP_CMDS)
export HOMEBREW_NO_ENV_HINTS=1
eval "$(/opt/homebrew/bin/brew shellenv)"
if [[ -z ${ZSH_VERSION:-} && $- == *i* ]]; then
  # shellcheck source=/dev/null
  . "$HOMEBREW_PREFIX"/etc/bash_completion.d/git-prompt.sh
fi

DOTFILES_INCLUDE_LIBS+=(
  brew
  elasticsearch
  redis
)

OMZ_PLUGINS+=(macos)

UPDATE_BACKUP_CMDS+=(
  'brew update --quiet'
  'brew upgrade --quiet' # Removed --greedy because apps auto-download in the background anyway
  'js_update_globals'
  'update_open_tabs'
  "$OPEN_CMD /Applications # Manually update the non-App Store, infrequently-opened, etc. apps"
  'update_notify_chrome'
)
