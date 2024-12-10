for hook in "${POST_INIT_HOOKS[@]}"; do
  eval "$hook"
done
unset POST_INIT_HOOKS
