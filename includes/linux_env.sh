export VIM_CMD=vim
export OPEN_CMD='nohup xdg-open'
export CLIP='xclip -sel clip'

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
  export VIM_NO_SERVER=1 # --remote-silent is not supported
  UPDATE_BACKUP_CMDS+=(
    'pkg update'
    'pkg upgrade -y'
  )
else
  if [[ -e /etc/debian_version ]]; then
     # Because of a name clash, see: apt-cache show bat
    function bat() {
      batcat "$@"
    }
  fi

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
