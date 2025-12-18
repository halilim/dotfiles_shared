alias libr='$EDITOR "$DOTFILES_INCLUDES"/lib/ruby_rails.sh' # cSpell:ignore libr

# bin/* ones sometimes raise "You have already activated ...", so using bundle exec for now
# Use the Rails defaults - binstubs, Spring, etc. Change only when needed.
# Alternative: Oh My Zsh bundler plugin (_run-with-bundler), but it uses an alias which breaks some flows.
export RUBY_CMD_PREFIX=${RUBY_CMD_PREFIX-'bundle exec '} # `bin/` | `bundle exec `
export RAILS_CMD="${RUBY_CMD_PREFIX}rails"
export RAKE_CMD="${RUBY_CMD_PREFIX}rake"

export RAILS_ROUTE_CACHE=.routes_expanded.txt

function gem_install_bundler_gemfile() {
  local version
  version=$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1 | tr -d ' ')
  gem install bundler:"$version"
}
# cSpell:ignore gemib
alias gemib='gem_install_bundler_gemfile'

function gem_uri_open() {
  local name=$1 version=$2 uri_field=$3
  local -r home_uri_field='homepage_uri'

  local json
  json=$(FAKE_ECHO="{\"$uri_field\": \"https://example.com\", \"$home_uri_field\": \"\"}" echo_eval \
    'curl -Ls %q' "https://rubygems.org/api/v2/rubygems/$name/versions/$version.json")

  local uri
  uri=$(jq -r ".$uri_field // .$home_uri_field" <<< "$json")

  if [[ $uri ]]; then
    echo_eval "$OPEN_CMD %q" "$uri"
  else
    echo >&2 "No $uri_field or $home_uri_field"
    echo >&2 "$json" | jq
    return 1
  fi
}

function gem_() {
  local cmd=$1 selected name version
  selected=$2 # foo/1.0/ or bar/2.0/default
  name=$(echo "$selected" | cut -d '/' -f 1)
  version=$(echo "$selected" | cut -d '/' -f 2)
  # declare -p cmd name version 1>&2

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

function kill_spring() {
  pgrep 'spring (app|server)' | xargs kill -9
}

# More functionality is in *_completions.zsh
function rails_request() {
  local method_and_uri=$1 # E.g., `GET /users/:id(.:format)`
  local tool=${2:-postman}

  local method
  method=$(echo "$method_and_uri" | cut -d ' ' -f 1)

  local uri
  uri=$(echo "$method_and_uri" | cut -d ' ' -f 2)
  uri=$(echo "$uri" | sed -E 's/\(\.:format\)//')

  case "$tool" in
    curl)
      echo "curl -X $method $uri"
      ;;

    httpie)
      echo "http $method $uri"
      ;;

    postman)
      echo "curl -X $method {{baseUrl}}$(echo "$uri" | sed -E 's/:([^\/]+)/{{\1}}/g')"
      ;;

    _edit-action)
      local uri_regex controller_and_action controller action file line
      uri_regex=$(ruby -e "puts Regexp.new('$uri\W')")
      controller_and_action=$(rg "$uri_regex.*\nController#Action\s*\|\s*(\S+)" \
        --multiline --only-matching --replace '$1' $RAILS_ROUTE_CACHE)
      controller=$(echo "$controller_and_action" | cut -d '#' -f 1)
      action=$(echo "$controller_and_action" | cut -d '#' -f 2)
      # shellcheck disable=SC2012
      file=$(\ls -d {,components/*/}app/controllers/**/"${controller}_controller.rb" | head -n 1)
      line=$(rg --line-number --only-matching "def\s+$action\b" "$file" | head -n 1)
      line=${line%%:*}
      echo_eval 'open_from_iterm %q %q' "$(realpath "$file")" "$line"
      ;;

    _edit-route)
      local uri_regex route_source gem_name file_and_line
      uri_regex=$(ruby -e "puts Regexp.new('$uri\W')")
      route_source=$(rg "$uri_regex.*\nController#Action.*\nSource Location\s*\|\s*(.+)" \
        --multiline --only-matching --replace '$1' $RAILS_ROUTE_CACHE)
      gem_name=$(echo "$route_source" | rg '^(\S+)\s+\([\d.]+\)' --only-matching --replace '$1')
      if [[ $gem_name ]]; then
        local gem_path relative_path
        gem_path=$(bundle info "$name" --path)
        relative_path=$(echo "$route_source" | rg '^\S+\s+\([\d.]+\)\s+(.+)' --only-matching --replace '$1')
        file_and_line="$gem_path/$relative_path"
      else
        file_and_line="$route_source"
      fi
      local file=${file_and_line%%:*}
      local line=${file_and_line##*:}
      echo_eval 'open_from_iterm %q %q' "$(realpath "$file")" "$line"
      ;;
  esac
}
# shellcheck disable=SC2139
alias {rar,rbr}='rails_request'

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
  local file=$1 current_version

  current_version=$(rails_migration_version "$file")

  if rake db:migrate:status | rg -q "up\s+$current_version"; then
    echo >&2 "$current_version is up, roll it back before renaming it"
    return 1
  fi

  local dummy_output
  dummy_output=$("${RAILS_CMD}" generate migration dummy --pretend)
  local new_version
  new_version=$(rails_migration_version "$dummy_output")

  local new_file
  new_file=$(echo "$file" | "$GNU_SED" -e "s/$current_version/$new_version/")
  echo_eval 'mv %q %q' "$file" "$new_file"

  echo_eval "$RAKE_CMD db:migrate"
}

function ruby_cd_pull_migrate() {
  local dir=$1 branch=$2

  # PRE_PULL_CMD is in cd_checkout_pull

  cd_checkout_pull "$dir" "$branch"
  local -r last_status=$?
  if [[ $last_status != 0 && ! $FORCE ]]; then
    printf '\n'
    return $last_status
  fi

  if [[ ${POST_PULL_CMD:-} ]]; then
    echo_eval "$POST_PULL_CMD"
  fi

  if [[ -e Gemfile.lock ]]; then
    local bundle_cmd=${BUNDLE_CMD:-'bundle install --quiet'}
    echo_eval "$bundle_cmd"
  fi

  if [[ -e bin/spring ]]; then
    echo_eval 'kill_spring'
  fi

  if [[ -d db/migrate && ! ${NO_MIG:-} ]]; then
    local migrate_cmd=${MIGRATE_CMD:-"$RAKE_CMD db:migrate"}
    echo_eval "$migrate_cmd"
  fi

  if [[ -d log ]]; then
    echo_eval "$RAKE_CMD log:clear LOGS=all"
  fi

  printf '\n'
}
# shellcheck disable=SC2139
alias {pim,pull_install_migrate}=ruby_cd_pull_migrate
