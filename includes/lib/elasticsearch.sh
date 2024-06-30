:
# shellcheck disable=SC2139
alias libe="$EDITOR $0"

function es_get_uri() {
  echo "${1:-${ES_URI:-127.0.0.1:9200}}"
}

# Set a default "0 replicas" template for all new indices so that they are green
function es_no_replicas_tpl() {
  local es_uri \
        version \
        version_arr \
        major_version data \
        settings='{ "number_of_replicas": 0 }'

  es_uri=$(es_get_uri "$1")

  version=$(curl -fLs "$es_uri" | jq -r '.version.number')
  IFS='.' read_array version_arr <<< "$version"
  major_version=${version_arr[1]}

  if [[ $major_version -le 5 ]]; then
    read -r -d '' data <<JSON
{
  "template": "*",
  "settings": $settings
}
JSON

  elif [[ $major_version = 6 || $major_version = 7 ]]; then
    read -r -d '' data <<JSON
{
  "index_patterns": ["*"],
  "settings": $settings
}
JSON

  elif [[ $major_version = 8 ]]; then
    read -r -d '' data <<JSON
{
  "index_patterns": ["*"],
  "settings": { "template": $settings }
}
JSON

  else
    echo "Unsupported version: $version"
    echo "Please check https://www.elastic.co/guide/en/elasticsearch/reference/current/index-templates.html"
    return 1

  fi

  echo_eval 'curl -fLs -XPUT %q/_template/no_replica -H ''Content-Type: application/json'' -d %q' \
    "$es_uri" "$data"
}

# Set number_of_replicas to 0 for an existing index so that it's green
function es_no_replicas_index() {
  local es_uri \
        index=$2

  es_uri=$(es_get_uri "$1")

  echo_eval 'curl -XPUT "%q/%q/_settings -d ''{ "index": { "number_of_replicas": 0 } }''' "$es_uri" "$index"
}

function es_no_replicas_index_all() {
  local es_uri
  es_uri=$(es_get_uri "$1")

  curl -fLs "$es_uri/_cat/indices" | awk '{print $3}' | while read -r index; do
    es_no_replicas_index "$es_uri" "$index"
    printf '\n'
  done
}

# https://github.com/mobz/elasticsearch-head
# Usage: eshead <es_uri> <additional proxies>
# Example: eshead 'http://localhost:9105'
# Example: ESHEAD_NO_PROXY=1 eshead 'http://user:pass@example.com:9200'
# Multiple URIs > proxy to all, open the first one
# TODO: This throws `address already in use :::9101`
function eshead_srv() {
  local es_uri \
        additional_proxies=$2 \
        cmd

  es_uri=$(es_get_uri "$1")

  # LANG=en_US.UTF is a fix for the Turkish I issue
  #   Loading "connect.js" tasks...ERROR
  #   >> TypeError: argument fn must be a function
  # https://github.com/facebook/create-react-app/issues/7315
  local server_cmd='LANG=en_US.UTF-8 npm run start'

  # Using proxy even for local URIs as CORS can cause issues there too
  # if [[ $es_uri = *'localhost'* || $es_uri = *'127.0.0.1'* ]]; then
  if [[ $ESHEAD_NO_PROXY ]]; then
    cmd=$server_cmd
  else
    local proxy=$es_uri
    if [[ $additional_proxies ]]; then
      proxy="$proxy,$additional_proxies"
    fi
    # echo "proxy: $proxy"
    cmd="(PROXY=$proxy npm run proxy & $server_cmd)"
    # shellcheck disable=SC2034
    es_uri='http://localhost:9101'
  fi

  (
    eshead_update 1
    echo_eval "$cmd"
  ) &
  echo_eval 'sleep 2'

  eshead_open "http://localhost:9100/" "$es_uri"
  echo_eval 'fg'
}

function eshead() {
  local es_uri=$1
  es_uri=$(es_get_uri "$1")

  (
    eshead_update
  )

  eshead_open "file:///$ESHEAD_DIR/_site/index.html" "$es_uri"
}

function eshead_open() {
  local eshead_uri=$1 \
        es_uri

  es_uri=$(es_get_uri "$2")
  es_uri=$(encode_uri_component "$es_uri")
  echo_eval 'o %q?lang=en&base_uri=%q' "$eshead_uri" "$es_uri"
}

function eshead_update() {
  local install=$1
  cd "$ESHEAD_DIR" || return
  if needs_update_and_mark; then
    echo 'Pulling updates'
    echo_eval 'git pull'
    [[ $install ]] && echo_eval 'npm install'
  fi
}
