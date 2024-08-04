# shellcheck disable=SC2139
# Intentionally disabled for the whole file, mostly for RUBY_CMD_PREFIX/RAILS_CMD/RAKE_CMD
# TODO: Replace with block level disables if it gets implemented

# cSpell:ignore libr
alias libr="$EDITOR $0"

export RUBY_CMD_PREFIX=${RUBY_CMD_PREFIX:-'bundle exec '} # or 'bin/'
export RAILS_CMD="${RUBY_CMD_PREFIX}rails"
export RAKE_CMD="${RUBY_CMD_PREFIX}rake"

if [ -n "${ZSH_VERSION:-}" ]; then
  alias -g CNE='-- --with-cflags="-Wno-error=implicit-function-declaration"'
  alias -g DS='DISABLE_SPRING=1'
  # TODO: What's gem_select? Find (from history) or remove
  alias -g GD='$(bundle info --path "$(gem_select)")'
  alias -g RW0='RUBYOPT="-W0"'
fi

# cSpell:ignore biq bebr beru berua besf bucq
alias bundle_conf="$EDITOR ~/.bundle/config"
alias b='bundle'
alias {biq,bq}='bundle install --quiet'
alias bebr='bundle exec brakeman'
alias bep='bundle exec puma'
alias berk='bundle exec rake'
alias beru='bundle exec rubocop'
alias berua='bundle exec rubocop -a'
alias bes='bundle exec standardrb'
alias besf='bundle exec standardrb --fix'
alias bub='bundle update --bundler'
alias buc='bundle update --conservative'
alias bucq='bundle update --conservative --quiet'
alias bv='bundle --version'

alias fs='foreman start'

# cSpell:ignore hrr hrrc hrrr
alias hrr="heroku run rails"
alias hrrc="heroku run rails console"
alias hrrr='heroku run rails runner ""'

# cSpell:ignore mailcatch
alias {mc,mailcatch}='mailcatcher -f'

# Ripgrep
# cSpell:ignore rgr rgrr rgrw
alias rgr="rg -g '!config/locales/' -g '!features/' -g '!spec/' -g '!test/'"
alias rgrr="rg -g '*.rb' -g '!features/' -g '!spec/' -g '!test/'"
alias rgrw="rgr -w"

# cSpell:ignore  rpry ramazing
alias rp='ruby -rpry -ramazing_print'
alias rv='ruby -v'

# cSpell:ignore raa rav rcac rgg rgm rgmp rgmo rrz rro rsl rvv
alias raa="$RAILS_CMD about"
alias rav="$RAILS_CMD -v"
alias rc="$RAILS_CMD console"
alias rce="EDITOR='code --wait' $RAILS_CMD credentials:edit"
alias rcac="rm -rf tmp/cache/{assets,webpacker}/*" # Rails clear asset cache
alias rgg="$RAILS_CMD generate"
alias rgm="$RAILS_CMD generate migration"
alias rgmp="$RAILS_CMD generate migration dummy --pretend"
alias rgmo="$RAILS_CMD generate model"
alias rgs="$RAILS_CMD generate scaffold"
alias rnd="rails new dummy --minimal --skip-active-record --skip-test --skip-git --skip-gemfile"
alias rnv='rails _7.1.0_ new'
alias rr="$RAILS_CMD runner"
alias rrz="$RAILS_CMD routes | fzf"
alias rro="$RAILS_CMD routes"
alias rrp="$RAILS_CMD runner -e production"
alias rrt="$RAILS_CMD runner -e test"
alias rs="$RAILS_CMD server"
alias rsl='rails_serve_lan' # Allow access from LAN (must be in the same network/Wi-Fi etc.)
alias rvv="ruby -v && $RAILS_CMD -v"

# cSpell:ignore rkdc rkdcl rkdct rkdm rkdmdv rkdms rkdmst rkdmt rkdmv rkdr rkdrt rkds rkro rrs gco
alias rk="$RAKE_CMD"
alias rkdc="$RAKE_CMD db:create"
alias rkdcl="$RAKE_CMD db:create db:schema:load"
alias rkdct="$RAKE_CMD db:create RAILS_ENV=test"
alias rkdm="$RAKE_CMD db:migrate"
alias rkdmdv="$RAKE_CMD db:migrate:up VERSION=" # Migrate SPECIFIED version
alias rkdmdv="$RAKE_CMD db:migrate:down VERSION=" # Roll back SPECIFIED version
alias rkdms="$RAKE_CMD db:migrate:status"
alias rkdmst="$RAKE_CMD db:migrate:status RAILS_ENV=test"
alias rkdmt="$RAKE_CMD db:migrate RAILS_ENV=test"
alias rkdmv="$RAKE_CMD db:migrate VERSION=" # Migrate up/down UNTIL version
alias rkdr="$RAKE_CMD db:rollback"
alias rkdrt="$RAKE_CMD db:rollback RAILS_ENV=test"
alias rkds="$RAKE_CMD db:seed"
alias rkro="$RAKE_CMD routes"
alias rkT="$RAKE_CMD -T"
alias rrs="gco db/schema.rb && $RAKE_CMD db:drop db:create db:schema:load db:migrate"

# cSpell:ignore sfd
alias s="${RUBY_CMD_PREFIX}rspec"
alias ss="${RUBY_CMD_PREFIX}rspec --seed"
alias {rsb,rst,sb,st}="${RUBY_CMD_PREFIX}rspec --backtrace" # Replaces `rails server --bind` from oh-my-zsh Rails plugin
alias {rfd,sfd}="${RUBY_CMD_PREFIX}rspec --format documentation"

# cSpell:ignore nosp ksp pssp psg spst
alias nosp='DISABLE_SPRING=1'
alias ksp="pgrep 'spring (app|server)' | xargs kill -9"
alias pssp='psg spring'
alias sps="${RUBY_CMD_PREFIX}spring status"
alias spst="${RUBY_CMD_PREFIX}spring stop"

alias sq="${RUBY_CMD_PREFIX}sidekiq"

# cSpell:ignore testrb
alias testrb='$EDITOR ~/Desktop/test\ code/test.rb'

function gem_install_bundler_gemfile() {
  local version
  version=$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1 | tr -d ' ')
  gem install bundler:"$version"
}
# cSpell:ignore gemib
alias gemib='gem_install_bundler_gemfile'

function gem_uri_open() {
  local name=$1 version=$2 uri_field=$3 home_uri_field=homepage_uri
  json=$(curl -fLs https://rubygems.org/api/v2/rubygems/"$name"/versions/"$version".json)
  uri=$(jq -r ".$uri_field // .$home_uri_field" <<< "$json")

  if [[ $uri ]]; then
    o "$uri"
  else
    echo "No $uri_field or $home_uri_field"
    jq <<< "$json"
  fi
}

function gem_() {
  local cmd=$1 selected arr name version
  selected=$2 # etc/1.0
  IFS='/' read_array arr <<< "$selected"
  name=${arr[1]}
  version=${arr[2]}
  # echo "cmd: $cmd, name: $name, version: $version"

  case "$cmd" in
    cd) cd "$(bundle info "$name" --path)" || return ;;
    doc) gem_uri_open "$name" "$version" 'documentation_uri' ;;
    src) gem_uri_open "$name" "$version" 'source_code_uri' ;;
  esac
}
if [ -n "${ZSH_VERSION:-}" ]; then
  _gem_()  {
    local state

    _arguments '1: :->cmd' '2: :->gem'

    # shellcheck disable=2046
    case $state in
      cmd) compadd 'cd' 'doc' 'src' ;;
      gem) compadd $(bundle exec gem list | tr ' ' '/' | tr -d '()') ;;
    esac
  }
  compdef _gem_ gem_
fi

# cSpell:ignore gemcd gemdoc gemsrc
# shellcheck disable=SC2139
alias {gem_cd,gemcd}='gem_ cd'
# shellcheck disable=SC2139
alias {gem_doc,gemdoc}='gem_ doc'
# shellcheck disable=SC2139
alias {gem_src,gemsrc}='gem_ src'

# Roll back branch-specific migrations before switching to main
function rails_reset_to_main() {
  local new_migrations
  new_migrations=$(git diff --name-only "$(git_main_branch)" db/migrate)

  # Approach 1: Rollback one by one
  # Cons: Can take time
  new_migrations=$(echo "$new_migrations" | sort -t / -k 3 -n -r)

  local file name version
  while IFS= read -r file; do
    file=${file#db/migrate/}

    name=$(echo "$file" | cut -d '_' -f 2-)
    name=${name%.rb}
    name=$(echo "$name" | tr '_' ' ')

    version=$(echo "$file" | grep -Eoz '^\d+')

    echo_eval "$RAKE_CMD db:migrate:down VERSION=%q # %q" "$version" "$name"
  done <<< "$new_migrations"

  # # Approach 2: Rollback by the number of new migrations
  # # Cons: Can roll back wrong migrations, if the new migrations were not run
  # local count
  # count=$(echo "$new_migrations" | wc -l)
  # count=${count//[[:blank:]]/}
  # echo_eval "$RAKE_CMD db:rollback STEP=%q" "$count"

  # # Approach 3: Figure out the latest version before $new_migrations
  # # Cons: Unreliable if the order of migrations is not chronological (e.g. after merging a branch)
  # all_migrations=$($RAKE_CMD db:migrate:status)
  # all_migrations=$(echo "$all_migrations" | awk '{print $2}' | awk -F '_' '{print $1}' | sort -u | sort -r)

  echo_eval 'git checkout db/schema.rb'
  # shellcheck disable=SC2016
  echo_eval 'git checkout "$(git_main_branch)"'
}

function rails_migration_version() {
  local file=$1 base_name
  base_name=$(echo "$file" | grep -Ezo 'db/migrate/\d+')
  echo "$base_name" | cut -d '/' -f 3
}

function rails_update_migration() {
  local file=$1 current_version dummy_output new_version new_file

  current_version=$(rails_migration_version "$file")

  if rake db:migrate:status | rg -q "up\s+$current_version"; then
    echo >&2 "$current_version is up, roll it back before renaming it"
    return 1
  fi

  dummy_output=$("${RAILS_CMD}" generate migration dummy --pretend)
  new_version=$(rails_migration_version "$dummy_output")

  new_file=$(echo "$file" | gsed -e "s/$current_version/$new_version/")
  echo_eval 'mv %q %q' "$file" "$new_file"

  echo_eval "$RAKE_CMD db:migrate"
}

function ruby_cd_pull_migrate() {
  local dir=$1 branch=$2

  # PRE_PULL_CMD is in cd_checkout_pull

  cd_checkout_pull "$dir" "$branch"
  last_status=$?
  if [[ $last_status != 0 ]]; then
    printf '\n'
    return $last_status
  fi

  if [[ $POST_PULL_CMD ]]; then
    echo_eval "$POST_PULL_CMD"
  fi

  if [ -f Gemfile.lock ]; then
    local bundle_cmd=${BUNDLE_CMD:-'bundle install --quiet'}
    echo_eval "$bundle_cmd"
    echo_eval 'git checkout Gemfile.lock'
  fi

  local should_migrate
  [[ -d db/migrate && ! $NO_MIG ]] && should_migrate=1
  if [[ $should_migrate ]]; then
    local migrate_cmd=${MIGRATE_CMD:-"$RAKE_CMD db:migrate"}
    echo_eval "$migrate_cmd"
    [[ -e db/schema.rb ]] && echo_eval 'git checkout db/schema.rb' # Sometimes migrations modify db/schema.rb
  fi

  printf '\n'
}
alias {pim,pull_install_migrate}=ruby_cd_pull_migrate
