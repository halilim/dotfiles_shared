# See also: OMZ/bun, OMZ/npm, and OMZ/yarn plugins

alias libn='$EDITOR "$DOTFILES_INCLUDES"/lib/node.sh' # cSpell:ignore libn

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
