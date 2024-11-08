function launch_darkly_flag() {
  local flag_key=$1
  # shellcheck disable=SC2059
  $OPEN_CMD "$(printf "$LAUNCH_DARKLY_URL" "$flag_key")"
}
alias ldf='launch_darkly_flag'
