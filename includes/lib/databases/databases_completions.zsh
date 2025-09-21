function _db_host() {
  # shellcheck disable=SC2034
  local context state state_descr line
  # shellcheck disable=SC2034
  typeset -A opt_args

  local type=$1
  _arguments '1: :->host'

  case $state in
    host)
      # shellcheck disable=SC2046
      compadd $(SILENT=1 db_hosts "$type")
      ;;
  esac
}

compdef '_db_host mysql' mysql_databases
compdef '_db_host mariadb' mariadb_databases
compdef '_db_host postgres' postgres_databases

function _db_host_db() {
  # shellcheck disable=SC2034
  local context state state_descr line
  # shellcheck disable=SC2034
  typeset -A opt_args

  local type=$1
  _arguments '1: :->host' '2: :->db'

  # shellcheck disable=2046
  case $state in
    host)
      compadd $(SILENT=1 db_hosts "$type")
      ;;

    db)
      local host=${words[2]:-}
      compadd $(SILENT=1 dbs "$type" "$host")
      ;;
  esac
}
compdef '_db_host_db mysql' mysql_tables mysql_exec
compdef '_db_host_db mariadb' mariadb_tables mariadb_exec
compdef '_db_host_db postgres' postgres_tables psql_exec

function _db_host_db_table() {
  # shellcheck disable=SC2034
  local context state state_descr line
  # shellcheck disable=SC2034
  typeset -A opt_args

  local type=$1
  _arguments '1: :->host' '2: :->db' '3: :->table'

  local host=${words[2]:-}
  local db=${words[3]:-}

  # shellcheck disable=2046
  case $state in
    host)
      compadd $(SILENT=1 db_hosts "$type")
      ;;

    db)
      compadd $(SILENT=1 dbs "$type" "$host")
      ;;

    table)
      compadd $(SILENT=1 tables "$type" "$host" "$db")
      ;;
  esac
}
compdef '_db_host_db_table mysql' mysql_table
compdef '_db_host_db_table mariadb' mariadb_table
compdef '_db_host_db_table postgres' postgres_table

function _db_type() {
  # shellcheck disable=SC2034
  local context state state_descr line
  # shellcheck disable=SC2034
  typeset -A opt_args

  _arguments '1: :->type'

  # shellcheck disable=2046
  case $state in
    type)
      compadd 'mysql' 'mariadb' 'postgres'
      ;;
  esac
}
compdef _db_type db_hosts

function _db_type_host() {
  # shellcheck disable=SC2034
  local context state state_descr line
  # shellcheck disable=SC2034
  typeset -A opt_args

  _arguments '1: :->type' '2: :->host'

  # shellcheck disable=2046
  case $state in
    type)
      compadd 'mysql' 'mariadb' 'postgres'
      ;;

    host)
      local type=${words[2]:-}
      compadd $(SILENT=1 db_hosts "$type")
      ;;
  esac
}
compdef _db_type_host dbs

function _db_type_host_db() {
  # shellcheck disable=SC2034
  local context state state_descr line
  # shellcheck disable=SC2034
  typeset -A opt_args

  _arguments '1: :->type' '2: :->host' '3: :->db'

  local type=${words[2]:-}
  local host=${words[3]:-}

  # shellcheck disable=2046
  case $state in
    type)
      compadd 'mysql' 'mariadb' 'postgres'
      ;;

    host)
      compadd $(SILENT=1 db_hosts "$type")
      ;;

    db)
      compadd $(SILENT=1 dbs "$type" "$host")
      ;;
  esac
}

compdef _db_type_host_db tables

function _db_type_host_db_table() {
  # shellcheck disable=SC2034
  local context state state_descr line
  # shellcheck disable=SC2034
  typeset -A opt_args

  _arguments '1: :->type' '2: :->host' '3: :->db' '4: :->table'

  local type=${words[2]:-}
  local host=${words[3]:-}
  local db=${words[4]:-}

  # shellcheck disable=2046
  case $state in
    type)
      compadd 'mysql' 'mariadb' 'postgres'
      ;;

    host)
      compadd $(SILENT=1 db_hosts "$type")
      ;;

    db)
      compadd $(SILENT=1 dbs "$type" "$host")
      ;;

    table)
      compadd $(SILENT=1 tables "$type" "$host" "$db")
      ;;
  esac
}
compdef _db_type_host_db_table table
