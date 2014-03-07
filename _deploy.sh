#!/bin/bash
jekyll build
cd _site
git add .
git commit -m 'update posts from Evernote'
git push origin gh-pages
