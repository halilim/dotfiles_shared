alias liba='$EDITOR "$DOTFILES_INCLUDES"/lib/adminer.sh' # cSpell:ignore liba

alias adminer_pg_local='adminer "pgsql=127.0.0.1&username=postgres" postgres'

function adminer_np() {
  # shellcheck disable=SC2034
  local params=$1 \
    password=$2

  pbcopy_tmp "$password"

  echo_eval 'nginx_php_start'

  local url="http://localhost:$HOST_NGINX_PORT/tools/adminer/adminer/?$params"
  echo_eval 'o %q' "$url"
}
alias adminer='adminer_np'

function adminer_install() {
  if [[ ! ${ADMINER_DIR:-} ]]; then
    _adminer_var_set_warning ADMINER_DIR
    return 1
  fi

  git clone --recurse-submodules https://github.com/adminerevo/adminerevo "$ADMINER_DIR"
  adminer_update_activate
}

# Instead of using the single file adminer, using the full repo to get updates to plugins as well.
function adminer_update() {
  (
    cd "$ADMINER_DIR" || return

    if [[ -f adminer/index.orig.php ]]; then
      rm -f adminer/index.php
      mv adminer/index{.orig,}.php
    fi

    git checkout "$(git_main_branch)"
    git pull
    latest=$(git describe --tags)
    git checkout "$latest" --quiet
  )
  adminer_update_activate
}

function adminer_update_activate() {
  (
    cd "$ADMINER_DIR"/adminer || return

    if [[ ! ${ADMINER_HASH:-} ]]; then
      _adminer_var_set_warning ADMINER_HASH
      return 1
    fi

    mv index{,.orig}.php
    cp "$DOTFILES_SHARED"/share/adminer_custom.php index.php
    # Docker LAMP raises "AH00037: Symbolic link not allowed or link target not accessible",
    #   probably because the target is outside the doc root.
    # ln -s .../adminer_custom.php "$ADMINER_DIR"/adminer/custom.php
  )
}

function _adminer_var_set_warning() {
  echo >&2 "Set $1 in custom/includes/env.sh. Example: custom_example/includes/env.sh"
}
