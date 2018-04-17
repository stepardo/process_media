#!/bin/bash

# this script checks that an import does not overwrite files in the remote
# media store

for tool in "mktemp" "realpath";
do
    if ! which $tool > /dev/null;
    then
        echo "'$tool' not found. Exit."
        exit 1
    fi
done

if [[ -z "$1" ]];
then
    echo "Usage: $0 /path/to/target_dir"
    exit 1
fi

if [[ ! -d "$1" ]];
then
    echo "Given target dir '$1' is not a directory."
    exit 1
fi

target=$(realpath "$1")

# get config
if [[ ! -e ./config.inc ]];
then
    echo "Could not find config (./config.inc)"
    exit 1
fi

source ./config.inc

if [[ -z "$remote_path" ]];
then
    echo "You need to specify the variable 'remote_path' in config.inc"
    exit 1
fi

tmpdir=$(mktemp -d)
if [[ ! -d "$tmpdir" ]];
then
    echo "mktemp failed. strange."
    exit 1
fi

local="$tmpdir/md5sums_local.txt"
remote="$tmpdir/md5sums_remote.txt"

# ensure tmpdir is gone when this script is done
trap "rm -rf -- '$tmpdir'" EXIT

set +e # bail out if any command fails
set +v # tell about commands that are executed

# make a list of md5 sums of all files in $target
find "$target" -type f -exec md5sum {} \; >> "$local"

# retrieve remote md5 sums
rsync -avz --info=progress2 "$remote_path" "$remote"

# if we came this far we no longer want the tmpdir to be deleted automatically
trap - EXIT

echo -n "Checking..."
# do the actual checks
# print existing files
process_md5_lists -l "$local" -r "$remote" -p > "$tmpdir/existing_files.txt"

# print existing paths
process_md5_lists -l "$local" -r "$remote" -c > "$tmpdir/filename_clashes.txt"

echo "Done."

# update remote md5list.txt
remote_update="$tmpdir/md5sums_remote_update.txt"
cat "$remote" >> "$remote_update"
cat "$local"  >> "$remote_update"

echo "Updated remote md5sums in file '$remote_update'. Please review and push it to remote yourself."
echo "Original remote path was '$remote_path'"

echo "Please see '$tmpdir' for results."
