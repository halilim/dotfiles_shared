export VIM=mvim
export OPEN_CMD='open'
export BAT_CMD=bat

export GNU_DATE=gdate
export GNU_FIND=gfind
export GNU_NUMFMT=gnumfmt
export GNU_REALPATH=grealpath
export GNU_SED=gsed
export GNU_STAT=gstat
export GNU_TOUCH=gtouch

export HOMEBREW_NO_AUTO_UPDATE=1 # Covered by update_and_backup ($UPDATE_BACKUP_CMDS)
export HOMEBREW_NO_ENV_HINTS=1
eval "$(/opt/homebrew/bin/brew shellenv)"
if [[ -z ${ZSH_VERSION:-} && $- == *i* ]]; then
  # shellcheck source=/dev/null
  . "$HOMEBREW_PREFIX"/etc/bash_completion.d/git-prompt.sh
fi
