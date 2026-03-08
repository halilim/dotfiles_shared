Include includes/lib/colors.sh
Include includes/lib/functions.sh
Include includes/lib/update_and_backup.sh

Describe 'update_and_backup'
  export UPDATE_BACKUP_CMDS=(
    'foo bar --baz'
    qux
  )

  # Mocks
  foo_calls=''
  function foo() {
    echo_eval echo 'must escape this'
    foo_calls+="$* ¶ "
    %preserve foo_calls
  }

  qux_calls=''
  function qux() {
    qux_calls+="$* ¶ "
    %preserve qux_calls
  }
  # End: Mocks

  Example 'calls update commands'
    When call update_and_backup
    The status should eq 0
    The stdout should eq 'must escape this'
    The stderr should include '-> foo bar --baz'
    The stderr should include '-> echo must\ escape\ this'
    The stderr should include '-> qux'
    The variable foo_calls should eq 'bar --baz ¶ '
    The variable qux_calls should eq ' ¶ '
  End
End
