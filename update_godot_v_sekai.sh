#!/usr/bin/env bash

set -e

ORIGINAL_BRANCH=main
MERGE_REMOTE=v-sekai-godot
MERGE_BRANCH=groups-4.x
MERGE_BRANCH_SHARED=groups-shared-4.x
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
add_remote SaracenOne https://github.com/SaracenOne/godot
add_remote lyuma https://github.com/lyuma/godot
add_remote fire https://github.com/fire/godot
add_remote v-sekai-godot git@github.com:V-Sekai/godot.git
add_remote BastiaanOlij https://github.com/BastiaanOlij/godot.git
add_remote tokage https://github.com/TokageItLab/godot.git
add_remote reduz https://github.com/reduz/godot
add_remote briansemrau https://github.com/briansemrau/godot.git
add_remote Faless https://github.com/Faless/godot.git
add_remote groud https://github.com/groud/godot.git
add_remote jonbonazza https://github.com/jonbonazza/godot.git
add_remote Chaosus https://github.com/Chaosus/godot.git
add_remote clayjohn https://github.com/clayjohn/godot.git
add_remote nikitalita https://github.com/nikitalita/godot.git
add_remote NNesh https://github.com/NNesh/godot.git
add_remote Calinou https://github.com/Calinou/godot.git
add_remote AnilBK https://github.com/AnilBK/godot.git
add_remote bruvzg https://github.com/bruvzg/godot.git
add_remote timothyqiu https://github.com/timothyqiu/godot.git
add_remote Calinou https://github.com/Calinou/godot.git
add_remote Zylann https://github.com/Zylann/godot.git
add_remote techiepriyansh https://github.com/techiepriyansh/godot.git
add_remote adamscott https://github.com/adamscott/godot.git
add_remote Geometror https://github.com/Geometror/godot.git
add_remote YakoYakoYokuYoku https://github.com/YakoYakoYokuYoku/godot
add_remote WindyDarian https://github.com/WindyDarian/godot/
add_remote vnen https://github.com/vnen/godot/
#


merge_branch () {
    git checkout $ORIGINAL_BRANCH --force
    git branch -D $MERGE_BRANCH || true
    python3 ./thirdparty/git-assembler -av --recreate
    git checkout $MERGE_BRANCH -f
    export MERGE_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    export MERGE_TAG=$(echo $MERGE_BRANCH.$MERGE_DATE | tr ':' ' ' | tr -d ' \t\n\r')
    if [[ $DRY_RUN -eq 0 ]]; then
        git tag -a $MERGE_TAG -m "Commited at $MERGE_DATE."
        git push $MERGE_REMOTE $MERGE_TAG
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
export MERGE_BRANCH=$MERGE_BRANCH_SHARED
merge_branch
echo -e "ALL DONE. ----------------------------"
if [[ $has_changes -ne 0 ]]; then
	echo "Note that any uncommitted changes to the merge script may have been stashed. Run"
	echo "    git stash apply"
	echo "to re-apply those stashed changes"
	git stash list
fi
