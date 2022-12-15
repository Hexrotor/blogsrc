---
title: 博客搭建
date: 2022-12-14 21:42:26
---
以前搭建过博客和Onedrive资源站。资源站是一键式搭建的，但博客是用一个静态网页完全自己手动编辑的，当时不懂博客框架这种东西。这次搭博客我选择用Github+Hexo搭建。域名暂时懒得买了，就用Github Page凑合下。

都是照着教程来的，过程没什么写的，这里简单写一下遇到的坑。

## WSL与Windows共用PATH

安装Nodejs时发现的，因为我Windows和WSL里都装了Nodejs，而WSL的$PATH中居然包含Windows的PATH，导致我在WSL中无法正常运行npm。不是很理解这种机制到底有什么意义。

解决方案：编辑/etc/wsl.conf，添加如下字段

```shell
[interop]
appendWindowsPath=false
```

然后管理员运行PowerShell，执行如下命令以重启WSL

```
net stop LxssManager; net start LxssManager
```

## 字体

总觉得代码块的字体很丑，主题也没有提供修改接口，等有时间研究下给它换掉。

## Live2D

![](/images/post_imgs/xtxnbj.jpg)

在电脑端访问我的博客，会加载一个Live2D小人。这玩意儿我很早以前在第一个博客里放过，但是当时完全是静态Html，直接引用一条js即可。但现在我使用Hexo，页面是根据主题自动生成的，要如何插入js？

主题生成页面时肯定有某些规则文件。研究了一番，发现是在主题根目录的layout文件夹中(仅对于我的主题"redefine"而言)，里面有很多ejs文件，记录了生成页面的规则。找到script.ejs文件添加了js即可。

![](/images/post_imgs/live2djs.jpg)

我当年弄网页Live2D就是想要放上血小板那个模型，但当年怎么都找不到，而且技术也不过关。现在看来，这个Live2D接口要自己搭后端，否则就只能用别人的老接口，只能用现有的模型。最近期末了比较忙没时间整了，先挖个坑以后来填。

后续待更新