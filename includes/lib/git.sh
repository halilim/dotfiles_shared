if [[ ! ${GIT_ALREADY_UP_TO_DATE:-} ]]; then
  declare -rx GIT_ALREADY_UP_TO_DATE=64
fi

alias libg='$EDITOR "$DOTFILES_INCLUDES"/lib/git.sh' # cSpell:ignore libg

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

function git_clone_or_pull() {
  local repo=$1 dir=$2

  if [[ -d "$dir" ]]; then
    git --git-dir="$dir"/.git pull --prune
  else
    git clone "$repo" "$dir"
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
  for commit_id in $(echo "$git_log" | "$GNU_SED" -e "s/$color_pat//g" | grep -Eo '^([0-9a-f]{7})\s+'); do
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
