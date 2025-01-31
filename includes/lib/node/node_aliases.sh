alias libna='$EDITOR "$DOTFILES_INCLUDES"/lib/node/node_aliases.sh' # cSpell:ignore libna

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

alias yi='yarn install'
alias yl='yarn link'
alias yul='yarn unlink'
alias ysa='yarn start'
alias ysb='yarn storybook'
alias yts='yarn test --silent'
# OMZ/yarn sets this to `yarn version`, let's keep it compatible with the other *v aliases
alias yv='yarn --version'
alias yvv='yarn version'
alias yw='yarn why'
