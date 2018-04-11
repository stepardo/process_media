#!/bin/bash

#exiftool -ext JPG -ext NEF '-FileName<CreateDate' -d
#%Y/%m/%d/%H_%M_%%f%%-c.%%e -r ../../NIKON\ D90/

# ensure all required tools are available

for tool in "exiftool" "realpath" "tee";
do
    if ! which $tool > /dev/null;
    then
        echo "$tool not found"
        exit 1
    fi
done

# input validation
if [[ -z $1 || -z $2 ]];
then
    echo "Usage: exif.sh /path/to/source /path/to/target"
    exit 1
fi

if [[ ! -d "$1" ]];
then
    echo "Source '$1' is not a directory"
    exit 1
fi

if [[ ! -d "$2" ]];
then
    echo "Target '$2' is not a directory"
    exit 1
fi

source=$(realpath $1)
target=$(realpath $2)

exit 2

cd "$target"

SDCARD="$source"
PATTERN="%Y/%Y_%m_%d/%H_%M_%S_%%f%%-c.%%e"

set -v # show all commands prior to execution
set -e # exit if a command fails

# move all image files
exiftool -P -progress -ext ARW -ext NEF -ext JPG '-FileName<DateTimeOriginal' -d $PATTERN -r $SDCARD
# move all avchd files as well...
exiftool -P -progress -ext MTS '-FileName<DateTimeOriginal' -d $PATTERN -r $SDCARD
exiftool -P -progress -ext MP4 '-FileName<CreateDate' -d $PATTERN -r $SDCARD
# move mpegs
exiftool -P -progress -ext MPG -ext MPEG '-FileName<FileModifyDate' -d $PATTERN -r $SDCARD
# move files that to not have the DateTimeOriginal tag
exiftool -P -progress -ext JPG '-FileName<FileModifyDate' -d $PATTERN -r $SDCARD
# move MOV, AVI
exiftool -P -progress -ext MOV -ext AVI '-FileName<DateTimeOriginal' -d $PATTERN -r $SDCARD
exiftool -P -progress -ext MOV '-FileName<MediaCreateDate' -d $PATTEN -r $SDCARD
exiftool -P -progress -ext MOV '-FileName<CreateDate' -d $PATTEN -r $SDCARD
