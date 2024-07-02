function source_glob() {
  local file
  for file in "$@"; do
    # shellcheck disable=SC1090
    . "$file"
  done
}

function source_custom() {
  source_glob "$DOTFILES_CUSTOM"/includes/"$1"
}

function source_with_custom() {
  # shellcheck disable=SC1090
  . "$DOTFILES_INCLUDES"/"$1"
  source_custom "$1"
}

# shellcheck disable=SC2139
alias envsh='$EDITOR '"$0"

export EDITOR='code'
export BUNDLER_EDITOR='code'
export VISUAL='vim' # Needed for `crontab -e` (`code --wait` doesn't work)

# eza (ls alternative)
export EZA_ICONS_AUTO=true
export EZA_ICON_SPACING=2
export TIME_STYLE=long-iso

eval "$(/opt/homebrew/bin/brew shellenv)"

# Set this so that tr_TR is not sent in SSH connections
# https://bugzilla.mindrot.org/show_bug.cgi?id=1285
# https://bugs.php.net/bug.php?id=18556
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

num_procs=$(nproc) # nproc is installed via Homebrew, thus it needs to come after it
half_procs=$((num_procs / 2)) # Rounds down
export BUNDLE_JOBS=$half_procs # TODO: Why half?
# https://build.betterup.com/one-weird-trick-that-will-speed-up-your-bundle-install/
# This version breaks other builds, e.g. ruby-build
# export MAKE="make -j$num_procs"
export MAKEFLAGS="-j$num_procs"
unset num_procs half_procs

# Start: oh-my-zsh config

# Disabled:
#   * direnv: Breaks Powerlevel10k instant prompt, added to .zshrc manually
#   * fzf-tab-completion: Broken. Outputs pygmentize (pygments) help. Without pygmentize, emits 3
#     lines of "_normal:6: command not found: pygmentize"
#   * gpg-agent: GPG_TTY is set in env_interactive.sh, no need to slow down
#   * heroku: Eats lines, even with COMPLETION_WAITING_DOTS=false - there is autocomplete anyway
#   * rake: Aliases rake to `noglob rake` which doesn't take bundler into account
#   * zsh-nvm: Slow (1.5-2 s) to change folders, replaced with nodenv.
#     If re-enabled: uncomment nvm lines below

# Notes:
#   * fzf-tab: Breaks _expand_alias

# Custom: $ZSH_CUSTOM/plugins

export OMZ_PLUGINS=(
  bgnotify
  brew
  bundler
  common-aliases
  docker
  docker-compose
  fd
  git
  git-extras
  globalias
  httpie
  npm
  rails
  rake-fast
  ruby
  rust
  safe-paste
  yarn
  z
  zsh-syntax-highlighting
  zsh-vi-mode
)

if [[ $OSTYPE == darwin* ]]; then
  OMZ_PLUGINS+=(macos)
elif [[ $(uname -a) == *Ubuntu* ]]; then
  OMZ_PLUGINS+=(ubuntu)
fi

# End: oh-my-zsh config

export DOTFILES_INCLUDE_LIBS=(
  docker
  elasticsearch
  git
  node
  redis
  ruby_rails
  update_and_backup
)

# shellcheck disable=SC2016
export UPDATE_BACKUP_CMDS=(
  'brew upgrade --quiet' # Removed --greedy because apps auto-download in the background anyway
  'npm update -g --silent'
  'omz update --unattended'
  'omz_update_custom'
  update_iterm2_color_schemes
)

# Global troubleshooting reminder: Some apps treat PATH as case-insensitive, causing problems when
# a variable named lowercase `path` used in scripts or functions.
PATH="$HOME/.cargo/bin:$PATH:$HOME/bin"

# https://ruby.github.io/rdoc/RI_rdoc.html
export RI="--format ansi"

export RIPGREP_CONFIG_PATH="$DOTFILES_SHARED/.ripgreprc"

source_custom env.sh

# Put the manual/external steps at the end
UPDATE_BACKUP_CMDS+=(
  'mvim +"PlugUpgrade | PlugUpdate"'
  'open_dotfile_tabs'
  'o /Applications # Manually update the non-App Store, infrequently-opened, etc. apps'
)
