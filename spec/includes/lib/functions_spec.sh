Include includes/lib/functions.sh
Include includes/env.sh

Describe 'color'
  It 'does not print in color when not tty'
    When call color red 'bar'
    The stdout should eq 'bar'
    The stderr should eq ''
    The status should eq 0
  End
End

Describe 'echo_eval'
  It 'prints, evaluates a string'
    When call echo_eval 'echo "foo"'
    The status should eq 0
    The stdout should eq 'foo'
    The stderr should eq '-> echo "foo"'
  End

  It 'returns status'
    When call echo_eval 'false'
    The status should eq 1
    The stdout should eq ''
    The stderr should eq '-> false'
  End

  It 'escapes with %q'
    # shellcheck disable=SC2016
    var='foo "$bar'
    When call echo_eval 'echo %q' "$var"
    The status should eq 0
    # shellcheck disable=SC2016
    The stdout should eq 'foo "$bar'
    # shellcheck disable=SC2016
    The stderr should eq '-> echo foo\ \"\$bar'
  End

  It 'outputs fake echo with dry run'
    # shellcheck disable=SC2016
    var='foo "$bar'
    export DRY_RUN=1
    export FAKE_ECHO=baz
    When call echo_eval 'echo %q' "$var"
    The status should eq 0
    The stdout should eq 'baz'
    # shellcheck disable=SC2016
    The stderr should start with '-> echo foo\ \"\$bar'
  End

  It 'returns fake status with dry run'
    # shellcheck disable=SC2016
    var='foo "$bar'
    export DRY_RUN=1
    export FAKE_STATUS=3
    When call echo_eval 'echo %q' "$var"
    The status should eq 3
    The stdout should eq ''
    # shellcheck disable=SC2016
    The stderr should start with '-> echo foo\ \"\$bar'
  End
End

Describe 'join_array'
  It 'joins an array'
    array=(foo "bar \n baz" qux)
    When call join_array '| \n |' "${array[@]}"
    The status should eq 0
    The stdout should eq 'foo| \n |bar \n baz| \n |qux'
    The stderr should eq ''
  End
End

Describe 'remove_broken_links'
  setup() {
    tmp_dir=$(mktemp -d)
    file="$tmp_dir"/file
    another_file="$tmp_dir"/another_file
    broken_link="$tmp_dir"/broken_link
    another_link="$tmp_dir"/another_link
    touch "$file" "$another_file"
    ln -s "$file" "$broken_link"
    ln -s "$another_file" "$another_link"
    rm "$file"
  }
  BeforeEach 'setup'

  cleanup() {
    rm -rf "$tmp_dir"
  }
  AfterEach 'cleanup'

  Parameters
    'without' ''
    # shellcheck disable=SC2288
    'with (e.g. a script)' $'\n\t'
  End

  Example "removes broken links $1 custom IFS"
    if [[ $2 ]]; then
      IFS=$2
    fi

    [[ ! -e "$file" && -L "$broken_link" && -f "$another_file" && -L "$another_link" ]]

    When call remove_broken_links "$tmp_dir"
    The file "$broken_link" should not be exist
    The file "$another_link" should be exist
    The stdout should eq "Removing: $broken_link"
    The stderr should include "$tmp_dir"
    The status should eq 0
  End
End
