#!/bin/bash

git pull origin master

grep -l "evernote: true" ../content/*/* | xargs rm
mkdir -p ../static/evernote

coffee fetch.coffee

cd ..
./build.sh

git add .
git commit -m 'update posts from Evernote'

git push origin master
