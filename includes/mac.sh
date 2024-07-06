:
# shellcheck disable=SC2139
alias libm="$EDITOR $0"

alias ahr='air_buddy_handoff receive'
alias ahs='air_buddy_handoff send'
alias cb="pbcopy"
alias chrome='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
alias fdns='sudo killall -HUP mDNSResponder'
alias lc="launchctl"
alias o='open'
alias sjpg='defaults write com.apple.screencapture type heic' # heic | jpg | png
alias sm='smerge .'
# shellcheck disable=SC2139
alias smerge_conf="$EDITOR $HOME'/Library/Application Support/Sublime Merge/Packages/User/Preferences.sublime-settings'"

# https://iterm2.com/documentation-scripting-fundamentals.html#setting-user-defined-variables
function iterm2_print_user_vars() {
  iterm2_set_user_var pathShort "$(iterm2_custom_path_short)"
}

function iterm2_custom_path_short() {
  local dir
  dir=$(git rev-parse --show-toplevel 2> /dev/null || pwd)
  if [[ $dir == "$HOME" ]]; then
    dir='~'
  fi
  echo "${dir:t}"
}

function quick_look() {
  qlmanage -p "$1" > /dev/null 2>&1
}
alias ql="quick_look"
