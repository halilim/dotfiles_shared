Include includes/lib/colors.sh
Include includes/lib/functions.sh

Describe 'join_array'
  It 'joins an array'
    # shellcheck disable=SC2190
    declare -a array=(foo "bar \n baz" qux)
    When call join_array '| \n |' "${array[@]}"
    The status should eq 0
    The stdout should eq 'foo| \n |bar \n baz| \n |qux'
    The stderr should eq ''
  End
End

Describe 'print_array'
  It 'prints regular array'
    # shellcheck disable=SC2190
    declare -a array=(foo "bar= 'baz'" "lorem\nipsum" '')
    When call print_array array
    The status should eq 0
    The stdout should eq "Indexed array
1 : foo
2 : 'bar= '\''baz'\'
3 : 'lorem
ipsum'
4 : ''"
    The stderr should eq ''
  End

  It 'prints associative array'
    declare -A array=([foo]='bar= "baz"' ["qux\nlorem"]="ipsum\ndolor" [etc]='')
    When call print_array array
    The status should eq 0
    The stdout should include 'Associative array'
    The stdout should include "foo : 'bar= \"baz\"'"
    The stdout should include "qux
lorem : 'ipsum
dolor'"
    The stdout should include "etc : ''"
    The stderr should eq ''
  End
End
