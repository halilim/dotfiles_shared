#!/usr/bin/env bash

function is_debug_enabled() {
  [[ -f ~/bin/open_from_iterm.debug ]]
}

function debug_print() {
  if ! is_debug_enabled; then
    return
  fi

  print_to_log "$1"
}

function debug_vars() {
  if ! is_debug_enabled; then
    return
  fi

  for arg in "$@"; do
    print_to_log "$(declare -p "$arg")"
  done

  print_to_log ''
}

function get_editor_titles() {
  if [[ $EDITOR = mvim* ]]; then
    window_names 'MacVim'
  elif [[ $EDITOR == code || $EDITOR == */code ]]; then
    window_names 'Visual Studio Code.app' 'Code'
  elif [[ $EDITOR == code-insiders || $EDITOR == */code-insiders  ]]; then
    window_names 'Visual Studio Code - Insiders.app' 'Code - Insiders'
  fi
}

function print_to_log() {
  echo "$1" >> ~/bin/open_from_iterm.log
}

# Returns: `foo, bar`
function window_names() {
  local process_str=$1 app=${2:-$1}

  if pgrep -f "$process_str" >/dev/null 2>&1; then
    osascript -e "tell application \"System Events\" to get name of every window of (process \"$app\")"
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

function is_in_rubymine_titles() {
  local rubymine_titles=$1 git_dir=$2

  if [[ $git_dir ]]; then
    local rubymine_title
    for rubymine_title in ${rubymine_titles//,/ }; do
      # Format: `<project>( – <file>)?` - not a regular dash
      if [[ $rubymine_title == "$git_dir" || $rubymine_title == "$git_dir – "* ]]; then
        return 0
      fi
    done
  fi

  return 1
}

function open_with_rubymine() {
  local abs_path=$1 line=$2 column=$3
  # https://www.jetbrains.com/help/ruby/opening-files-from-command-line.html#88f1a126
  # Note: column is only documented in the "Windows" tab. -1: it goes to the next character (bug?)
  ~/bin/mine --line "$line" --column $((column - 1)) "$abs_path"
}

function is_in_editor_titles() {
  local git_dir=$1 git_path=$2 editor_titles=$3 parent_path parent_dir project_path project_dir
  parent_path=$(dirname "$git_path")
  parent_dir=$(basename "$parent_path")
  project_path=$(get_project_path "$parent_path")
  project_dir=$(basename "$project_path")
  debug_vars parent_path parent_dir project_path project_dir

  local editor_title
  for editor_title in ${editor_titles//,/ }; do
    if [[ $editor_title &&
          ($git_dir && $editor_title == *$git_dir)
          || ($parent_dir && $editor_title == *$parent_dir)
          || ($project_dir && $editor_title == *$project_dir) ]]; then
      return 0
    fi
  done

  return 1
}
