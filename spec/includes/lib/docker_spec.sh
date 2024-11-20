Include includes/lib/docker.sh

Describe "docker_hosts"
  function docker() {
    local ps_base='ps --format {{.Names}}'

    case "$*" in
      info)
        echo 'Client: ...'
        ;;

      "$ps_base")
        printf '%s\n%s\n%s\n' \
          'foo' \
          'bar' \
          'baz'
        ;;

      "$ps_base --filter ancestor=qux"|"$ps_base --filter ancestor=qux --filter ancestor=baz")
        echo 'bar'
        ;;

      "$ps_base --filter ancestor=baz")
        echo ''
        ;;

      *)
        echo >&2 "Unregistered docker mock: $*"
        return 1
    esac
  }

  It "returns hosts"
    When call docker_hosts
    The stdout should eq 'foo.docker
bar.docker
baz.docker'
  End

  Parameters
    'qux' 'bar.docker'
    'baz' ''
    'qux baz' 'bar.docker'
  End

  Example "when filtered by $1"
    # shellcheck disable=SC2086,SC2116,SC2207
    docker_hosts_args=($(echo $1))
    When call docker_hosts "${docker_hosts_args[@]}"
    The stdout should eq "$2"
  End
End
