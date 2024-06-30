# alias zprofile="$EDITOR $0" # Doesn't work, $0=`-zsh`
alias zprofile='$EDITOR ~/.zprofile'

# shellcheck disable=SC1091
. "$HOME"/.dotfiles_paths.sh
# shellcheck disable=SC1091
. "$DOTFILES_INCLUDES"/env.sh
