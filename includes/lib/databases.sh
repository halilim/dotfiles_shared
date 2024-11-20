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
    echo >&2 'Usage: mysql_databases <host> [<username> <password>]'
    return 1
  fi

  local host_param
  if [[ $host = *.docker ]]; then
    local container=${host%.docker}
    cmd+="docker exec $container"
  else
    host_param="-h$host"
  fi

  if [[ ${TYPE:-} && $TYPE = 'mariadb' ]]; then
    cmd+=" mariadb"
  else
    cmd+=" mysql"
  fi

  if [[ $host_param ]]; then
    cmd+=" $host_param"
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
  local host=${1:-127.0.0.1} username=${2:-$(whoami)} password=${3:-postgres}
  PGPASSWORD=$password psql -h "$host" -U "$username" --list --tuples-only |
    cut -d\| -f 1 | awk NF | tr -d ' ' | \grep --color -v -e postgres -e template
}

function postgres_tables() {
  local host=${1:-127.0.0.1} username=${2:-$(whoami)} password=${3:-postgres} database=${4:?db is required}
  PGPASSWORD=$password psql -h "$host" -U "$username" -d "$database" -Atc '\dt public.*' | cut -d\| -f 2
}
