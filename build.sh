#! /bin/bash
# Use for local test
if hexo clean;
then
	cp -ruf post_imgs/* themes/redefine/source/images/post_imgs
	cat replace.sh|bash
	git add -A
	git commit -m "build"
	git push
	rm -r themes/redefine/source/images/post_imgs/*
fi
