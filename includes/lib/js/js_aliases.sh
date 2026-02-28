# cSpell:disable

alias libjsa='$EDITOR "$DOTFILES_INCLUDES"/lib/js/js_aliases.sh'

alias buna='bun add'
alias bunad='bun add --dev'
alias buni='bun install'
alias bunrb='bun run --bun'
alias bunrd='bun run --bun dev'
alias bunrm='bun remove'
alias bunu='bun update'
alias bunv='bun --version'
alias bunxb='bunx --bun'

alias nv='node -v'

alias ni='npm install'
alias nig='npm install -g' # global
alias nigp='npm install -g npm' # self upgrade
alias ninp='npm install $([[ -f package-lock.json ]] || printf %s "--no-package-lock")'
alias nis='npm install -S' # save
alias nlg='npm list -g'
alias npv='npm --version'
alias nr='npm run'
alias nrb='npm run build'
alias nrd='npm run dev'
alias nu='npm update'
alias nug='npm update -g'

alias yi='yarn install'
alias yl='yarn link'
alias yul='yarn unlink'
alias ys='yarn start'
alias ysb='yarn storybook'
alias ysv='yarn serve'
alias ysvs='yarn set version stable' # Update to the latest versions (v3+)
alias yt='yarn test --silent'
# OMZ/yarn sets this to `yarn version`, let's keep it compatible with the other *v aliases
alias yv='yarn --version'
alias yvv='yarn version'
alias yw='yarn watch'
alias ywh='yarn why'
