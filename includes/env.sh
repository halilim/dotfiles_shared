alias envsh='$EDITOR "$DOTFILES_INCLUDES"/env.sh'

# Shared: required, Custom: optional
function source_with_custom() {
  local file="$DOTFILES_INCLUDES"/"$1"
  # shellcheck disable=SC1090
  . "$file"
  source_custom "$1"
}

# Shared: optional, Custom: optional
function source_with_custom_if_exists() {
  local file="$DOTFILES_INCLUDES"/"$1"
  # shellcheck disable=SC1090
  source_if_exists "$file"
  source_custom "$1"
}

function source_custom() {
  source_if_exists "$DOTFILES_CUSTOM"/includes/"$1"
}

function source_if_exists() {
  if [[ -e "$1" ]]; then
    # shellcheck disable=SC1090
    . "$1"
  fi
}

# eza (ls alternative)
export EZA_ICONS_AUTO=true
export EZA_ICON_SPACING=2
export TIME_STYLE=relative

# Allow overriding stuff defined later anywhere
export POST_INIT_HOOKS=()

export DOTFILES_INCLUDE_LIBS=(
  databases
  docker
  editing
  functions
  git
  js
  net
  ruby_rails
  update_and_backup
  which
)

export FORGIT_NO_ALIASES=1

# Disabled:
#   * direnv: Breaks Powerlevel10k instant prompt, added to .zshrc manually
#   * docker & docker-compose: Has legacy completion logic, not needed (docker itself has completions)
#   * fzf-tab-completion: Broken. Outputs pygmentize (pygments) help. Without pygmentize, emits 3
#     lines of "_normal:6: command not found: pygmentize"
#   * gpg-agent: GPG_TTY is set in env_interactive.sh, no need to slow down
#   * heroku: Eats lines, even with COMPLETION_WAITING_DOTS=false - there is autocomplete anyway
#   * rake: Aliases rake to `noglob rake` which doesn't take bundler into account
#   * zsh-nvm: Slow (1.5-2 s) to change folders, replaced with nodenv.
#     If re-enabled: uncomment nvm lines below
# Notes:
#   * fzf-tab: Breaks _expand_alias
export OMZ_PLUGINS=(
  aliases
  bgnotify
  bundler
  common-aliases
  forgit
  git
  git-extras
  globalias
  httpie
  mise
  rails
  rake-fast
  ruby
  rust
  safe-paste
  yarn
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-vi-mode
)

# shellcheck disable=SC2016
export UPDATE_BACKUP_CMDS=(
  '$ZSH/tools/upgrade.sh -v silent' # https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#how-do-i-update-oh-my-zsh
  omz_update_custom
  update_bat_syntaxes
  update_completions
  update_mise
)

if [[ $OSTYPE == darwin* ]]; then
  source_with_custom mac_env.sh
elif [[ $OSTYPE == linux* ]]; then
  source_with_custom linux_env.sh
fi

num_procs=$(getconf _NPROCESSORS_ONLN) # cSpell:ignore NPROCESSORS ONLN
export BUNDLE_JOBS=$num_procs
# https://build.betterup.com/one-weird-trick-that-will-speed-up-your-bundle-install/
# This version breaks other builds, e.g. ruby-build
# export MAKE="make -j$num_procs"
export MAKEFLAGS="-j$num_procs"
unset num_procs

# Prevent re-sourcing dot files from duplicating paths
if [[ ! ${PATH_MODIFIED:-} ]]; then
  # Global troubleshooting reminder: Some apps treat PATH as case-insensitive, causing problems when
  # a variable named lowercase `path` used in scripts or functions.
  PATH="$HOME/.bun/bin:$PATH:$HOME/bin"
  export PATH_MODIFIED=1
fi

# https://ruby.github.io/rdoc/RI_rdoc.html
export RI="--format ansi"

export RIPGREP_CONFIG_PATH="$DOTFILES_SHARED/.ripgreprc"

source_custom env.sh

# Put the manual/external steps at the end
UPDATE_BACKUP_CMDS+=(
  js_update_globals
  git_maintain_large_repos
  update_vim
)
