function _adminer() {
  local state db_type host username password url
  local LOCALHOST='127.0.0.1'

  _arguments '1: :->db_type' '2: :->host' '3: :->username' '4: :->password' '5: :->database' '6: :->table'

  # shellcheck disable=SC2154
  if [[ ${#words} -ge 2 ]]; then
    db_type="${words[*]:1:1}"
  fi
  if [[ ${#words} -ge 3 ]]; then
    host="${words[*]:2:1}"
  fi
  if [[ ${#words} -ge 4 ]]; then
    username="${words[*]:3:1}"
  fi
  if [[ ${#words} -ge 5 ]]; then
    password="${words[*]:4:1}"
  fi

  if [[ $host && $password ]]; then
    url="$db_type://$username:$password@$host"
  fi

  case $state in
    db_type) compadd postgres mysql ;;
    host) compadd "$LOCALHOST" ;;

    username)
      local username_suggestions=()
      case "$db_type" in
        postgres)
          username_suggestions+=("$(whoami)" postgres)
          ;;

        mysql)
          username_suggestions+=(root)
          ;;
      esac

      if [[ ${#username_suggestions} -gt 0 ]]; then
        compadd -a username_suggestions
      fi
      ;;

    password)
      local password_suggestions=()
      if [[ $host == "$LOCALHOST" ]]; then
        case "$db_type" in
          postgres)
            password_suggestions+=(postgres '')
            ;;

          mysql)
            password_suggestions+=(root)
            ;;
        esac

        if [[ ${#password_suggestions} -gt 0 ]]; then
          compadd -a password_suggestions
        fi
      fi
      ;;

    database)
      local databases=()
      case $url in
        postgre*)
          # shellcheck disable=SC2034
          databases=("$(postgres_databases "$url")")
          ;;
        default)
          # Not supported yet
          return 1
          ;;
      esac

      compadd -a databases
      ;;

    table)
      local database="${words[*]:5:1}"

      local tables=()
      case $url in
        postgre*)
          # shellcheck disable=SC2034
          tables=("$(postgres_tables "$url" "$database")")
          ;;
        default)
          # Not supported yet
          return 1
          ;;
      esac

      compadd -a tables
      ;;
  esac
}
compdef _adminer adminer
