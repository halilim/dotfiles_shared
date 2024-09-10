# Auto-complete Heroku app names n times
# Multi-app usage: compdef '_heroku_apps 2' function_name
# TODO: Remove the empty entry
function _heroku_apps() {
  local count=${1:-1} args=() state

  local i
  # shellcheck disable=SC2004
  for ((i = 1; i <= $count; i++)); do
    args+=("$i: :->app$i")
  done
  _arguments "${args[@]}"

  if [[ -z $HEROKU_APPS ]]; then
    export HEROKU_APPS=()
    local heroku_cache=~/.cache/heroku_apps \
      heroku_app_list

    mkdir -p ~/.cache

    if ! last_mod_older_than "$heroku_cache" '7 days'; then
      heroku_app_list=$(cat "$heroku_cache")
    fi

    # The cache file may exist but be empty
    if [[ ! $heroku_app_list ]]; then
      heroku_app_list=$(heroku apps --json | jq -r '.[].name')
      printf '%s' "$heroku_app_list" > "$heroku_cache"
    fi

    IFS=$'\n' read_array -d '' HEROKU_APPS <<< "$heroku_app_list"
  fi

  case $state in
    app*) compadd -a HEROKU_APPS ;;
  esac
}

# function heroku_2() {
#   local app1=$1 app2=$2
#   echo "app 1: $app1, app 2: $app2"
# }
# compdef '_heroku_apps 2' heroku_2

compdef _heroku_apps adminer_heroku
compdef _heroku_apps heroku_db_url
compdef _heroku_apps heroku_deploy_dash
compdef _heroku_apps heroku_psql
compdef _heroku_apps heroku_redco

function _heroku_deploy_git_branch() {
  local state

  _arguments '1: :->remote' '2: :->branch'

  # shellcheck disable=2046
  case $state in
    remote) compadd $(heroku_remotes) ;;
    branch) compadd $(git branch --no-color --format='%(refname:short)') ;;
  esac
}
compdef _heroku_deploy_git_branch heroku_deploy_git_branch

function _heroku_fix_git_remote() {
  local state

  _arguments '1: :->remote'

  # shellcheck disable=2046
  case $state in
    remote) compadd $(heroku_remotes) ;;
  esac
}
compdef _heroku_fix_git_remote heroku_fix_git_remote
