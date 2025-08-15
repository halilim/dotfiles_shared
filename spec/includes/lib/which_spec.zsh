Include includes/lib/which.sh

Describe 'which_detailed'
  # TODO: alias tests only work with Zsh
  Describe 'aliases'
    # Mainly to prevent passing bat arguments to cat
    function bat() { # Mock
      cat
    }

    function color() { # Mock
      echo "$2"
    }

    function color_() { # Mock
      echo -n "$2"
    }

    export GNU_SED=${GNU_SED:-sed}

    It 'prints alias details'
      alias baz_alias='baz'
      When call eval which_detailed 'baz_alias'
      The stdout should eq 'alias alias baz_alias=baz'
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
  End
End
