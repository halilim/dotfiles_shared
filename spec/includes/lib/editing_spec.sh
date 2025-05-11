Include includes/lib/editing.sh
Include includes/lib/functions.sh # For echo_eval

Describe 'open_with_editor'
  function code() {
    if [[ $1 != '-g' || $2 != 'foo' || $3 != 'bar baz' ]]; then
      echo >&2 'Invalid code call'
      return 1
    fi

    return 0
  }

  export EDITOR=code

  It 'opens given paths with editor'
    When call open_with_editor foo 'bar baz'
    The stdout should eq ''
    The stderr should eq '-> code -g foo bar\ baz'
    The status should eq 0
  End
End
