# cSpell:ignore hrkdm

# Add OMZ/heroku plugin too

alias hg50="heroku logs -n 50"
alias hgw="heroku logs --dyno worker"
alias hko="heroku open"
alias hnr="heroku addons:open newrelic"
alias hps="heroku ps"
alias hr="heroku run"
alias hrb="heroku run bash"
alias hrc="heroku run console"
alias hrk="heroku run rake"
alias hrkdm="heroku run rake db:migrate"
alias hv="heroku --version"

if [ -n "${ZSH_VERSION:-}" ]; then
  # Auto-complete Heroku app names n times
  # Multi-app usage: compdef '_heroku_apps 2' function_name
  # TODO: Remove the empty entry
  function _heroku_apps() {
    local count=${1:-1} args=() state

    local i
    # shellcheck disable=SC2004
    for ((i = 1; i <= $count; i++)); do
      args+=( "$i: :->app$i" )
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
fi

function adminer_heroku() {
  local app=${1:?Heroku app name is required} db_url adminer_values=() adminer_params password

  # db_url='postgres://user:pass@host:123/db'
  db_url=$(heroku_db_url "$app")

  IFS=$'\n' read_array -d '' adminer_values < <( db_url_to_adminer_params "$db_url" && printf '\0' )
  adminer_params=${adminer_values[1]}
  password=${adminer_values[2]}

  # `adminer` uses system PHP which doesn't support SSL
  echo_eval 'adminer %q %q' "$adminer_params" "$password"
}
[ -n "${ZSH_VERSION:-}" ] && compdef _heroku_apps adminer_heroku

function heroku_config_get() {
  local key=$1 app=$2
  echo_eval 'heroku config:get %q -a %q' "$key" "$app"
}

function heroku_db_url() {
  local app=$1
  heroku_config_get DATABASE_URL "$app"
}
[ -n "${ZSH_VERSION:-}" ] && compdef _heroku_apps heroku_db_url

function heroku_deploy_dash() {
  local app=${1:?Heroku app name is required}
  o "https://dashboard.heroku.com/apps/$app/deploy/github"
}
[ -n "${ZSH_VERSION:-}" ] && compdef _heroku_apps heroku_deploy_dash

function heroku_deploy_git_branch() {
  local app=${1:?Heroku app name is required} \
        branch=${2:-$(git_current_branch)} \
        main_branch

  main_branch=$(git_main_branch)

  if prompt "Push $branch to $app's $main_branch ?"; then
    git push --force-with-lease "$app" "$branch":"$main_branch"
  fi
}
# cSpell:ignore hdgb gphb
# shellcheck disable=SC2139
alias {hdgb,gphb}='heroku_deploy_git_branch'
if [ -n "${ZSH_VERSION:-}" ]; then
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
fi

# Fix `error: failed to push some refs to ...`
function heroku_fix_git_remote() {
  local remote=$1
  git pull "$remote" master
}
if [ -n "${ZSH_VERSION:-}" ]; then
  function _heroku_fix_git_remote() {
    local state

    _arguments '1: :->remote'

    # shellcheck disable=2046
    case $state in
      remote) compadd $(heroku_remotes) ;;
    esac
  }
  compdef _heroku_fix_git_remote heroku_fix_git_remote
fi

# Sometimes `heroku pg:psql -a ...` => "... has no databases", because of different billing app etc.
function heroku_psql() {
  local app=$1 db_url
  db_url=$(heroku_db_url "$app")
  psql "$db_url"
}
# cSpell:ignore hpsql
alias hpsql='heroku_psql'
[ -n "${ZSH_VERSION:-}" ] && compdef _heroku_apps heroku_psql

function heroku_remotes() {
  local remote
  for remote in $(git remote); do
    [[ $(git remote get-url "$remote") == 'https://git.heroku.com'* ]] && echo "$remote"
  done
}

function redco_heroku() {
  local app=${1:?Heroku app name is required} redis_url
  redis_url=$(heroku_config_get REDIS_TLS_URL "$app")
  REDCO_LABEL=$app redco_uri "$redis_url"
}
alias redco_heroku_w='REDCO_WRITABLE=1 redco_heroku'
[ -n "${ZSH_VERSION:-}" ] && compdef _heroku_apps redco_heroku
