# shellcheck source=../../includes/functions.sh
Include includes/functions.sh

Describe "join_array"
  It "joins an array"
    array=(foo "bar \n baz" qux)
    When call join_array "| \n |" "${array[@]}"
    The stdout should eq "foo| \n |bar \n baz| \n |qux"
    The stderr should eq ''
  End
End
