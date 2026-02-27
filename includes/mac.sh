alias libm='$EDITOR "$DOTFILES_INCLUDES"/mac.sh' # cSpell:ignore libm

# Prevent: Ruby UTF-8 to US-ASCII Encoding::UndefinedConversionError, ...
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

alias fdns='sudo killall -HUP mDNSResponder' # cSpell:ignore fdns
alias lc="launchctl"

# https://iterm2.com/documentation-scripting-fundamentals.html#setting-user-defined-variables
function iterm2_print_user_vars() {
  # Usage: Profile > Session > Configure Status Bar > Interpolated String > `\(user.gitBranch)`
  local branch
  branch=$(git_current_branch)
  if [[ $branch ]]; then
    # SF Symbols > arrow.triangle.branch > Copy symbol
    branch="􀙠 $branch"
  fi
  iterm2_set_user_var gitBranch "$branch"
}

function mac_set_screenshot_format() {
  local format="${1:-heic}" # heic | jpg | png
  defaults write com.apple.screencapture type "$format"
}

# https://www.jetbrains.com/help/ruby/working-with-the-ide-features-from-command-line.html#standalone
function mine() {
  local q_ct=${#@} q_seq
  q_seq=$(printf ' %%q%.0s' $(seq 1 "$q_ct"))
  echo_eval "open -na 'RubyMine.app' --args nosplash$q_seq" "$@"
}

function quick_look() {
  qlmanage -p "$1" > /dev/null 2>&1
}
alias ql="quick_look"

function open_from_iterm_debug() {
  touch "$OPEN_FROM_ITERM_DEBUG" "$OPEN_FROM_ITERM_DEBUG_LOG"
  truncate -s 0 "$OPEN_FROM_ITERM_DEBUG_LOG"
  trap '\rm "$OPEN_FROM_ITERM_DEBUG"' SIGINT
  tail -f "$OPEN_FROM_ITERM_DEBUG_LOG"
}

# Returns: `foo, bar`
function window_names() {
  local process_str=$1 app=${2:-$1}

  if pgrep -f "$process_str" >/dev/null 2>&1; then
    osascript -e "tell application \"System Events\" to get name of every window of (process \"$app\")"
  fi
}
