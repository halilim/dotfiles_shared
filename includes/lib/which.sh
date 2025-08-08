alias libw='$EDITOR "$DOTFILES_INCLUDES"/lib/which.sh' # cSpell:ignore libw

# shellcheck disable=SC2139
alias {edit_function,ef,fe,edit_which,ew}='EDIT=1 wh'

function locate_function() {
  local function_name=$1 output file line is_zsh

  if [ -n "${ZSH_VERSION:-}" ]; then
    is_zsh=1
  fi

  # Check out if you have (a lot of) time :) https://unix.stackexchange.com/a/85250/4678

  if [ $is_zsh ]; then
    output=$(whence -v "$function_name")
    file=${output#*from } # fun is a shell function from /foo/bar.sh
  else
    output=$(declare -F "$function_name") # fun 123 /foo/bar.sh
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

function which_() {
  local cmd=$1 name=$2 file_path
  file_path=$(which "$name")
  if [[ -f $file_path ]]; then
    "$cmd" "$file_path"
  else
    echo "$file_path"
  fi
}
alias wb='which_ bat'
alias wl='which_ less'

# Why not in ~/bin? Because this needs the whole environment to be able to detect all types of
# symbols. And loading all that is a slow process. This way, it's all in the current shell.
function which_detailed() {
  local input=${1?} is_zsh

  if [ -n "${ZSH_VERSION:-}" ]; then
    is_zsh=1
  fi

  # When it's a variable name in 2nd round
  if [[ $input == '$'* ]]; then
    local bare_name
    bare_name="${input#'$'}"
    which_variable "$bare_name"
    return $?
  fi

  # Starting with a non-word char, probably a global alias
  if [[ $input =~ ^[^[:alnum:]_] ]]; then
    return
  fi

  local type_lines=()
  if [ $is_zsh ]; then
    # shellcheck disable=SC2296,SC2116
    type_lines=("${(f)$(type 2>&1 -a "$input")}")
  else
    mapfile -t type_lines < <( type 2>&1 -af "$input" )
  fi

  local i line_count=${#type_lines[@]} type_line padding \
        file \
        type \
        which_variable_ret

  padding=$(printf "%${#input}s " ' ')

  for ((i = 0; i < line_count; i++)); do
    # shellcheck disable=SC2124
    type_line="${type_lines[@]:$i:1}"

    if [[ $i == 0 ]]; then
      color_ 'green' "$input "
    else
      printf '%s' "$padding"
    fi

    if [[ $line_count -gt 1 ]]; then
      printf '%d. ' $((i + 1))
    fi

    case "$type_line" in
      *'is an alias'*|*'is aliased'*)
        color_ 'yellow' 'alias '
        which_print_alias "$input"
        ;;

      *'is a global alias'*)
        color_ 'yellow' 'global alias '
        which_print_alias "$input" 1
        ;;

      *'is a shell builtin')
        color 'yellow' 'builtin'
        ;;

      *'is /'*)
        color_ 'yellow' 'command/file '
        file=$(echo "$type_line" | rg "^$input is (.+)$" --only-matching --replace '$1')

        color_ 'magenta' "$file"
        if [[ -L $file ]]; then
          printf ' -> '
          color_ 'magenta' "$(readlink -f "$file")"
        fi
        printf '\n'

        if [[ ${EDIT:-} ]]; then
          open_with_editor "$file"
        fi
        ;;

      *)
        if [ $is_zsh ]; then
          type=$(whence -aw "$input" | rg "^$input: (.+)$" --only-matching --replace '$1')
        else
          type=$(type -at "$input")
        fi

        if [[ $type == 'function' ]]; then
          color_ 'yellow' 'function '
          which_print_function "$input"

        else
          color >&2 'red' "$type_line"
          which_variable "$input"
          which_variable_ret=$?
          if [[ $which_variable_ret -ne 0 && $line_count -eq 1 ]]; then
            return $which_variable_ret
          fi
        fi

        ;;
    esac
  done
}
alias wh="which_detailed"

function which_print_alias() {
  local input=$1 is_global_alias=$2

  local alias_output
  alias_output=$(alias "$input")
  if [[ $alias_output != 'alias '* ]]; then
    local prefix='alias'
    if [[ $is_global_alias ]]; then
      prefix+=' -g'
    fi
    alias_output="$prefix $alias_output"
  fi
  color 'magenta' "$alias_output"

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
    printf '---\n'
    which_detailed "$alias_cmd"
  fi
}

function which_print_function() {
  local input=$1 location

  location=$(locate_function "$input")
  if [[ $location ]]; then
    color 'magenta' "$location"
  fi

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

  local declare_output declare_ret
  declare_output=$(declare -p "$var_name" 2>&1)
  declare_ret=$?
  if [[ $declare_ret -eq 0 ]]; then
    echo "$declare_output"
  else
    color >&2 'red' "$declare_output"
    return $declare_ret
  fi

  if [[ $declare_output == 'typeset -g'* ]]; then
    color 'cyan' "-g (global) flag is probably due to the local scope of ${funcstack[1]:-${FUNCNAME[0]}}"
  fi

  local value
  if [ -n "${ZSH_VERSION:-}" ]; then
    # shellcheck disable=SC2296
    value=${(P)var_name:-}
  else
    value=${!var_name:-}
  fi

  if [[ $value ]]; then
    if [[ $value == "${ORIG_INPUT:-}" ]]; then
      color >&2 'red' 'Circular reference detected (variable value = original input)'
      return 1
    else
      which_detailed "$value"
    fi
  else
    return 1
  fi
}
