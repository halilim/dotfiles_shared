alias libe='$EDITOR "$DOTFILES_INCLUDES"/lib/editing.sh' # cSpell:ignore libe

function edit() {
  if [[ $# -eq 0 ]]; then
    echo >&2 'Usage: edit file1:line:column [file2:line2:column2 ...]'
    return 1
  fi

  local silent=1 verbose=''
  if [[ "${VERBOSE:-}" ]]; then
    silent=''
    verbose=1
  fi

  local editor_titles rubymine_titles titles_loaded

  if [ -n "${ZSH_VERSION:-}" ]; then
    setopt local_options BASH_REMATCH
  fi

  local arg arg_path line column \
    real_abs_path base_name real_abs_dir_path dirs real_abs_path_line_col \
    dir_candidates project_dir git_path

  local ct=0
  for arg in "$@"; do
    if [[ $verbose && $ct -gt 0 ]]; then
      echo >&2 '-------'
    fi

    if [[ $arg =~ ^([^:]+):?([0-9]*):?([0-9]*)$ ]]; then
      arg_path=${BASH_REMATCH[*]:1:1}
      line=${line:-${BASH_REMATCH[*]:2:1}}
      column=${column:-${BASH_REMATCH[*]:3:1}}
    else
      arg_path=$arg
    fi

    if [[ $verbose ]]; then
      declare -p arg_path line column 1>&2
    fi

    if [[ -e $arg_path ]]; then
      real_abs_path=$(realpath "$arg_path")

      if [[ -d $real_abs_path ]]; then
        open_with_editor "$real_abs_path"
        continue
      fi

      real_abs_dir_path=$(dirname "$real_abs_path")
    else
      dirs=$(dirname "$arg_path")
      # Create a new file along with the directories
      if [[ ! -e $dirs ]]; then
        echo_eval mkdir -p "$dirs"
      fi
      real_abs_dir_path=$(FAKE_ECHO="$dirs" SILENT=$silent echo_eval realpath "$dirs")
      base_name=$(basename "$arg_path")
      real_abs_path=$real_abs_dir_path/$base_name
    fi

    if [[ $verbose ]]; then
      declare -p real_abs_path real_abs_dir_path 1>&2
    fi

    real_abs_path_line_col=$real_abs_path
    [[ $line ]] && real_abs_path_line_col="$real_abs_path_line_col:$line"
    [[ $column ]] && real_abs_path_line_col="$real_abs_path_line_col:$column"

    if [[ $verbose ]]; then
      declare -p real_abs_path_line_col 1>&2
    fi

    # Lazy load
    if [[ ! $titles_loaded ]]; then
      editor_titles=$(get_editor_titles)
      rubymine_titles=$(window_names RubyMine)
      titles_loaded=1
    fi

    if [[ $verbose ]]; then
      declare -p editor_titles rubymine_titles 1>&2
    fi

    if [[ $rubymine_titles ]]; then
      dir_candidates=()

      if [[ -e $real_abs_dir_path ]]; then
        project_dir=$(basename "$(get_project_path "$real_abs_dir_path")")
        if [[ $project_dir ]]; then
          dir_candidates+=("$project_dir")
        fi
      fi

      git_path=$(git -C "$real_abs_dir_path" rev-parse --show-toplevel 2> /dev/null)
      if [[ $git_path ]]; then
        dir_candidates+=("$(basename "$git_path")")
      fi

      if [[ $verbose ]]; then
        declare -p dir_candidates 1>&2
      fi

      if (DRY_RUN='' SILENT=$silent echo_eval is_in_rubymine_titles "$rubymine_titles" "${dir_candidates[@]}") \
        || (is_ruby_file "$real_abs_path" \
          && ! DRY_RUN='' SILENT=$silent echo_eval is_in_editor_titles "$editor_titles" "${dir_candidates[@]}"); then
        open_with_rubymine "$real_abs_path" "$line" "$column"
        continue
      fi
    fi

    open_with_editor "$real_abs_path_line_col"

    ct=$((ct + 1))
  done
}
alias e='edit'

function get_editor_titles() {
  if is_editor_mvim; then
    window_names 'MacVim'
  elif is_editor_vscode; then
    window_names 'Visual Studio Code.app' 'Code'
  elif is_editor_vscode_insiders; then
    window_names 'Visual Studio Code - Insiders.app' 'Code - Insiders'
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

function is_editor_mvim() {
  [[ $EDITOR == mvim* ]]
}

function is_editor_vscode() {
  [[ $EDITOR == code || $EDITOR == */code ]]
}

function is_editor_vscode_insiders() {
  [[ $EDITOR == code-insiders || $EDITOR == */code-insiders ]]
}

function is_in_editor_titles() {
  local editor_titles=${1?}
  shift

  local candidate_dir_name editor_title
  for candidate_dir_name in "$@"; do
    while read -d ', ' -r editor_title; do
      if [[ $editor_title ]]; then
        if (is_editor_vscode || is_editor_vscode_insiders) \
          && is_in_vscode_titles "$editor_title" "$candidate_dir_name"; then
          return 0
        elif is_editor_mvim \
          && is_in_mvim_titles "$editor_title" "$candidate_dir_name"; then
          return 0
        fi
      fi
    done < <(printf '%s, ' "$editor_titles")
  done

  return 1
}

# mvim_title examples:
# ~ • [No Name]               (file: ❌, folder: ✅) (opens the home directory by default)
# ~/code/dir_name • [No Name] (file: ❌, folder: ✅)
# ~/code/dir_name // file.txt (file: ✅, folder: ✅)
# / // /etc                   (file: ❌, folder: ✅) (special case: / is the root directory, /etc is a subdirectory of /)
function is_in_mvim_titles() {
  local mvim_title=${1?} dir_name=${2?}
  [[ $mvim_title == *"$dir_name • "* ]] \
    || [[ $mvim_title == *"$dir_name // "* ]] \
    || [[ $mvim_title == "/ // /$dir_name" ]]
}

# vscode_title examples:
# Visual Studio Code              (nothing open)
# file.txt                        (file: ✅, folder: ❌, workspace: ❌)
# dir_name                        (file: ❌, folder: ✅, workspace: ❌)
# file.txt — dir_name             (file: ✅, folder: ✅, workspace: ❌)
# dir_name (Workspace)            (file: ❌, folder: ✅, workspace: ✅)
# file.txt — dir_name (Workspace) (file: ✅, folder: ✅, workspace: ✅)
function is_in_vscode_titles() {
  local vscode_title=${1?} dir_name=${2?}
  [[ $vscode_title == "$dir_name" ]] \
    || [[ $vscode_title == *" — $dir_name"* ]]
}

# rubymine_title examples:
# Welcome to RubyMine (nothing open)
# dir_name            (file: ❌, folder: ✅)
# dir_name – file.txt (file: ✅, folder: ✅)
function is_in_rubymine_titles() {
  local rubymine_titles=${1?}
  shift

  local candidate_dir_name rubymine_title
  for candidate_dir_name in "$@"; do
    while read -d ', ' -r rubymine_title; do
      # Format: `<project>( – <file>)?` - not a regular dash
      if [[ $rubymine_title == "$candidate_dir_name" || $rubymine_title == "$candidate_dir_name – "* ]]; then
        return 0
      fi
    done < <(printf '%s, ' "$rubymine_titles")
  done

  return 1
}

function is_ruby_file() {
  local file_path=${1?} file_name
  file_name=$(basename "$file_path")
  [[ $file_name == *.rb ||
    $file_name == *.gemspec ||
     $file_name == Brewfile ||
     $file_name == Gemfile ||
     $file_name == Guardfile ||
     $file_name == Rakefile ||
     $file_name == Vagrantfile ]]
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
