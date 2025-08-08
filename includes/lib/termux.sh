# cSpell:ignore pkin
alias pki='pkg install'
alias pkin='pkg info'
alias pkli='pkg list-installed' # cSpell:ignore pkli
alias pks='pkg search'
alias pku='pkg uninstall'

# For git and ssh commands
function termux_prepare_ssh() {
  set +e
  # shellcheck disable=SC1090
  . ~/../usr/libexec/source-ssh-agent.sh
  set -e
}

function termux_update_shellspec() {
  # https://github.com/shellspec/shellspec?tab=readme-ov-file#upgrade-to-the-latest-release-version-
  curl -fsSL https://git.io/shellspec | sh -s -- --switch
}

function termux_install_update_shellcheck() {
  local target_dir=~/../usr/bin should_install

  if [[ -e "$target_dir"/shellcheck ]]; then
    local current_version
    current_version=$(shellcheck --version | rg 'version: (.+)$' --replace '$1')

    local released_version
    released_version=$(curl -s https://api.github.com/repos/koalaman/shellcheck/releases/latest | jq -r '.tag_name')
    released_version=${released_version#v}

    if [[ $current_version != "$released_version" ]]; then
      should_install=1
    else
      echo "Already up to date ($current_version)"
    fi
  else
    should_install=1
  fi

  if [[ $should_install ]]; then
    # https://github.com/koalaman/shellcheck?tab=readme-ov-file#installing-a-pre-compiled-binary
    local version='stable' # or "v0.4.7", or "latest"
    curl -fLs "https://github.com/koalaman/shellcheck/releases/download/${version?}/shellcheck-${version?}.linux.aarch64.tar.xz" | tar -xJv
    mv "shellcheck-${version}/shellcheck" "$target_dir"
  fi
}
