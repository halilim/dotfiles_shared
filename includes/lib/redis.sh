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

    echo_eval "NODE_TLS_REJECT_UNAUTHORIZED=0 redis-commander --redis-label ""${REDCO_LABEL:-$host}"" \
      --redis-host ""$host"" --redis-port ""$port"" --redis-password ""$password"" \
      --noload --nosave --open ""$tls_param"" ""$read_only_param"""
  )
}
alias redco_w='REDCO_WRITABLE=1 redco'

function redco_uri() {
  local uri=$1 uri_arr
  IFS=$'\n' read_array -d '' uri_arr < <( redis_url_to_redco "$uri" && printf '\0' )
  redco "${uri_arr[1]}" "${uri_arr[2]}" "${uri_arr[3]}" "${uri_arr[4]}"
}
alias redco_uri_w='REDCO_WRITABLE=1 redco_uri'
