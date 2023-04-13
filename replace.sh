new="https://gcore.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/"
old="https://test1.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/"
ls -d source/_posts/* | xargs -i sed -i "s@\(\!\[.*\](\)$old@\1$new@g" {}