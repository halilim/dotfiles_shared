alias libe='$EDITOR "$DOTFILES_INCLUDES"/lib/editing.sh' # cSpell:ignore libe

function open_with_editor() {
  local abs_path_line_col=$1 silent=1 cmd

  if [[ ${VERBOSE:-} ]]; then
    silent=''
  fi

  if [[ $EDITOR == "$VIM_CMD" ]]; then
    cmd='vim_open %q'
  elif [[ $EDITOR = code || $EDITOR = code-insiders ]]; then
    # https://code.visualstudio.com/docs/editor/command-line#_core-cli-options
    cmd="/usr/local/bin/$EDITOR -g %q"
  else
    cmd='open %q'
  fi

  SILENT=$silent echo_eval "$cmd" "$abs_path_line_col"
}

function vim_open() {
  local vim_cmd_=''

  if [[ ${SUDO:-} ]]; then
    vim_cmd_+='sudo'
  fi

  vim_cmd_+=" $VIM_CMD"

  # https://stackoverflow.com/a/5945322/372654
  if [[ "$#" -eq 1 ]]; then
    if [[ -d $1 ]]; then
      vim_cmd_+=" $1 +':lcd %'"
    else
      if [[ ! ${VIM_NO_SERVER:-} ]]; then
        vim_cmd_+=" --remote-silent"
      fi
      vim_cmd_+=" $1"
    fi
  fi

  echo_eval "$vim_cmd_"
}
