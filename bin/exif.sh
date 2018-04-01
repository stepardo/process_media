#!/bin/bash

#exiftool -ext JPG -ext NEF '-FileName<CreateDate' -d
#%Y/%m/%d/%H_%M_%%f%%-c.%%e -r ../../NIKON\ D90/

cd originals

SDCARD="../incoming"
PATTERN="%Y/%Y_%m_%d/%H_%M_%S_%%f%%-c.%%e"

# copy all image files
exiftool -P -ext ARW -ext NEF -ext JPG '-FileName<DateTimeOriginal' -d $PATTERN -r $SDCARD
# copy all avchd files as well...
exiftool -P -ext MTS '-FileName<DateTimeOriginal' -d $PATTERN -r $SDCARD
exiftool -P -ext mp4 '-FileName<CreateDate' -d $PATTERN -r $SDCARD
# copy mpegs
exiftool -P -ext MPG -ext MPEG '-FileName<FileModifyDate' -d $PATTERN -r $SDCARD
# install files that to not have the DateTimeOriginal tag
exiftool -P -ext jpg -ext JPG '-FileName<FileModifyDate' -d $PATTERN -r $SDCARD
# MOV, AVI
exiftool -P -ext MOV -ext AVI '-FileName<DateTimeOriginal' -d $PATTERN -r $SDCARD
exiftool -P -ext MOV '-FileName<MediaCreateDate' -d $PATTEN -r $SDCARD
exiftool -P -ext MOV '-FileName<CreateDate' -d $PATTEN -r $SDCARD
