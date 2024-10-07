function _brew_service_log() {
  local state

  _arguments '1: :->log_path'

  # shellcheck disable=2046
  case $state in
    log_path)
      compadd $(brew services info --all --json |
        jq -r '.[] | (.log_path, .error_log_path) | values')
      ;;
  esac
}
compdef _brew_service_log brew_service_log
