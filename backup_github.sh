#!/usr/bin/env bash

# Download gh client https://github.com/cli/cli/releases/tag/v2.14.2

# Declare an array of string with type
declare -a StringArray=("v-sekai-fire" "v-sekai" "godot-extended-libraries" "fire" "lyuma" "SaracenOne" "omigroup" "mrmetaverse")

export BACKUP_GITHUB_DATE=`date --iso=min --utc`

# Iterate the string array using for loop
for val in ${StringArray[@]}; do
   mkdir -p ../$BACKUP_GITHUB_DATE/$val
   cd ../$BACKUP_GITHUB_DATE/$val
   gh repo list $val --limit 9999999 | awk '{print $1; }' | xargs -I {} gh repo clone {} -- --recurse-submodules
   cd -
done
