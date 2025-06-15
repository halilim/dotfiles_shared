alias al='$EDITOR "$DOTFILES_INCLUDES"/aliases.sh'
alias real='source "$DOTFILES_INCLUDES"/aliases.sh'
alias alc='$EDITOR "$DOTFILES_CUSTOM"/includes/aliases.sh'

alias c='code'
alias cb='$CLIP'
# alias c='code-insiders'
alias ci='code-insiders'
alias cdiff='code --diff' # cSpell:ignore cdiff

# `chrome` is an OS-specific alias defined in lib/linux and lib/mac
alias chrome_incognito='chrome --incognito'
# https://support.google.com/chrome/a/answer/6271282?hl=tr
# 1. Close all instances
alias chrome_with_logging='chrome --enable-logging=stderr --v=1'

alias crone='crontab -e'
alias cronl='crontab -l | bat --language=crontab' # cSpell:ignore cronl

# cSpell:ignore cuiv
alias ct="echo_eval 'rm tags && ctags -f tags -R'"
alias cui="curl -I"
alias cuiv="curl -Iv"
alias da='direnv allow'
alias dp='declare -p'

# cSpell:ignore dcdc dcds dric dris
alias dcd='cd $DOTFILES'
# shellcheck disable=SC2139
alias {dcdc,cdd}='cd $DOTFILES_CUSTOM'
alias dcds='cd $DOTFILES_SHARED'
alias di='dotfiles import'
alias dic='dotfiles import custom'
alias dis='dotfiles import shared'
alias dot='dotfiles edit'
alias dri='dotfiles revert_import'
alias dric='dotfiles revert_import custom'
alias dris='dotfiles revert_import shared'
alias ds='dotfiles sync'
alias dse='dotfiles setup'

alias e='open_with_editor'
alias ee="echo_eval"
alias ek="echo"

alias f='fd -t f'
alias fh='fd -t f --hidden'
alias ft="fd --no-ignore -t f '^tags$'"

# cSpell:ignore hhnv hostconf myip uroot omzp

alias h='http'
alias hh='http --headers'
alias hhnv='http --headers --verify=no'
alias hnv='http --verify=no'

# sudo inside VSCode only accepts password and not Touch ID
alias hostconf='open_with_editor /etc/hosts'

alias ic="imgcat"
alias k9='kill -9'

alias l='eza --group-directories-first --long'
alias la='eza --all --group-directories-first --long'

alias le="less"

# shellcheck disable=SC2139
alias {lp,path}='echo "$PATH" | tr ":" "\n"'
alias lps='echo "$PATH" | tr ":" "\n" | sort -f'

alias lzd='lazydocker'
alias lzg='lazygit'

alias m='mine .' # RubyMine
alias mi='mediainfo'
alias mii='mise install'
alias mil='mise list'
alias mit='mise trust'
alias miu='mise uninstall'
alias myip='my_ips'

alias mysql_dump='mysqldump --no-create-info -uroot -p db_name > db_name.sql'
alias mysql_restore='mysql -uroot -p db_name < db_name.sql'

alias notes='$EDITOR ~/Desktop/notes.md'
# cSpell:ignore notesv
alias notesv='vim_open ~/Desktop/notes.md'

alias o='$OPEN_CMD'

alias omzp='open_with_editor ~/.oh-my-zsh/plugins/'

alias pg='ping google.com'
alias p1='ping 1.1.1.1'
alias p192='ping 192.168.1.1'

alias pg_fg='postgres -D "$(brew --prefix)"/var/postgres'

# Make high-resolution screenshots etc. more shareable
alias png2jpg50="convert ./*.png -resize '50%' -set filename:base '%[basename]' '%[filename:base].jpg'"

# cSpell:ignore psgw rgfh rghi rgchi rgnt rgsw rgwc rgws sshc sshconf

alias psf='ps aux | fzf'
alias psg='ps aux | grep -v " grep " | grep -i'
alias psgw='ps aux | grep -v " grep " | grep -i -w'

# - [...] foo -> - [ ] foo
alias reset_markdown_todo='"$GNU_SED" -i -E '"'s/^([*-]) \[[^]]?\]/\1 [ ]/'"

# Ripgrep
alias rg3='rg -C 1' # Show 1 line before and after
alias rga2='rg -A 2' # Show 2 lines after
alias rga3='rg -A 3' # Show 3 lines after
alias rgb2='rg -B 2' # Show 2 lines before
alias rgb3='rg -B 3' # Show 3 lines before
alias rgc='rg -s'
alias rgf="rg -F" # Treat the pattern as a literal string instead of a regular expression
alias rgh='rg -.' # Include dotfiles
alias rgfh='rg -.F'
alias rghi='rg -. --no-ignore'
alias rgchi='rg -.s --no-ignore'
alias rgnt="rg -g '!features/' -g '!spec/' -g '!test/' -g '!__tests__/' -g '!*.test.*'"
alias rgw='rg -w' # Word
# shellcheck disable=SC2139
alias {rgsw,rgwc,rgws}='rg -sw' # Word and case sensitive

# cSpell:ignore shsd shsfd shsz shsdz
alias shc='shellcheck'
alias shs='shellspec'
# shellcheck disable=SC2139
alias {shsd,shsfd}='shellspec -f d'
alias shsz='shellspec -s zsh'
alias shsdz='shellspec -f d -s zsh'

# shellcheck disable=SC2139
alias {sshc,ssh_copy_key,copy_ssh_key}='cb < ~/.ssh/id_*.pub'
alias sshconf='vim_open ~/.ssh/config'

alias str='stree .' # cSpell:ignore stree

alias taf="tail -f"
alias taf50="tail -n50 -f"
alias taf100="tail -n100 -f"

alias tr1="traceroute 1.1.1.1"
alias tr192="traceroute 192.168.1.1"
alias trg='traceroute google.com'

alias th='tree -a'
alias tv='bat .tool-versions'

alias v='vim_open'
alias sv='SUDO=1 vim_open'
alias vimrc='$EDITOR ~/.vimrc'

alias wu='who -u'

source_custom aliases.sh

for lib in "${DOTFILES_INCLUDE_LIBS[@]}"; do
  source_with_custom "lib/$lib/${lib}_aliases.sh"
done
