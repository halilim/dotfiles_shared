Include includes/lib/editing.sh
Include includes/lib/colors.sh
Include includes/lib/functions.sh

Describe 'edit'
  OPEN_CMD=open_cmd_test

  # Mocks
  open_calls=''
  function open_cmd_test() {
    open_calls+="$* ¶ "
    %preserve open_calls
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

    open_with_editor_calls=''
    function open_with_editor() {
      open_with_editor_calls+="$* ¶ "
      %preserve open_with_editor_calls
    }

    function window_names() {
      if [[ $1 == 'Visual Studio Code.app' && $2 == 'Code' ]]; then
        if [[ ${code_is_open:-} ]]; then
          echo 'README.md — project_a (Workspace)'
        fi
      elif [[ $1 == 'Visual Studio Code - Insiders.app' && $2 == 'Code - Insiders' ]]; then
        if [[ ${code_insiders_is_open:-} ]]; then
          echo 'README.md — project_a (Workspace)'
        fi
      elif [[ $1 == 'RubyMine' ]]; then
        if [[ ${rubymine_is_open:-} ]]; then
          echo 'project_a – README.md, project_b'
        fi
      elif [[ $1 == 'MacVim' ]]; then
        if [[ ${vim_is_open:-} ]]; then
          echo "$dir/project_a // README.md"
        fi
      else
        echo >&2 "Unexpected window_names call: $*"
        exit 1
      fi
    }
    # End: Mocks

    Context 'when non-text'
      # Mocks
      function file() {
        echo 'binary'
      }
      # End: Mocks

      It "calls $OPEN_CMD"
        When call edit "$file"
        The stdout should eq ''
        The stderr should eq "-> $OPEN_CMD /project_a/a_file"
        The status should eq 0
        The variable open_calls should eq "$file ¶ "
      End
    End

    Context 'when text'
      line=21
      column=45

      # Mocks
      vim_open_calls=''
      function vim_open() {
        vim_open_calls+="$* ¶ "
        %preserve vim_open_calls
      }
      # End: Mocks

      It 'calls vim'
        When call edit "$file" "$line" "$column"
        The stdout should eq ''
        The stderr should eq ''
        The status should eq 0
        The variable vim_open_calls should eq "$file:$line:$column ¶ "
      End

      Context 'RubyMine'
        # Mocks
        mine_calls=''
        function mine() {
          mine_calls+="$* ¶ "
          %preserve mine_calls
        }
        # End: Mocks

        Context 'when open'
          rubymine_is_open=1

          Context 'without a git project'
            It 'calls vim'
              When call edit "$file" "$line" "$column"
              The stdout should eq ''
              The stderr should eq ''
              The status should eq 0
              The variable vim_open_calls should eq "$file:$line:$column ¶ "
            End

            Context 'with a Ruby file'
              file=a_file.rb

              It 'calls it'
                When call edit "$file" "$line" "$column"
                The stdout should eq ''
                The stderr should eq ''
                The status should eq 0
                The variable mine_calls should eq "--line $line --column $((column - 1)) $file ¶ "
              End
            End
          End

          Context 'with a git project'
            git_output=$dir

            It 'calls it'
              # shellcheck disable=SC2034
              When call edit "$file" "$line" "$column"
              The stdout should eq ''
              The stderr should eq ''
              The status should eq 0
              The variable mine_calls should eq "--line $line --column $((column - 1)) $file ¶ "
            End
          End
        End
      End

      Context 'with editor'
        setup_editor() {
          export EDITOR="$test_editor"
        }
        BeforeEach 'setup_editor'

        Context 'MacVim'
          test_editor=mvim
          vim_is_open=1

          It 'calls it'
            When call edit "$file" "$line" "$column"
            The stdout should eq ''
            The stderr should eq ''
            The status should eq 0
            The variable open_with_editor_calls should eq "$file:$line:$column ¶ "
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
            The variable open_with_editor_calls should eq "$file:$line:$column ¶ "
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
            The variable open_with_editor_calls should eq "$file:$line:$column ¶ "
          End
        End
      End
    End
  End
End

Describe 'open_with_editor'
  Context 'with VS Code'
    export EDITOR=code

    # Mocks
    code_calls=''
    function code() {
      code_calls+="$* ¶ "
      %preserve code_calls
    }
    # End: Mocks

    It 'opens given paths with editor'
      When call open_with_editor foo 'bar baz'
      The stdout should eq ''
      The stderr should eq '-> code -g foo bar\ baz'
      The status should eq 0
      The variable code_calls should eq '-g foo bar baz ¶ '
    End
  End

  Context 'when the editor is Vim'
    export EDITOR=/foo/bar/bin/vim
    export VIM_PATH=vim

    # Mocks
    vim_calls=''
    function vim() {
      vim_calls+="$* ¶ "
      %preserve vim_calls
    }
    # End: Mocks

    It 'opens given paths with editor'
      When call open_with_editor foo 'bar baz'
      The stdout should eq ''
      The stderr should eq '-> vim --remote-silent foo bar\ baz'
      The status should eq 0
      The variable vim_calls should eq '--remote-silent foo bar baz ¶ '
    End
  End
End
