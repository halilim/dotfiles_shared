alias libdb='$EDITOR "$DOTFILES_INCLUDES"/lib/databases.sh' # cSpell:ignore libdb

function dbs() {
  local type=${1?Which type? Hit tab} \
    host=${2:-127.0.0.1}
  eval "${type}_databases" "$host"
}

function db_hosts() {
  local type=${1:-} hosts='127.0.0.1'
  if [[ $type ]]; then
    local dk_hosts
    dk_hosts=$(docker_hosts "$type")
    if [[ $dk_hosts ]]; then
      hosts+="\n$dk_hosts"
    fi
  fi
  echo "$hosts"
}

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

function mariadb_exec() {
  TYPE=mariadb mysql_exec "$@"
}

# https://mariadb.com/docs/server/clients-and-utilities/mariadb-client/mariadb-command-line-client
# https://dev.mysql.com/doc/refman/en/mysql-command-options.html
function mysql_exec() {
  local host=${1:-127.0.0.1} database=${2:-} cmd=''

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
      cmd+=" -P $port"
    fi
  fi

  local user=${DB_USER:-root}
  if [[ $user ]]; then
    cmd+=" -u $user"
  fi

  local password=${DB_PASSWD:-root}
  if [[ $password ]]; then
    cmd+=" -p$password"
  fi

  cmd+=" --skip-column-names"

  if [[ $database ]]; then
    cmd+=" $database"
  fi

  if [[ ${QUERY:-} ]]; then
    cmd+=$(printf ' -e %q' "$QUERY")
  fi

  # FIXME: Find another way, because this also silences real errors
  # # `2>`: mysql: [Warning] Using a password on the command line interface can be insecure.
  # cmd+=' 2> /dev/null'

  echo_eval "$cmd"
}

function postgres_databases() {
  local host=${1:-127.0.0.1}
  psql_exec "$host" '' '' --list --tuples-only |
    cut -d'|' -f 1 | awk NF | tr -d ' ' | \grep --color -v -e postgres -e template
}
alias pg_databases='postgres_databases'

function postgres_tables() {
  local host=${1:?Which host? Hit tab} \
    db=${2:?Which db? Hit tab}
  psql_exec "$host" "$db" '' -Atc '\\\dt public.*' | cut -d\| -f 2
}
alias pg_tables='postgres_tables'

function postgres_table() {
  local host=${1:?Which host? Hit tab} \
    db=${2:?Which db? Hit tab} \
    table=${3:?Which table? Hit tab}
  psql_exec "$host" "$db" "\\\d $table"
}
alias pgt='postgres_table'

# https://www.postgresql.org/docs/current/app-psql.html
function psql_exec() {
  local host=${1:-127.0.0.1} database=${2:-} query=${3:-} cmd=''

  local password=${DB_PASSWD:-}
  if [[ $password ]]; then
    cmd+="PGPASSWORD=${password} "
  fi

  local container
  container=$(docker_host_to_container "$host")
  if [[ $container ]]; then
    cmd+="docker exec $container "
  fi

  cmd+='psql'

  if [[ ! $container ]]; then
    cmd+=" -h $host"
    local port=${host#*:}
    if [[ $port && $port != "$host" ]]; then
      cmd+=" -p $port"
    fi
  fi

  local user=${DB_USER:-postgres}
  cmd+=" -U $user"

  if [[ $database ]]; then
    cmd+=" -d $database"
  fi

  if [[ ${query:-} ]]; then
    cmd+=$(printf ' --command %q' "$query")
  fi

  cmd+=" ${*:4}"

  echo_eval "$cmd"
}

function db_table() {
  local type=${1?Which type? Hit tab} \
    host=${2:?Which host? Hit tab} \
    db=${3:?Which db? Hit tab} \
    table=${4:?Which table? Hit tab}
  eval "${type}_table" "$host" "$db" "$table"
}
# shellcheck disable=SC2139
alias {dbt,table,tbl}='db_table'

function db_tables() {
  local type=${1?Which type? Hit tab} \
    host=${2:?Which host? Hit tab} \
    db=${3:?Which db? Hit tab}
  eval "${type}_tables" "$host" "$db"
}
# shellcheck disable=SC2139
alias {dbts,tables,tbls}='db_tables' # cSpell:disable-line
