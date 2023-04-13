---
title: 小米路由器登录脚本
date: 2023-03-01 21:20:35
tags:
---

# 起源

最近研究了下学校校园网，本来想试试不登录的情况下宿舍和教学楼的IP能否互通，答案是不能。这个脚本本来是为了从宿舍路由器获得WANIP而写的，但既然不能互通，拿到IP也没啥用了。脚本地址：[miRouterLogin](https://github.com/Hexrotor/miRouterLogin)

## 分析

登进路由器，url是这样的：`http://路由器IP/cgi-bin/luci/;stok=3064506d8615d0a05cad3356af54d898/web/home`

中间有串参数就是token，我的目的是要模拟网页登录拿到它

而获取WANIP的方式可以通过控制台轻松查看

![](https://gcore.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/router_pppoe_status.jpg)

url是这样的：`http://路由器IP/cgi-bin/luci/;stok=3064506d8615d0a05cad3356af54d898/api/xqnetwork/pppoe_status`

可见只要拿到token，一切都好说，为此，我们需要从登录页面入手，了解网页是如何跳转到包含token的网址的。

这个过程我参考了[https://blog.csdn.net/hackzkaq/article/details/119676876](https://blog.csdn.net/hackzkaq/article/details/119676876)

总之先在登录界面抓包，我嫌麻烦就在手机上用HttpCanary抓的

抓包发现了登录时会向`http://路由器IP/cgi-bin/luci/api/xqsystem/login` 这个url发送POST请求，内容是类似`username=admin&password=0afb4d1dc7ce1c48afa11233bc055b9106ba1c8cd&logtype=2&nonce=0_98%3A15%3A3d%3Afb%3A3b%3Acb_1677680921_8869`这样的数据，其中nonce和password都是js动态生成的。

查找网页源代码，发现登录时调用loginHandle方法

![](https://gcore.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/loginhandle.jpg)

源码显示加密是用了Encrypt方法，继续搜索关键词，最终发现会涉及`aes.js`和`sha1.js`两个源文件

![](https://gcore.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/encryptjs.jpg)

捋一下逻辑就是：输入密码，由loginHandle方法调用Encrypt方法来生成nonce和加密后的password。将nonce和password POST给路由器，路由器就会返回token

可以直接把要用到的js代码粘到一个文件里，方便调用
Python脚本：
```Python
#参考自https://blog.csdn.net/hackzkaq/article/details/119676876
from urllib.parse import urlencode
import execjs # 导入PyExecJS 库
import os

def get_js(): # 导入js文件
    f = open("login.js", 'r', encoding='UTF-8')
    line = f.readline()
    htmlstr = ''
    while line:
        htmlstr = htmlstr + line
        line = f.readline()
    f.close()
    return htmlstr

def get_token(ip, passwd): # 使用curl获取token
    jsstr = get_js()
    ctx = execjs.compile(jsstr)
    utf = ctx.call("tokenGen", passwd)
    #print("utf: " , utf)
    en = urlencode(utf, encoding='utf-8')
    #print("en: " + en)
    cmd = "curl -ss -X POST -H \"Accept-Encoding:gzip, deflate\" -H \"Accept-Language:zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7\" -H \"Host:192.168.114.1\" -H \"Connection:keep-alive\" -H \"User-Agent:Mozilla/5.0 (Linux; Android 12; 22081212C Build/SKQ1.220303.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/110.0.5481.65 Mobile Safari/537.36\" -H \"Content-Length:126\" -H \"Accept:*/*\" -H \"X-Requested-With:XMLHttpRequest\" -H \"Content-Type:application/x-www-form-urlencoded; charset=UTF-8\" -H \"Origin:http://"+ip+"\" -H \"Referer:http://"+ip+"/cgi-bin/luci/web\" -d \""+en+"\" \"http://"+ip+"/cgi-bin/luci/api/xqsystem/login\"|jq -r \".token\""
    #print("cmd: " + cmd)
    apikey = os.popen(cmd).read()[:-1] # 执行curl
    return apikey

ip = input("Please enter the router ip: ")
passwd = input("Please enter password: ")
token = get_token(ip, passwd)
print("token: " + token)
url = "http://"+ip+"/cgi-bin/luci/;stok="+token+"/api/xqnetwork/pppoe_status"
print("weburl: "+ url)
#print("apikey :"+ apikey)
print(os.popen("curl -ss \""+url+"\"|jq").read())
```

执行结果：

![](https://gcore.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/router_script_stdout.jpg)