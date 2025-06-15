alias libw='$EDITOR "$DOTFILES_INCLUDES"/lib/which.sh' # cSpell:ignore libw

# shellcheck disable=SC2139
alias {edit_function,ef,fe}='EDIT_FUNCTION=1 wh'

function locate_function() {
  local function_name=$1 output=${2:-} file line is_zsh

  if [ -n "${ZSH_VERSION:-}" ]; then
    is_zsh=1
  fi

  # Check out if you have (a lot of) time :) https://unix.stackexchange.com/a/85250/4678

  if [ $is_zsh ]; then
    if [[ ! $output ]]; then
      output=$(whence -v "$function_name")
    fi
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
alias wb='which_ "$BAT_CMD"'
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

  local type_output
  type_output=$(type -a "$input" 2>&1)
  local type_ret=$?

  if [[ $type_ret -ne 0 ]]; then
    color >&2 red "$type_output"
    ORIG_INPUT=$orig_input which_variable "$input"
    local which_variable_ret=$?
    if [[ $which_variable_ret -ne 0 ]]; then
      return $which_variable_ret
    fi
  fi

  local type_strs=()
  if [[ $type_output ]]; then
    if command -v mapfile > /dev/null 2>&1; then
      mapfile -t type_strs <<< "$type_output"
    elif [ -n "${ZSH_VERSION:-}" ]; then
      # shellcheck disable=SC2296,SC2116
      type_strs=("${(f)$(echo "$type_output")}")
    fi
  fi

  local i type_str_ct=${#type_strs[@]} type_str
  for ((i = 0; i < type_str_ct; i++)); do
    # shellcheck disable=SC2124
    type_str="${type_strs[@]:$i:1}"

    if [[ $type_str_ct -gt 1 ]]; then
      color green-bold "=== $((i + 1)) of $type_str_ct ==="
    fi

    if [[ ! $is_zsh && $type_str == *'function'* ]]; then
      # Bash includes the function definition in the output of `type -a`
      type_str=$(echo "$type_str" | head -n 1)
    fi

    type_str=${type_str:-'not found'}

    echo "$type_str"

    if [[ $type_str == *'function'* ]]; then
      local bat_cmd_and_args=("$BAT_CMD" --language=sh --paging=never)

      local location
      location=$(locate_function "$input" "$type_str")

      if [[ ${EDIT_FUNCTION:-} ]]; then
        if [[ $location ]]; then
          open_with_editor "$location"
        else
          echo >&2 'Source file and line not found'
          return 1
        fi
      else
        [[ $location ]] && color magenta "$location"

        if [[ $is_zsh ]]; then
          which -x 2 "$input" | "${bat_cmd_and_args[@]}"
        else
          declare -f "$input" | "${bat_cmd_and_args[@]}"
        fi

        color yellow 'Comments are not shown, and the output can differ from the source'
      fi

    elif [[ $type_str == *'alias'* ]]; then
      if [ $is_zsh ]; then
        type_str=${type_str#*for } # Zsh: "... is (an|a global) alias for ..."
      else
        type_str=${type_str#*to \`} # Bash: "... is aliased to `...'"
        type_str=${type_str%\'*}
      fi

      # Remove prepended variables
      type_str=$(echo "$type_str" | $GNU_SED -E 's/^(\w+=(["'\''][^"'\'']*["'\'']|\w+) )*//')

      # Remove arguments
      type_str=${type_str%% *}

      # Return early for global aliases, and prevent infinite loops, e.g. `alias ls=ls -etc`
      if [[ ! $type_str || $type_str == "$input" ]]; then
        return 0
      fi

      ORIG_INPUT=$orig_input which_detailed "$type_str"

    elif [[ $type_str == *'command'* || $type_str == *'file'* ]]; then
      local file_out
      file_out=$(type "$input")
      local file="${file_out#*is }"

      if [[ -L $file ]]; then
        ls -l "$file"
      else
        echo "$file"
      fi
    fi

    if [[ $type_str_ct -gt 1 ]]; then
      echo
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
