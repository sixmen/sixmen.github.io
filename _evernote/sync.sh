#!/bin/sh

git pull origin master

rm ../_posts/*/*.html
mkdir -p ../_posts/mylife
mkdir -p ../assets/evernote

coffee fetch.coffee

git add ../_posts
git commit -m 'update posts from Evernote'

git push origin master

cd ..
jekyll build
cd _site
git commit -a -m 'update posts from Evernote'
git push origin gh-pages
