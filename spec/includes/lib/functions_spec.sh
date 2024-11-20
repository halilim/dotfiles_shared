Include includes/lib/functions.sh

Describe "echo_eval"
  It "prints, evaluates a string"
    When call echo_eval 'echo "foo"'
    The stdout should eq "foo"
    The stderr should eq '-> echo "foo"'
  End

  It "returns status"
    When call echo_eval 'false'
    The status should eq 1
    The stdout should eq ''
    The stderr should eq '-> false'
  End

  It "escapes with %q"
    # shellcheck disable=SC2016
    var='foo "$bar'
    When call echo_eval 'echo %q' "$var"
    # shellcheck disable=SC2016
    The stdout should eq 'foo "$bar'
    # shellcheck disable=SC2016
    The stderr should eq '-> echo foo\ \"\$bar'
  End
End

Describe "join_array"
  It "joins an array"
    array=(foo "bar \n baz" qux)
    When call join_array "| \n |" "${array[@]}"
    The stdout should eq "foo| \n |bar \n baz| \n |qux"
    The stderr should eq ''
  End
End
