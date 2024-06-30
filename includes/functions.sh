:
# shellcheck disable=SC2139
alias fn="$EDITOR $0"
# shellcheck disable=SC2139
alias refn="source $0"

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
    echo "$func_name white 'some text'"
    echo "$func_name red-bold 'some text'"
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
  # Dependencies:
  # * gnumfmt - macOS: brew install coreutils, already in ~/Brewfile

  curl -ILs "$1" |
      http_header_value Content-Length |
      gnumfmt --to=si --suffix=B
}
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

# Usage: EE_DRY_RUN=1 FAKE_RETURN=foo echo_eval 'bar %q' "$baz"
function echo_eval() {
  local cmd
  # shellcheck disable=SC2059
  cmd=$(printf "$@")
  color_arrow >&2 green "$cmd"
  # Dry-run output is not always accurate, since some intermediate conditionals depend on a
  # previous step actually running
  if [[ ${EE_DRY_RUN:-} ]]; then
    echo >&2 'Dry running...'
    [[ ${FAKE_RETURN:-} ]] && echo "$FAKE_RETURN"
    return 0
  else
    eval "$cmd"
  fi
}

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
# Usage: join_array '|' $array (Zsh) / join_array '|' "${array[@]}" (Bash/Zsh)
function join_array() {
  local delim=$1 arr=$2
  shift 2
  printf %s "${arr[*]}${*/#/$delim}"
}

function list_file_names() {
  # ls -B "$1"
  # find "$1" -type_str f | rg -N .
  gfind "$1" -type_str f -printf "%f\n" | sort
}

function diff_file_names() {
  diff <(list_file_names "$1") <(list_file_names "$2")
}
alias dfn='diff_file_names'

function md5_of_str() {
  printf '%s' "$1" | md5
}

function my_external_ip() {
  # Doesn't recognize proxy (Caches the result?)
  # dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com | tr -d '"'
  curl -fLs ifconfig.me
}

function myip_whois() {
  local ip
  ip=$(echo_eval my_external_ip)
  echo_eval 'whois %q' "$ip"
}
alias whois_myip='myip_whois'

# https://stackoverflow.com/a/5945322/372654
function mvim_open() {
  if [[ "$#" -eq 1 ]]; then
    if [[ -d $1 ]]; then
      mvim "$1" +':lcd %'
    else
      mvim --remote-silent "$1"
    fi
  else
    mvim
  fi
}

function date_older_than() {
  local ts=$1 ago=$2 threshold
  threshold=$(gdate -d "$ago ago" +%s)
  [[ $ts < $threshold ]]
}

function last_mod_older_than() {
  local file=$1 ago=$2 last_mod
  last_mod=$(gdate -r "$file" +%s)
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

function ssl_check() {
  local domain=$1
  printf Q | openssl s_client -servername "$domain" -connect "$domain":443 | openssl x509 -noout -dates
}
alias tls_check='ssl_check'

function update_and_backup() {
  (
    cd "$HOME" || return 1

    UPDATE_BACKUP_CMDS+=(
      "mvim +'PlugUpgrade | PlugUpdate'"
      'o /Applications' # Manually update the non-App Store, infrequently-opened, etc. apps
    )

    local cmd
    for cmd in "${UPDATE_BACKUP_CMDS[@]}"; do
      echo_eval "$cmd"
      printf '\n'
    done
  )
}

function update_iterm2_color_schemes() {
  if [[ -d "$ITERM2_COLOR_SCHEMES" ]]; then
    git --git-dir="$ITERM2_COLOR_SCHEMES"/.git pull --prune
  else
    mkdir -p "$(dirname "$ITERM2_COLOR_SCHEMES")"
    git clone https://github.com/mbadolato/iTerm2-Color-Schemes.git "$ITERM2_COLOR_SCHEMES"
  fi

  "$ITERM2_COLOR_SCHEMES"/tools/import-scheme.sh "$ITERM2_COLOR_SCHEMES"/schemes/*
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
alias wb="which_ bat"
alias wl="which_ less"

# Why not in ~/bin? Because this needs the whole environment to be able to detect all types of
# symbols. And loading all that is a slow process. This way, it's all in the current shell.
function which_detailed() {
  local input=$1 type_str type_ret

  # When it's a variable name in 2nd round
  if [[ $input == '$'* ]]; then
    printf '%s=' "$input"
    eval "echo ""$input"""
    return
  fi

  # Starting with a non-word char, probably a global alias in 2nd round
  if [[ $input =~ ^[^[:alnum:]_] ]]; then
    return
  fi

  type_str=$(type "$input")
  type_ret=$?

  if [[ $type_str == *' function '* ]]; then
    whence -v "$input"
    echo '--------------------------------------------------------------------------------------------'
    echo 'Comments are not shown, and there can be other differences between the output and the source'
    echo '--------------------------------------------------------------------------------------------'
    which -x 2 "$input" | bat --language=sh

  elif [[ $type_str == *' alias '* ]]; then
    echo "$type_str"
    local full_cmd=${type_str#*for } cmd
    cmd=${full_cmd%% *}
    [[ $cmd == "$input" ]] && return # Prevent infinite loop, e.g. `alias ls=ls -etc`
    which_detailed "$cmd"

  elif [[ $type_str == *' is '* ]]; then
    local file="${type_str#*is }"
    if [[ -L $file ]]; then
      ls -l "$file"
    else
      echo "$type_str"
    fi

  else
    echo "$type_str"
    return $type_ret
  fi
}
alias wh="which_detailed"

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
alias ymll="yaml_lint"
