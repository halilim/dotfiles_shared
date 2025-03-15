script='link/home/bin/open_from_iterm'

Describe "$script"
  tmp_dir=${TMPDIR%/}/shellspec/$script
  orig_home=''

  setup() {
    mkdir -p "$tmp_dir/bin"
    touch "$tmp_dir"/.dotfiles_bootstrap.sh
    touch "$tmp_dir"/bash_shared.sh
    cp 'link/home/bin/open_from_iterm_functions' "$tmp_dir/bin"
    orig_home=$HOME
    HOME=$tmp_dir
    orig_dotfiles_includes=$DOTFILES_INCLUDES
    export DOTFILES_INCLUDES=$tmp_dir
  }

  cleanup() {
    rm -rf "$tmp_dir"
    HOME=$orig_home
    DOTFILES_INCLUDES=$orig_dotfiles_includes
  }

  BeforeAll 'setup'
  AfterAll 'cleanup'

  Mock git
    echo "${git_output:-}"
  End

  Mock mine
    rubymine_column=$((column - 1))
    if [[ $1 != '--line' || $2 != "$line" || $3 != '--column' || $4 != "$rubymine_column" ||
          $5 != "${expected_rubymine_arg?}" ]]; then
      echo >&2 "Unregistered mine mock: $*"
      declare -p line rubymine_column expected_rubymine_arg 1>&2
      exit 1
    fi
  End

  Mock open
    if [[ $1 != "${expected_open_arg?}" ]]; then
      echo >&2 "Unregistered open mock: $*"
      exit 1
    fi
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
    expected_open_arg="$tmp_dir"
    %preserve expected_open_arg
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
      expected_open_arg="$file"
      %preserve expected_open_arg
      When run script "$script" "$file"
      The stdout should eq ''
      The stderr should eq ''
      The status should eq 0
    End

    Context 'text'
      line=2
      column=3

      expected_rubymine_arg=$file
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
            expected_rubymine_arg=$file
            %preserve expected_rubymine_arg
            When run script "$script" "$file" "$line" "$column"
            The stdout should eq ''
            The stderr should eq ''
            The status should eq 0
          End
        End

        Example 'with git project calls it'
          %preserve git_output \
            expected_rubymine_arg
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
