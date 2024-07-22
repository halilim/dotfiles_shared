# cSpell:ignore libg gcpn gcano gcom gdnc gdtc gdtk gmmnc gmtk gpft gpla gplp grgu grpo

[[ -z $GIT_ALREADY_UP_TO_DATE ]] && declare -rx GIT_ALREADY_UP_TO_DATE=64

# shellcheck disable=SC2139
alias libg="$EDITOR $0"

alias ga='git add -p'
alias gan='git add -N'
alias gcpn='git cherry-pick --no-commit'
alias gcano='git commit --amend --no-edit'
alias gcm="git commit --verbose --message '"
alias gcn='git commit --no-edit'
alias gcom='git checkout $(git_main_branch)'

alias gdh='git diff HEAD'
alias gdh~='git diff HEAD~'
alias gdm='git diff $(git_main_branch)'
alias gdnc='git diff --no-color'
alias gdtc='git difftool --tool=code'
alias gdtk='git difftool --tool=kdiff3'

alias glg='git log --graph --stat'
alias gmd='git merge --no-edit $(git_develop_branch)'
alias gmm='git merge --no-edit $(git_main_branch)'
alias gmmnc='git merge --no-edit $(git_main_branch) --no-commit'
alias gmn='git merge --no-edit'
alias gmt='git mergetool'
alias gmtk='git mergetool --tool=kdiff3'

# push with annotated & reachable tags, remove dry-run after confirming
alias gpft='git push --follow-tags --dry-run'
alias gpl='git pull'
# shellcheck disable=SC2139
alias {gla,gpla}="for_each_dir 'git checkout "'$(git_main_branch)'" && git pull --prune'" # Pull all
# shellcheck disable=SC2139
alias {gplp,glp}='git pull --prune'
alias gps='git push --set-upstream origin'

alias grh~='git reset HEAD~'

alias grgu='git remote get-url'
alias grpo='git remote prune origin'

# cSpell:ignore gsta gstp gstpb gsts ghprc ghprv grhh

# Original gsta (omz/git.plugin.zsh) sounds like apply :)
alias gsta="git stash apply"
alias gstp="git stash push --include-untracked -m"
alias gstpb='git stash push --include-untracked -m"$(git rev-parse --abbrev-ref HEAD)"'
# alias gsts="git stash save"

alias gsv="GIT_SSH_COMMAND='ssh -vvv'"
alias gt='export NEW_VERSION=1.2.3 && git tag -a v$NEW_VERSION -m "" && git push --tags origin v$NEW_VERSION'

# GitHub CLI
alias ghprc='gh pr create --web'
alias ghprv='gh pr view --web'

# Not using .config/git/config because apparently some tools create ~/.gitconfig
alias git_conf_core='$EDITOR ~/.gitconfig'
alias git_conf_ignores='$EDITOR ~/.config/git/ignore'
alias git_conf_attributes='$EDITOR ~/.config/git/attributes'

alias gpc='pre-commit install -c $DOTFILES_INCLUDES/lib/git/pre-commit-common.yml'

# Unalias the dangerous `git reset --hard` alias from omz/git.plugin.zsh, easy to mistype grh
unalias grhh 2>/dev/null || true

function cd_checkout_pull() {
  local dir=$1 branch=$2

  if [ "$dir" ]; then
    cd_with_header "$dir" || return
  fi

  if [[ $PRE_PULL_CMD ]]; then
    echo_eval "$PRE_PULL_CMD"
  fi

  # Must be after cd since the git branch depends on the folder
  [[ -z $branch ]] && branch=$(git_main_branch)

  echo_eval 'git checkout %q' "$branch"

  local git_pull_result
  git_pull_result=$(echo_eval 'git pull --prune')
  [[ $git_pull_result ]] && echo "$git_pull_result"
  if [[ $git_pull_result == *'up to date'* ]]; then
    return "$GIT_ALREADY_UP_TO_DATE"
  fi
}

# Copy a repo without the remotes but with the .git folder for sending, e.g. an interview
function git_cp_remoteless() {
  local source=$1 dest=$2
  git clone "$source" "$dest"
  (
    cd "$dest" || return
    git remote | xargs -n1 git remote remove
  )
  iterm_tab "$dest"
  o "$dest"
}

function git_diff_save() {
  git add -N .
  git diff --no-color > "$1"
  git reset
}

function git_find_file() {
  local file_name=$1 git_log

  # Output of git log:
  # ---
  # 0123abc Foo bar (Mad Gitter, 1 days ago)
  #
  # path/file
  # 4567def Bar baz (Hieronymus Bosch, 2 days ago)
  #
  # path/file
  # ---
  # To trick it into separating commits properly, we duplicate all newlines and "de-quadruplicate" them.
  # https://stackoverflow.com/a/1252191/372654
  git_log=$(git log --all --name-status -- "*$file_name*" |
    sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\n\n/g' -e 's/\n\n\n\n/\n/g')

  local commit_id branches color_pat='\x1b\[[0-9;]*m'
  for commit_id in $(echo "$git_log" | gsed -e "s/$color_pat//g" | grep -Eo '^([0-9a-f]{7})\s+'); do
    # shellcheck disable=SC2001
    git_log=$(echo "$git_log" | sed -e "s/\(.*$commit_id\)/%s\n\1/")
    branches=$(git branch -a --contains "$commit_id" | head -n 3)

    # Inject branches at the top of each commit
    branches=$(printf %s "$branches" | tr '\n' ',' | tr -s ' ')
    # shellcheck disable=SC2059
    git_log=$(printf "$git_log" "$branches")
  done

  echo "$git_log"
}
alias gff='git_find_file'
