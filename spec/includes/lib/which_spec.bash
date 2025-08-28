Include includes/lib/which.sh
Include includes/lib/functions.sh

Describe 'which_detailed'
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

  It 'prints command'
    When call which_detailed 'echo'
    The stdout should include 'builtin'
    The stdout should include 'file'
    The stdout should include '/bin/echo'
    The stderr should eq ''
    The status should eq 0
  End
End
