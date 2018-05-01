#!/bin/bash

# check if required tools are available
for tool in "fdupes" "rsync" "exiftool" "realpath" "tee" "date";
do
    if ! which $tool > /dev/null;
    then
        echo "'$tool' not found. Exit."
        exit 1
    fi
done

# get input
if [[ -z $1 ]];
then
    echo "Usage: import /path/to/source_dir"
    exit 1
fi

if [[ ! -d $1 ]];
then
    echo "Source dir '$1' is not a directory"
    exit 1
fi
source=$(realpath $1)

projectdir=$(dirname $(realpath $0))

source $projectdir/helpers.inc

# get config
if [[ ! -e ./config.inc ]];
then
    echo "Could not find config (./config.inc)"
    exit 1
fi

source ./config.inc

# validate config
for dir in "$source" "$target";
do
    if [[ ! -d "$dir" ]];
    then
        echo "Could not find dir '$dir'";
        exit 1
    fi
done

set -e # exit if a command fails
# check that there is enough space in $target
ensure_enough_space_in_target $source $target

for file in "$md5_list_remote";
do
    if [[ ! -e "$file" ]];
    then
        echo "File '$file' not found";
        exit 1;
    fi
done

if [[ ! -z $logfile ]];
then
    exec > >(tee -a "$logfile") 2>&1
    export LOGFILE=$logfile
fi

echo "Importing media files from '$source' to '$target'"

echo "Type 'YES' to proceed"

read answer

if [[ "$answer" = "YES" ]];
then
    echo "Proceeding."
else
    echo "NOT proceeding."
fi

set -v # show commands before executing them

# first, move and rename files from source to target
bash exif.sh "$source" "$target"

#second, try to find duplicates in target dir (interactive!)
echo "Finding duplicates"
echo fdupes -d -r "$target"

# TODO
# - generate md5list of target_dir
# - check against md5_list_remote for duplicates and delete them, and check for
#   filename clashes
# - rsync files to destination
