#!/bin/bash

tempdir=$(mktemp -d)
datadir=$(mktemp -d)
basedir=$(dirname $(realpath $0))

trap "rm -rf -- '$tempdir' '$datadir'" EXIT

if [[ ! -d $tempdir  || ! -d $datadir ]];
then
  echo "mktemp did not work"
  exit
fi

logfile=$(mktemp)
if [[ -z "$logfile" ]];
then
  echo "mktemp failed"
  exit
fi

echo "Logging into $logfile"
exec > >(tee -a "$logfile") 2>&1

echo "Tempdir is $tempdir"
echo "Datadir is $datadir"

set -e # exit if a command fails
set -x # show commands

rsync -a $basedir/data $datadir

echo "import 1"
bash $basedir/../bin/exif.sh $datadir/data/import1/ $tempdir
find $tempdir

echo "import 2"
bash $basedir/../bin/exif.sh $datadir/data/import2/ $tempdir
find $tempdir

echo "import 3"
bash $basedir/../bin/exif.sh $datadir/data/import3/ $tempdir

cd $tempdir
fdupes -r . > $datadir/expected_fdupes.txt

diff $basedir/data/expected_fdupes.txt $datadir/expected_fdupes.txt
if [[ $? -ne 0 ]];
then
  echo "fdupes output is not equal to the expected output. Consult $logfile"
  exit 1
fi

rm $logfile
echo "OK - Test successful"
