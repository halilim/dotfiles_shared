Include includes/lib/which.sh

Describe 'which_detailed'
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

  It 'prints command'
    When call which_detailed 'echo'
    The stdout should include 'builtin'
    The stdout should include 'file'
    The stdout should include '/bin/echo'
    The stderr should eq ''
    The status should eq 0
  End
End
