# cSpell:ignore libd dcrr dcos

alias libd='$EDITOR "$DOTFILES_INCLUDES"/lib/docker.sh'

# cSpell:ignore dkcl dkcs dkcst dkei dkeis dkirm dkin dkins dkst dkri dkrm dkrr dkrri
alias dk='docker'
alias dkb='docker build'
alias dkc='docker container'
# shellcheck disable=SC2139
alias {dkcl,dkl}='docker container ls'
alias dkcs='docker container start'
alias dkcst='docker container stop'
alias dke='docker exec'
alias dkei='docker exec -it'
alias dkeis='docker exec -it ... bash'
alias dkirm='docker images rm'
alias dkin='docker info'
alias dkins='docker inspect'
alias dkk='docker kill'
alias dkst='docker stop'
alias dkr='docker run'
alias dkri='docker run -it'
alias dkrm='docker rm'
alias dkrr='docker run --rm'
alias dkrri='docker run --rm -it'
alias dks='docker stats --no-stream'
alias dps="docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}'"

# cSpell:ignore dceis
# shellcheck disable=SC2139
alias {dceis,dcs}='docker compose exec -it ... sh'
alias dcos='docker compose stats'
alias dcrr='dcr --rm'

function colima_start() {
  local args=''
  if [[ $OSTYPE == darwin* ]]; then
    args='--vm-type=vz --vz-rosetta --mount-type=virtiofs --cpu 4'
  fi
  echo_eval "colima status > /dev/null 2>&1 || colima start $args"
}
alias cos='colima_start'
alias cost='colima stop'
alias costa='colima status'

# Internal utils to pass Docker containers as hosts and vice versa
function docker_host_to_container() {
  local host=$1
  local container=${host%.docker}
  if [[ $container == "$host" ]]; then
    return 1
  else
    echo "$container"
  fi
}
function docker_container_to_host() {
  printf "%s.docker\n" "$1"
}

function docker_hosts() {
  if ! command -v docker > /dev/null 2>&1 || ! docker info > /dev/null 2>&1; then
    return
  fi

  local cmd=(docker ps --format '{{.Names}}')

  if [[ $# -gt 0 ]]; then
    local arg
    for arg in "$@"; do
      case "$arg" in
        -h | --help)
          echo >&2 'Usage: docker_hosts [-h,--help] [<image1> <image2> ...]'
          return
          ;;

        -*)
          echo >&2 "Unknown option: $arg"
          return 1
          ;;

        *)
          cmd+=(--filter "$(printf 'name=%q' "$arg")")
          ;;
      esac
    done
  fi

  local docker_output
  if [[ ${VERBOSE:-} ]]; then
    docker_output=$(FAKE_RETURN="foo\nbar\nbaz" echo_eval "${cmd[*]}")
  else
    docker_output=$("${cmd[@]}")
  fi

  if [[ ! $docker_output ]]; then
    return
  fi

  local line name
  while IFS= read -r line; do
    name=${line%%=*}
    docker_container_to_host "$name"
  done < <(printf '%s\n' "$docker_output")
}
alias dkh='docker_hosts'

# https://tunzor.github.io/posts/docker-list-images-by-size/ - added -r to sort
function docker_images() {
  docker image ls --format "{{.Repository}}:{{.Tag}} {{.Size}}" |
    awk '{if ($2~/GB/) print substr($2, 1, length($2)-2) * 1000 "MB - " $1 ; else print $2 " - " $1 }' |
    sed '/^0/d' |
    sort -nr
}
alias dki='docker_images'
