export GNU_DATE=date
export GNU_FIND=find
export GNU_HEAD=head
export GNU_NUMFMT=numfmt
export GNU_REALPATH=realpath
export GNU_SED=sed
export GNU_STAT=stat
export GNU_TOUCH=touch
export GNU_XARGS=xargs

if [[ -v TERMUX_VERSION ]]; then
  export CLIP='clipcopy'
  export OPEN_CMD='termux-open'
  export SPEEDTEST_CMD='speedtest-go'

  DOTFILES_INCLUDE_LIBS+=(termux)

  UPDATE_BACKUP_CMDS+=(
    'pkg update'
    'pkg upgrade -y'
    termux_install_update_shellcheck
    termux_update_shellspec
  )
else
  export CLIP='xclip -sel clip'
  export OPEN_CMD='nohup xdg-open'
  export SPEEDTEST_CMD='speedtest'

  if [[ -r /etc/lsb-release ]]; then
    # shellcheck disable=SC1091
    . /etc/lsb-release

    if [[ $DISTRIB_ID == Ubuntu ]]; then
      OMZ_PLUGINS+=(ubuntu)

      UPDATE_BACKUP_CMDS+=(
        'sudo apt update'
        'sudo apt upgrade -y'
        '[[ -e /var/run/reboot-required ]] && sudo reboot'
      )
    fi
  fi
fi
