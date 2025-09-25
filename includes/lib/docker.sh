alias libd='$EDITOR "$DOTFILES_INCLUDES"/lib/docker.sh' # cSpell:ignore libd

function act_t() {
  if [[ $DOCKER_PROVIDER == 'colima' ]]; then
    # https://github.com/abiosoft/colima/issues/997#issuecomment-2266030827
    COLIMA_PROFILE=act MOUNT_TYPE=sshfs colima_start
  fi

  # https://nektosact.com/missing_functionality/docker_context.html
  # shellcheck disable=SC2016
  echo_eval 'export DOCKER_HOST=$(docker context inspect --format "{{.Endpoints.docker.Host}}")'

  echo_eval "act $*"
}
alias actt='act_t' # cSpell:ignore actt

function colima_start() {
  local common_args="--profile ${COLIMA_PROFILE:-default}"
  # shellcheck disable=SC2086
  if FAKE_STATUS=1 echo_eval "colima $common_args status > /dev/null 2>&1"; then
    echo >&2 'Colima is already running'
    return 0
  fi

  # ~/.colima/default/colima.yaml
  local args="$common_args --ssh-port 5022"
  if [[ $OSTYPE == darwin* ]]; then
    args+=" --vm-type=vz --vz-rosetta --mount-type=${MOUNT_TYPE:-virtiofs} --cpu 4"
  fi

  echo_eval "colima start $args"
}
alias cos='colima_start'
alias cosa='colima stop --profile act'
alias coss='colima status'
alias cost='colima stop'

# https://github.com/docker/cli/issues/6231
function docker_completion_use_self() {
  echo_eval 'brew uninstall --ignore-dependencies docker-completion 2>/dev/null || true'

  # docker completion zsh --help
  local file
  if [[ $OSTYPE == darwin* ]]; then
    file="$HOMEBREW_PREFIX"/share/zsh/site-functions/_docker
  else
    # shellcheck disable=SC2154
    file="${fpath[1]}/_docker"
  fi
  echo_eval 'docker completion zsh > %q' "$file"
}

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
    docker_output=$(FAKE_ECHO="foo\nbar\nbaz" echo_eval "${cmd[*]}")
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
