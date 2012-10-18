#!/bin/bash

# installing ffmpeg on Mac w/ homebrew
# brew install ffmpeg --with-libvpx --with-libvorbis

for file in `find . -type f -name '*.webm'`
do
  echo $file
  cmd="ffmpeg -y -i $file -acodec libfaac -ar 22050 -ac 1 -ab 48000 ${file/webm/m4a}"
  echo $cmd
  `$cmd`
done
