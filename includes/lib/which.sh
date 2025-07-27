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
  local input=${1?} is_zsh orig_input
  orig_input=${ORIG_INPUT:-$input}

  if [ -n "${ZSH_VERSION:-}" ]; then
    is_zsh=1
  fi

  # When it's a variable name in 2nd round
  if [[ $input == '$'* ]]; then
    local bare_name
    bare_name="${input#'$'}"
    ORIG_INPUT=$orig_input which_variable "$bare_name"
    return $?
  fi

  # Starting with a non-word char, probably a global alias
  if [[ $input =~ ^[^[:alnum:]_] ]]; then
    return
  fi

  local types=() output
  # shellcheck disable=SC2207
  if [ -n "${ZSH_VERSION:-}" ]; then
    output=$(whence -aw "$input" | rg "^$input: (.+)$" --only-matching --replace '$1')
    # shellcheck disable=SC2296,SC2116
    types=("${(f)$(echo "$output")}")
  else
    output=$(type -at "$input" || echo 'none')
    mapfile -t types < <( echo "$output" )
  fi

  local bat_cmd_and_args=(bat --language=sh --paging=never)
  local i type_ct=${#types[@]} type location file
  for ((i = 0; i < type_ct; i++)); do
    # shellcheck disable=SC2124
    type="${types[@]:$i:1}"

    if [[ $type_ct -gt 1 ]]; then
      color green-bold "=== $((i + 1)) of $type_ct ==="
    fi

    color_ yellow "$type "

    case "$type" in
      *'alias')
        local alias_output alias_value alias_cmd
        alias_output=$(alias "$input")
        if [[ $alias_output != 'alias '* ]]; then
          local prefix='alias'
          if [[ $type == 'global alias' ]]; then
            prefix+=' -g'
          fi
          alias_output="$prefix $alias_output"
        fi
        color magenta "$alias_output"
        alias_value=$(echo "$alias_output" | rg "^alias $input='?(.+?)'?$" --only-matching --replace '$1')

        # Remove prepended variables
        alias_cmd=$(echo "$alias_value" | $GNU_SED -E 's/^(\w+=(["'\''][^"'\'']*["'\'']|\w+) )*//')

        # Remove arguments
        alias_cmd=${alias_cmd%% *}

        # Prevent infinite loops, e.g. `alias ls=ls -etc`
        if [[ $alias_cmd && $alias_cmd != "$input" ]]; then
          ORIG_INPUT=$orig_input which_detailed "$alias_cmd"
        fi

        ;;

      'builtin') ;;

      'command'|'file')
        file=$(command -vp "$input")
        if [[ ! $file || $file == "$input" ]]; then
          if [ -n "${ZSH_VERSION:-}" ]; then
            file=$(which -p "$input")
          else
            file=$(which "$input")
          fi

          if [[ -L $file ]]; then
            file+=" -> $(readlink -f "$file")"
          fi
        fi
        color magenta "$file"

        if [[ ${EDIT:-} ]]; then
          open_with_editor "$file"
        fi
        ;;

      'function')
        location=$(locate_function "$input")
        if [[ $location ]]; then
          color magenta "$location"
        fi

        if [[ ${EDIT:-} ]]; then
          if [[ $location ]]; then
            open_with_editor "$location"
          else
            echo >&2 'Source file and line not found'
            continue
          fi
        else
          if [[ $is_zsh ]]; then
            which -x 2 "$input" | "${bat_cmd_and_args[@]}"
          else
            declare -f "$input" | "${bat_cmd_and_args[@]}"
          fi

          color yellow 'Comments are not shown, and the output can differ from the source'
        fi
        ;;

      *)
        color >&2 red "$type"
        ORIG_INPUT=$orig_input which_variable "$input"
        local which_variable_ret=$?
        if [[ $which_variable_ret -ne 0 && $type_ct -eq 1 ]]; then
          return $which_variable_ret
        fi
        ;;
    esac

    if [[ $type_ct -gt 1 ]]; then
      printf '\n'
    fi
  done
}
alias wh="which_detailed"

function which_variable() {
  local var_name=${1?}

  local declare_output declare_ret
  declare_output=$(declare -p "$var_name" 2>&1)
  declare_ret=$?
  if [[ $declare_ret -eq 0 ]]; then
    echo "$declare_output"
  else
    color >&2 red "$declare_output"
    return $declare_ret
  fi

  if [[ $declare_output == 'typeset -g'* ]]; then
    color cyan "-g (global) flag is probably due to the local scope of ${funcstack[1]:-${FUNCNAME[0]}}"
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
      color >&2 red 'Circular reference detected (variable value = original input)'
      return 1
    else
      ORIG_INPUT=${ORIG_INPUT:-} which_detailed "$value"
    fi
  else
    return 1
  fi
}
