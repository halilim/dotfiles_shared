# cSpell:ignore libga gcpn gcae gcane gcano gcanev gcanov gcbu gcem gcmb gcemb gcom

alias libga='$EDITOR "$DOTFILES_INCLUDES"/lib/git/git_aliases.sh'

alias ga='git add -p'
alias gam='git_matching add -p'
alias gan='git add -N'
alias gcpn='git cherry-pick --no-commit'
alias gcae='git commit --amend --edit'
# shellcheck disable=SC2139
alias {gcane,gcano}='git commit --amend --no-edit'
# shellcheck disable=SC2139
alias {gcanev,gcanov}='git commit --amend --no-edit --no-verify'
alias gcbu="git commit --message 'Backup updates'" # :)
alias gcm="git commit --message '"
alias gcem="git commit --allow-empty --message '"
alias gcmb='git commit --message "$(git rev-parse --abbrev-ref HEAD)"'
alias gcemb='git commit --allow-empty --message "$(git rev-parse --abbrev-ref HEAD) Re-trigger checks"'
# shellcheck disable=SC2139
alias {gcn,gcne,gcno}='git commit --no-edit' # cSpell:ignore gcne gcno
# shellcheck disable=SC2139
alias {gcnev,gcnov,gcnn}='git commit --no-edit --no-verify' # cSpell:ignore gcnev gcnov gcnn
alias gcnv='git commit --no-verify' # cSpell:ignore gcnv
alias gcom='git checkout $(git_main_branch)'

# cSpell:ignore gdhh gdma gdnc gdtc gdtk
alias gdh='git diff HEAD'
alias gdh~='git diff HEAD~'
alias gdhh='git diff HEAD~ HEAD'
alias gdm='git diff $(git_main_branch)'
alias gdma='git_matching diff'
alias gdnc='git diff --no-color'
alias gdtc='git difftool --tool=code'

# cSpell:ignore gmmnc gmtk
alias glg='git log --graph --stat'
alias gmd='git merge --no-edit $(git_develop_branch)'
alias gmm='git merge --no-edit $(git_main_branch)'
alias gmmnc='git merge --no-edit $(git_main_branch) --no-commit'
alias gmn='git merge --no-edit'
alias gmt='git mergetool'

# cSpell:ignore gpft gpla gplb gpnv gplp grgu grpo

# push with annotated & reachable tags, remove dry-run after confirming
alias gpft='git push --follow-tags --dry-run'
alias gpl='git pull'
# shellcheck disable=SC2139
alias {gla,gpla}="for_each_dir 'git checkout "'$(git_main_branch)'" && git pull --prune'" # Pull all
# shellcheck disable=SC2016
alias gplb='git pull origin $(git rev-parse --abbrev-ref HEAD)'
alias gpnv='git push --no-verify'
# shellcheck disable=SC2139
alias {gplp,glp,gpp}='git pull --prune'
alias gps='git push --set-upstream origin'

alias grh~='git reset HEAD~'

alias grgu='git remote get-url'
alias grpo='git remote prune origin'

# cSpell:ignore gsta gstdiff gstp gstpb gsts ghprc ghprv grhh

# Original gsta (omz/git.plugin.zsh) sounds like apply :)
alias gsta="git stash apply"
alias gstdiff='git stash show --patch'
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
