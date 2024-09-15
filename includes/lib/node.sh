# See also: OMZ/npm & OMZ/yarn plugins

alias libn='$EDITOR "$DOTFILES_INCLUDES"/lib/node.sh' # cSpell:ignore libn

function npm_update_globals() {
  local packages=''

  if [[ ${NPM_UPDATE_GLOBALS_EXCLUDE_PATTERN:-''} ]]; then
    packages=$(npm -g outdated --parseable --depth=0 |
      cut -d: -f2 |
      sed 's/@[0-9.]*$//' |
      grep -Ev "$NPM_UPDATE_GLOBALS_EXCLUDE_PATTERN" |
      tr '\n' ' ')

    [[ ! $packages ]] && return 0
  fi

  echo_eval "npm update -g --silent $packages"
}
