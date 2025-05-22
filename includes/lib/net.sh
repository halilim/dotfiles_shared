alias libnet='$EDITOR "$DOTFILES_INCLUDES"/lib/net.sh' # cSpell:ignore libnet

function content_length() {
  curl -ILs "$1" |
    http_header_value Content-Length |
    "$GNU_NUMFMT" --to=si --suffix=B
}
# cSpell:ignore cuil
alias cuil="content_length"

function curl_time() {
  if [[ ! $1 ]]; then
    echo >&2 "Usage: $0 <url> [<interface>]"
    return 1
  fi

  local params=()
  [[ $2 ]] && params+=(--interface "$2")

  # https://stackoverflow.com/a/22625150/372654
  # cSpell:disable
  curl "$1" "${params[@]}" -Isv -o /dev/null -w "     time_namelookup:  %{time_namelookup}s
        time_connect:  %{time_connect}s
     time_appconnect:  %{time_appconnect}s
    time_pretransfer:  %{time_pretransfer}s
       time_redirect:  %{time_redirect}s
  time_starttransfer:  %{time_starttransfer}s
                       ---------
          time_total:  %{time_total}s\n"
  # cSpell:enable
}

function encode_uri_component() {
  jq -rR @uri <<< "$1"
}

function http_header_value() {
  local headers header

  if [[ $# = 1 ]]; then
    headers=$(cat -)
    header=$1
  else
    headers=$1
    header=$2
  fi

  echo "$headers" |
      grep -i "^$header:" |
      cut -d ' ' -f 2 |
      tr -d '\r'
}

function my_external_ip() {
  # Doesn't recognize proxy (Caches the result?)
  # dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com | tr -d '"'
  curl -fLs ifconfig.me
}

# cSpell:ignore myip
function myip_whois() {
  local ip
  ip=$(echo_eval my_external_ip)
  echo_eval 'whois %q' "$ip"
}
alias whois_myip='myip_whois'

function port_check() {
  local ports=$1 \
    out

  if [[ ! $ports =~ ^[0-9,]+$ ]]; then
    echo >&2 "Usage: ${funcstack[1]:-${FUNCNAME[0]}} <port>[,<port 2>]"
    return 1
  fi

  out=$(FAKE_ECHO='COMMAND\tPID\nfoo\t1\nbar\t2' echo_eval 'lsof -nP +c0 -iTCP:%q -sTCP:LISTEN' "$ports")
  echo "$out"

  if [[ $out =~ docker ]]; then
    docker container ls --format "table {{.ID}}\t{{.Names}}\t{{.Ports}}" -a | rg -n -w "$ports"
  else
    local body pids
    body=$(echo "$out" | tail -n +2)
    pids=$(echo "$body" | awk '{print $2}')
    pids=$(printf %s "$pids" | tr '\n' ',')
    echo_eval 'ps u -p %q' "$pids"
  fi
}

function router_ip() {
  traceroute -n -m 1 192.168.255.255 2>&1 | sed '1d' | tr -s ' ' | cut -d ' ' -f 3
}

function router_ping() {
  ping "$(router_ip)"
}
# shellcheck disable=SC2139
alias {pgg,pingr,ping_router}='router_ping' # cSpell:ignore pingr

function ssl_check() {
  local domain=$1
  printf Q | openssl s_client -servername "$domain" -connect "$domain":443 | openssl x509 -noout -dates
}
alias tls_check='ssl_check'

# cSpell:ignore whoip
function whoip() {
  local ip
  ip=$(dig +short "$1" | head -n1)
  local cmd="whois $ip"
  echo >&2 "$cmd"
  printf "=%.0s" $(seq 1 ${#cmd})

  # Yeah, the long version by default, since whois outputs are so inconsistent...
  if [[ $2 == '-s' ]]; then
    printf '\n'
    eval "$cmd" | noglob grep -i orgname | sed -e 's/OrgName:[[:space:]]*//' | sed -e 's/[[:space:]]*$//'
    printf '\n'
  else
    eval "$cmd" | more
  fi
}
