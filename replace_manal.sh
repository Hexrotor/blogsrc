echo "Replacing imgs/pic.jpg to jsdelivr link"
new="https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/"
old="https://gcore.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/"
ls -d source/_posts/* | xargs -i sed -i "s@\(\!\[.*\](\)$old@\1$new@g" {}
sed -i "s@$old@$new@g" _config.redefine.yml
echo "Done"
