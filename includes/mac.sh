:
# shellcheck disable=SC2139
alias libm="$EDITOR $0"

# shellcheck disable=SC2139
alias brewfile="$EDITOR ~/Brewfile"

# See also: OMZ/brew plugin
alias brb='brew bundle'
alias bri='brew install'
alias brin='brew info'
alias brl='brew list'
alias brs='brew search'
alias brsl='brew services list'
alias bru='brew uninstall'
alias brup='brew update'
alias brupg='brew upgrade'

alias brbf='brew bump-formula-pr --version=ver name'
alias brbc='brew bump-cask-pr --version=ver name'

alias cb="pbcopy"
alias chrome='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
alias fdns='sudo killall -HUP mDNSResponder'
alias lc="launchctl"
alias o='open'
alias sjpg='defaults write com.apple.screencapture type heic' # heic | jpg | png

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

function iterm_tab() {
  local dir=$1 cmd=$2 cd_cmd='' cmd_cmd=''

  [[ $dir ]] && cd_cmd="write text \"cd $dir\""
  [[ $cmd ]] && cmd_cmd="write text \"$cmd\""
  # echo "cd_cmd: $cd_cmd"

  osascript &> /dev/null <<- EOF
      tell application "iTerm2"
          tell current window to set newWindow to (create tab with default profile)
          tell current session of newWindow
              $cd_cmd
              $cmd_cmd
          end tell
      end tell
EOF
}

function quick_look() {
  qlmanage -p "$1" > /dev/null 2>&1
}
alias ql="quick_look"

function sm() {
  smerge "${1:-.}"
}

# shellcheck disable=SC2139
alias smerge_conf="$EDITOR $HOME'/Library/Application Support/Sublime Merge/Packages/User/Preferences.sublime-settings'"
