# https://github.com/joeferner/redis-commander
# Usage: redco <scheme> <host> <port> <password>
# WARNING: Not recommended for large instances since it scans all keys
function redco() {
  (
    cd ~ || return

    local scheme=$1 host=$2 port=$3 password=$4 read_only_param='--read-only' tls_param=''

    if [[ $host == localhost ]]; then
      host='127.0.0.1'
    fi

    if [[ $REDCO_WRITABLE ]]; then
      read_only_param=''
    fi

    if [[ $scheme == 'rediss' ]]; then
      tls_param='--redis-tls'
    fi

    # cSpell:ignore noload nosave
    echo_eval "NODE_TLS_REJECT_UNAUTHORIZED=0 redis-commander --redis-label %q \
      --redis-host %q --redis-port %q --redis-password %q \
      --noload --nosave --open $tls_param $read_only_param" \
      "${REDCO_LABEL:-$host}" "$host" "$port" "$password"
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
