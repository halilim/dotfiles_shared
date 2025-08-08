Include includes/lib/which.sh

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

  It 'prints variable details and value'
    # shellcheck disable=SC2034
    foo=bar
    # shellcheck disable=SC2016
    When call which_detailed '$foo'
    The stdout should include 'foo='
    The stdout should include 'bar'
    The stderr should include 'bar'
    The stderr should include 'not found'
    The status should eq 1
  End

  It 'reports unknowns'
    When call which_detailed 'baz'
    The stdout should include 'baz'
    The stderr should include 'not found'
    The status should eq 1
  End

  It 'prints function details'
    foo() { echo 'bar'; }
    When call which_detailed 'foo'
    The stdout should include 'function'
    The stdout should include "echo 'bar'"
    The stderr should eq ''
    The status should eq 0
  End
End
