Include includes/lib/editing.sh
Include includes/lib/colors.sh
Include includes/lib/functions.sh

export GNU_DIRNAME=${GNU_DIRNAME:-dirname}
export GNU_REALPATH=${GNU_REALPATH:-realpath}

Describe 'edit without args'
  It 'prints usage and returns 1'
    When run edit
    The stdout should eq ''
    The stderr should include 'Usage'
    The status should eq 1
  End
End

Describe 'edit'
  # NOTE: Prefix variable names with `test_` to avoid collisions with code under test

  test_tmp_dir=''

  test_dir_name=project_a
  test_existing_file=$test_dir_name/existing
  test_existing_ruby_file=$test_existing_file.rb

  test_sub_dir=$test_dir_name/sub_dir

  test_new_dir=$test_dir_name/new/dir
  test_new_file=$test_new_dir/new
  test_new_ruby_file=$test_new_file.rb

  setupAll() {
    test_tmp_dir=$(mktemp -d)
    cd "$test_tmp_dir" || return
    mkdir -p $test_sub_dir
    touch "$test_existing_file" "$test_existing_ruby_file"
  }
  BeforeAll 'setupAll'

  cleanupAll() {
    if [[ $test_tmp_dir && -d $test_tmp_dir ]]; then
      rm -rf "$test_tmp_dir"
    fi
  }
  AfterAll 'cleanupAll'

  # Mocks
  function git() {
    local arg_str=$*
    if [[ $arg_str != "-C $test_dir_name"*' rev-parse --show-toplevel' ]]; then
      %logger "Unexpected git call: $arg_str"
      return 1
    fi

    if [[ ${test_dir_is_git:-} ]]; then
      echo "${test_dir_name:-}"
    fi
  }

  test_mine_calls=''
  function mine() {
    test_mine_calls+="$* ¶ "
    %preserve test_mine_calls
  }

  test_open_with_editor_calls=''
  function open_with_editor() {
    test_open_with_editor_calls+="$* ¶ "
    %preserve test_open_with_editor_calls
  }

  function realpath() {
    echo "$1"
  }

  function window_names() {
    case "${1?}" in
      RubyMine)
        if [[ ${test_project_is_open_in_rubymine:-} ]]; then
          echo "$test_dir_name – README.md"
          echo "project_b"
        elif [[ ${test_rubymine_is_open:-} ]]; then
          echo 'project_b – something.txt'
        fi
        ;;

      'Visual Studio Code.app')
        if [[ ${test_project_is_open_in_vscode:-} ]]; then
          echo "README.md — $test_dir_name (Workspace)"
          echo 'something.txt — project_b'
        fi
        ;;

      *)
        %logger "Unexpected window_names call: $*"
        exit 1
        ;;
    esac
  }
  # End: Mocks

  Context 'with an existing directory'
    It 'opens it with editor'
      When call edit "$test_sub_dir"
      The stdout should eq ''
      The stderr should eq ''
      The status should eq 0
      The variable test_open_with_editor_calls should eq "$test_sub_dir ¶ "
      The variable test_mine_calls should eq ''
    End
  End

  Context 'with a new file'
    test_file=$test_new_file

    Context 'when one of its parent directories is a git repo open in RubyMine'
      test_project_is_open_in_rubymine=1
      test_dir_is_git=1

      It 'opens it in RubyMine'
        When call edit "$test_file"
        The stdout should eq ''

        # TODO: GitHub CI: `printf: write error: Broken pipe` (is_in_rubymine_titles)
        # The stderr should eq "-> mkdir -p $test_new_dir"$'\n'"-> touch $test_file"
        The stderr should include "-> mkdir -p $test_new_dir"
        The stderr should include "-> touch $test_file"

        The path $test_file should be exist
        The status should eq 0
        The variable test_mine_calls should eq "$test_file ¶ "
        The variable test_open_with_editor_calls should eq ''
      End
    End

    Context 'when RubyMine is open'
      test_rubymine_is_open=1

      Context 'when given path is a Ruby file'
        test_file=$test_new_ruby_file

        It 'opens it in RubyMine'
          When call edit "$test_file"
          The stdout should eq ''
          The stderr should eq "-> mkdir -p $test_new_dir"$'\n'"-> touch $test_file"
          The status should eq 0
          The variable test_mine_calls should eq "$test_file ¶ "
          The variable test_open_with_editor_calls should eq ''
        End

        Context 'when the project is open in the editor'
          export EDITOR=code
          test_dir_is_git=1
          test_project_is_open_in_vscode=1

          It 'opens it with editor'
            When call edit "$test_file"
            The stdout should eq ''
            The stderr should eq "-> mkdir -p $test_new_dir"
            The status should eq 0
            The variable test_open_with_editor_calls should eq "$test_file ¶ "
            The variable test_mine_calls should eq ''
          End
        End
      End
    End
  End

  Context 'with an existing file'
    test_file=$test_existing_file

    Context 'when the file is text'
      test_line=21
      test_column=45

      Context 'when one of its parent directories is a git repo open in RubyMine'
        test_dir_is_git=1
        test_project_is_open_in_rubymine=1

        It 'opens it in RubyMine'
          When call edit "$test_file:$test_line:$test_column"
          The stdout should eq ''

          # TODO: GitHub CI: `printf: write error: Broken pipe` (is_in_rubymine_titles)
          # The stderr should eq ''
          The stderr should not include 'mkdir'
          The stderr should not include 'touch'

          The status should eq 0
          The variable test_mine_calls should eq "--line $test_line --column $((test_column - 1)) $test_file ¶ "
          The variable test_open_with_editor_calls should eq ''
        End
      End

      Context 'when RubyMine is open'
        test_rubymine_is_open=1

        Context 'with a Ruby file'
          test_file=$test_existing_ruby_file

          It 'opens it in RubyMine'
            When call edit "$test_file:$test_line:$test_column"
            The stdout should eq ''
            The stderr should eq ''
            The status should eq 0
            The variable test_mine_calls should eq "--line $test_line --column $((test_column - 1)) $test_file ¶ "
            The variable test_open_with_editor_calls should eq ''
          End

          Context 'when the project is open in the editor'
            export EDITOR=code
            test_dir_is_git=1
            test_project_is_open_in_vscode=1

            It 'opens it with editor'
              When call edit "$test_file:$test_line:$test_column"
              The stdout should eq ''
              The stderr should eq ''
              The status should eq 0
              The variable test_open_with_editor_calls should eq "$test_file:$test_line:$test_column ¶ "
              The variable test_mine_calls should eq ''
            End
          End
        End

        It 'opens it with editor'
          When call edit "$test_file:$test_line:$test_column"
          The stdout should eq ''
          The stderr should eq ''
          The status should eq 0
          The variable test_open_with_editor_calls should eq "$test_file:$test_line:$test_column ¶ "
          The variable test_mine_calls should eq ''
        End
      End

      It 'opens it with editor'
        When call edit "$test_file:$test_line:$test_column"
        The stdout should eq ''
        The stderr should eq ''
        The status should eq 0
        The variable test_open_with_editor_calls should eq "$test_file:$test_line:$test_column ¶ "
        The variable test_mine_calls should eq ''
      End
    End
  End
End

Describe 'open_with_editor'
  Context 'with VS Code'
    export EDITOR=code

    # Mocks
    test_code_calls=''
    function code() {
      test_code_calls+="$* ¶ "
      %preserve test_code_calls
    }
    # End: Mocks

    It 'opens given paths with editor'
      When call open_with_editor foo 'bar baz'
      The stdout should eq ''
      The stderr should eq '-> code -g foo bar\ baz'
      The status should eq 0
      The variable test_code_calls should eq '-g foo bar baz ¶ '
    End
  End
End
