Include includes/lib/ruby_rails.sh
Include includes/lib/colors.sh
Include includes/lib/functions.sh

Describe 'ruby_cd_pull_migrate'
  export RAKE_CMD=(rake)

  bundle_calls=''
  function bundle() {
    bundle_calls+="$* ¶ "
    %preserve bundle_calls
  }

  cd_checkout_pull_calls=''
  function cd_checkout_pull() {
    cd_checkout_pull_calls+="$* ¶ "
    %preserve cd_checkout_pull_calls

    if [[ ${cd_checkout_pull_ret:-} ]]; then
      return $cd_checkout_pull_ret
    else
     return 0
    fi
  }

  function kill_spring() { # Mock
    :
  }

  rake_calls=''
  function rake() {
    rake_calls+="$* ¶ "
    %preserve rake_calls
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
    The variable bundle_calls should eq 'install --quiet ¶ '
    The variable rake_calls should eq 'db:migrate ¶ log:clear LOGS=all ¶ '
  End

  Context 'when cd_checkout_pull fails'
    cd_checkout_pull_ret=7

    It 'returns cd_checkout_pull status and does not run further commands'
      When call ruby_cd_pull_migrate foo bar
      The status should eq 7
      The stdout should eq ''
      The stderr should not include '-> bundle install'
      The variable cd_checkout_pull_calls should eq 'foo bar ¶ '
      The variable bundle_calls should eq ''
      The variable rake_calls should eq ''
    End
  End
End
