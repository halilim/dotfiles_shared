alias libld='$EDITOR "$DOTFILES_INCLUDES"/lib/launch_darkly.sh' # cSpell:ignore libld

function launch_darkly_flag() {
  local flag_url=${LAUNCH_DARKLY_FLAG_URL:-'https://app.launchdarkly.com/projects/%s/flags/%s/targeting'}

  local flag_key=$1 url
  local project=${LAUNCH_DARKLY_PROJECT:-default}
  # shellcheck disable=SC2059
  url=$(printf "$flag_url" "$project" "$flag_key")

  if [[ ${FED:-} ]]; then
    url=${url/.com\//.us\/}
  fi

  SILENT=1 echo_eval "$OPEN_CMD %q" "$url"
}
alias ldf='launch_darkly_flag'
# shellcheck disable=SC2139
alias {ldff,ldfg,ldg}='FED=1 launch_darkly_flag' # cSpell:ignore ldff ldfg

function launch_darkly_flag_keys() {
  # https://launchdarkly.com/docs/guides/api/rest-api#required-headers
  local token=${LAUNCH_DARKLY_ACCESS_TOKEN:-}
  if [[ ! $token ]]; then
    echo >&2 'LAUNCH_DARKLY_REST_API_ACCESS_TOKEN is not set'
    return 1
  fi

  local project=${LAUNCH_DARKLY_PROJECT:-default}
  local nextPath="/api/v2/flags/$project?limit=100"
  local currentJson line

  while [[ $nextPath && $nextPath != 'null' ]]; do
    if ! currentJson=$(echo_eval 'curl -L --fail-with-body --no-progress-meter %q -H %q' "https://app.launchdarkly.com$nextPath" "Authorization: $token"); then
      jq <<< "$(printf %s "$currentJson")"
      return 1
    fi

    while IFS= read -r line; do
      echo "$line"
    done <<< "$(printf %s "$currentJson" | jq -r '.items.[].key')"
    nextPath=$(printf %s "$currentJson" | jq -r '._links.next.href')
  done
}
