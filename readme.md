This repository shall contain the tooling I need for my media storage.

The scenario is that I have a central media storage on a remote machine. There
I store all incoming photos and videos in a folder structure like this:

originals/2010/2010-03-12/20-10-orignal-filename.ext

Now I do not upload my incoming media regularly, but I wait until this cannot
be done manually anymore. This leaves me with a set of folders of incoming
media that I need to rename, check for duplicates and upload for storage.

The tools in this repository shall help me with these problems:
- How to rename the incoming files such that they fit into the directory
  structure.
- Ensure that there are no duplicates on inport.
- Upload to the storage server, and ensuring that this does not overwrite
  existing media files, and that no duplicates are introduced.

I want to reuse existing tools as much as possible, therefore I use exiftool,
rsync and fdupes.

== Tools ==
=== exif.sh ===

This is just a wrapper around exiftool that sets the correct (to my liking)
options and lets exiftool do its thing.

=== process_md5_lists ===

This tool uses two files with the output of find:

{{{
find originals/ -type f -exec md5sum {} \; > md5sums.txt
}}}

I create such a list for the incoming (sorted and renamed) files, and one on
the storage server.

This tool creates a list of the files that are already on the storage server,
and must not be uploaded, and it checks that there will be no collisions on
file names.

It basically helps me with the fact that rsync would either just overwrite an
existing filename, or it would not upload the new file.

== TODO ==

1. Write a script that automates everything
2. Write process_md5_lists
