alias libd='$EDITOR "$DOTFILES_INCLUDES"/lib/docker.sh' # cSpell:ignore libd

function act_t() {
  if [[ $DOCKER_PROVIDER == 'colima' ]]; then
    # https://github.com/abiosoft/colima/issues/997#issuecomment-2266030827
    COLIMA_PROFILE=act MOUNT_TYPE=sshfs colima_start
  fi

  # https://nektosact.com/missing_functionality/docker_context.html
  local docker_host
  docker_host=$(FAKE_ECHO='unix:///Users/user/.docker/run/docker.sock' \
    echo_eval docker context inspect --format '{{.Endpoints.docker.Host}}')
  echo_eval export DOCKER_HOST="$docker_host"

  echo_eval act "$@"
}
alias actt='act_t' # cSpell:ignore actt

# Interactive debugging
# Then manually run commands in .github/workflows/build.yml
function act_shell() {
  local container_dir=/tmp/code
  local shared_dotfiles_dir=$container_dir/dotfiles/shared
  # cSpell:ignore catthehacker
  echo_eval container run --rm -it -v ~/code:$container_dir --cwd "$shared_dotfiles_dir" \
    catthehacker/ubuntu:act-latest bash -c "$shared_dotfiles_dir/share/act_shell"
    # bash -c 'curl -fsSL https://git.io/shellspec | sh -s latest.tar.gz --bin /usr/local/bin --yes && echo "ShellSpec version: $(shellspec --version)"; exec bash'
}
alias acts='act_shell'

function colima_start() {
  local common_args=(--profile "${COLIMA_PROFILE:-default}")
  if FAKE_STATUS=1 echo_eval colima "${common_args[@]}" status '> /dev/null 2>&1'; then
    echo >&2 'Colima is already running'
    return 0
  fi

  # ~/.colima/default/colima.yaml
  local args=("${common_args[@]}" --ssh-port 5022)
  if [[ $OSTYPE == darwin* ]]; then
    args+=(
      --vm-type=vz
      --vz-rosetta
      --mount-type="${MOUNT_TYPE:-virtiofs}"
      --cpu 4
    )
  fi

  echo_eval colima start "${args[@]}"
}
alias cos='colima_start'

alias cor='colima restart'
# shellcheck disable=SC2139
alias {colima_rebuild,corb}='colima delete && colima_start' # cSpell:disable-line
alias coss='colima status'
alias cost='colima stop'
alias cosa='colima stop --profile act'

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
  if ! echo_eval command -v docker '> /dev/null 2>&1' \
     || ! echo_eval docker info '> /dev/null 2>&1'; then
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
          cmd+=(--filter name="$arg")
          ;;
      esac
    done
  fi

  local docker_output
  docker_output=$(FAKE_ECHO="foo\nbar\nbaz" echo_eval "${cmd[@]}")

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
