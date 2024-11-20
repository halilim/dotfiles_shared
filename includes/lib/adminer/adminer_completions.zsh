function _adminer() {
  # shellcheck disable=SC2034
  local context state state_descr line
  # shellcheck disable=SC2034
  typeset -A opt_args

  local db_type host username password url

  # shellcheck disable=SC2154
  if [[ ${#words} -ge 2 ]]; then
    db_type="${words[*]:1:1}"
  fi

  if [[ $db_type == 'sqlite' ]]; then
    _arguments '1: :->db_type' '2: :->database' '3: :->table'

    database="${words[*]:2:1}"
  else
    _arguments '1: :->db_type' '2: :->host' '3: :->username' '4: :->password' '5: :->database' '6: :->table'

    host="${words[*]:2:1}"
    username="${words[*]:3:1}"
    password="${words[*]:4:1}"
    database="${words[*]:5:1}"
    url="$db_type://$username:$password@$host"
  fi

  case $state in
    db_type) compadd mariadb mysql postgres sqlite ;;
    host)
      local hosts=('127.0.0.1')
      # shellcheck disable=SC2207
      hosts+=($(docker_hosts "$db_type"))
      compadd -a hosts
      ;;

    username)
      local username_suggestions=()
      case "$db_type" in
        mariadb|mysql) username_suggestions+=(root) ;;
        postgres) username_suggestions+=("$(whoami)" postgres) ;;
      esac
      compadd -a username_suggestions
      ;;

    password)
      local password_suggestions=()
      case "$db_type" in
        mariadb|mysql) password_suggestions+=(root) ;;
        postgres) password_suggestions+=(postgres) ;;
      esac
      compadd -a password_suggestions
      ;;

    database)
      # shellcheck disable=2046
      case $db_type in
        mariadb) compadd $(mariadb_databases "$host" "$username" "$password") ;;
        mysql) compadd $(mysql_databases "$host" "$username" "$password") ;;
        postgres) compadd $(postgres_databases "$url") ;;
        sqlite) _files ;;
      esac
      ;;

    table)
      local tables=()
      # shellcheck disable=SC2034,SC2207
      case $db_type in
        mariadb) tables=($(mariadb_tables "$host" "$username" "$password" "$database")) ;;
        mysql) tables=($(mysql_tables "$host" "$username" "$password" "$database")) ;;
        postgres) tables=($(postgres_tables "$url" "$database")) ;;
        sqlite) tables=($(sqlite3 "$database" '.tables')) ;;
      esac
      compadd -a tables
      ;;
  esac
}
compdef _adminer adminer
