script='link/home/bin/dotfiles'

Describe "$script"
  export tmp_dir dotfiles_dir shared_dir custom_dir script_dir copied_script mock_home mock_root

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

    dotfiles_dir=$tmp_dir/dotfiles
    shared_dir=$dotfiles_dir/shared
    custom_dir=$dotfiles_dir/custom

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

  Mock js_install_globals
    :
  End

  Mock omz_install_custom
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

      bootstrap_file="$mock_home"/.dotfiles_bootstrap.sh

      # It seems command -v can't be mocked, so the EDITOR values will be different locally
      The contents of file "$bootstrap_file" should include 'declare -x EDITOR="/'
      The contents of file "$bootstrap_file" should include 'declare -x BUNDLER_EDITOR="/'
      The contents of file "$bootstrap_file" should include 'declare -x VIM_PATH="/'
      The contents of file "$bootstrap_file" should include 'declare -x VISUAL="/'

      The contents of file "$bootstrap_file" should include "declare -x DOTFILES=\"$dotfiles_dir\""
      The contents of file "$bootstrap_file" should include "declare -x DOTFILES_SHARED=\"$shared_dir\""
      The contents of file "$bootstrap_file" should include "declare -x DOTFILES_INCLUDES=\"$shared_dir/includes\""
      The contents of file "$bootstrap_file" should include "declare -x DOTFILES_CUSTOM=\"$custom_dir\""

      The status should eq 0
    End
  End

  Describe 'sync'
    Example 'no args'
      git_exclude_path=$custom_dir/link/home/code1/.git.linked/info/exclude
      create_file_with_content "$git_exclude_path" 'ignored1'

      platform=''
      if [[ $OSTYPE == darwin* ]]; then
        platform='mac'
      elif [[ -v TERMUX_VERSION ]]; then
        platform='termux'
      elif [[ $OSTYPE == linux* ]]; then
        platform='linux'
      fi
      platform_file_path=$custom_dir/link/home/foo/.bar_platform_$platform.baz
      create_file_with_content "$platform_file_path" 'platform-specific content'

      When run script "$copied_script" sync
      The stdout should eq ''

      The stderr should include 'code1'
      synced_git_exclude="$mock_home"/code1/.git/info/exclude
      The file "$synced_git_exclude" should be exist
      The contents of file "$synced_git_exclude" should equal 'ignored1'
      The path "$mock_home"/code1/.git.linked should not be exist

      The stderr should include 'foo'
      synced_platform_file="$mock_home"/foo/.bar_platform.baz
      The file "$synced_platform_file" should be exist
      The contents of file "$synced_platform_file" should equal 'platform-specific content'
      The file "$mock_home"/foo/.bar_platform_$platform.baz should not be exist
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
        orig_path=$5
        imported_path=$6
        content=$7
        git_exclude_path=$dir_root/$orig_path
        create_file_with_content "$git_exclude_path" "$content"
        cd "$dir_root" || exit

        When run script "$copied_script" import "$dotfile_type" "$orig_path"
        The path "$git_exclude_path" should be symlink
        The contents of file "$git_exclude_path" should equal "$content"
        The stderr should include "$orig_path"
        The stderr should include "$imported_path"

        imported_path_full="$dotfile_dir/link/$dir_type/$imported_path"
        The file "$imported_path_full" should be file
        The contents of file "$imported_path_full" should equal "$content"
      End
    End
  End

  Describe 'revert_import'
    Parameters
      home "$mock_home" 'false'
      home "$mock_home" 'true'
      root "$mock_root" 'false'
    End

    Example "$1 link, $([[ $3 == 'true' ]] && echo "with" || echo "without") extra content: replaces with the original file, removes empty dirs"
      dir_type=$1
      orig_base=$2
      dir1_has_extra_content=$3

      dir_name=dir1/dir2
      file_name=orig_file
      content='original content'

      dotfile_path=$custom_dir/link/$dir_type/$dir_name/$file_name
      create_file_with_content "$dotfile_path" "$content"

      if [[ $dir1_has_extra_content == 'true' ]]; then
        extra_path=$custom_dir/link/$dir_type/dir1/extra
        touch "$extra_path"
      fi

      orig_dir=$orig_base/$dir_name
      mkdir -p "$orig_dir"

      orig_path=$orig_dir/$file_name
      ln -s "$dotfile_path" "$orig_path"

      When run script "$copied_script" revert_import "$orig_path"
      if [[ $dir1_has_extra_content == 'true' ]]; then
        The path "$extra_path" should be exist
      else
        The path "$custom_dir/link/$dir_type/dir1" should not be exist
      fi
      The path "$custom_dir/link/$dir_type" should be exist
      The contents of file "$orig_path" should equal "$content"
      The stdout should eq ''
      The stderr should include "$orig_path"
      The status should eq 0

      rm -f "$orig_path"
    End
  End

  Describe 'vim_setup'
    Example 'calls mkspell! and quits'
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
      The status should eq 0
    End
  End

  Example 'no args'
    When run script "$copied_script"
    The stdout should eq ''
    The stderr should include 'Usage'
    The status should eq 1
  End
End
