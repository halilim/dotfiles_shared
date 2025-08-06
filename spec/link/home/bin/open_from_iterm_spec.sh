script='link/home/bin/open_from_iterm'

Describe "$script"
  tmp_dir=${TMPDIR%/}/shellspec/$script
  orig_home=''

  before_all() {
    mkdir -p "$tmp_dir/bin"
    touch "$tmp_dir"/.dotfiles_bootstrap.sh
    touch "$tmp_dir"/bash_shared.sh
    cp 'link/home/bin/open_from_iterm_functions' 'link/home/bin/mine' "$tmp_dir/bin"
    orig_home=$HOME
    HOME=$tmp_dir
    orig_dotfiles_includes=$DOTFILES_INCLUDES
    export DOTFILES_INCLUDES=$tmp_dir
  }
  BeforeAll 'before_all'

  after_all() {
    rm -rf "$tmp_dir"
    HOME=$orig_home
    DOTFILES_INCLUDES=$orig_dotfiles_includes
  }
  AfterAll 'after_all'

  Mock git
    echo "${git_output:-}"
  End

  Mock open
    arg_ct=$#
    expected_arg_ct=${#expected_open_args[@]}
    if [[ $arg_ct != "$expected_arg_ct" ]]; then
      echo >&2 "Unregistered open mock: $*"
      exit 1
    fi

    # shellcheck disable=SC2124,SC2154
    for ((i = 1; i <= arg_ct; i++)); do
      actual_arg=${@:$i:1}
      expected_arg=${expected_open_args[@]:$((i-1)):1}
      if [[ $actual_arg != "$expected_arg" ]]; then
        echo >&2 "Expected open arg #$i to be $expected_arg, but got $actual_arg"
        exit 1
      fi
    done
  End

  Mock open_with_editor
    if [[ $1 != "${expected_open_with_editor_arg?}" ]]; then
      echo >&2 "Unregistered open_with_editor mock: $*"
      exit 1
    fi
  End

  Mock osascript
    if [[ ${expected_osascript_app:-} &&
          $2 == "tell application \"System Events\" to get name of every window of \
(process \"$expected_osascript_app\")" ]]; then
      echo "${osascript_output?}"
    fi
  End

  Mock pgrep
    if [[ ! ${expected_pgrep_process:-} || $2 != "$expected_pgrep_process" ]]; then
      exit 1
    fi
  End

  Mock vim_open
    if [[ $1 != "${expected_vim_arg?}" ]]; then
      echo >&2 "Unregistered vim_open mock: $*"
      exit 1
    fi
  End

  Example 'without args does nothing'
    When run script "$script"
    The stdout should eq ''
    The stderr should eq ''
    The status should eq 0
  End

  Example 'with a directory calls open'
    expected_open_args=("$tmp_dir")
    %preserve expected_open_args
    When run script "$script" "$tmp_dir"
    The stdout should eq ''
    The stderr should eq ''
    The status should eq 0
  End

  Context 'file'
    file_name=a_file
    dir=$tmp_dir/project_a
    file=$dir/$file_name
    git_output=$dir

    setup_file() {
      mkdir -p "$(dirname "$file")"
      touch "$file"
    }
    BeforeEach 'setup_file'

    Example 'calls open'
      expected_open_args=("$file")
      %preserve expected_open_args
      When run script "$script" "$file"
      The stdout should eq ''
      The stderr should eq ''
      The status should eq 0
    End

    Context 'text'
      line=2
      column=3

      expected_vim_arg="$file:$line:$column"

      setup_text() {
        %preserve line \
          column
      }
      BeforeEach 'setup_text'

      Example 'calls vim'
        %preserve expected_vim_arg
        When run script "$script" "$file" "$line" "$column"
        The stdout should eq ''
        The stderr should eq ''
        The status should eq 0
      End

      Context 'RubyMine'
        expected_pgrep_process='RubyMine'
        expected_osascript_app='RubyMine'
        osascript_output='project_a – README.md, project_b'

        setup_rubymine() {
          %preserve expected_osascript_app \
            expected_pgrep_process \
            osascript_output
        }
        BeforeEach 'setup_rubymine'

        Context 'without git project'
          Example 'calls vim'
            %preserve expected_vim_arg
            When run script "$script" "$file" "$line" "$column"
            The stdout should eq ''
            The stderr should eq ''
            The status should eq 0
          End

          Example 'Ruby file calls it'
            file=$tmp_dir/a_file.rb
            expected_open_args=(-na 'RubyMine.app' --args --line "$line" --column "$((column - 1))" "$file")
            %preserve expected_open_args
            When run script "$script" "$file" "$line" "$column"
            The stdout should eq ''
            The stderr should eq ''
            The status should eq 0
          End
        End

        Example 'with git project calls it'
          expected_open_args=(-na 'RubyMine.app' --args --line "$line" --column "$((column - 1))" "$file")
          %preserve git_output \
            expected_open_args
          When run script "$script" "$file" "$line" "$column"
          The stdout should eq ''
          The stderr should eq ''
          The status should eq 0
        End
      End

      Context 'editor'
        setup_editor() {
          export EDITOR="$test_editor"
          expected_open_with_editor_arg="$file:$line:$column"
          %preserve expected_pgrep_process \
            expected_osascript_app \
            osascript_output \
            expected_open_with_editor_arg
        }
        BeforeEach 'setup_editor'

        Context 'MacVim'
          test_editor=mvim
          expected_pgrep_process='MacVim'
          expected_osascript_app='MacVim'
          osascript_output="$tmp_dir/project_a // README.md"

          Example 'calls it'
            When run script "$script" "$file" "$line" "$column"
            The stdout should eq ''
            The stderr should eq ''
            The status should eq 0
          End
        End

        Context 'VS Code'
          test_editor='code'
          expected_pgrep_process='Visual Studio Code.app'
          expected_osascript_app='Code'
          osascript_output='README.md — project_a (Workspace)'

          Example 'calls it'
            When run script "$script" "$file" "$line" "$column"
            The stdout should eq ''
            The stderr should eq ''
            The status should eq 0
          End
        End

        Context 'VS Code Insiders'
          test_editor='code-insiders'
          expected_pgrep_process='Visual Studio Code - Insiders.app'
          expected_osascript_app='Code - Insiders'
          osascript_output='README.md — project_a (Workspace)'

          Example 'calls it'
            When run script "$script" "$file" "$line" "$column"
            The stdout should eq ''
            The stderr should eq ''
            The status should eq 0
          End
        End
      End
    End
  End
End
