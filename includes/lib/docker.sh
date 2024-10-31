# cSpell:ignore libd dcrr dcos

alias libd='$EDITOR "$DOTFILES_INCLUDES"/lib/docker.sh'

alias cos='colima start'

alias dk='docker'
alias dks='docker stats --no-stream'
alias dcrr='dcr --rm'

alias dcos='docker-compose stats'

# https://tunzor.github.io/posts/docker-list-images-by-size/ - added -r to sort
function docker_images() {
  docker image ls --format "{{.Repository}}:{{.Tag}} {{.Size}}" |
    awk '{if ($2~/GB/) print substr($2, 1, length($2)-2) * 1000 "MB - " $1 ; else print $2 " - " $1 }' |
    sed '/^0/d' |
    sort -nr
}
