: # TODO: Remove after https://github.com/koalaman/shellcheck/issues/1877 here and everywhere else
  #       Without it, it disables for the whole file
# shellcheck disable=SC2139
alias includes="$EDITOR $0"

# !!! PUT ENVIRONMENT VARIABLES (especially $PATH) IN env.sh !!!

source_with_custom aliases.sh
source_with_custom functions.sh

for lib in "${DOTFILES_INCLUDE_LIBS[@]}"; do
  # shellcheck disable=SC1090
  . "$DOTFILES_INCLUDES/lib/$lib.sh"
done
source_glob "$DOTFILES_CUSTOM"/includes/lib/*.sh

if [[ $OSTYPE == darwin* ]]; then
  source_with_custom mac.sh
elif [[ $OSTYPE == linux* ]]; then
  source_with_custom linux.sh
fi
