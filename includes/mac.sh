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

function quick_look() {
  qlmanage -p "$1" > /dev/null 2>&1
}
alias ql="quick_look"
