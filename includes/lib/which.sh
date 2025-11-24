alias libw='$EDITOR "$DOTFILES_INCLUDES"/lib/which.sh' # cSpell:ignore libw

# shellcheck disable=SC2139
alias {edit_file,edit_function,ef,fe,edit_which,ew}='EDIT=1 wh'
alias ea='EDIT_ALIAS=1 wh'

function locate_function() {
  local function_name=$1 output file line is_zsh

  if [ -n "${ZSH_VERSION:-}" ]; then
    is_zsh=1
  fi

  # Check out if you have (a lot of) time :) https://unix.stackexchange.com/a/85250/4678

  if [ $is_zsh ]; then
    output=$(whence -v "$function_name" 2> /dev/null) || return
    file=${output#*from } # fun is a shell function from /foo/bar.sh
  else
    output=$(declare -F "$function_name" 2> /dev/null) || return # fun 123 /foo/bar.sh
    output=${output#*"$function_name "}
    file=${output#* }
  fi

  if [[ ! -e $file ]]; then
    return 1
  fi

  if [[ $is_zsh ]]; then
    line=$(grep -En "$function_name\s*\(" "$file")
    line=${line%%:*}
  else
    line=${output%% *}
  fi

  echo "$file:$line"
}

# Why not in ~/bin? Because this needs the whole environment to be able to detect all types of
# symbols. And loading all that is a slow process. This way, it's all in the current shell.
function which_detailed() {
  local input=${1?}

  local type_arg command_which_arg=''
  if [ -n "${ZSH_VERSION:-}" ]; then
    type_arg='w'
    command_which_arg='p' # Without this, Zsh includes aliases in the output of `which -a ...`
  else
    type_arg='t'
  fi

  local types
  types=$(type 2>&1 -a$type_arg "$input")

  if [ -n "${ZSH_VERSION:-}" ]; then
    # shellcheck disable=SC2001
    types=$(echo "$types" | rg -F "$input: " --replace '$1')
    # shellcheck disable=SC2001
    types=$(echo "$types" | sed "s/none//")
  fi

  local var_output
  if var_output=$(which_variable "$input"); then
    if [[ $types ]]; then
      types+=$'\n'
    fi
    types+='variable'
  fi

  if [[ $types == '' ]]; then
    return 1
  fi

  local type_count
  type_count=$(echo "$types" | wc -l | tr -d '[:space:]')

  local unique_type \
        line_no=1 \
        file_no file real_path link_path

  while IFS=$'\n' read -r unique_type; do
    if [[ $type_count -gt 1 ]]; then
      printf '%d. ' $line_no
    fi

    case "$unique_type" in
      'alias')
        color_ 'yellow' 'alias '
        _which_alias "$input"
        ;;

      'global alias')
        color_ 'yellow' 'global alias '
        _which_alias "$input" 1
        ;;

      'builtin')
        color 'yellow' 'builtin'
        ;;

      'file'|'command')
        file_no=1

        while IFS=$'\n' read -r file; do
          if [[ $file_no -gt 1 ]]; then
            printf '%d. ' $line_no
          fi

          real_path=$file
          color_ 'yellow' 'command/file '
          color_ 'magenta' "$(shorten_path "$file")"
          if [[ -L $file ]]; then
            printf ' -> '
            link_path=$(readlink -f "$file")
            real_path=$link_path
            link_path=$(shorten_path "$link_path")
            color_ 'magenta' "$link_path"
          fi
          printf '\n'

          if [[ ${EDIT:-} && $file_no == 1 ]]; then
            open_with_editor "$real_path"
          fi

          file_no=$((file_no + 1))
          line_no=$((line_no + 1))
        done < <(which -a$command_which_arg "$input")
        ;;

      'function')
        color_ 'yellow' 'function '
        which_function "$input"
        ;;

      'variable')
        echo "$var_output"
        ;;
    esac

    line_no=$((line_no + 1))
  done < <(printf '%s\n' "$types" | uniq)
}
alias wh="which_detailed"

function _which_alias() {
  local input=$1 is_global_alias=$2

  local alias_output prefix='alias'
  if [[ $is_global_alias ]]; then
    prefix+=' -g'
  fi
  alias_output=$(alias "$input")

  if [[ $alias_output != 'alias '* ]]; then
    alias_output="$prefix $alias_output"
  fi
  color 'magenta' "$alias_output"

  if [[ ${EDIT_ALIAS:-} ]]; then
    _edit_alias "$prefix $input="
    return
  fi

  local alias_value
  alias_value=$(echo "$alias_output" | rg "^alias(?: -g)? $input='?(.+?)'?$" --only-matching --replace '$1')
  # remove "| " prefix
  alias_value=${alias_value#*| }

  local alias_cmd
  # Remove prepended variables
  alias_cmd=$(echo "$alias_value" | $GNU_SED -E 's/^(\w+=(["'\''][^"'\'']*["'\'']|\w+) )*//')
  # Remove arguments
  alias_cmd=${alias_cmd%% *}

  # Prevent infinite loops, e.g. `alias ls=ls -etc`
  if [[ $alias_cmd && $alias_cmd != "$input" ]]; then
    echo '->'
    which_detailed "$alias_cmd"
  fi
}

function _edit_alias() {
  local search_prefix=$1 location

  location=$(_locate_alias "$search_prefix" "$DOTFILES")
  if [[ ! $location ]]; then
    location=$(_locate_alias "$search_prefix" "$HOME"/.oh-my-zsh)
  fi

  if [[ $location ]]; then
    location=$(echo "$location" | rg '^([^:]+(:\d+)+).*' --only-matching --replace '$1')
    open_with_editor "$location"
    return
  else
    echo >&2 "Couldn't locate the alias"
    return 1
  fi
}

function _locate_alias() {
  local prefix=${1:?prefix is required, e.g. 'alias foo='} dir=${2:?directory is required}
  rg -.Fn --column "$prefix" "$dir"
}

function which_function() {
  local input=$1 location

  location=$(locate_function "$input")

  color 'magenta' "$(shorten_path "$location")"

  if [[ ${EDIT:-} ]]; then
    if [[ $location ]]; then
      open_with_editor "$location"
    else
      echo >&2 'Source file and line not found'
      return
    fi
  else
    local bat_cmd_and_args=(bat --language=sh --paging=never)
    if [ -n "${ZSH_VERSION:-}" ]; then
      which -x 2 "$input" | "${bat_cmd_and_args[@]}"
    else
      declare -f "$input" | "${bat_cmd_and_args[@]}"
    fi

    color 'yellow' 'Comments are not shown, and the output can differ from the source'
  fi
}

function which_variable() {
  local var_name=${1?}

  if [[ $var_name == '$'* ]]; then
    var_name="${var_name#'$'}"
  fi

  local declare_output
  declare_output=$(declare -p "$var_name" 2>&1) || return

  color_ 'yellow' 'variable '

  if print_array "$var_name" "$declare_output" 2> /dev/null; then
    return
  fi

  color 'magenta' "$declare_output"
}
