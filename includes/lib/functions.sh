alias fn='$EDITOR "$DOTFILES_INCLUDES"/lib/functions.sh'

function bak_toggle() {
  if [[ $1 == *.bak ]]; then
    echo_eval 'mv %q %q' "$1" "${1%.bak}"
  else
    echo_eval 'mv %q %q' "$1" "$1.bak"
  fi
}

function bat_rebuild_syntaxes() {
  bat cache --build
}

function builtin_help() {
  local url
  url="$(printf "$BUILTIN_URL#:~:text=%s [" "$1")"
  echo_eval "$OPEN_CMD %q" "$url"
}
alias bh='builtin_help'

function cb_tmp() {
  # https://github.com/lastpass/lastpass-cli/issues/59#issuecomment-439316889
  # Usage: cb_tmp "$secret" 10
  local str=$1
  if [[ $str ]]; then
    local expiry=${2:-20} name=${3:-PASSWORD}
    if [[ ${DRY_RUN:-} ]]; then
      echo >&2 " !!! $name WILL BE COPIED TO YOUR CLIPBOARD FOR $expiry SECONDS !!! (DRY RUN)"
      return
    else
      echo >&2 " !!! $name IS COPIED TO YOUR CLIPBOARD FOR $expiry SECONDS !!! "
    fi
    printf %s "$str" | "${CLIP[*]}"
    ( sleep "$expiry" && printf '' | "${CLIP[*]}" ) &
  fi
}

function cd_or_fail() {
  local dir=${1:?dir is required} name=${2:-Directory}
  if [[ ! -d "$dir" ]]; then
    echo >&2 "$name does not exist: $dir"
    return 1
  fi

  if ! cd "$dir"; then
    echo >&2 "Could not change directory to $dir"
    return 1
  fi
}

function cd_with_header() {
  local dir=$1
  color >&2 white-bold "---> $dir"
  cd "$dir" || return
}

function color() {
  if [[ $# -lt 2 ]]; then
    local func_name=${funcstack[1]:-${FUNCNAME[0]}}

    echo 'Usage examples:'
    echo "$($func_name green "$func_name") white $($func_name yellow "'some text'")"
    echo "$($func_name green "$func_name") red-bold $($func_name yellow "'some text'")"
    return 1
  fi

  local color=$1 text=$2

  if [[ ${NO_COLOR:-} ]]; then
    echo "$text"
    return
  fi

  local code
  case "$color" in
    black*) code='30' ;;
    red*) code='31' ;;
    green*) code='32' ;;
    yellow*) code='33' ;;
    blue*) code='34' ;;
    magenta*) code='35' ;;
    cyan*) code='36' ;;
    white*) code='37' ;;
    gray*) code='90' ;;
  esac

  local style
  if [[ $color == *'-bold' ]]; then
    style='1'
  else
    style='0'
  fi

  local prefix='\033['
  local echo_opts=(-e)
  if [[ ${NO_NL:-} ]]; then
    echo_opts+=(-n)
  fi
  echo "${echo_opts[@]}" "$prefix$style;${code}m$text${prefix}0m"
}

function color_() {
  NO_NL=1 color "$@"
}

function color_arrow() {
  # Usage: color_arrow green "text"
  color "$1" "-> $2"
}

# Usage: DRY_RUN=1 FAKE_ECHO=foo echo_eval 'bar %q' "$baz"
function echo_eval() {
  local cmd dry_run=${DRY_RUN:-}
  # shellcheck disable=SC2059
  cmd=$(printf "$@")

  if [[ $dry_run || ${VERBOSE:-'1'} ]]; then
    color_arrow >&2 green "$cmd"
  fi

  # NOTE: Dry-run output is not always accurate, since some intermediate conditionals depend on a
  #       previous step actually running.FAKE_ECHO & FAKE_STATUS are used to simulate the
  #       output and return status of the command.
  if [[ $dry_run ]]; then
    echo >&2 'Dry running...'
    if [[ ${FAKE_ECHO:-} ]]; then
      echo "$FAKE_ECHO"
    fi

    if [[ ${FAKE_STATUS:-} ]]; then
      return "${FAKE_STATUS:-0}"
    fi
  else
    eval "$cmd"
  fi
}

function for_each_dir() {
  local dir
  for dir in */; do
    (
      cd_with_header "$dir"
      echo_eval "$@"
      printf '\n'
    )
  done
}

# List processes accessing a file/folder
function fuser_ps() {
  local pids
  pids=$(fuser "$1")
  [[ -z $pids ]] && return 1
  ps -fp "$pids"
}

function grep_hl() {
  grep -iE "$1|\$"
}

# https://stackoverflow.com/a/8574392/372654
# Usage: in_array 'foo' "${array[@]}" (Bash/Zsh) - in_array 'foo' $array (Zsh)
function in_array() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

# Usage: join_array '|' "${array[@]}"
function join_array() {
  local separator=$1
  shift
  local el out=''
  for el in "$@"; do
    out+="$el$separator"
  done
  out=${out%"$separator"}
  printf '%s' "$out"
}

function print_array() {
  local var_name=${1?}
  local declare_output=${2:-"$(declare -p "$var_name")"}

  local is_associative
  if echo "$declare_output" | grep -q '\-a' > /dev/null 2>&1; then
    color white-bold 'Indexed array'
  elif echo "$declare_output" | grep -q '\-A' > /dev/null 2>&1; then
    color white-bold 'Associative array'
    is_associative=1
  else
    color >&2 red 'Not an array'
    return 1
  fi

  local key
  if [ -n "${ZSH_VERSION:-}" ]; then
    # shellcheck disable=SC1009,SC2296,SC2298
    if [[ $is_associative ]]; then
      for key in ${(@k)${(P)var_name}}; do
        print_array_row "$key" "${${(P)var_name}[$key]}"
      done

    else
      # shellcheck disable=SC2124
      local array_len=${(P)#var_name[@]}
      for ((key = 1; key <= array_len; key++)); do
        print_array_row "$key" "${${(@P)var_name}[$key]}"
      done
    fi

  else
    # TODO: If the var name is "__array_ref", this will break
    declare -n __array_ref=$var_name
    for key in "${!__array_ref[@]}"; do
      print_array_row "$key" "${__array_ref[$key]}"
    done
  fi
}
alias pa='print_array'

function print_array_row() {
  local key=$1 value=$2
  value=$(declare -p value | rg '^(declare|typeset)[^=]+=(.*)' --replace '$2' --only-matching)
  # TODO: Bash: Fix: newlines in value is displayed literally, i.e. "\n"
  echo -e "$(color yellow "$key") : $(color green "$value")"
}

function in_dir() {
  local a_path=${1:?'path required'} a_dir=${2:?'directory required'} relative_path
  relative_path=$($GNU_REALPATH -s --relative-to="$a_dir" "$a_path")
  [[ $relative_path != '../'* ]]
}

function list_file_names() {
  "$GNU_FIND" "$1" -type f -printf "%f\n" | sort
}

function diff_file_names() {
  local dir1=$1 dir2=$2 file_names1 file_names2
  file_names1=$(list_file_names "$dir1")
  file_names2=$(list_file_names "$dir2")
  diff "$file_names1" "$file_names2"
}
alias dfn='diff_file_names'

function md5_of_str() {
  printf '%s' "$1" | md5
}

function date_older_than() {
  local ts=$1 ago=$2 threshold
  threshold=$("$GNU_DATE" -d "$ago ago" +%s)
  [[ $ts < $threshold ]]
}

function last_mod_older_than() {
  local file=$1 ago=$2 last_mod
  last_mod=$("$GNU_DATE" -r "$file" +%s)
  [[ -f $file ]] && date_older_than "$last_mod" "$ago"
}

# Utility for basic auto-update
function needs_update_and_mark() {
  local last_updated_file=${1:-./.last_updated_at} days=${2:-7}

  if [[ ! -f $last_updated_file ]] || last_mod_older_than "$last_updated_file" "$days days"; then
    echo_eval 'touch %q' "$last_updated_file"
    return 0
  else
    return 1
  fi
}

function read_prompt() {
  local question="${1:?}" is_secure="${2:-}" params=()
  [[ $is_secure ]] && params+=(-s)

  if [ -n "${ZSH_VERSION:-}" ]; then
    # shellcheck disable=SC2162
    read "${params[@]}" "REPLY?$question"

  elif [ -n "${BASH_VERSION:-}" ]; then
    # shellcheck disable=SC2229
    read -r -p "$question" "${params[@]}"
  fi
}

function prompt() {
  local question="$1"
  read_prompt "$question [yN] "
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    return 0
  else
    return 1
  fi
}

function relative_to() {
  $GNU_REALPATH -s --relative-to="$1" "$2"
}

function remove_broken_links() {
  local folder=${1:-.} recursive=${2:-} find_args=''

  if [[ ! $recursive ]]; then
    find_args+=' -maxdepth 1'
  fi

  find_args+=" -xtype l"

  local printf_msg
  if [[ ${DRY_RUN:-} ]]; then
    echo >&2 'Dry running...'
    printf_msg='Will remove'
  else
    find_args+=' -delete'
    printf_msg='Removing'
  fi

  find_args+=' -printf "'"$printf_msg: %%p"'\\\\n"'

  DRY_RUN='' echo_eval "$GNU_FIND %q$find_args" "$folder"
}

function remove_line_including() {
  if [[ $# -lt 2 ]]; then
    echo >&2 "Usage: ${funcstack[1]:-${FUNCNAME[0]}} text file1 [file2 ...]"
    return 1
  fi

  $GNU_SED -i "/$1/d" "${@:2}"
}
alias rml='remove_line_including'

function same_inode() {
  local inode_count
  inode_count=$($GNU_STAT --format %i "$1" "$2" | uniq | wc -l | tr -d '[:space:]')
  [[ $inode_count == 1 ]]
}
alias are_hardlinks='same_inode'

function shorten_path() {
  local given_path=$1
  echo "$given_path" | rg "^$HOME(.*)" --only-matching --passthru --replace '~$1'
}

function yaml_lint() {
  # https://mikefarah.gitbook.io/yq/upgrading-from-v3#validate-documents
  # https://mikefarah.gitbook.io/yq/usage/tips-and-tricks#validating-yaml-files
  yq 'true' "$@" > /dev/null
}
# cSpell:ignore ymll
alias ymll="yaml_lint"
