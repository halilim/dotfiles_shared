alias libes='$EDITOR "$DOTFILES_INCLUDES"/lib/elasticsearch.sh' # cSpell:ignore libes

function es_get_uri() {
  echo "${1:-${ES_URI:-127.0.0.1:9200}}"
}

# Set a default "0 replicas" template for all new indices so that they are green (local dev)
function es_no_replicas_tpl() {
  local es_uri settings='{ "number_of_replicas": 0 }'
  es_uri=$(es_get_uri "$1")

  local version_arr=() version
  version=$(curl -fLs "$es_uri" | jq -r '.version.number')
  if command -v mapfile > /dev/null 2>&1; then
    mapfile -t version_arr < <( echo "$version" )
  elif [ -n "${ZSH_VERSION:-}" ]; then
    # shellcheck disable=SC2296,SC2116
    version_arr=("${(f)$(echo "$version")}")
  fi

  # shellcheck disable=SC2124
  local major_version=${version_arr[@]:0:1}
  local data

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
