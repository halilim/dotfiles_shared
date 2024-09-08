# See also: OMZ/npm & OMZ/yarn plugins

alias libn='$EDITOR "$DOTFILES_INCLUDES"/lib/node.sh' # cSpell:ignore libn

alias nv="node -v"

# cSpell:ignore nigp ninp
alias ni="npm install"
alias nig="npm install -g" # global
alias nigp="npm install -g npm" # self upgrade
alias ninp="npm install \$([[ -f package-lock.json ]] || printf %s '--no-package-lock')"
alias nis="npm install -S" # save
alias nlg='npm list -g'
alias npv="npm -v"
alias nr="npm run"
alias nu="npm update"
# alias nus="npm uninstall -S"
alias nug="npm update -g"

# OMZ/yarn sets this to `yarn version`, let's keep it compatible with the other *v aliases
alias yv='yarn --version'
alias yvv='yarn version'

function npm_update_globals() {
  local packages=''

  if [[ ${NPM_UPDATE_GLOBALS_EXCLUDE_PATTERN:-''} ]]; then
    packages=$(npm -g outdated --parseable --depth=0 |
      cut -d: -f2 |
      sed 's/@[0-9.]*$//' |
      grep -Ev "$NPM_UPDATE_GLOBALS_EXCLUDE_PATTERN" |
      tr '\n' ' ')

    [[ ! $packages ]] && return 0
  fi

  echo_eval "npm update -g --silent $packages"
}
