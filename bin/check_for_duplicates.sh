#!/bin/bash

for tool in "fdupes" "realpath";
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

# ok, run fdupes and let it do its thing
echo "Running fdupes interactively. This might take some time."
exec fdupes -d -r "$target"
