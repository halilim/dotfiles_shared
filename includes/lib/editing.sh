alias libe='$EDITOR "$DOTFILES_INCLUDES"/lib/editing.sh' # cSpell:ignore libe

# For a given file:
# 1. Git repo is open in RubyMine -> Open in RubyMine
# 2. Git repo, folder, or parent folder is open in $EDITOR -> Open in $EDITOR
# 3. Is *.rb, and RubyMine is open -> Open in RubyMine
# 4. Likely a text file
#    - $EDITOR is open -> Open in $EDITOR
#    - Otherwise -> Open in Vim
# 5. Otherwise -> Open with $OPEN_CMD
function edit() {
  local abs_path=${1:?} line=${2:-} column=${3:-}

  if [[ -d $abs_path ]]; then
    echo_eval "$OPEN_CMD %q" "$abs_path"
    return
  fi

  if [ -n "${ZSH_VERSION:-}" ]; then
    setopt local_options BASH_REMATCH
  fi

  if [[ $abs_path =~ ^([^:]+):?([0-9]*):?([0-9]*)$ ]]; then
    abs_path=${BASH_REMATCH[*]:1:1}
    line=${line:-${BASH_REMATCH[*]:2:1}}
    column=${column:-${BASH_REMATCH[*]:3:1}}
  fi

  local abs_path_line_col=$abs_path
  [[ $line ]] && abs_path_line_col="$abs_path_line_col:$line"
  [[ $column ]] && abs_path_line_col="$abs_path_line_col:$column"

  # declare -p abs_path line column abs_path_line_col 1>&2

  local dir git_path git_dir
  dir=$(dirname "$abs_path")
  git_path=$(git -C "$dir" rev-parse --show-toplevel 2> /dev/null)
  if [[ $git_path ]]; then
    git_dir=$(basename "$git_path")
  fi

  local rubymine_titles
  rubymine_titles=$(window_names RubyMine)

  if is_in_rubymine_titles "$rubymine_titles" "$git_dir"; then
    open_with_rubymine "$abs_path" "$line" "$column"
    return
  fi

  local editor_titles
  editor_titles=$(get_editor_titles)
  if is_in_editor_titles "$git_dir" "$git_path" "$editor_titles"; then
    open_with_editor "$abs_path_line_col"
    return
  fi

  if [[ $rubymine_titles && ${abs_path##*.} == 'rb' ]]; then
    open_with_rubymine "$abs_path" "$line" "$column"
    return
  fi

  if [[ $line ]] || file --mime-type "$abs_path" | grep -qv binary; then
    if [[ $editor_titles ]]; then
      open_with_editor "$abs_path_line_col"
    else
      vim_open "$abs_path_line_col"
    fi
  else
    echo_eval "$OPEN_CMD %q" "$abs_path"
  fi
}
alias e='edit'

function get_editor_titles() {
  if [[ $EDITOR = mvim* ]]; then
    window_names 'MacVim'
  elif [[ $EDITOR == code || $EDITOR == */code ]]; then
    window_names 'Visual Studio Code.app' 'Code'
  elif [[ $EDITOR == code-insiders || $EDITOR == */code-insiders  ]]; then
    window_names 'Visual Studio Code - Insiders.app' 'Code - Insiders'
  elif [[ $EDITOR = */zed ]]; then
    window_names 'Zed'
  fi
}

function get_project_path() {
  local dir=$1
  dir=$(realpath "$dir")

  while [[ $dir && ! -f "$dir/.project_root" ]]; do
    # echo "dir=|$dir|"
    if [[ $dir == '/' || $dir == '.' ]]; then
      dir=''
      break
    fi
    dir=$(dirname "$dir")
  done
  echo "$dir"
}

function is_in_editor_titles() {
  local git_dir=$1 git_path=$2 editor_titles=$3 parent_path parent_dir project_path project_dir
  parent_path=$(dirname "$git_path")
  parent_dir=$(basename "$parent_path")
  project_path=$(get_project_path "$parent_path")
  project_dir=$(basename "$project_path")

  local editor_title
  while read -d ', ' -r editor_title; do
    if [[ $editor_title &&
          ($git_dir && $editor_title == *" $git_dir "*)
          || ($parent_dir && $editor_title == *" $parent_dir "*)
          || ($project_dir && $editor_title == *" $project_dir "*) ]]; then
      return 0
    fi
  done < <(printf '%s, ' "$editor_titles")

  return 1
}

function is_in_rubymine_titles() {
  local rubymine_titles=$1 git_dir=$2

  if [[ $git_dir ]]; then
    local rubymine_title

    while read -d ', ' -r rubymine_title; do
      # Format: `<project>( – <file>)?` - not a regular dash
      if [[ $rubymine_title == "$git_dir" || $rubymine_title == "$git_dir – "* ]]; then
        return 0
      fi
    done < <(printf '%s, ' "$rubymine_titles")
  fi

  return 1
}

function open_with_rubymine() {
  local abs_path=$1 line=$2 column=$3 args=()

  # https://www.jetbrains.com/help/ruby/opening-files-from-command-line.html#88f1a126
  # Note: column is only documented in the "Windows" tab. -1: it goes to the next character (bug?)

  # \\'s are for escaping special values like 21, which are also global aliases
  if [[ $line ]]; then
    args+=(--line "\\$line")
  fi
  if [[ $column ]]; then
    args+=(--column "\\$((column - 1))")
  fi

  args+=("$abs_path")

  mine "${args[@]}"
}

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
