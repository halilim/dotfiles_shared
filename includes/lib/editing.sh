alias libe='$EDITOR "$DOTFILES_INCLUDES"/lib/editing.sh' # cSpell:ignore libe

function open_with_editor() {
  if [[ $EDITOR == */*vim ]]; then
    vim_open "$@"
    return
  fi

  local arg_arr=("$@") cmd

  if [[ $EDITOR == code || $EDITOR == */code || $EDITOR == code-insiders || $EDITOR == */code-insiders ]]; then
    # https://code.visualstudio.com/docs/editor/command-line#_core-cli-options
    # https://github.com/microsoft/vscode/issues/176343 No multiple -g's :(
    cmd="$EDITOR -g"
  elif [[ $EDITOR == */*zed ]]; then
    cmd="$EDITOR"
  else
    cmd='open'
  fi

  local arg_ct=${#arg_arr[@]} pct_qs
  pct_qs=$(printf ' %%q%.0s' $(seq 1 "$arg_ct"))

  echo_eval "$cmd$pct_qs" "${arg_arr[@]}"
}

function vim_open() {
  local arg_arr=("$@") vim_cmd_=''

  if [[ ${SUDO:-} ]]; then
    vim_cmd_+='sudo '
  fi

  vim_cmd_+="$VIM_PATH"

  local arg_ct=${#arg_arr[@]} pct_qs
  pct_qs=$(printf ' %%q%.0s' $(seq 1 "$arg_ct"))

  # https://stackoverflow.com/a/5945322/372654
  if [[ "$#" -gt 0 ]]; then
    if [[ -d $1 ]]; then
      vim_cmd_+="$pct_qs +':lcd %%'"
    else
      if [[ $VIM_PATH != */vim ]]; then
        vim_cmd_+=" --remote-silent"
      fi
      vim_cmd_+="$pct_qs"
    fi
  fi

  echo_eval "$vim_cmd_" "${arg_arr[@]}"
}
