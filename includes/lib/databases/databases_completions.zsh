function _mysql_databases() {
  # shellcheck disable=SC2034
  local context state state_descr line
  # shellcheck disable=SC2034
  typeset -A opt_args

  local type=${1:-mysql}
  _arguments '1: :->host' '2: :(root)' '3: :(root)'

  case $state in
    host)
      local hosts=('127.0.0.1')
      # shellcheck disable=SC2207
      hosts+=($(docker_hosts "$type"))
      compadd -a hosts
      ;;
  esac
}

compdef _mysql_databases mysql_databases
compdef '_mysql_databases mariadb' mariadb_databases
