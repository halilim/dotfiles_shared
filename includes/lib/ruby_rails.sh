alias libr='$EDITOR "$DOTFILES_INCLUDES"/lib/ruby_rails.sh' # cSpell:ignore libr

# bin/* ones sometimes raise "You have already activated ...", so using bundle exec for now
if [[ ! -v RUBY_CMD_PREFIX ]]; then
  export RUBY_CMD_PREFIX=(bundle exec) # _run-with-bundler | bin/ | bundle exec
fi

# These are used with echo_eval, which escapes aliases, so bare `rails` and `rake` are really bare
# The _*_command functions are from Oh My Zsh's Rails plugin

if [[ ${#RUBY_CMD_PREFIX[@]} -eq 1 && ${RUBY_CMD_PREFIX[*]:0:1} == 'bin/' ]]; then
  export RAILS_CMD=("${RUBY_CMD_PREFIX[*]}rails")
  export RAKE_CMD=("${RUBY_CMD_PREFIX[*]}rake")
  export RUBY_CMD_PREFIX_STR=${RUBY_CMD_PREFIX[*]:0:1}
else
  export RAILS_CMD=("${RUBY_CMD_PREFIX[@]}" rails)
  export RAKE_CMD=("${RUBY_CMD_PREFIX[@]}" rake)
  export RUBY_CMD_PREFIX_STR="${RUBY_CMD_PREFIX[*]} "
fi

export RAILS_ROUTE_CACHE=.routes_expanded.txt

function kill_spring() {
  pgrep 'spring (app|server)' | xargs kill -9
}

# More functionality is in *_completions.zsh
function rails_request() {
  local method_uri_format=$1 # E.g., `GET /users/:id(.:format)`
  local tool=${2:-postman}

  local method
  method=$(echo "$method_uri_format" | cut -d ' ' -f 1)

  local uri_and_format uri
  uri_and_format=$(echo "$method_uri_format" | cut -d ' ' -f 2)
  uri=$(echo "$uri_and_format" | sed -E 's/\(\.:format\)//')

  local file line
  case "$tool" in
    curl)
      echo "curl -X $method $uri"
      return
      ;;

    httpie)
      echo "http $method $uri"
      return
      ;;

    postman)
      echo "curl -X $method {{baseUrl}}$(echo "$uri" | sed -E 's/:([^\/]+)/{{\1}}/g')"
      return
      ;;

    _edit-action)
      local controller_and_action controller action
      controller_and_action=$(rails_request_find "$method" "$uri_and_format" '\s*\|\s*(\S+)')
      controller=$(echo "$controller_and_action" | cut -d '#' -f 1)
      action=$(echo "$controller_and_action" | cut -d '#' -f 2)
      # shellcheck disable=SC2012
      file=$(\ls -d {,components/*/}app/controllers/**/"${controller}_controller.rb" | head -n 1)
      line=$(rg --line-number --only-matching "def\s+$action\b" "$file" | head -n 1)
      line=${line%%:*}
      ;;

    _edit-route)
      local route_source gem_name file_and_line
      route_source=$(rails_request_find "$method" "$uri_and_format" '.*\nSource Location\s*\|\s*(.+)')
      gem_name=$(echo "$route_source" | rg '^(\S+)\s+\([\d.]+\)' --only-matching --replace '$1')
      if [[ $gem_name ]]; then
        local gem_path relative_path
        gem_path=$(bundle info "$name" --path)
        relative_path=$(echo "$route_source" | rg '^\S+\s+\([\d.]+\)\s+(.+)' --only-matching --replace '$1')
        file_and_line="$gem_path/$relative_path"
      else
        file_and_line="$route_source"
      fi
      file=${file_and_line%%:*}
      line=${file_and_line##*:}
      ;;
  esac

  if [[ $file ]]; then
    edit "$(realpath "$file")" "$line"
  fi
}
# shellcheck disable=SC2139
alias {rar,rbr}='rails_request'

function rails_request_find() {
  local method=${1?} uri_and_format=${2?} regex_suffix=${3?}
  rg "Verb\s*\|\s*$method\nURI\s*\|\s*$(ruby_escape_regex "$uri_and_format")\nController#Action$regex_suffix" \
    --multiline --no-line-number --only-matching --replace '$1' $RAILS_ROUTE_CACHE
}

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

    echo_eval "${RAKE_CMD[@]}" db:migrate:down VERSION="$version" "# $name"
  done <<< "$new_migrations"

  # # Approach 2: Rollback by the number of new migrations
  # # Cons: Can roll back wrong migrations, if the new migrations were not run
  # local count
  # count=$(echo "$new_migrations" | wc -l)
  # count=${count//[[:blank:]]/}
  # echo_eval "${RAKE_CMD[@]}" db:rollback STEP="$count"

  # # Approach 3: Figure out the latest version before $new_migrations
  # # Cons: Unreliable if the order of migrations is not chronological (e.g. after merging a branch)
  # all_migrations=$("${RAKE_CMD[@]}" db:migrate:status)
  # all_migrations=$(echo "$all_migrations" | awk '{print $2}' | awk -F '_' '{print $1}' | sort -u | sort -r)

  echo_eval git checkout db/schema.rb
  # shellcheck disable=SC2016
  echo_eval git checkout "$(git_main_branch)"
}

function rails_migration_version() {
  local file=$1 base_name
  base_name=$(echo "$file" | grep -Ezo 'db/migrate/\d+')
  echo "$base_name" | cut -d '/' -f 3
}

function rails_migration_bump_version() {
  local file=$1 current_version

  current_version=$(rails_migration_version "$file")

  if ! [[ $current_version =~ ^[0-9]+$ ]]; then
    echo >&2 "Invalid current version: $current_version"
    return 1
  fi

  local migration_status=${MIGRATION_STATUS:-}
  if [[ ! $migration_status ]]; then
    migration_status=$(DRY_RUN='' echo_eval "${RAKE_CMD[@]}" db:migrate:status '2> /dev/null')
  fi
  if echo "$migration_status" | rg -q "up\s+$current_version"; then
    echo >&2 "$current_version is up, roll it back before renaming it:"
    echo >&2 "VERSION=$current_version ${RAKE_CMD[*]} db:migrate:down"
    return 1
  fi

  local new_version=${NEW_VERSION:-}
  if [[ ! $new_version ]]; then
    local dummy_output
    dummy_output=$(DRY_RUN='' echo_eval "${RAILS_CMD[@]}" generate migration dummy --pretend '2> /dev/null')
    new_version=$(rails_migration_version "$dummy_output")
  fi

  if ! [[ $new_version =~ ^[0-9]+$ ]]; then
    echo >&2 "Invalid new version: $new_version"
    return 1
  fi

  local replace_part
  replace_part="{$current_version,$new_version}"
  local replaced
  replaced=$(echo "$file" | rg "(db/migrate/)($current_version)(.*)" --replace "\$1$replace_part\$3")

  local replace_part_color
  replace_part_color="{$(color gray "$current_version")$(color green ',')$(color white "$new_version")$(color_start green)}"
  local replaced_color
  replaced_color=$(echo "$file" | rg "(db/migrate/)($current_version)(.*)" --replace "\$1$replace_part_color\$3")

  CMD_TO_SHOW="mv $replaced_color" echo_eval mv "$replaced"

  if [[ ! ${NO_MIG:-} ]]; then
    echo_eval "${RAKE_CMD[@]}" db:migrate '2> /dev/null'
  fi
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
    local bundle_cmd
    if [[ ${BUNDLE_CMD:-} ]]; then
      bundle_cmd=("${BUNDLE_CMD[@]}")
    else
      bundle_cmd=(bundle install --quiet)
    fi

    echo_eval "${bundle_cmd[@]}"
  fi

  if [[ -e bin/spring ]]; then
    echo_eval kill_spring
  fi

  if [[ -d db/migrate && ! ${NO_MIG:-} ]]; then
    local migrate_cmd
    if [[ ${MIGRATE_CMD:-} ]]; then
      migrate_cmd=("${MIGRATE_CMD[@]}")
    else
      migrate_cmd=("${RAKE_CMD[@]}" db:migrate)
    fi
    echo_eval "${migrate_cmd[@]}"
  fi

  if [[ -d log ]]; then
    echo_eval "${RAKE_CMD[@]}" log:clear LOGS=all
  fi

  printf '\n'
}
# shellcheck disable=SC2139
alias {pim,pull_install_migrate}=ruby_cd_pull_migrate

function ruby_escape_regex() {
  ruby -e 'puts Regexp.escape(ARGV[0])' "$1"
}
