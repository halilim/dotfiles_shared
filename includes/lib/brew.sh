# See also: OMZ/brew plugin
:
export HOMEBREW_NO_AUTO_UPDATE=1 # Covered by update_and_backup ($UPDATE_BACKUP_CMDS)
export HOMEBREW_NO_ENV_HINTS=1

# cSpell:ignore brbc brun brbf brri brsv brsi brsl brsl brsr brsre brss brst brup brupg brupd
# shellcheck disable=SC2139
alias {bru,brun}='brew uninstall'
alias brb='brew bundle'
alias brbc='brew bump-cask-pr --version=ver name'
alias brbf='brew bump-formula-pr --version=ver name'
alias bred='brew edit'
alias brewfile='$EDITOR ~/Brewfile'
alias bri='brew install'
alias bric='brew install --cask'
alias brin='brew info'
alias brl='brew list'
alias bro='brew outdated'
# shellcheck disable=SC2139
alias {brei,brri}='brew reinstall'
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

# Interactive Zsh: OMZ > brew plugin, Non-interactive Zsh & all Bash: this helper
function brew_activate() {
  local brew_bin=/opt/homebrew/bin/brew
  if [[ -e "$brew_bin" ]]; then
    eval "$($brew_bin shellenv)"
  fi
}

# Most functionality is in brew_completions.zsh
function brew_service_log() {
  local log_path=$1
  $OPEN_CMD "$log_path"
}
alias brslo='brew_service_log' # cSpell:ignore brslo
