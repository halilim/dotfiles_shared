alias libnp='$EDITOR "$DOTFILES_INCLUDES"/lib/nginx_php.sh' # cSpell:ignore libnp

function nginx_fg() {
  nginx -g 'daemon off;' &
  tail -f -n0 "$HOMEBREW_PREFIX"/var/log/nginx/{access,error}.log
}

function nginx_php_start() {
  pgrep php-fpm >/dev/null 2>&1 || php-fpm -D
  pgrep nginx >/dev/null 2>&1 || nginx
}

function nginx_php_stop() {
  pkill -QUIT 'php-fpm*'
  nginx -s quit
}
