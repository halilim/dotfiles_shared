Include includes/lib/which.sh

Describe 'which_detailed'
  # TODO: alias tests only work with Zsh
  Describe 'aliases'
    function color() { # Mock
      echo "$2"
    }

    function color_() { # Mock
      echo -n "$2"
    }

    # Mainly to prevent passing bat arguments to cat
    function bat() { # Mock
      cat
    }

    export GNU_SED=${GNU_SED:-sed}

    It 'prints alias and function details'
      baz() { echo 'qux'; }
      alias baz_alias='baz'
      When call eval which_detailed 'baz_alias'
      The stdout should include 'alias baz_alias=baz'
      The stdout should include 'function'
      The stdout should include "echo 'qux'"
      The stderr should eq ''
      The status should eq 0
    End

    It 'prints global alias'
      alias -g GLOBAL_ALIAS=' | grep foo'
      When call which_detailed 'GLOBAL_ALIAS'
      The stdout should eq "global alias alias -g GLOBAL_ALIAS=' | grep foo'"
      The stderr should eq ''
      The status should eq 0
    End

    It 'prints alias with prefixed variables and parameters'
      alias test_alias='FOO=bar baz="qux etc" echo "lorem '"'ipsum'"'" | grep "dolor"'
      When call which_detailed 'test_alias'
      The stdout should include "alias test_alias='FOO=bar baz="'"qux etc"'' echo "lorem '"'\''"'ipsum'"'\''"'" | grep "dolor"'
      The stdout should include 'builtin'
      The stderr should eq ''
      The status should eq 0
    End

    It 'prints self referencing alias and the command'
      alias cp='cp -i'
      When call which_detailed 'cp'
      The stdout should include "alias cp='cp -i'"
      The stdout should include 'command /bin/cp'
      The stderr should eq ''
      The status should eq 0
    End
  End
End
