alias envsh='$EDITOR "$DOTFILES_INCLUDES"/env.sh'

function source_with_custom() {
  local file="$DOTFILES_INCLUDES"/"$1"
  source_if_exists "$file"
  source_custom "$1"
}

function source_if_exists() {
  if [[ -e "$1" ]]; then
    # shellcheck disable=SC1090
    . "$1"
  fi
}

function source_custom() {
  source_if_exists "$DOTFILES_CUSTOM"/includes/"$1"
}

# eza (ls alternative)
export EZA_ICONS_AUTO=true
export EZA_ICON_SPACING=2
export TIME_STYLE=long-iso

# Ports in use: 80: Docker, 8080: nginx.conf, 8081-8084: reserve for apps
# Run install_nginx_config after changing
export HOST_NGINX_PORT=8085

# https://github.com/npm/cli/issues/7857
export NODE_OPTIONS='--disable-warning=ExperimentalWarning'

# Allow overriding stuff defined later anywhere
export POST_INIT_HOOKS=()

if [[ $OSTYPE == darwin* ]]; then
  source_with_custom mac_env.sh
elif [[ $OSTYPE == linux* ]]; then
  source_with_custom linux_env.sh
fi

num_procs=$(nproc) # On Mac, nproc is installed via Homebrew, thus it needs to come after mac_env
export BUNDLE_JOBS=$num_procs
# https://build.betterup.com/one-weird-trick-that-will-speed-up-your-bundle-install/
# This version breaks other builds, e.g. ruby-build
# export MAKE="make -j$num_procs"
export MAKEFLAGS="-j$num_procs"
unset num_procs

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
  aliases
  bgnotify
  brew
  bundler
  common-aliases
  docker
  docker-compose
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
  zsh-autosuggestions
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
  adminer
  nginx_php
  brew
  databases
  docker
  elasticsearch
  functions
  git
  node
  redis
  ruby_rails
  update_and_backup
)

# shellcheck disable=SC2016
export UPDATE_BACKUP_CMDS=(
  'brew update --quiet'
  'brew upgrade --quiet' # Removed --greedy because apps auto-download in the background anyway
  'npm_update_globals'
  'omz update --unattended'
  'omz_update_custom'
  update_bat_syntaxes
)

# Global troubleshooting reminder: Some apps treat PATH as case-insensitive, causing problems when
# a variable named lowercase `path` used in scripts or functions.
PATH="$PATH:$HOME/bin"

# https://ruby.github.io/rdoc/RI_rdoc.html
export RI="--format ansi"

export RIPGREP_CONFIG_PATH="$DOTFILES_SHARED/.ripgreprc"

source_custom env.sh

# Put the manual/external steps at the end
UPDATE_BACKUP_CMDS+=(
  "$VIM +'PlugUpgrade | PlugUpdate'"
  'open_dotfile_tabs'
  'o /Applications # Manually update the non-App Store, infrequently-opened, etc. apps'
)
