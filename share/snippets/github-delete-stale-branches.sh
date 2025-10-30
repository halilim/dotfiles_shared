#!/usr/bin/env bash
set -euo pipefail
if [[ ${SET_X:-} ]]; then
  set -x
fi
IFS=$'\n\t'

# Dry-run success:
# DR $DOTFILES_SHARED/share/snippets/github-delete-stale-branches.sh foo/bar '["branch1", "branch2"]'
# Dry-run failure:
# DR FAKE_ECHO='gh: Reference does not exist (HTTP 422)' FAKE_STATUS=1 $DOTFILES_SHARED/share/snippets/github-delete-stale-branches.sh foo/bar '["branch1", "branch2"]'

repo=''
file=''

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -r | --repo)
      repo="${2:?Please provide a repo path after -r|--repo, e.g., foo/bar}"
      shift # past argument
      shift # past value
      ;;

    -f | --file)
      file="${2:?Please provide a file path after -f|--file}"
      shift # past argument
      shift # past value
      ;;

    -*)
      echo "Unknown option $1"
      exit 1
      ;;

    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [[ ! $repo ]]; then
  repo=${1:?Please provide a repo path as the first positional argument (e.g., foo/bar), or use -r|--repo to provide it}
  content="${2:?Please provide content as the second positional argument (a JSON array), or use -f|--file to provide a file path}"
fi

if [[ $file ]]; then
  if [[ ! -s $file ]]; then
    echo >&2 "File doesn't exist, or is empty"
    exit 1
  fi
  content="$(< "$file")"
fi

# shellcheck disable=SC1091
. "$HOME"/.dotfiles_bootstrap.sh
# shellcheck disable=SC1091
. "$DOTFILES_INCLUDES"/bash_shared.sh

branches=$(echo "$content" | jq -r '.[]')
branch_count=$(echo "$branches" | wc -l | tr -d ' ')
branch_index=0

# https://docs.github.com/en/rest/git/refs?apiVersion=2022-11-28#delete-a-reference
while IFS= read -r branch; do
  branch_index=$((branch_index + 1))
  printf >&2 "[%d/%d] " "$branch_index" "$branch_count"
  if output=$(
    echo_eval 'PAGER='' gh api --silent --method DELETE \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    repos/%q/git/refs/heads/%q' \
      "$repo" "$branch"
  ); then
    echo "$output"
  else
    color red "$output"
  fi
done < <(echo "$branches")
