#! /bin/bash
# Use for local test
cp -ruf post_images/* node_modules/hexo-theme-redefine/source/images/post_imgs
hexo clean
git add -A
git commit -m "build"
git push
rm -r node_modules/hexo-theme-redefine/source/images/post_imgs/*
