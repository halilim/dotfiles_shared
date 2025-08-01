export CLIP='pbcopy'
export OPEN_CMD='open'
export SPEEDTEST_CMD='speedtest'
export VIM_CMD=mvim

export GNU_DATE=gdate
export GNU_FIND=gfind
export GNU_HEAD=ghead
export GNU_NUMFMT=gnumfmt
export GNU_REALPATH=grealpath
export GNU_SED=gsed
export GNU_STAT=gstat
export GNU_TOUCH=gtouch
export GNU_XARGS=gxargs

DOTFILES_INCLUDE_LIBS+=(
  brew
  elasticsearch
  redis
)

OMZ_PLUGINS+=(macos)

UPDATE_BACKUP_CMDS+=(
  'js_update_globals'
  'update_open_tabs'
  "$OPEN_CMD /Applications # Manually update the non-App Store, infrequently-opened, etc. apps"
  'iterm_tab . update_chrome_notes'
)
