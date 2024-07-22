:

# shellcheck disable=SC2139
# cSpell:ignore libm
alias libm="$EDITOR $0"

export OPEN_CMD='open'

# cSpell:ignore fdns
alias ahr='air_buddy_handoff receive'
alias ahs='air_buddy_handoff send'
alias cb="pbcopy"
alias chrome='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
alias fdns='sudo killall -HUP mDNSResponder'
alias lc="launchctl"
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

# https://superuser.com/a/1625752/59919
# Or move the Dock to the active display, and the app switcher should follow it
# cSpell:ignore appswitcher
function mac_app_switcher_all_displays() {
  local value="${1:-true}"
  defaults write com.apple.dock appswitcher-all-displays -bool "$value"
  killall Dock
}

function mac_set_screenshot_format() {
  local format="${1:-heic}" # heic | jpg | png
  defaults write com.apple.screencapture type "$format"
}

function quick_look() {
  qlmanage -p "$1" > /dev/null 2>&1
}
alias ql="quick_look"

function xbar_update_template() {
  # https://github.com/matryer/xbar-plugins/blob/main/CONTRIBUTING.md#xbar-config
  jq -n '{autoupdate: true, terminal: {appleScriptTemplate3: $new_val}}' \
    --arg new_val "$(cat "$DOTFILES_SHARED"/share/xbar.applescript)" \
    > ~/Library/Application\ Support/xbar/xbar.config.json
}
