script='link/home/bin/dotfiles'

Describe "$script"
  tmp_dir=${TMPDIR%/}/shellspec/$script
  shared_dir=$tmp_dir/dotfiles/shared
  custom_dir=$tmp_dir/dotfiles/custom
  base_dir=$(dirname "$script")
  name=$(basename "$script")
  script_dir=$shared_dir/$base_dir
  copied_script=$script_dir/$name

  orig_home=''
  mock_home=$tmp_dir/home

  create_file_with_content() {
    local file=$1 content=$2
    mkdir -p "$(dirname "$file")"
    echo "$content" > "$file"
  }

  setup() {
    mkdir -p "$script_dir"
    cp "$script" "$script_dir"
    mkdir -p "$custom_dir"

    # Dependencies
    mkdir -p "$shared_dir"/includes/lib
    local dep
    for dep in env.sh linux_env.sh mac_env.sh lib/functions.sh; do
      ln -s "$(realpath includes/$dep)" "$shared_dir"/includes/$dep
    done

    orig_home=$HOME
    mkdir -p "$mock_home"
    HOME=$mock_home
  }

  cleanup() {
    rm -rf "$tmp_dir"
    HOME=$orig_home
  }

  BeforeAll 'setup'
  AfterAll 'cleanup'

  Mock curl
    :
  End

  Mock iterm_tab
    :
  End

  Mock vim
    if [[ $1 != +"$expected_vim_arg" ]]; then
      echo >&2 "Unregistered docker mock: $*"
      exit 1
    fi
  End

  Describe 'setup'
    Example 'no args'
      When run script "$copied_script" setup
      The stdout should eq ''
      The stderr should not include 'No such'
      The path "$mock_home"/.dotfiles_bootstrap.sh should be exist
    End
  End

  Describe 'sync'
    Example 'no args'
      local_exclude_to_sync=$custom_dir/link/home/code/repo_one/.git.linked/info/exclude
      create_file_with_content "$local_exclude_to_sync" 'synced_local_ignore'

      When run script "$copied_script" sync
      The stdout should eq ''
      The stderr should include 'repo_one'
      The contents of file "$mock_home"/code/repo_one/.git/info/exclude should equal \
        'synced_local_ignore'
      The path "$mock_home"/code/repo_one/.git.linked should not be exist
    End
  End

  Describe 'import'
    Example 'no args'
      When run script "$copied_script" import
      The stderr should include 'Usage'
      The status should eq 1
    End

    Example 'with args'
      local_exclude_to_import=$mock_home/code/repo_two/.git/info/exclude
      create_file_with_content "$local_exclude_to_import" 'imported_local_ignore'

      When run script "$copied_script" import custom "$local_exclude_to_import"
      The stdout should include 'Importing'
      The stdout should include 'custom'
      The stderr should include '.git.linked'
      The contents of file "$custom_dir/link/home/code/repo_two/.git.linked/info/exclude" should equal \
        'imported_local_ignore'
    End
  End

  Example 'vim_mk_spell'
    vim_spell_dir=$mock_home/.vim/spell
    vim_spell_file_1=$vim_spell_dir/test1.en.utf-8.add
    vim_spell_file_2=$vim_spell_dir/test2.en.utf-8.add
    expected_vim_arg="mkspell! $vim_spell_file_1 | mkspell! $vim_spell_file_2 | q"

    mkdir -p "$vim_spell_dir"
    touch "$vim_spell_file_1"
    touch "$vim_spell_file_2"
    %preserve expected_vim_arg

    When run script "$copied_script" vim_mk_spell
    The stdout should not include "error" # To satisfy shellspec expectation requirement
    The stderr should include "vim +'$expected_vim_arg'"
  End

  Example 'no args'
    When run script "$copied_script"
    The stdout should eq ''
    The stderr should include 'Usage'
    The status should eq 1
  End
End
