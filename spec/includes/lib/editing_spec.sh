Include includes/lib/editing.sh
Include includes/lib/colors.sh
Include includes/lib/functions.sh

Describe 'edit'
  binary_file_name=binary_file
  text_file_name=text_file
  dir_name=project_a
  OPEN_CMD=open_cmd_test

  # Mocks
  function file() {
    if [[ $4 == */"$text_file_name" ]]; then
      echo text
    elif [[ $4 == */"$binary_file_name" ]]; then
      echo binary
    else
      echo >&2 "Unexpected file call: $*"
      return 1
    fi
  }

  function git() {
    local arg_str=$*
    if [[ $arg_str != "-C $dir_name rev-parse --show-toplevel" ]]; then
      echo >&2 "Unexpected git call: $arg_str"
      return 1
    fi

    if [[ ${dir_is_git:-} ]]; then
      echo "${dir_name:-}"
    fi
  }

  iterm_tab_calls=''
  function iterm_tab() {
    iterm_tab_calls+="$* ¶ "
    %preserve iterm_tab_calls
  }

  mine_calls=''
  function mine() {
    mine_calls+="$* ¶ "
    %preserve mine_calls
  }

  open_calls=''
  function open_cmd_test() {
    open_calls+="$* ¶ "
    %preserve open_calls
  }

  open_with_editor_calls=''
  function open_with_editor() {
    open_with_editor_calls+="$* ¶ "
    %preserve open_with_editor_calls
  }

  function realpath() {
    echo "$1"
  }

  vim_open_calls=''
  function vim_open() {
    vim_open_calls+="$* ¶ "
    %preserve vim_open_calls
  }

  function window_names() {
    if [[ $1 == 'Visual Studio Code.app' && $2 == 'Code' ]]; then
      if [[ ${code_is_open:-} ]]; then
        echo "README.md — $dir_name (Workspace)"
      fi
    elif [[ $1 == 'Visual Studio Code - Insiders.app' && $2 == 'Code - Insiders' ]]; then
      if [[ ${code_insiders_is_open:-} ]]; then
        echo "README.md — $dir_name (Workspace)"
      fi
    elif [[ $1 == 'RubyMine' ]]; then
      if [[ ${rubymine_is_open:-} ]]; then
        echo "$dir_name – README.md, project_b"
      fi
    elif [[ $1 == 'MacVim' ]]; then
      if [[ ${vim_is_open:-} ]]; then
        echo "foo/bar/$dir_name // NetrwTreeListing"
      fi
    else
      echo >&2 "Unexpected window_names call: $*"
      exit 1
    fi
  }
  # End: Mocks

  Context 'without args'
    It 'prints usage and returns 1'
      When run edit
      The stdout should eq ''
      The stderr should include 'Usage'
      The status should eq 1
    End
  End

  Context 'with args'
    tmp_dir=''
    file=$dir_name/$text_file_name
    sub_dir=$dir_name/sub_dir

    setupAll() {
      tmp_dir=$(mktemp -d)
      cd "$tmp_dir" || return
      mkdir -p $sub_dir
      touch "$file"
    }
    BeforeAll 'setupAll'

    cleanupAll() {
      if [[ $tmp_dir && -d $tmp_dir ]]; then
        rm -rf "$tmp_dir"
      fi
    }
    AfterAll 'cleanupAll'

    setupEach() {
      if [[ ${test_editor:-} ]]; then
        export EDITOR="$test_editor"
      fi
    }
    BeforeEach 'setupEach'

    Context 'with a non-existent file'
      file=$dir_name/non_existent

      It "calls $OPEN_CMD"
        When call edit "$file"
        The stdout should eq ''
        The stderr should eq "-> $OPEN_CMD $file"
        The status should eq 0
        The variable open_calls should eq "$file ¶ "
      End
    End

    Context 'with an existing directory'
      It 'calls open_with_editor'
        When call edit "$sub_dir"
        The stdout should eq ''
        The stderr should eq ''
        The status should eq 0
        The variable open_with_editor_calls should eq "$sub_dir ¶ "
      End
    End

    Context 'when the file is binary'
      file=$dir_name/$binary_file_name

      It "calls $OPEN_CMD"
        When call edit "$file"
        The stdout should eq ''
        The stderr should eq "-> $OPEN_CMD $file"
        The status should eq 0
        The variable open_calls should eq "$file ¶ "
      End

      Context "when VS Code is open, and the directory is the file's git repo"
        dir_is_git=1
        test_editor='code'
        code_is_open=1

        It 'calls it'
          When call edit "$file"
          The stdout should eq ''
          The stderr should eq ''
          The status should eq 0
          The variable open_with_editor_calls should eq "$file ¶ "
        End
      End
    End

    Context 'when the file is text'
      line=21
      column=45

      It 'calls vim'
        When call edit "$file:$line:$column"
        The stdout should eq ''
        The stderr should eq ''
        The status should eq 0
        The variable vim_open_calls should eq "$file:$line:$column ¶ "
      End

      Context 'when RubyMine is open'
        rubymine_is_open=1

        It 'calls vim'
          When call edit "$file:$line:$column"
          The stdout should eq ''
          The stderr should eq ''
          The status should eq 0
          The variable vim_open_calls should eq "$file:$line:$column ¶ "
        End

        Context 'with a Ruby file'
          file=$dir_name/a_file.rb

          It 'calls it'
            When call edit "$file:$line:$column"
            The stdout should eq ''
            The stderr should eq ''
            The status should eq 0
            The variable mine_calls should eq "--line $line --column $((column - 1)) $file ¶ "
          End
        End

        Context "when the directory is the file's git repo"
          dir_is_git=1

          It 'calls it'
            # shellcheck disable=SC2034
            When call edit "$file:$line:$column"
            The stdout should eq ''
            The stderr should eq ''
            The status should eq 0
            The variable mine_calls should eq "--line $line --column $((column - 1)) $file ¶ "
          End
        End
      End

      Context 'with editor'
        Context 'MacVim'
          test_editor=mvim
          vim_is_open=1

          It 'calls it'
            When call edit "$file:$line:$column"
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
            When call edit "$file:$line:$column"
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
            When call edit "$file:$line:$column"
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
