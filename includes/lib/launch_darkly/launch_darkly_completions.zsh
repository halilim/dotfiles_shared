function _launch_darkly_flag() {
  local state

  _arguments '1: :->flag_key'

  # shellcheck disable=2046
  case $state in
    flag_key)
      local file=.launch_darkly_flags.txt

      if [[ ! -s $file ]] || last_mod_older_than "$file" '3 day'; then
        if [[ ${LAUNCH_DARKLY_KEYS_CMD:-} ]]; then
          printf >&2 "\nRegenerating %s ...\n" "$file"
          "${LAUNCH_DARKLY_KEYS_CMD[@]}" > "$file"
        else
          printf >&2 "\nLAUNCH_DARKLY_KEYS_CMD is not set, cannot generate %s\n" "$file"
          return 1
        fi
      fi

      compadd $(cat "$file")
      ;;
  esac
}

compdef _launch_darkly_flag launch_darkly_flag
