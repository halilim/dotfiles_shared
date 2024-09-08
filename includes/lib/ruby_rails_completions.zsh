_gem_()  {
  local state

  _arguments '1: :->cmd' '2: :->gem'

  # shellcheck disable=2046
  case $state in
    cmd) compadd 'cd' 'doc' 'src' ;;
    gem) compadd $(bundle exec gem list | tr ' ' '/' | tr -d '()') ;;
  esac
}
compdef _gem_ gem_
