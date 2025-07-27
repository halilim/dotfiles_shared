function _print_array() {
  # shellcheck disable=SC2034
  local context state state_descr line
  # shellcheck disable=SC2034
  typeset -A opt_args

  _arguments '1: :->arg'

  # shellcheck disable=2046
  case $state in
    arg)
      local associative_arrays indexed_arrays
      associative_arrays=$(declare -pA)
      indexed_arrays=$(declare -pa)
      compadd $(echo "$associative_arrays" "$indexed_arrays" |
        rg '(\w+)=' --replace '$1' --only-matching |
        uniq)
      ;;
  esac
}

compdef _print_array print_array
