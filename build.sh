#! /bin/bash
# Use for local test
hexo clean

cp -ruf post_imgs/* node_modules/hexo-theme-redefine/source/images/post_imgs
cat replace.sh|bash
git add -A
git commit -m "build"
git push
rm -r node_modules/hexo-theme-redefine/source/images/post_imgs/*
