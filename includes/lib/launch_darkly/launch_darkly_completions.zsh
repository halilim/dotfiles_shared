function _launch_darkly_flag() {
  local state

  _arguments '1: :->flag_key'

  # shellcheck disable=2046
  case $state in
    flag_key)
      local file=.launch_darkly_flags.txt

      regen_if_stale "$file" '3 day' \
        launch_darkly_flag_keys '|' sort

      compadd $(cat "$file")
      ;;
  esac
}

compdef _launch_darkly_flag launch_darkly_flag
