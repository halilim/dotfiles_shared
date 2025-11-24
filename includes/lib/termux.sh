alias cdn='cd ~/storage/documents/notes'

alias pki='pkg install'
alias pkin='pkg info' # cSpell:ignore pkin
alias pkli='pkg list-installed' # cSpell:ignore pkli
alias pks='pkg search'
alias pku='pkg uninstall'

# For git and ssh commands
function termux_prepare_ssh() {
  set +e
  # shellcheck disable=SC1090
  . ~/../usr/libexec/source-ssh-agent.sh
  set -e
}
