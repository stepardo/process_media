#!/bin/bash

tempdir=$(mktemp -d)
datadir=$(mktemp -d)

trap "rm -rf -- '$tempdir' '$datadir'" EXIT

if [[ ! -d $tempdir  || ! -d $datadir ]];
then
  echo "mktemp did not work"
  exit
fi

echo "Tempdir is $tempdir"
echo "Datadir is $datadir"

rsync -a data $datadir

echo "import 1"
bash ../bin/exif.sh $datadir/data/import1/ $tempdir
find $tempdir

echo "import 2"
bash ../bin/exif.sh $datadir/data/import2/ $tempdir
find $tempdir

echo "import 3"
bash ../bin/exif.sh $datadir/data/import3/ $tempdir
cd $tempdir
find . -type f -ls

