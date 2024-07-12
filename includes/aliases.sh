:
# shellcheck disable=SC2139
alias al="$EDITOR $0"
# shellcheck disable=SC2139
alias real="source $0"

# cSpell:ignore brbc brun brbf brsl brup brupg cdiff cuiv

# See also: OMZ/brew plugin
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
alias brsl='brew services list'
alias brup='brew update'
alias brupg='brew upgrade'

alias c='code'
# alias c='code-insiders'
alias ci='code-insiders'
alias cdiff='code --diff'

# `chrome` is an OS-specific alias defined in lib/linux and lib/mac
alias chrome_incognito='chrome --incognito'
# https://support.google.com/chrome/a/answer/6271282?hl=tr
# 1. Close all instances
alias chrome_with_logging='chrome --enable-logging=stderr --v=1'

alias copy_ssh_key="cb < ~/.ssh/*.pub"
alias ct="echo_eval 'rm tags && ctags -f tags -R'"
alias cui="curl -I"
alias cuiv="curl -Iv"
alias da='direnv allow'
alias dp='declare -p'

alias di='dotfiles import'
alias ds='dotfiles sync'
alias dse='dotfiles setup'

alias e='open_with_editor'
alias ee="echo_eval"
alias EED='EE_DRY_RUN=1'
alias ek="echo"

alias f='fd -t f'
alias fh='fd -t f --hidden'
alias ft="fd --no-ignore -t f '^tags$'"

# cSpell:ignore hhnv hostconf myip uroot

alias h='http'
alias hh='http --headers'
alias hhnv='http --headers --verify=no'
alias hnv='http --verify=no'

# sudo inside VSCode only accepts password and not Touch ID
alias hostconf='sudo mvim --remote-silent /etc/hosts'

alias ic="imgcat"
alias k9='kill -9'

# TODO: Other configs/defaults: env.sh > eza. These can't be set like that...yet. PR?
alias l='eza --group-directories-first --long'
alias la='eza --all --group-directories-first --long'

alias le="less"

# shellcheck disable=SC2139
alias {lp,path}='echo "$PATH" | tr ":" "\n"'
alias lps='echo "$PATH" | tr ":" "\n" | sort -f'

alias m='mine .' # RubyMine
alias mi='mediainfo'
alias myip='my_ips'

alias mysql_dump='mysqldump --no-create-info -uroot -p db_name > db_name.sql'
alias mysql_restore='mysql -uroot -p db_name < db_name.sql'

alias pg="ping google.com" # TODO: Can be confused with postgres?
alias p1="ping 1.1.1.1"
alias p192="ping 192.168.1.1"

alias pg_fg='postgres -D "$(brew --prefix)"/var/postgres'

# Make high-resolution screenshots etc. more shareable
alias png2jpg50="convert ./*.png -resize '50%' -set filename:base '%[basename]' '%[filename:base].jpg'"

# cSpell:ignore psgw rgfh rghi rgchi rgwc rgws sshconf

alias psf='ps aux | fzf'
alias psg='ps aux | grep -v " grep " | grep -i'
alias psgw='ps aux | grep -v " grep " | grep -i -w'

# - [...] foo -> - [ ] foo
alias reset_markdown_todo="gsed -i -E 's/^([*-]) \[[^]]?\]/\1 [ ]/'"

# Ripgrep
alias rg3="rg -C 1" # Show 1 line before and after
alias rga2="rg -A 2" # Show 2 lines after
alias rga3="rg -A 3" # Show 3 lines after
alias rgb2="rg -B 2" # Show 2 lines before
alias rgb3="rg -B 3" # Show 3 lines before
alias rgc='rg --case-sensitive'
alias rgf="rg -F" # Treat the pattern as a literal string instead of a regular expression
alias rgh="rg --hidden" # Include dotfiles
alias rgfh="rg -F --hidden"
alias rghi="rg --hidden --no-ignore"
alias rgchi="rg --case-sensitive --hidden --no-ignore"
alias rgw="rg -w" # Word
# shellcheck disable=SC2139
alias {rgwc,rgws}="rg -ws" # Word and case sensitive

alias shc='shellcheck'

# VSCode doesn't have ssh config highlighting
alias sshconf='mvim_open ~/.ssh/config'

# Enable aliases to be sudo'ed
alias sudo='nocorrect sudo '

alias t="tail" # common-aliases oh-my-zsh plugin sets this to tail -f
alias tf="tail -f"
alias tf50="tail -n50 -f"
alias tf100="tail -n100 -f"

alias tr1="traceroute 1.1.1.1"
alias tr192="traceroute 192.168.1.1"
alias trg='traceroute google.com'

alias th='tree -a'

alias v='mvim_open'
alias sv='sudo mvim'
alias vimrc='$EDITOR ~/.vimrc'

alias wu='who -u'

alias xbar_cd='cd ~/Library/Application\ Support/xbar/plugins'
