#!/bin/bash
 
# Declare an array of string with type
declare -a StringArray=("v-sekai-fire" "v-sekai" "godot-extended-libraries" "fire" "lyuma" )
 
export BACKUP_GITHUB_DATE=`date --iso=min --utc`

# Iterate the string array using for loop
for val in ${StringArray[@]}; do
   mkdir -p ../$BACKUP_GITHUB_DATE/$val
   cd ../$BACKUP_GITHUB_DATE/$val
   /mingw64/bin/gh repo list $val --limit 9999999 | awk '{print $1; }' | xargs -L1 /mingw64/bin/gh repo clone
   cd -
done