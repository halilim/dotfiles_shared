Include includes/lib/which.sh

Describe 'which_detailed'
  # alias tests only work with Zsh
  Describe 'aliases'
    function color() { # Mock
      echo "$2"
    }

    # Mainly to prevent passing bat arguments to cat
    function my_cat() {
      cat
    }

    export BAT_CMD=my_cat
    export GNU_SED=${GNU_SED:-sed}

    It 'prints alias and function details'
      baz() { echo 'qux'; }
      alias baz_alias='baz'
      When call eval which_detailed 'baz_alias'
      The stdout should include 'baz_alias is an alias for baz'
      The stdout should include 'function'
      The stdout should include "echo 'qux'"
      The stderr should eq ''
      The status should eq 0
    End

    It 'prints global alias'
      alias -g GLOBAL_ALIAS=' | grep foo'
      When call which_detailed 'GLOBAL_ALIAS'
      The stdout should eq 'GLOBAL_ALIAS is a global alias for  | grep foo'
      The stderr should eq ''
      The status should eq 0
    End

    It 'prints alias with prefixed variables and parameters'
      alias test_alias='FOO=bar baz="qux etc" echo "lorem ipsum" | grep "dolor"'
      When call which_detailed 'test_alias'
      The stdout should include 'alias for FOO=bar baz="qux etc" echo "lorem ipsum" | grep "dolor"'
      The stdout should include 'echo is a shell builtin'
      The stderr should eq ''
      The status should eq 0
    End
  End
End
