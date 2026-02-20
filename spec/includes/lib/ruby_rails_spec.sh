Include includes/lib/ruby_rails.sh
Include includes/lib/colors.sh
Include includes/lib/functions.sh

Describe 'ruby_cd_pull_migrate'
  export RAKE_CMD=rake

  bundle_call_count=0
  function bundle() {
    bundle_call_count=$((bundle_call_count + 1))
    if [[ $1 != 'install' ]]; then
      echo >&2 "Unregistered bundle mock: $*"
      exit 1
    fi
  }

  cd_checkout_pull_ret=0
  function cd_checkout_pull() {
    if [[ $1 != 'foo' || $2 != 'bar' ]]; then
      echo >&2 "Unregistered cd_checkout_pull mock: $*"
      exit 1
    fi
    return $cd_checkout_pull_ret
  }

  function kill_spring() { # Mock
    :
  }

  rake_call_count=0 # To track the number and order of rake calls
  function rake() {
    rake_call_count=$((rake_call_count + 1))

    case "$rake_call_count" in
      1) [[ $1 == 'db:migrate' ]] ;;
      2) [[ $1 == 'log:clear' ]] ;;
    esac
    rake_status=$?

    if [[ $rake_status != 0 ]]; then
      echo >&2 "Unregistered rake mock for call #$rake_call_count: $*"
      exit 1
    fi
  }

  dir=''
  setup() {
    dir=$(mktemp -d)
    cd "$dir" || exit 1
    mkdir -p bin db/migrate log
    touch Gemfile.lock bin/spring
  }
  BeforeAll 'setup'

  cleanup() {
    if [[ $dir ]]; then
      rm -rf "$dir"
    fi
  }
  AfterAll 'cleanup'

  Example 'pulls, installs, and migrates'
    When call ruby_cd_pull_migrate foo bar
    The status should eq 0
    The stdout should eq ''
    The stderr should include '-> bundle install'
    The variable bundle_call_count should eq 1
    The variable rake_call_count should eq 2
  End

  Context 'when cd_checkout_pull fails'
    cd_checkout_pull_ret=7

    It 'returns cd_checkout_pull status and does not run further commands'
      When call ruby_cd_pull_migrate foo bar
      The status should eq 7
      The stdout should eq ''
      The stderr should not include '-> bundle install'
      The variable bundle_call_count should eq 0
      The variable rake_call_count should eq 0
    End
  End
End
