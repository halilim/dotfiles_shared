Include includes/lib/functions.sh

Describe 'print_array'
  It 'prints regular array'
    # shellcheck disable=SC2190
    declare -a array=(foo 'bar= "baz"' "lorem\nipsum" '')
    When call print_array array
    The status should eq 0
    The stdout should eq 'Indexed array
0 : "foo"
1 : "bar= \"baz\""
2 : "lorem\nipsum"
3 : ""'
    The stderr should eq ''
  End

  It 'prints associative array'
    # shellcheck disable=SC2034
    declare -A array=([foo]='bar= "baz"' ["qux\nlorem"]="ipsum\ndolor" [etc]='')
    When call print_array array
    The status should eq 0
    The stdout should include 'Associative array'
    The stdout should include 'foo : "bar= \"baz\""'
    The stdout should include 'qux
lorem : "ipsum\ndolor"'
    The stdout should include 'etc : ""'
    The stderr should eq ''
  End
End
