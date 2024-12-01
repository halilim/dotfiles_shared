function launch_darkly_flag() {
  local flag_key=$1 url
  # shellcheck disable=SC2059
  url=$(printf "$LAUNCH_DARKLY_URL" "$flag_key")
  SILENT=1 echo_eval "$OPEN_CMD %q" "$url"
}
alias ldf='launch_darkly_flag'
