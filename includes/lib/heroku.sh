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
alias hrkdm="heroku run rake db:migrate" # cSpell:ignore hrkdm
alias hv="heroku --version"

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

function heroku_config_get() {
  local key=$1 app=$2
  echo_eval 'heroku config:get %q -a %q' "$key" "$app"
}

function heroku_db_url() {
  local app=$1
  heroku_config_get DATABASE_URL "$app"
}

function heroku_deploy_dash() {
  local app=${1:?Heroku app name is required}
  o "https://dashboard.heroku.com/apps/$app/deploy/github"
}

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

# Fix `error: failed to push some refs to ...`
function heroku_fix_git_remote() {
  local remote=$1
  git pull "$remote" master
}

# Sometimes `heroku pg:psql -a ...` => "... has no databases", because of different billing app etc.
function heroku_psql() {
  local app=$1 db_url
  db_url=$(heroku_db_url "$app")
  psql "$db_url"
}
# cSpell:ignore hpsql
alias hpsql='heroku_psql'

function heroku_remotes() {
  local remote
  for remote in $(git remote); do
    [[ $(git remote get-url "$remote") == 'https://git.heroku.com'* ]] && echo "$remote"
  done
}

function heroku_redco() {
  local app=${1:?Heroku app name is required} redis_url
  redis_url=$(heroku_config_get REDIS_TLS_URL "$app")
  REDCO_LABEL=$app redco_uri "$redis_url"
}
alias heroku_redco_w='REDCO_WRITABLE=1 heroku_redco'
