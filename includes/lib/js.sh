# See also: OMZ/bun, OMZ/npm, and OMZ/yarn plugins

alias libjs='$EDITOR "$DOTFILES_INCLUDES"/lib/js.sh' # cSpell:ignore libjs

function js_install_globals() {
  # npm doesn't support installing globals from a package.json
  # To see existing globals:
  # - Node: npm list -g --depth 0
  # - Bun: bat ~/.bun/install/global/package.json

  echo_eval "$JS_PM" install -g bash-language-server
}

function js_update_globals() {
  if ! command -v npm > /dev/null 2>&1; then
    return 0
  fi

  local packages_arr=()
  if [[ ${JS_UPDATE_GLOBALS_EXCLUDE_PATTERN:-''} ]]; then
    local output
    # bun doesn't support --parseable or --depth=0
    output=$(DRY_RUN='' echo_eval npm -g outdated --parseable --depth=0 '|
  ' cut -d: -f2 '|
  ' sed 's/@[0-9.]*$//' '|
  ' grep -Ev "$JS_UPDATE_GLOBALS_EXCLUDE_PATTERN")

    if [[ ! $output ]]; then
      return 0
    fi

    if command -v mapfile > /dev/null 2>&1; then
      mapfile -t packages_arr < <( echo "$output" )
    elif [ -n "${ZSH_VERSION:-}" ]; then
      # shellcheck disable=SC2296,SC2116
      packages_arr=("${(f)$(echo "$output")}")
    fi
  fi

  echo_eval npm update -g --silent "${packages_arr[@]}"
}
