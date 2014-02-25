#!/bin/sh

#git pull origin master
rm ../_posts/mylife/*.html
mkdir -p ../_posts/mylife
mkdir -p ../assets/mylife
coffee fetch.coffee
#git add ../_posts/mylife
#git commit -m 'posts from Evernote'
#git push origin master
