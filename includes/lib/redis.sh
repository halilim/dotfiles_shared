# https://github.com/joeferner/redis-commander
# Usage: redco <host> <port> <password>
# WARNING: Not recommended for large instances since it scans all keys
function redco() {
  (
    cd ~ || return

    local host=${1:-} port=${2:-} password=${3:-} args=()

    if [[ ${REDCO_LABEL:-} || $host ]]; then
      args+=(--redis-label "${REDCO_LABEL:-$host}")
    fi

    if [[ $host ]]; then
      if [[ $host == localhost ]]; then
        host='127.0.0.1'
      fi
      args+=(--redis-host "$host")
    fi

    if [[ $port ]]; then
      args+=(--redis-port "$port")
    fi

    if [[ $password ]]; then
      args+=(--redis-password "$password")
    fi

    if [[ ${TLS:-} ]]; then
      args+=(--redis-tls)
    fi

    if [[ ! ${REDCO_WRITABLE:-} ]]; then
      args+=(--read-only)
    fi

    args+=(
      --noload # cSpell:disable-line
      --nosave # cSpell:disable-line
      --open
    )

    echo_eval NODE_TLS_REJECT_UNAUTHORIZED=0 redis-commander "${args[@]}"
  )
}
alias redco_w='REDCO_WRITABLE=1 redco'

function redco_uri() {
  local uri=$1

  local uri_arr=() output
  output=$(redis_url_to_redco "$uri")
  if [ -n "${ZSH_VERSION:-}" ]; then
    # shellcheck disable=SC2296,SC2116
    uri_arr=("${(f)$(echo "$output")}")
  else
    mapfile -t uri_arr < <( echo "$output" )
  fi

  # shellcheck disable=SC2124
  local scheme="${uri_arr[@]:0:1}"
  # shellcheck disable=SC2124
  local host="${uri_arr[@]:1:1}"
  # shellcheck disable=SC2124
  local port="${uri_arr[@]:2:1}"
  # shellcheck disable=SC2124
  local password="${uri_arr[@]:3:1}"

  redco "$scheme" "$host" "$port" "$password"
}
alias redco_uri_w='REDCO_WRITABLE=1 redco_uri'
