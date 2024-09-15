alias libr='$EDITOR "$DOTFILES_INCLUDES"/lib/ruby_rails.sh' # cSpell:ignore libr

export RUBY_CMD_PREFIX=${RUBY_CMD_PREFIX:-'bundle exec '} # or 'bin/'
export RAILS_CMD="${RUBY_CMD_PREFIX}rails"
export RAKE_CMD="${RUBY_CMD_PREFIX}rake"

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
  local cmd=$1 selected name version
  selected=$2 # etc/1.0
  name=${selected%%/*}
  version=${selected#*/}
  # echo "cmd: $cmd, name: $name, version: $version"

  case "$cmd" in
    cd) cd "$(bundle info "$name" --path)" || return ;;
    doc) gem_uri_open "$name" "$version" 'documentation_uri' ;;
    src) gem_uri_open "$name" "$version" 'source_code_uri' ;;
  esac
}

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

  new_file=$(echo "$file" | "$GNU_SED" -e "s/$current_version/$new_version/")
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
# shellcheck disable=SC2139
alias {pim,pull_install_migrate}=ruby_cd_pull_migrate
