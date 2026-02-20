COLOR_PREFIX='\033['
COLOR_RESET="${COLOR_PREFIX}0m"
if [ -n "${ZSH_VERSION:-}" ]; then
  declare -rx COLOR_PREFIX COLOR_RESET
else
  readonly COLOR_PREFIX COLOR_RESET
  export COLOR_PREFIX COLOR_RESET
fi

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

  local echo_opts=(-e)
  if [[ ${NO_NL:-} ]]; then
    echo_opts+=(-n)
  fi
  echo "${echo_opts[@]}" "$(color_start "$color")$text${COLOR_RESET}"
}

function color_() {
  NO_NL=1 color "$@"
}

function color_arrow() {
  # Usage: color_arrow green "text"
  color "$1" "-> $2"
}

function color_start() {
  local color=$1

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

  printf %s "$COLOR_PREFIX$style;${code}m"
}
