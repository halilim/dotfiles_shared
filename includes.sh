alias includes='$EDITOR "$DOTFILES_SHARED"/includes.sh'

source_with_custom functions.sh

for lib in "${DOTFILES_INCLUDE_LIBS[@]}"; do
  # shellcheck disable=SC1090
  . "$DOTFILES_INCLUDES/lib/$lib.sh"
done

for custom_lib in "$DOTFILES_CUSTOM"/includes/lib/*.sh; do
  # shellcheck disable=SC1090
  . "$custom_lib"
done

if [[ $OSTYPE == darwin* ]]; then
  source_with_custom mac.sh
elif [[ $OSTYPE == linux* ]]; then
  source_with_custom linux.sh
fi
