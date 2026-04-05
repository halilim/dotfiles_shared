Include includes/lib/editing.sh
Include includes/lib/colors.sh
Include includes/lib/functions.sh

Describe 'edit'
  file_name=a_file
  dir_name=project_a

  # Mocks
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

  mine_calls=''
  function mine() {
    mine_calls+="$* ¶ "
    %preserve mine_calls
  }

  open_with_editor_calls=''
  function open_with_editor() {
    open_with_editor_calls+="$* ¶ "
    %preserve open_with_editor_calls
  }

  function realpath() {
    echo "$1"
  }

  function window_names() {
    if [[ $1 == 'RubyMine' ]]; then
      if [[ ${rubymine_is_open:-} ]]; then
        echo "$dir_name – README.md, project_b"
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
    file=$dir_name/$file_name
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

    Context 'with an existing directory'
      It 'opens it with editor'
        When call edit "$sub_dir"
        The stdout should eq ''
        The stderr should eq ''
        The status should eq 0
        The variable open_with_editor_calls should eq "$sub_dir ¶ "
      End
    End

    Context 'with a non-existent path'
      file=$dir_name/non_existent

      Context 'when RubyMine is open'
        rubymine_is_open=1

        Context 'when its directory is a git repo open in RubyMine'
          dir_is_git=1

          It 'opens it in RubyMine'
            When call edit "$file"
            The stdout should eq ''
            The stderr should eq ''
            The status should eq 0
            The variable mine_calls should eq "$file ¶ "
          End
        End

        Context 'when given path is a Ruby file'
          file=$dir_name/non_existent.rb

          It 'opens it in RubyMine'
            When call edit "$file"
            The stdout should eq ''
            The stderr should eq ''
            The status should eq 0
            The variable mine_calls should eq "$file ¶ "
          End
        End
      End

      It 'opens it with editor'
        When call edit "$sub_dir"
        The stdout should eq ''
        The stderr should eq ''
        The status should eq 0
        The variable open_with_editor_calls should eq "$sub_dir ¶ "
      End
    End

    Context 'with an existing file'
      Context 'when the file is text'
        line=21
        column=45

        Context 'when RubyMine is open'
          rubymine_is_open=1

          Context 'when its directory is a git repo open in RubyMine'
            dir_is_git=1

            It 'opens it in RubyMine'
              When call edit "$file:$line:$column"
              The stdout should eq ''
              The stderr should eq ''
              The status should eq 0
              The variable mine_calls should eq "--line $line --column $((column - 1)) $file ¶ "
            End
          End

          Context 'with a Ruby file'
            file=$dir_name/a_file.rb

            It 'opens it in RubyMine'
              When call edit "$file:$line:$column"
              The stdout should eq ''
              The stderr should eq ''
              The status should eq 0
              The variable mine_calls should eq "--line $line --column $((column - 1)) $file ¶ "
            End
          End
        End

        It 'opens it with editor'
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
