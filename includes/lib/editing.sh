alias libe='$EDITOR "$DOTFILES_INCLUDES"/lib/editing.sh' # cSpell:ignore libe

export PROJECT_ROOT='.project_root'

function edit() {
  local args=("$@")
  if [[ ${#args} -eq 0 ]]; then
    args=(.)
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

  local ct=0 arg arg_path line column \
    dir_name is_new real_abs_path is_link base_name real_abs_dir_path real_abs_path_line_col

  for arg in "${args[@]}"; do
    if [[ $verbose && $ct -gt 0 ]]; then
      echo >&2 '-------'
    fi

    if [[ $arg =~ ^([^:]+):?([0-9]*):?([0-9]*)$ ]]; then
      arg_path=${BASH_REMATCH[*]:1:1}
      line=${BASH_REMATCH[*]:2:1}
      column=${BASH_REMATCH[*]:3:1}
    else
      arg_path=$arg
      line=''
      column=''
    fi

    if [[ $verbose ]]; then
      declare -p arg_path line column 1>&2
    fi

    is_link=''

    dir_name=$(dirname "$arg_path")
    if [[ -e $arg_path ]]; then
      is_new=''
      real_abs_path=$(realpath "$arg_path")

      if [[ -d $real_abs_path ]]; then
        open_with_editor "$real_abs_path"
        continue
      fi

      if [[ -L $arg_path ]]; then
        is_link=1
      fi

      real_abs_dir_path=$(dirname "$real_abs_path")
    else
      is_new=1
      # Create a new file along with the directories
      if [[ ! -e $dir_name ]]; then
        echo_eval mkdir -p "$dir_name"
      fi

      if [[ -L $dir_name ]]; then
        is_link=1
      fi

      base_name=$(basename "$arg_path")
      real_abs_path=$base_name
      real_abs_dir_path=$(FAKE_ECHO="$dir_name" SILENT=$silent echo_eval realpath "$dir_name")
      if [[ $real_abs_dir_path ]]; then
        real_abs_path=$real_abs_dir_path/$base_name
      fi
    fi

    if [[ $verbose ]]; then
      declare -p dir_name real_abs_path real_abs_dir_path 1>&2
    fi

    real_abs_path_line_col=$real_abs_path
    [[ $line ]] && real_abs_path_line_col="$real_abs_path_line_col:$line"
    [[ $column ]] && real_abs_path_line_col="$real_abs_path_line_col:$column"

    if [[ $verbose ]]; then
      declare -p real_abs_path_line_col 1>&2
    fi

    # Lazy load
    if [[ ! ${titles_loaded:-} ]]; then
      editor_titles=$(get_editor_titles)
      rubymine_titles=$(window_names RubyMine)
      titles_loaded=1
    fi

    if [[ $verbose ]]; then
      declare -p editor_titles rubymine_titles 1>&2
    fi

    if VERBOSE=$verbose SILENT=$silent _should_edit_in_rubymine \
         "$editor_titles" \
         "$rubymine_titles" \
         "$real_abs_path" \
         "$real_abs_dir_path" \
         "$dir_name" \
         "$is_link"; then
      # RubyMine opens nonexistent files in a new window, even when the file path is within the project
      if [[ $is_new ]]; then
        echo_eval touch "$real_abs_path"
      fi
      open_with_rubymine "$real_abs_path" "$line" "$column"
      continue
    fi

    open_with_editor "$real_abs_path_line_col"

    ct=$((ct + 1))
  done
}
# alias e='edit'
# When manually using e in the command line, `pgrep -f RubyMine` takes some time if it's not running.
# I can directly call mine (m) or code (c) since I already know my intention.
# open_from_iterm will continue using the full-fledged `edit`, since Cmd+click doesn't carry an intent.
alias e='open_with_editor'

function _should_edit_in_rubymine() {
  local editor_titles=$1 \
    rubymine_titles=$2 \
    real_abs_path=${3?} \
    real_abs_dir_path=${4?} \
    dir_name=${5?} \
    is_link=${6:-} \
    verbose=${VERBOSE:-} \
    silent=${SILENT:-}

  [[ ! $rubymine_titles ]] && return 1

  local dir_candidates=()

  if [[ -e $real_abs_dir_path ]]; then
    local project_dir
    project_dir=$(basename "$(get_project_root_path "$dir_name")")
    if [[ $project_dir ]]; then
      dir_candidates+=("$project_dir")
    fi

    if [[ $is_link ]]; then
      local real_project_dir
      real_project_dir=$(basename "$(get_project_root_path "$real_abs_dir_path")")
      if [[ $real_project_dir ]]; then
        dir_candidates+=("$real_project_dir")
      fi
    fi
  fi

  local git_path
  git_path=$(git -C "$dir_name" rev-parse --show-toplevel 2> /dev/null)
  if [[ $git_path ]]; then
    dir_candidates+=("$(basename "$git_path")")
  fi

  # TODO: Should this check $is_link?
  if [[ $is_link ]]; then
    local real_git_path
    real_git_path=$(git -C "$real_abs_dir_path" rev-parse --show-toplevel 2> /dev/null)
    if [[ $real_git_path ]]; then
      dir_candidates+=("$(basename "$real_git_path")")
    fi
  fi

  local dir_candidate_ct=${#dir_candidates[@]} any_dir_candidates
  if [[ $dir_candidate_ct -ge 1 ]]; then
    # Remove duplicates
    if [[ $dir_candidate_ct -ge 2 ]]; then
      local dir_candidates_s
      dir_candidates_s=$(printf '%s\n' "${dir_candidates[@]}" | uniq)
      if command -v mapfile > /dev/null 2>&1; then
        mapfile -t dir_candidates < <( echo "$dir_candidates_s" )
      elif [ -n "${ZSH_VERSION:-}" ]; then
        # shellcheck disable=SC2296,SC2116
        dir_candidates=("${(f)$(echo "$dir_candidates_s")}")
      fi
    fi

    any_dir_candidates=1
  else
    any_dir_candidates=''
  fi

  if [[ $verbose ]]; then
    declare -p dir_candidates any_dir_candidates 1>&2
  fi

  if DRY_RUN='' SILENT=$silent echo_eval is_in_rubymine_titles "$rubymine_titles" "${dir_candidates[@]}"; then
    return
  fi

  # Open even external Ruby files in RubyMine, if:
  # - RubyMine is already open ($rubymine_titles is not empty)
  # - The project of the file is not already open in the editor (if so, it falls through to open_with_editor)
  if is_ruby_file "$real_abs_path" \
    && ! DRY_RUN='' SILENT=$silent echo_eval is_in_editor_titles "$editor_titles" "${dir_candidates[@]}"; then
    return
  fi

  return 1
}

function get_editor_titles() {
  if is_editor_vscode; then
    window_names 'Visual Studio Code.app' 'Code'
  elif is_editor_vscode_insiders; then
    window_names 'Visual Studio Code - Insiders.app' 'Code - Insiders'
  fi
}

function get_project_root_path() {
  local dir=${1:-.} previous_dir
  dir=$($GNU_REALPATH "$dir" -s)

  while [[ $dir != '/' && $dir != '~' ]]; do
    if [[ ${DEBUG:-} || ${VERBOSE:-} ]]; then
      echo >&2 "dir=|$dir|"
    fi

    if [[ -e "$dir/$PROJECT_ROOT" ]]; then
      echo "$dir"
      return
    fi

    previous_dir=$dir
    dir=$(dirname "$dir")
    if [[ $dir == "$previous_dir" ]]; then
      if [[ ${DEBUG:-} || ${VERBOSE:-} ]]; then
        echo >&2 "Recursion detected while searching for $PROJECT_ROOT (dir=$dir, previous_dir=$previous_dir)"
      fi
      return 1
    fi
  done

  return 1
}

function is_editor_vscode() {
  [[ $EDITOR == code || $EDITOR == */code ]]
}

function is_editor_vscode_insiders() {
  [[ $EDITOR == code-insiders || $EDITOR == */code-insiders ]]
}

function is_in_editor_titles() {
  local editor_titles=$1
  [[ ! $editor_titles ]] && return 1

  shift
  [[ $# -eq 0 ]] && return 1

  local candidate_dir_name editor_title
  for candidate_dir_name in "$@"; do
    while IFS= read -r editor_title; do
      if (is_editor_vscode || is_editor_vscode_insiders) \
        && is_in_vscode_titles "$editor_title" "$candidate_dir_name"; then
        return 0
      fi
    done < <(printf '%s\n' "$editor_titles")
  done

  return 1
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

function is_in_rubymine_titles() {
  local rubymine_titles=$1
  [[ ! $rubymine_titles ]] && return 1

  shift
  [[ $# -eq 0 ]] && return 1

  local candidate_dir_name rubymine_title
  for candidate_dir_name in "$@"; do
    while IFS= read -r rubymine_title; do
      if is_in_rubymine_title "$rubymine_title" "$candidate_dir_name"; then
        return 0
      fi
    done < <(printf '%s\n' "$rubymine_titles") # TODO: GitHub CI: `printf: write error: Broken pipe`
  done

  return 1
}

# rubymine_title examples:
# Welcome to RubyMine (nothing open)
# dir_name            (file: ❌, folder: ✅)
# dir_name – file.txt (file: ✅, folder: ✅)
function is_in_rubymine_title() {
  local rubymine_title=${1?} dir_name=${2?}
  [[ $rubymine_title == "$dir_name" || \
     $rubymine_title == "$dir_name – "* ]]
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
  local args=("$@") cmd_args=()

  if [[ ${#args} -eq 0 ]]; then
    args=(.)
  fi

  if is_editor_vscode || is_editor_vscode_insiders; then
    # shellcheck disable=SC2124
    local first_arg="${args[@]:0:1}"
    if [[ $first_arg && -d $first_arg ]]; then
      local code_workspace
      code_workspace=$(find "$first_arg" -name '*.code-workspace' -maxdepth 1 -print -quit)
      if [[ $code_workspace ]]; then
        args[ARRAY_START+0]=$code_workspace
      fi
    fi

    # https://code.visualstudio.com/docs/editor/command-line#_core-cli-options
    # https://github.com/microsoft/vscode/issues/176343 No multiple -g's :(
    cmd_args=("$EDITOR" -g)
  else
    cmd_args=("$OPEN_CMD")
  fi

  echo_eval "${cmd_args[@]}" "${args[@]}"
}
