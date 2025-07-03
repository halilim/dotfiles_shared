Include includes/lib/editing.sh
Include includes/lib/functions.sh # For echo_eval

Describe 'open_with_editor'
  Context 'when the editor is VS Code'
    export EDITOR=code

    function code() {
      if [[ $1 != '-g' || $2 != 'foo' || $3 != 'bar baz' ]]; then
        echo >&2 'Invalid code call'
        return 1
      fi

      return 0
    }

    It 'opens given paths with editor'
      When call open_with_editor foo 'bar baz'
      The stdout should eq ''
      The stderr should eq '-> code -g foo bar\ baz'
      The status should eq 0
    End
  End

  Context 'when the editor is Vim'
    export EDITOR=/foo/bar/bin/vim
    export VIM_CMD=vim

    function vim() {
      if [[ $1 != '--remote-silent' || $2 != 'foo' || $3 != 'bar baz' ]]; then
        echo >&2 'Invalid vim call'
        return 1
      fi

      return 0
    }

    It 'opens given paths with editor'
      When call open_with_editor foo 'bar baz'
      The stdout should eq ''
      The stderr should eq '-> vim_open foo bar\ baz
-> vim --remote-silent foo bar\ baz'
      The status should eq 0
    End
  End
End
