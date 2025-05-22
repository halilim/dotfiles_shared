# See also: OMZ/brew plugin
:
# cSpell:ignore brbc brun brbf brsv brsi brsl brsl brsr brsre brss brst brup brupg brupd
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
alias brsv='brew services'
alias brsi='brew services info'
alias brsl='brew services list'
alias brsr='brew services run'
alias brsre='brew services restart'
alias brss='brew services start'
alias brst='brew services stop'
# shellcheck disable=SC2139
alias {brup,brupg}='brew upgrade'
alias brupd='brew update'

# Most functionality is in brew_completions.zsh
function brew_service_log() {
  local log_path=$1
  $OPEN_CMD "$log_path"
}
alias brslo='brew_service_log' # cSpell:ignore brslo
