function launch_darkly_flag() {
  local flag_key=$1 url
  # shellcheck disable=SC2059
  url=$(printf "$LAUNCH_DARKLY_URL" "$flag_key")

  if [[ ${FED:-} ]]; then
    url=${url/.com\//.us\/}
  fi

  SILENT=1 echo_eval "$OPEN_CMD %q" "$url"
}
alias ldf='launch_darkly_flag'
# shellcheck disable=SC2139
alias {ldff,ldfg,ldg}='FED=1 launch_darkly_flag' # cSpell:ignore ldff ldfg
