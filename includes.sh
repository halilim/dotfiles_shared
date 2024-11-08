alias includes='$EDITOR "$DOTFILES_SHARED"/includes.sh'

source_with_custom functions.sh

for lib in "${DOTFILES_INCLUDE_LIBS[@]}"; do
  source_with_custom "lib/$lib.sh"
done

if [[ $OSTYPE == darwin* ]]; then
  source_with_custom mac.sh
elif [[ $OSTYPE == linux* ]]; then
  source_with_custom linux.sh
fi
