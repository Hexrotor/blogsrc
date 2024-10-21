---
title: 联通 PT928G 光猫改桥接
date: 2024-10-02 23:10:27
tags: [IOT, 路由器]
categories: [技术]
excerpt: "进管理员的办法"
---

### 起因

国庆回家发现家里网用不了，原来是联通改光纤了。摇了师傅来家里重新接了线，同时也把老调制解调器换成了光猫。

那么问题来了，以前老铜线猫就起个桥接作用，都是用路由器拨号，现在换了光猫就变成光猫拨号了。光猫这东西我知道他有运营商限制，但是一直没机会搞，现在终于有机会了。

### 破解超管密码

首先打开光猫登陆页面 192.168.1.1，可以看到如下内容

![Login](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/modem_login.png.avif)

选右边，在光猫机子背面找到密码登录，登录后直接点击管理选项找到密码修改页面

![manage](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/modem_manage.png.avif)

虽然只有一个选项，但是可以通过 F12 修改前端，改变发包数据使得选择的用户变成超管

如图只需要把 `value` 从 `0` 改为 `1` 即可，旧密码就是 user 的旧密码，但是新密码修改的是超管的密码

![f12](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/modem_f12.png.avif)

修改完成后就可以回到主页登录超管了

![超管](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/modem_success.png.avif)

### 修改桥接

先说一下我为什么要修改桥接，其实是为了让设备有 IPv6。我登录光猫超管后尝试了调它 IPv6 的选项，路由器也尝试开 NAT6。然后 IPv6 能上网了，但是路由器依旧无法给下层设备分配 IPv6 独立地址，还是改桥接最简单。

但是就早听说现在的光猫都有上级云控，WAN 配置里的 TR069 路由就是云控，据说删了就能防止云控了。我暂时先不删，看看后面会不会被恢复再另作打算

![tr069](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/modem_tr069.png.avif)

改桥接没什么好说的，如下图很好改，然后在路由器设置拨号即可。要注意的是不要把光猫的 DHCP 关掉了，否则以后可能访问不到光猫。

![bridge](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/modem_bridge.png.avif)

### 修改后效果

路由器：

![router](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/modem_router.png.avif)

电脑：

![pc](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/modem_pc.png.avif)