function _s3_explore() {
  # shellcheck disable=SC2034
  local context state state_descr line
  # shellcheck disable=SC2034
  typeset -A opt_args

  _arguments '1: :->profile' '2: :->bucket'

  # shellcheck disable=2046
  case $state in
    profile)
      compadd $(aws configure list-profiles 2>/dev/null)
      ;;

    bucket)
      local profile=${words[2]:?}
      compadd $(echo_eval aws s3 ls --profile "$profile" 2>/dev/null | awk '{print $3}' | sort -u)
      ;;
  esac
}

compdef _s3_explore s3_explore
