alias libdb='$EDITOR "$DOTFILES_INCLUDES"/lib/databases.sh' # cSpell:ignore libdb

function mariadb_databases() {
  TYPE=mariadb QUERY='SHOW DATABASES' mysql_exec "$@"
}

function mysql_databases() {
  QUERY='SHOW DATABASES' mysql_exec "$@"
}

function mariadb_tables() {
  TYPE=mariadb QUERY='SHOW TABLES' mysql_exec "$@"
}

function mysql_tables() {
  QUERY='SHOW TABLES' mysql_exec "$@"
}

function mysql_exec() {
  local host=${1:-127.0.0.1} username=${2:-root} password=${3:-root} database=${4:-} cmd=''

  if [[ $# -lt 1 ]]; then
    echo >&2 'Usage: mysql_exec [<host> <username> <password>]'
    return 1
  fi

  local container
  container=$(docker_host_to_container "$host")
  if [[ $container ]]; then
    cmd+="docker exec $container"
  fi

  if [[ ${TYPE:-} && $TYPE = 'mariadb' ]]; then
    cmd+=" mariadb"
  else
    cmd+=" mysql"
  fi

  if [[ ! $container ]]; then
    cmd+=" -h$host"
    local port=${host#*:}
    if [[ $port ]]; then
      cmd+=" -P$port"
    fi
  fi

  if [[ $username ]]; then
    cmd+=" -u$username"
  fi

  if [[ $password ]]; then
    cmd+=" -p$password"
  fi

  if [[ $database ]]; then
    cmd+=" $database"
  fi

  cmd+=" --skip-column-names"

  if [[ ${QUERY:-} ]]; then
    cmd+=$(printf ' -e %q' "$QUERY")
  fi

  # `2>`: mysql: [Warning] Using a password on the command line interface can be insecure.
  cmd+=' 2> /dev/null'

  if [[ ${VERBOSE:-} ]]; then
    echo_eval "$cmd"
  else
    eval "$cmd"
  fi
}

function postgres_databases() {
  psql_exec "$@" '' --list --tuples-only |
    cut -d\| -f 1 | awk NF | tr -d ' ' | \grep --color -v -e postgres -e template
}

function postgres_tables() {
  psql_exec "$@" -Atc '\\\dt public.*' | cut -d\| -f 2
}

function psql_exec() {
  local host=${1:-127.0.0.1} username=${2:-$(whoami)} password=${3:-postgres} database=${4:-} cmd=''

  if [[ $# -lt 1 ]]; then
    echo >&2 'Usage: psql_exec [<host> <username> <password>]'
    return 1
  fi

  if [[ $password ]]; then
    cmd+="PGPASSWORD=${password}"
  fi

  local container
  container=$(docker_host_to_container "$host")
  if [[ $container ]]; then
    cmd+=" docker exec $container"
  fi

  cmd+=' psql'

  if [[ ! $container ]]; then
    cmd+=" -h $host"
    local port=${host#*:}
    if [[ $port ]]; then
      cmd+=" -p $port"
    fi
  fi

  if [[ $username ]]; then
    cmd+=" -U $username"
  fi

  if [[ $database ]]; then
    cmd+=" -d $database"
  fi

  if [[ $# -gt 4 ]]; then
    cmd+=" ${*:5}"
  fi

  if [[ ${QUERY:-} ]]; then
    cmd+=$(printf ' %q' "$QUERY")
  fi

  if [[ ${VERBOSE:-} ]]; then
    echo_eval "$cmd"
  else
    eval "$cmd"
  fi
 }
