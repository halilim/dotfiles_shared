script='link/home/bin/dotfiles'

Describe "$script"
  export tmp_dir shared_dir custom_dir script_dir copied_script mock_home mock_root

  orig_home_dir=''

  create_file_with_content() {
    local file=$1 dir content=$2
    dir=$(dirname "$file")
    mkdir -p "$dir"
    echo "$content" > "$file"
  }

  setup() {
    tmp_dir=$(mktemp -d)
    if [[ ! -d $tmp_dir ]]; then
      %logger 'Failed to create temp dir'
      return 1
    fi
    tmp_dir=$(readlink -f "$tmp_dir")

    shared_dir=$tmp_dir/dotfiles/shared
    custom_dir=$tmp_dir/dotfiles/custom

    local base_dir name
    base_dir=$(dirname "$script")
    name=$(basename "$script")
    script_dir=$shared_dir/$base_dir
    copied_script=$script_dir/$name

    mock_home=$tmp_dir/home
    mock_root=$tmp_dir

    mkdir -p "$script_dir"
    cp "$script" "$script_dir"
    mkdir -p "$custom_dir"

    # Dependencies
    mkdir -p "$shared_dir"/includes/lib
    local dep
    for dep in env.sh linux_env.sh mac_env.sh lib/functions.sh; do
      ln -s "$(realpath includes/$dep)" "$shared_dir"/includes/$dep
    done

    orig_home_dir=${HOME_DIR:-}
    orig_root=${ROOT_DIR:-}
    mkdir -p "$mock_home"
    export HOME_DIR=$mock_home
    export ROOT_DIR=$mock_root
  }

  cleanup() {
    rm -rf "$tmp_dir"

    if [[ $orig_home_dir ]]; then
      HOME_DIR=$orig_home_dir
    fi

    if [[ $orig_root ]]; then
      ROOT_DIR=$orig_root
    fi
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
      echo >&2 "Unregistered vim mock: $*"
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
      source_file=$custom_dir/link/home/code1/.git.linked/info/exclude
      create_file_with_content "$source_file" 'ignored1'

      When run script "$copied_script" sync
      The stdout should eq ''
      The stderr should include 'code1'
      synced_file="$mock_home"/code1/.git/info/exclude
      The file "$synced_file" should be exist
      The contents of file "$synced_file" should equal 'ignored1'
      The path "$mock_home"/code1/.git.linked should not be exist
    End
  End

  Describe 'import'
    Example 'no args'
      When run script "$copied_script" import
      The stderr should include 'Usage'
      The status should eq 1
    End

    Describe 'with args'
      Parameters
        custom "$custom_dir" home "$mock_home" code2/.git/info/exclude code2/.git.linked/info/exclude 'ignored2'
        shared "$shared_dir" root "$mock_root" etc/foo etc/foo 'bar=baz'
      End

      Example "with a $3 file to $1"
        dotfile_type=$1
        dotfile_dir=$2
        dir_type=$3
        dir_root=$4
        file_path=$5
        imported_path=$6
        content=$7
        source_file=$dir_root/$file_path
        create_file_with_content "$source_file" "$content"
        cd "$dir_root" || exit

        When run script "$copied_script" import "$dotfile_type" "$file_path"
        The file "$source_file" should be exist
        The contents of file "$source_file" should equal "$content"
        The stderr should include "$file_path"
        The stderr should include "$imported_path"

        imported_file="$dotfile_dir/link/$dir_type/$imported_path"
        The file "$imported_file" should be exist
        The contents of file "$imported_file" should equal "$content"
      End
    End
  End

  Example 'vim_setup'
    vim_spell_dir=$mock_home/.vim/spell
    vim_spell_file_1=$vim_spell_dir/test1.en.utf-8.add
    vim_spell_file_2=$vim_spell_dir/test2.en.utf-8.add
    expected_vim_arg="mkspell! $vim_spell_file_1 | mkspell! $vim_spell_file_2 | q"

    mkdir -p "$vim_spell_dir"
    touch "$vim_spell_file_1"
    touch "$vim_spell_file_2"
    %preserve expected_vim_arg

    When run script "$copied_script" vim_setup
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
