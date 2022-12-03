#!/usr/bin/env bash

set -e

ORIGINAL_BRANCH=main
MERGE_REMOTE=v-sekai-godot
MERGE_BRANCH=groups-staging-4.x
DRY_RUN=0

while [[ -n "$1" ]]; do
	echo "ARG $1"
	if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
		echo "Usage: $0 [--help|-h] [--dry-run|--no-push|-n]"
		echo ""
		echo "Compiles all branches in .gitassembly and pushes to V-Sekai/godot"
		echo "Automatically creates a tag and pushes by default."
		echo ""
		echo "--help"
		echo "    -h  Display help"
		echo ""
		echo "--dry-run"
		echo "       -n  Does not push or create tag."
		echo ""
		exit
	fi
	if [[ "$1" == "-n" ]] || [[ "$1" == "--no-push" ]] || [[ "$1" == "--dry-run" ]]; then
		DRY_RUN=1
	fi
	shift
done

echo -e "Checkout remotes"

add_remote ()
{
	git remote add "$1" "$2" || git remote set-url "$1" "$2"
	git fetch "$1"
}

#
add_remote godotengine https://github.com/godotengine/godot
add_remote v-sekai-godot git@github.com:V-Sekai/godot.git # Do not change to https or it will break fire's pushing workflow.
add_remote nikitalita https://github.com/nikitalita/godot.git
add_remote Geometror https://github.com/Geometror/godot.git
add_remote WindyDarian https://github.com/WindyDarian/godot/
add_remote bruvzg https://github.com/bruvzg/godot.git
add_remote haasanen https://github.com/haasanen/godot.git
add_remote TokageItLab https://github.com/TokageItLab/godot.git
add_remote aaronfranke https://github.com/aaronfranke/godot.git
#

merge_branch () {
    git checkout $ORIGINAL_BRANCH --force
    git branch -D $MERGE_BRANCH || true
    python3 ./thirdparty/git-assembler -av --recreate --config gitassembly-staging
    git checkout $MERGE_BRANCH -f
    export MERGE_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    if [[ $DRY_RUN -eq 0 ]]; then
        git push $MERGE_REMOTE $MERGE_BRANCH -f
    fi
    git checkout $ORIGINAL_BRANCH --force
    if [[ $DRY_RUN -eq 0 ]]; then
        git branch -D $MERGE_BRANCH || true
    else
        echo "$MERGE_BRANCH was created and is ready to push."
    fi
}

if ! [[ "`git rev-parse --abbrev-ref HEAD`" == "$ORIGINAL_BRANCH" ]]; then
	echo "Failed to run merge script: not on $ORIGINAL_BRANCH branch."
	exit 1
fi

echo -e "*** Working on assembling .gitassembly"
has_changes=0
git diff --quiet HEAD || has_changes=1
git stash
merge_branch
echo -e "ALL DONE. ----------------------------"
if [[ $has_changes -ne 0 ]]; then
	echo "Note that any uncommitted changes to the merge script may have been stashed. Run"
	echo "    git stash apply"
	echo "to re-apply those stashed changes"
	git stash list
fi
