if [[ ${POST_INIT_HOOKS_DEBUG:-} ]]; then
  # shellcheck disable=SC2016
  echo >&2 '$POST_INIT_HOOKS:'
  print_array POST_INIT_HOOKS
fi

for hook in "${POST_INIT_HOOKS[@]}"; do
  eval "$hook"
done
unset POST_INIT_HOOKS
