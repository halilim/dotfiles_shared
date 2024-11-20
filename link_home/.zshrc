# shellcheck disable=SC2296,SC1090
# Auto-generated by powerlevel10k
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export BUILTIN_URL='https://zsh.sourceforge.io/Doc/Release/Shell-Builtin-Commands.html'
export ARRAY_START=1
export READ_ARRAY=(read -rA)

alias zshrc='$EDITOR ~/.zshrc'

# Enable aliases to be sudo'ed
alias sudo='nocorrect sudo '

# Global aliases
alias -g 21='2>&1'
alias -g 21n='>/dev/null 2>&1'
alias -g 2D='2>/dev/null'
alias -g DR='DRY_RUN=1'
alias -g F='| fzf'
alias -g G='| rg -n' # Case insensitive by default due to ~/.ripgreprc
alias -g G3='| rg -n -A 1 -B 1'
alias -g HL='| grep_hl'
alias -g RGG="-g '!'"
alias -g V='VERBOSE=1'
alias -g WCL='| wc -l'

setopt NULL_GLOB

# shellcheck disable=SC1091
. "$DOTFILES_INCLUDES"/env_interactive.sh

# shellcheck disable=SC1091
. "$DOTFILES_INCLUDES"/omz.zsh

# Must be after OMZ to be able to override its aliases
# shellcheck disable=SC1091
. "$DOTFILES_INCLUDES"/aliases.sh

# Completions depend on compinit etc. via OMZ
for lib in "${DOTFILES_INCLUDE_LIBS[@]}"; do
  source_with_custom "lib/$lib/${lib}_completions.zsh"
done

# Ctrl+Backspace/Delete to delete whole words
bindkey '\e[3;5~' kill-word
# bindkey "\C-_" backward-kill-word

# Ctrl+Shift+Backspace/Delete to delete to start/end of the line
bindkey '\e[3;6~' kill-line
# bindkey "\xC2\x9F" backward-kill-line  # for UTF-8
# bindkey #"\x9F" backward-kill-line     # for ISO-8859-x
# bindkey "\e\C-_" backward-kill-line   # for any other charset

bindkey "^[a" beginning-of-line
bindkey "^[e" end-of-line

source_custom .zshrc
