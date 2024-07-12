# See also: OMZ/npm plugin

# cSpell:ignore nigp ninp

alias nv="node -v"

alias ni="npm install"
alias nig="npm install -g" # global
alias nigp="npm install -g npm" # self upgrade
alias ninp="npm install \$([[ -f package-lock.json ]] || printf %s '--no-package-lock')"
alias nis="npm install -S" # save
alias npv="npm -v"
alias nu="npm update"
# alias nus="npm uninstall -S"
alias nug="npm update -g"
