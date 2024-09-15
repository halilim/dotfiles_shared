alias libm='$EDITOR "$DOTFILES_INCLUDES"/mac.sh' # cSpell:ignore libm

alias ahr='air_buddy_handoff receive'
alias ahs='air_buddy_handoff send'
alias cb="pbcopy"
alias chrome='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
alias fdns='sudo killall -HUP mDNSResponder' # cSpell:ignore fdns
alias lc="launchctl"

alias sm='smerge .'
alias smerge_conf='$EDITOR "$HOME/Library/Application Support/Sublime Merge/Packages/User/Preferences.sublime-settings"'

alias xbar_cd='cd ~/Library/Application\ Support/xbar/plugins'

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

function xbar_update_template() {
  # https://github.com/matryer/xbar-plugins/blob/main/CONTRIBUTING.md#xbar-config
  jq -n '{autoupdate: true, terminal: {appleScriptTemplate3: $new_val}}' \
    --arg new_val "$(cat "$DOTFILES_SHARED"/share/xbar.applescript)" \
    > ~/Library/Application\ Support/xbar/xbar.config.json
}
