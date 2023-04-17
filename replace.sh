echo "Replacing imgs/pic.jpg to jsdelivr link"
new="https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/"
old="imgs/"
ls -d source/_posts/* | xargs -i sed -i "s@\(\!\[.*\](\)$old@\1$new@g" {}
echo "Done"
