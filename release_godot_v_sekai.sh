#!/usr/bin/env zsh

set -euo pipefail

source config.sh
ORIGINAL_BRANCH=main
MERGE_REMOTE=v-sekai-godot
MERGE_BRANCH="groups-${VERSION}" # Quoted the variable expansion
DRY_RUN=0

# Use a safer loop for arguments in zsh
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      printf "Usage: $0 [--help|-h] [--dry-run|--no-push|-n]\n"
      printf "\n"
      printf "Compiles all branches in .gitassembly and pushes to V-Sekai/godot\n"
      printf "Automatically creates a tag and pushes by default.\n"
      printf "\n"
      printf "--help\n"
      printf "    -h  Display help\n"
      printf "\n"
      printf "--dry-run\n"
      printf "       -n  Does not push or create tag.\n"
      printf "\n"
      exit 0
      ;;
    -n|--no-push|--dry-run)
      DRY_RUN=1
      ;;
    *)
      # Unknown option, print error and exit
      printf "Unknown option: %s\n" "$1" >&2
      exit 1
      ;;
  esac
  shift
done

printf "%s\n" "Checkout remotes"

add_remote ()
{
	git remote add "$1" "$2" 2>/dev/null || git remote set-url "$1" "$2"
	git fetch "$1"
}

#
add_remote v-sekai-godot https://github.com/V-Sekai/godot.git
#


merge_branch () {
	git checkout "$ORIGINAL_BRANCH" --force
	git branch -D "$MERGE_BRANCH" || true
	python3 ./thirdparty/git-assembler -av --recreate --config gitassembly
	git checkout "$MERGE_BRANCH" -f
	export MERGE_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
	export MERGE_TAG=$(echo "$MERGE_BRANCH.$MERGE_DATE" | tr ':' ' ' | tr -d ' \t\n\r') # Quoted and escaped
	git commit --allow-empty -m "Merge branch '$MERGE_BRANCH' into '$ORIGINAL_BRANCH' [skip ci]"
	if [[ $DRY_RUN -eq 0 ]]; then
		git tag -a $MERGE_TAG -m "Commited at $MERGE_DATE."
		git push "$MERGE_REMOTE" "$MERGE_TAG"
		git push "$MERGE_REMOTE" "$MERGE_BRANCH" -f
	fi
	git checkout "$ORIGINAL_BRANCH" --force
	if [[ $DRY_RUN -eq 0 ]]; then
		git branch -D "$MERGE_BRANCH" || true
	else
		printf "%s was created and is ready to push.\n" "$MERGE_BRANCH"
	fi
}

if ! [[ "$(git rev-parse --abbrev-ref HEAD)" == "$ORIGINAL_BRANCH" ]]; then
	printf "Failed to run merge script: not on %s branch.\n" "$ORIGINAL_BRANCH"
	exit 1
fi

printf "*** Working on assembling .gitassembly\n"
has_changes=0
git diff --quiet HEAD || has_changes=1
git stash
merge_branch
printf "ALL DONE. ----------------------------\n"
if [[ $has_changes -ne 0 ]]; then
	printf "Note that any uncommitted changes to the merge script may have been stashed. Run\n"
	printf "    git stash apply\n"
	printf "to re-apply those stashed changes\n"
	git stash list
fi
