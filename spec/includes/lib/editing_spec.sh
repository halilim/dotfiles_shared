Include includes/lib/editing.sh
Include includes/lib/colors.sh
Include includes/lib/functions.sh

Describe 'edit'
  OPEN_CMD=open_cmd_test

  # Mocks
  function open_cmd_test() {
    local arg_ct=$#
    local expected_arg_ct=${#expected_open_args[@]}
    if [[ $arg_ct != "$expected_arg_ct" ]]; then
      echo >&2 "Unregistered open_cmd_test mock: $*"
      exit 1
    fi

    local i actual_arg expected_arg
    for ((i = 1; i <= arg_ct; i++)); do
      actual_arg=${*:$i:1}
      expected_arg=${expected_open_args[*]:$((i-1)):1}
      if [[ $actual_arg != "$expected_arg" ]]; then
        echo >&2 "Expected open_cmd_test arg #$i to be $expected_arg, but got $actual_arg"
        exit 1
      fi
    done
  }

  function realpath() {
    echo "$1"
  }
  # End: Mocks

  Context 'without args'
    It 'raises error'
      When run edit
      The stdout should eq ''
      The stderr should include 'not set'
      The status should eq 1
    End
  End

  Context 'file'
    file_name=a_file
    dir=/project_a
    file=$dir/$file_name

    # Mocks
    function git() {
      echo "${git_output:-}"
    }

    function open_with_editor() {
      if [[ $1 != "${expected_open_with_editor_arg?}" ]]; then
        echo >&2 "Unregistered open_with_editor mock: $*"
        exit 1
      fi
    }

    function window_names() {
      if [[ $1 == 'Visual Studio Code.app' && $2 == 'Code' ]]; then
        if [[ ${code_is_open:-} ]]; then
          echo 'README.md — project_a (Workspace)'
        fi
        return
      fi

      if [[ $1 == 'Visual Studio Code - Insiders.app' && $2 == 'Code - Insiders' ]]; then
        if [[ ${code_insiders_is_open:-} ]]; then
          echo 'README.md — project_a (Workspace)'
        fi
        return
      fi

      if [[ $1 == 'RubyMine' ]]; then
        if [[ ${rubymine_is_open:-} ]]; then
          echo 'project_a – README.md, project_b'
        fi
        return
      fi

      if [[ $1 == *vim* ]]; then
        if [[ ${vim_is_open:-} ]]; then
          echo "$dir/project_a // README.md"
        fi
        return
      fi

      echo >&2 "Unexpected window_names call: $*"
      exit 1
    }
    # End: Mocks

    Context 'when non-text'
      # Mocks
      function file() {
        echo 'binary'
      }
      # End: Mocks

      It "calls $OPEN_CMD"
        expected_open_args=("$file")
        When call edit "$file"
        The stdout should eq ''
        The stderr should eq "-> $OPEN_CMD /project_a/a_file"
        The status should eq 0
      End
    End

    Context 'when text'
      line=2
      column=3

      # Mocks
      function vim_open() {
        if [[ ${expect_vim:-} && $1 != "${expected_vim_arg?}" ]]; then
          echo >&2 "Unregistered vim_open mock: $*"
          exit 1
        fi
      }
      # End: Mocks

      expected_vim_arg="$file:$line:$column"

      It 'calls vim'
        expect_vim=1
        When call edit "$file" "$line" "$column"
        The stdout should eq ''
        The stderr should eq ''
        The status should eq 0
      End

      Context 'RubyMine'
        # Mocks
        function mine() {
          local arg_ct=$#
          local expected_arg_ct=${#expected_mine_args[@]}
          if [[ $arg_ct != "$expected_arg_ct" ]]; then
            echo >&2 "Unregistered mine mock: $*"
            exit 1
          fi

          local i actual_arg expected_arg
          for ((i = 1; i <= arg_ct; i++)); do
            actual_arg=${*:$i:1}
            expected_arg=${expected_mine_args[*]:$((i-1)):1}
            if [[ $actual_arg != "$expected_arg" ]]; then
              echo >&2 "Expected mine arg #$i to be $expected_arg, but got $actual_arg"
              exit 1
            fi
          done
        }
        # End: Mocks

        Context 'without a git project'
          It 'calls vim'
            expect_vim=1
            When call edit "$file" "$line" "$column"
            The stdout should eq ''
            The stderr should eq ''
            The status should eq 0
          End

          Context 'when open and with a Ruby file'
            rubymine_is_open=1
            file=a_file.rb

            It 'calls it'
              expected_mine_args=(--line "\\$line" --column "\\$((column - 1))" "$file")
              When call edit "$file" "$line" "$column"
              The stdout should eq ''
              The stderr should eq ''
              The status should eq 0
            End
          End
        End

        Context 'with a git project'
          git_output=$dir

          It 'calls it'
            expected_mine_args=(--line "\\$line" --column "\\$((column - 1))" "$file")
            When call edit "$file" "$line" "$column"
            The stdout should eq ''
            The stderr should eq ''
            The status should eq 0
          End
        End
      End

      Context 'editor'
        setup_editor() {
          export EDITOR="$test_editor"
          expected_open_with_editor_arg="$file:$line:$column"
        }
        BeforeEach 'setup_editor'

        Context 'MacVim'
          test_editor=vim
          vim_is_open=1

          It 'calls it'
            When call edit "$file" "$line" "$column"
            The stdout should eq ''
            The stderr should eq ''
            The status should eq 0
          End
        End

        Context 'VS Code'
          test_editor='code'
          code_is_open=1

          It 'calls it'
            When call edit "$file" "$line" "$column"
            The stdout should eq ''
            The stderr should eq ''
            The status should eq 0
          End
        End

        Context 'VS Code Insiders'
          test_editor='code-insiders'
          code_insiders_is_open=1

          It 'calls it'
            When call edit "$file" "$line" "$column"
            The stdout should eq ''
            The stderr should eq ''
            The status should eq 0
          End
        End
      End
    End
  End
End

Describe 'open_with_editor'
  Context 'when the editor is VS Code'
    export EDITOR=code

    function code() {
      if [[ $1 != '-g' || $2 != 'foo' || $3 != 'bar baz' ]]; then
        echo >&2 'Invalid code call'
        return 1
      fi

      return 0
    }

    It 'opens given paths with editor'
      When call open_with_editor foo 'bar baz'
      The stdout should eq ''
      The stderr should eq '-> code -g foo bar\ baz'
      The status should eq 0
    End
  End

  Context 'when the editor is Vim'
    export EDITOR=/foo/bar/bin/vim
    export VIM_PATH=vim

    function vim() {
      if [[ $1 != '--remote-silent' || $2 != 'foo' || $3 != 'bar baz' ]]; then
        echo >&2 'Invalid vim call'
        return 1
      fi

      return 0
    }

    It 'opens given paths with editor'
      When call open_with_editor foo 'bar baz'
      The stdout should eq ''
      The stderr should eq '-> vim --remote-silent foo bar\ baz'
      The status should eq 0
    End
  End
End
