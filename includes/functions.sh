alias fn='$EDITOR "$DOTFILES_INCLUDES"/functions.sh'
alias refn='source "$DOTFILES_INCLUDES"/functions.sh' # cSpell:ignore refn

function bak_toggle() {
  if [[ $1 == *.bak ]]; then
    echo_eval 'mv %q %q' "$1" "${1%.bak}"
  else
    echo_eval 'mv %q %q' "$1" "$1.bak"
  fi
}

function builtin_help() {
  local url
  url="$(printf "$BUILTIN_URL#:~:text=%s [" "$1")"
  echo_eval 'o %q' "$url"
}
alias bh='builtin_help'

function cd_with_header() {
  local dir=$1
  color >&2 white-bold "---> $dir"
  cd "$dir" || return
}

function color() {
  local color=${1:-''} text=${2:-''}
  if [[ ! $color || ! $text ]]; then
    local func_name
    if [ -n "${ZSH_VERSION:-}" ]; then
      # shellcheck disable=SC2154
      func_name="${funcstack[1]}"
    else
      func_name="${FUNCNAME[0]}"
    fi

    echo 'Usage examples:'
    echo "$($func_name green "$func_name") white $($func_name yellow "'some text'")"
    echo "$($func_name green "$func_name") red-bold $($func_name yellow "'some text'")"
    return 1
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
  esac

  local style
  if [[ $color == *'-bold' ]]; then
    style='1'
  else
    style='0'
  fi

  local prefix='\033['
  echo -e "$prefix$style;${code}m$text${prefix}0m"
}

function color_arrow() {
  # Usage: color_arrow green "text"
  # shellcheck disable=SC2154
  color "$1" "-> $2"
}

function content_length() {
  curl -ILs "$1" |
    http_header_value Content-Length |
    "$GNU_NUMFMT" --to=si --suffix=B
}
# cSpell:ignore cuil
alias cuil="content_length"

function curl_time() {
  if [[ ! $1 ]]; then
    echo >&2 "Usage: $0 <url> [<interface>]"
    return 1
  fi

  local params=()
  [[ $2 ]] && params+=(--interface "$2")

  # https://stackoverflow.com/a/22625150/372654
  # cSpell:disable
  curl "$1" "${params[@]}" -Isv -o /dev/null -w "     time_namelookup:  %{time_namelookup}s
        time_connect:  %{time_connect}s
     time_appconnect:  %{time_appconnect}s
    time_pretransfer:  %{time_pretransfer}s
       time_redirect:  %{time_redirect}s
  time_starttransfer:  %{time_starttransfer}s
                       ---------
          time_total:  %{time_total}s\n"
  # cSpell:enable
}

# Usage: DRY_RUN=1 FAKE_RETURN=foo echo_eval 'bar %q' "$baz"
function echo_eval() {
  local cmd
  # shellcheck disable=SC2059
  cmd=$(printf "$@")
  color_arrow >&2 green "$cmd"
  # Dry-run output is not always accurate, since some intermediate conditionals depend on a
  # previous step actually running
  if [[ ${DRY_RUN:-} ]]; then
    echo >&2 'Dry running...'
    [[ ${FAKE_RETURN:-} ]] && echo "$FAKE_RETURN"
    return 0
  else
    eval "$cmd"
  fi
}

function edit_function() {
  local location
  location=$(locate_function "$1")
  if [[ ! $location ]]; then
    return 1
  fi

  open_with_editor "$location"
}
alias ef='edit_function'

function encode_uri_component() {
  jq -rR @uri <<< "$1"
}

function for_each_dir() {
  local dir
  for dir in */; do
    (
      cd_with_header "$dir" || return
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

function http_header_value() {
  local headers header

  if [[ $# = 1 ]]; then
    headers=$(cat -)
    header=$1
  else
    headers=$1
    header=$2
  fi

  echo "$headers" |
      grep -i "^$header:" |
      cut -d " " -f 2 |
      tr -d '\r'
}

# https://stackoverflow.com/a/49418778/372654
# Usage: join_array '|' "${array[@]}" (Bash/Zsh) - join_array '|' $array (Zsh)
function join_array() {
  local delim=$1 arr=$2
  shift 2
  printf %s "${arr[*]}${*/#/$delim}"
}

function list_file_names() {
  "$GNU_FIND" "$1" -type f -printf "%f\n" | sort
}

function diff_file_names() {
  diff <(list_file_names "$1") <(list_file_names "$2")
}
alias dfn='diff_file_names'

function locate_function() {
  local function_name=$1 output file line is_zsh

  if [ -n "${ZSH_VERSION:-}" ]; then
    is_zsh=1
  fi

  if [ $is_zsh ]; then
    output=$(whence -v "$function_name") # fun is a shell function from /foo/bar.sh
    file=${output#*from }
  else
    output=$(declare -F "$function_name") # fun 123 /foo/bar.sh
    output=${output#*"$function_name "}
    file=${output#* }
  fi

  if [[ ! -e $file ]]; then
    echo >&2 "$output"
    return 1
  fi

  if [[ $is_zsh ]]; then
    line=$(grep -n "$function_name(" "$file")
    line=${line%%:*}
  else
    line=${output%% *}
  fi

  echo "$file:$line"
}

function md5_of_str() {
  printf '%s' "$1" | md5
}

function my_external_ip() {
  # Doesn't recognize proxy (Caches the result?)
  # dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com | tr -d '"'
  curl -fLs ifconfig.me
}

# cSpell:ignore myip
function myip_whois() {
  local ip
  ip=$(echo_eval my_external_ip)
  echo_eval 'whois %q' "$ip"
}
alias whois_myip='myip_whois'

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

function open_with_editor() {
  local abs_path_line_col=$1

  if [[ $EDITOR = "$VIM" ]]; then
    vim_open "$abs_path_line_col"
  elif [[ $EDITOR = code || $EDITOR = code-insiders ]]; then
    # https://code.visualstudio.com/docs/editor/command-line#_core-cli-options
    /usr/local/bin/"$EDITOR" -g "$abs_path_line_col"
  else
    open "$abs_path_line_col"
  fi
}

function pbcopy_tmp() {
  # https://github.com/lastpass/lastpass-cli/issues/59#issuecomment-439316889
  # Usage: pbcopy_tmp "$secret" 10
  local str=$1
  if [[ $str ]]; then
    local expiry=${2:-20} name=${3:-PASSWORD}
    echo -n "$str" | cb
    echo " !!! $name IS COPIED TO YOUR CLIPBOARD FOR $expiry SECONDS !!! "
    ( sleep "$expiry"  && echo -n '' | cb ) &
  fi
}

function port_check() {
  local port=$1 \
    out

  out=$(lsof -nP +c0 -iTCP:"$port" -sTCP:LISTEN)
  echo "$out"

  if [[ $out =~ docker ]]; then
    docker container ls --format "table {{.ID}}\t{{.Names}}\t{{.Ports}}" -a | rg -n -w "$port"
  fi
}

function postgres_databases() {
  local uri=$1
  psql "$uri"/postgres -Atc 'SELECT datname FROM pg_database'
}

function postgres_tables() {
  local uri=$1 db=$2
  psql "$uri"/"$db" -Atc "SELECT tablename FROM pg_catalog.pg_tables WHERE schemaname='public'"
}

function read_prompt() {
  local question="$1" is_secure="$2" params=()
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

function remove_broken_links()  {
  local folder=${1:-.} recursive=${2:-} find_args=()

  if [[ ! $recursive ]]; then
    find_args+=('-maxdepth 1')
  fi

  find_args+=('-xtype l' '-print')

  if [[ ! ${DRY_RUN:-} ]]; then
    find_args+=('-delete')
  fi

  DRY_RUN='' echo_eval "$GNU_FIND %q ${find_args[*]}" "$folder"
}

function same_inode() {
  local inode_count
  inode_count=$($GNU_STAT --format %i "$1" "$2" | uniq | wc -l | tr -d '[:space:]')
  [[ $inode_count == 1 ]]
}
alias are_hardlinks='same_inode'

function ssl_check() {
  local domain=$1
  printf Q | openssl s_client -servername "$domain" -connect "$domain":443 | openssl x509 -noout -dates
}
alias tls_check='ssl_check'

function vim_open() {
  local vim_cmd=()
  if [[ ${SUDO:-} ]]; then
    vim_cmd+=(sudo)
  fi
  vim_cmd+=("$VIM")

  # https://stackoverflow.com/a/5945322/372654
  if [[ "$#" -eq 1 ]]; then
    if [[ -d $1 ]]; then
      vim_cmd+=("$1" +':lcd %')
    else
      if [[ ! ${VIM_NO_SERVER:-} ]]; then
        vim_cmd+=("--remote-silent")
      fi
      vim_cmd+=("$1")
    fi
  fi

  "${vim_cmd[@]}"
}

function which_() {
  local cmd=$1 name=$2 file_path
  file_path=$(which "$name")
  if [[ -f $file_path ]]; then
    "$cmd" "$file_path"
  else
    echo "$file_path"
  fi
}
alias wb='which_ "$BAT_CMD"'
alias wl='which_ less'

# Why not in ~/bin? Because this needs the whole environment to be able to detect all types of
# symbols. And loading all that is a slow process. This way, it's all in the current shell.
function which_detailed() {
  local input=$1 type_str type_ret is_zsh

  if [ -n "${ZSH_VERSION:-}" ]; then
    is_zsh=1
  fi

  # When it's a variable name in 2nd round
  if [[ $input == '$'* ]]; then
    local bare_name
    bare_name="${input#'$'}"
    local declare_output
    declare_output=$(declare -p "$bare_name")
    printf %s "$declare_output"

    if [[ $declare_output == 'typeset -g'* ]]; then
      local func_name
      if [ $is_zsh ]; then
        # shellcheck disable=SC2154
        func_name="${funcstack[1]}"
      else
        func_name="${FUNCNAME[0]}"
      fi

      printf %s " # -g (global) flag is probably due to the local scope of $func_name"
    fi

    printf '\n'

    return
  fi

  # Starting with a non-word char, probably a global alias in 2nd round
  if [[ $input =~ ^[^[:alnum:]_] ]]; then
    return
  fi

  local type_args=()
  if [[ $is_zsh ]]; then
    type_args+=(-w) # "...: function" / "...: command"
  else
    type_args+=(-t) # "function" / "...: file"
  fi

  type_str=$(type "${type_args[@]}" "$input")
  type_ret=$?

  if [[ $type_str == *'function'* ]]; then
    local bat=("$BAT_CMD" --language=sh --paging=never)

    # Check out if you have (a lot of) time :) https://unix.stackexchange.com/a/85250/4678
    locate_function "$input"
    if [[ $is_zsh ]]; then
      which -x 2 "$input" | "${bat[@]}"
    else
      declare -f "$input" | "${bat[@]}"
    fi

    color >&2 yellow 'Comments are not shown, and the output can differ from the source'

  elif [[ $type_str == *'alias'* ]]; then
    local type_output
    exec 5>&1
    type_output=$(type "$input" 2>&1 | tee >(cat - >&5))
    exec 5>&-

    if [ $is_zsh ]; then
      type_output=${type_output#*for } # Zsh says "... is an alias for ..."
    else
      type_output=${type_output#*to \`} # Bash says "... is aliased to `...'"
      type_output=${type_output%\'*}
    fi

    type_output=${type_output%% *} # Remove arguments

    [[ $type_output == "$input" ]] && return # Prevent infinite loop, e.g. `alias ls=ls -etc`
    which_detailed "$type_output"

  elif [[ $type_str == *'command'* || $type_str == *'file'* ]]; then
    local file_out
    file_out=$(type "$input")
    local file="${file_out#*is }"

    if [[ -L $file ]]; then
      ls -l "$file"
    else
      echo "$file"
    fi

  else
    echo "$type_str"
    return $type_ret
  fi
}
alias wh="which_detailed"

  # cSpell:ignore whoip
function whoip() {
  local ip
  ip=$(dig +short "$1" | head -n1)
  local cmd="whois $ip"
  echo >&2 "$cmd"
  printf "=%.0s" $(seq 1 ${#cmd})

  # Yeah, the long version by default, since whois outputs are so inconsistent...
  if [[ $2 == '-s' ]]; then
    printf '\n'
    eval "$cmd" | noglob grep -i orgname | sed -e 's/OrgName:[[:space:]]*//' | sed -e 's/[[:space:]]*$//'
    printf '\n'
  else
    eval "$cmd" | more
  fi
}

function yaml_lint() {
  local file
  for file in "$@"; do
    echo "-> $file"
    js-yaml "$file" 1> /dev/null
  done
}
# cSpell:ignore ymll
alias ymll="yaml_lint"
