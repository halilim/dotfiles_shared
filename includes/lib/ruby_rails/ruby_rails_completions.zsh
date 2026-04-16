_gem_()  {
  local state

  _arguments '1: :->cmd' '2: :->gem'

  # shellcheck disable=SC2046
  case $state in
    cmd) compadd 'cd' 'doc' 'src' ;;
    gem)
      local output
      if [[ -e Gemfile ]]; then
        output=$(bundle list --format json | jq -r '.gems.[] | .name + "/" + .version')
      else
        output=$(gem list | rg -v 'default:' | rg '^(\S+)\s+\(([\d.]+)' --only-matching --replace '$1/$2')
      fi

      local gems=()
      if command -v mapfile > /dev/null 2>&1; then
        mapfile -t gems < <( echo "$output" )
      elif [ -n "${ZSH_VERSION:-}" ]; then
        # shellcheck disable=SC2034,SC2296,SC2116
        gems=("${(f)$(echo "$output")}")
      fi
      compadd -a gems
      ;;
  esac
}
compdef _gem_ gem_

_rails_request() {
  local state

  _arguments '1: :->method_and_uri' '2: :->tool'

  # shellcheck disable=2046
  case $state in
    method_and_uri)
      local file=$RAILS_ROUTE_CACHE pairs=()

      regen_if_stale "$file" '3 day' \
        "${RAILS_CMD[@]}" routes --expanded "|" grep -vE '^(E,|I,|{\"|Active metric|---)'

      # shellcheck disable=SC2034,SC2296,SC2116
      pairs=("${(f)$(rg --multiline --only-matching --replace '$1 $2' \
        'Verb\s*\|\s*(\S+)\s*\nURI\s*\|\s*(\S+)' "$file")}")

      compadd -a pairs
      ;;

    tool) compadd 'curl' 'httpie' 'postman' '_edit-action' '_edit-route';;
  esac
}

compdef _rails_request rails_request
