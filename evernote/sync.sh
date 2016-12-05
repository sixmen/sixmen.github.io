#!/bin/bash

git pull origin master

grep -l "evernote: true" ../content/*/* | xargs rm
mkdir -p ../static/evernote

coffee fetch.coffee

git add ../content
git add ../static
git commit -m 'update posts from Evernote'

git push origin master

cd ..
./build.sh

cd public
git add . -A
git commit -m 'update posts from Evernote'
git push origin gh-pages
