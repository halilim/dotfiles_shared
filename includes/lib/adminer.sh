alias liba='$EDITOR "$DOTFILES_INCLUDES"/lib/adminer.sh' # cSpell:ignore liba

alias adminer_pg_local='adminer postgres 127.0.0.1 postgres postgres'

function adminer() {
  # shellcheck disable=SC2034
  local db_type=${1:-} host username password db ns table started_nginx_php

  if [[ $db_type == 'sqlite' ]]; then
    db=${2:-}
    table=${3:-}
  else
    host=${2:-}
    username=${3:-}
    password=${4:-}
    # shellcheck disable=SC2034
    db=${5:-}
    # shellcheck disable=SC2034
    table=${6:-}
  fi

  local adminer_type=$db_type
  # shellcheck disable=SC2034
  case "$adminer_type" in
    mariadb|mysql) adminer_type=server ;;
    postgres) adminer_type=pgsql; ns=public ;;
  esac

  if [[ $password ]]; then
    cb_tmp "$password"
  fi

  if ! pgrep -f nginx_php_fg > /dev/null 2>&1; then
    echo_eval 'nginx_php_fg &'
    if [[ ! ${DRY_RUN:-} ]]; then
      started_nginx_php=1
    fi
  fi

  local host_param
  if [[ $host = *.docker ]]; then
    local container=${host%.docker} port
    port=$(docker inspect "$container" |
      jq -r '.[0].HostConfig.PortBindings | to_entries.[0].value.[0].HostPort')
    host_param="docker:$port"
  else
    host_param=$host
  fi

  # Even if empty, username param is required for passwordless login
  local params="$adminer_type=$host_param&username=$username"

  local param value
  for param in db ns table; do
    if [ -n "${ZSH_VERSION:-}" ]; then
      # shellcheck disable=SC2296
      value=${(P)param}
    else
      value=${!param}
    fi

    if [[ $value ]]; then
      params+="&$param=$value"
    fi
  done

  local url="http://localhost:$HOST_NGINX_PORT/tools/adminer/adminer/?$params"
  echo_eval 'o %q' "$url"

  if [[ $started_nginx_php ]]; then
    fg
  fi
}

function adminer_install() {
  if [[ ! ${ADMINER_DIR:-} ]]; then
    echo >&2 'Set ADMINER_DIR in custom/includes/env.sh. Example: custom_example/includes/env.sh'
    return 1
  fi

  git clone --recurse-submodules https://github.com/adminerevo/adminerevo "$ADMINER_DIR"
  adminer_update_activate
}

function adminer_params_to_url() {
  local params=$1 # `pgsql=127.0.0.1&username=postgres` or `server=127.0.0.1&username=postgres`
  local password=$2

  # shellcheck disable=SC2207
  local parsed=($(rg --only-matching '(pgsql|server)=(.+)&username=(.+)' --replace '$1 $2 $3' <<< "$params"))
  local db_type="${parsed[*]:0:1}"
  local host="${parsed[*]:1:1}"
  local username="${parsed[*]:2:1}"

  local scheme
  case "$db_type" in
    pgsql)
      scheme=postgres
      ;;
    server)
      scheme=mysql
      ;;
    default)
      echo >&2 "Unknown db_type: $db_type"
      return 1
      ;;
  esac

  echo "$scheme://$username:$password@$host"
}

# Instead of using the single file adminer, using the full repo to get updates to plugins as well.
function adminer_update() {
  (
    cd "$ADMINER_DIR" || return

    if [[ -f adminer/index.orig.php ]]; then
      rm -f adminer/index.php adminer/adminer_password.php
      mv adminer/index{.orig,}.php
    fi

    git checkout "$(git_main_branch)"
    git pull
    latest=$(git describe --tags)
    git checkout "$latest" --quiet
  )
  adminer_update_activate
}

function adminer_update_activate() {
  (
    cd "$ADMINER_DIR"/adminer || return

    mv index{,.orig}.php
    cp "$DOTFILES_SHARED"/share/adminer_custom.php index.php
    cp "$DOTFILES_CUSTOM"/share/adminer_password.php .
    # Docker LAMP raises "AH00037: Symbolic link not allowed or link target not accessible",
    #   probably because the target is outside the doc root.
    # ln -s .../adminer_custom.php "$ADMINER_DIR"/adminer/custom.php
  )
}
