#! /bin/bash
# Use for local test
cp -ruf post_imgs/* node_modules/hexo-theme-redefine/source/images/post_imgs
echo "Replacing imgs/pic.jpg to jsdelivr link"
new="https://test1.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/"
old="imgs/"
ls -d source/_posts/* | xargs -i sed -i "s@\(\!\[.*\](\)$old@\1$new@g" {}
echo "Done"
hexo clean
git add -A
git commit -m "build"
git push
rm -r node_modules/hexo-theme-redefine/source/images/post_imgs/*
