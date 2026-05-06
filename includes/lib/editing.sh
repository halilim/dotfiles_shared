alias libe='$EDITOR "$DOTFILES_INCLUDES"/lib/editing.sh' # cSpell:ignore libe

function edit() {
  if [[ $# -eq 0 ]]; then
    echo >&2 'Usage: edit file1:line:column [file2:line2:column2 ...]'
    return 1
  fi

  local rubymine_titles rubymine_titles_loaded

  if [ -n "${ZSH_VERSION:-}" ]; then
    setopt local_options BASH_REMATCH
  fi

  local arg arg_path line column \
    parent_dir base_name real_abs_path real_abs_path_line_col \
    real_abs_dir git_path git_dir
  for arg in "$@"; do
    if [[ $arg =~ ^([^:]+):?([0-9]*):?([0-9]*)$ ]]; then
      arg_path=${BASH_REMATCH[*]:1:1}
      line=${line:-${BASH_REMATCH[*]:2:1}}
      column=${column:-${BASH_REMATCH[*]:3:1}}
    else
      arg_path=$arg
    fi

    if [[ -e $arg_path ]]; then
      real_abs_path=$(realpath "$arg_path")

      if [[ -d $real_abs_path ]]; then
        open_with_editor "$real_abs_path"
        continue
      fi

      real_abs_dir=$(dirname "$real_abs_path")
    else
      parent_dir=$(dirname "$arg_path")
      if [[ ! -e $parent_dir ]]; then
        echo_eval mkdir -p "$parent_dir"
      fi
      real_abs_dir=$(realpath "$parent_dir")
      base_name=$(basename "$arg_path")
      real_abs_path=$real_abs_dir/$base_name
    fi

    real_abs_path_line_col=$real_abs_path
    [[ $line ]] && real_abs_path_line_col="$real_abs_path_line_col:$line"
    [[ $column ]] && real_abs_path_line_col="$real_abs_path_line_col:$column"

    # Lazy load
    if [[ ! $rubymine_titles_loaded ]]; then
      rubymine_titles=$(window_names RubyMine)
      rubymine_titles_loaded=1
    fi

    if [[ $rubymine_titles ]]; then
      git_dir=''
      git_path=$(git -C "$real_abs_dir" rev-parse --show-toplevel 2> /dev/null)
      if [[ $git_path ]]; then
        git_dir=$(basename "$git_path")
      fi

      if ([[ $git_dir ]] && is_in_rubymine_titles "$rubymine_titles" "$git_dir") \
         || [[ ${real_abs_path##*.} == 'rb' ]]; then
        open_with_rubymine "$real_abs_path" "$line" "$column"
        continue
      fi
    fi

    open_with_editor "$real_abs_path_line_col"
  done
}
alias e='edit'

function is_in_rubymine_titles() {
  local rubymine_titles=$1 git_dir=$2

  if [[ ! $rubymine_titles || ! $git_dir ]]; then
    return 1
  fi

  local rubymine_title

  while read -d ', ' -r rubymine_title; do
    # Format: `<project>( – <file>)?` - not a regular dash
    if [[ $rubymine_title == "$git_dir" || $rubymine_title == "$git_dir – "* ]]; then
      return 0
    fi
  done < <(printf '%s, ' "$rubymine_titles")

  return 1
}

function open_with_rubymine() {
  local abs_path=$1 line=$2 column=$3 args=()

  # RubyMine doesn't support opening existing folders in open projects. It treats them as
  # new projects; i.e., it opens them in a new window and adds an .idea folder to them.
  # https://youtrack.jetbrains.com/issue/RUBY-35459
  if [[ -d $abs_path ]]; then
    echo_eval "$OPEN_CMD" "$abs_path"
    return
  fi

  # https://www.jetbrains.com/help/ruby/opening-files-from-command-line.html#88f1a126
  # Note: column is only documented in the "Windows" tab. -1: it goes to the next character (bug?)

  if [[ $line ]]; then
    args+=(--line "$line")
  fi

  if [[ $column ]]; then
    args+=(--column "$((column - 1))")
  fi

  args+=("$abs_path")

  mine "${args[@]}"
}

function open_with_editor() {
  if [[ $EDITOR == *vim ]]; then
    vim_open "$@"
    return
  fi

  local cmd_args=()

  if [[ $EDITOR == code || $EDITOR == */code || $EDITOR == code-insiders || $EDITOR == */code-insiders ]]; then
    # https://code.visualstudio.com/docs/editor/command-line#_core-cli-options
    # https://github.com/microsoft/vscode/issues/176343 No multiple -g's :(
    cmd_args=("$EDITOR" -g)
  else
    cmd_args=("$OPEN_CMD")
  fi

  echo_eval "${cmd_args[@]}" "$@"
}

function vim_open() {
  local args=()

  if [[ ${SUDO:-} ]]; then
    args+=('sudo')
  fi

  args+=("$VIM_PATH")

  # https://stackoverflow.com/a/5945322/372654
  if [[ "$#" -gt 0 ]]; then
    if [[ -d $1 ]]; then
      args+=(+':lcd %')
    else
      if [[ $VIM_PATH != */vim ]]; then
        args+=('--remote-silent')
      fi
    fi
  fi

  args+=("$@")

  echo_eval "${args[@]}"
}
