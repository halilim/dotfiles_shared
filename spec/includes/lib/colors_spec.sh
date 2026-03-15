Include includes/lib/colors.sh

Describe 'color'
  It 'does not print in color when not tty'
    When call color red 'bar'
    The stdout should eq 'bar'
    The stderr should eq ''
    The status should eq 0
  End
End
