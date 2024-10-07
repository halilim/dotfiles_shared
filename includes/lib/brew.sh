# See also: OMZ/brew plugin

# cSpell:ignore brbc brun brbf brsi brsl brup brupd
# shellcheck disable=SC2139
alias {bru,brun}='brew uninstall'
alias brb='brew bundle'
alias brbc='brew bump-cask-pr --version=ver name'
alias brbf='brew bump-formula-pr --version=ver name'
alias brewfile='$EDITOR ~/Brewfile'
alias bri='brew install'
alias bric='brew install --cask'
alias brin='brew info'
alias brl='brew list'
alias brs='brew search'
alias brsi='brew services info'
alias brsl='brew services list'
alias brup='brew upgrade'
alias brupd='brew update'

# Most functionality is in brew_completions.zsh
function brew_service_log() {
  local log_path=$1
  $OPEN_CMD "$log_path"
}
alias brslo='brew_service_log' # cSpell:ignore brslo
