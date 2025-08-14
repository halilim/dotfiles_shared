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
    # shellcheck disable=SC2016
    The stdout should include '$foo variable '
    The stdout should include 'foo='
    The stdout should include 'bar'
    The stderr should eq ''
    The status should eq 0
  End

  It 'reports unknowns'
    When call which_detailed 'baz'
    The stdout should include 'baz'
    The stderr should include 'none'
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

  Context 'with multiple commands with the same name'
    dir1=''
    dir2=''

    function before_each() {
      dir1=$(mktemp -d)
      dir2=$(mktemp -d)
      PATH="$dir1:$dir2:$PATH"
      touch "$dir1"/foo
      chmod +x "$dir1"/foo
      touch "$dir2"/foo
      chmod +x "$dir2"/foo
    }
    BeforeEach 'before_each'

    function after_each() {
      rm -rf "$dir1" "$dir2"
    }
    AfterEach 'after_each'

    It 'prints both commands'
      When call which_detailed foo
      The stdout should eq "$(cat <<OUT
foo 1. command/file $dir1/foo
    2. command/file $dir2/foo
OUT
    )"
      The stderr should eq ''
      The status should eq 0
    End
  End
End
