# See also: OMZ/bun, OMZ/npm, and OMZ/yarn plugins

alias libjs='$EDITOR "$DOTFILES_INCLUDES"/lib/js.sh' # cSpell:ignore libjs

function js_install_globals() {
  # npm doesn't support installing globals from a package.json
  # To see existing globals:
  # - Node: npm list -g --depth 0
  # - Bun: bat ~/.bun/install/global/package.json

  $JS_PM install -g bash-language-server
}

function js_update_globals() {
  local packages=''

  if [[ ${JS_UPDATE_GLOBALS_EXCLUDE_PATTERN:-''} ]]; then
    packages=$($JS_PM -g outdated --parseable --depth=0 |
      cut -d: -f2 |
      sed 's/@[0-9.]*$//' |
      grep -Ev "$JS_UPDATE_GLOBALS_EXCLUDE_PATTERN" |
      tr '\n' ' ')

    [[ ! $packages ]] && return 0
  fi

  echo_eval "$JS_PM update -g --silent $packages"
}
