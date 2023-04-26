---
title: 博客搭建
date: 2022-12-15 9:42:26
---

更新于2022-12-16 22:17

以前搭建过博客和Onedrive资源站。资源站是一键式搭建的，但博客是用一个静态网页完全自己手动编辑的，当时不懂博客框架这种东西。这次搭博客我选择用Github+Hexo搭建。域名暂时懒得买了，就用Github Page凑合下。

都是照着教程来的，过程没什么写的，这里简单写一下遇到的坑。

### WSL与Windows共用PATH

安装Nodejs时发现的，因为我Windows和WSL里都装了Nodejs，而WSL的$PATH中居然包含Windows的PATH，导致我在WSL中无法正常运行npm。不是很理解这种机制到底有什么意义。

解决方案：编辑/etc/wsl.conf，添加如下字段

```shell
[interop]
appendWindowsPath=false
```

然后管理员运行PowerShell，执行如下命令以重启WSL

```shell
$ net stop LxssManager; net start LxssManager
```

### Live2D

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/xtxnbj.jpg)

在电脑端访问我的博客，会加载一个Live2D小人。这玩意儿我很早以前在第一个博客里放过，但是当时完全是静态Html，直接引用一条js即可。现在我使用Hexo，页面是根据主题自动生成的，如何插入js？

主题生成页面时肯定有某些规则文件。研究了一番，发现是在主题根目录的layout文件夹中(仅对于我的主题"redefine"而言)，里面有很多ejs文件，记录了生成页面的规则。找到head.ejs文件添加\<script\>代码即可。

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/live2djs.jpg)

我当年弄网页Live2D就是想要放上血小板那个模型，但当年怎么都找不到，而且技术也不过关。现在看来，这个Live2D接口要自己搭后端，否则就只能用别人的老接口，用现有的模型。最近期末了比较忙没时间整了，先挖个坑以后来填。

### 字体

代码块的默认字体太丑了，换成Consolas了，也是靠修改主题文件中的highlight.styl配置，把font-family参数全部修改。

Mozilla还有个页面可以在线调试字体配置：[https://developer.mozilla.org/zh-CN/docs/Web/CSS/font-family](https://developer.mozilla.org/zh-CN/docs/Web/CSS/font-family)

### 网站源码

和我想的不一样，网页的部署是Hexo自动完成的，生成的网页和源码完全是两回事，所以还需要新开一个仓库来保存源码。但是感觉好麻烦，每次都要执行好几次命令，而且我node_module放在项目文件夹里的，git扫描要挺久的。后续想尝试下用Action，push源码后自动运行Hexo生成网页。

### Github Action 自动布署 Hexo

参考了这篇文章：[https://zhuanlan.zhihu.com/p/170563000](https://zhuanlan.zhihu.com/p/170563000)

简单说一下结构。我上传的源码中包含NodeModule和Hexo文件，所以在Action中直接用命令行调用即可。Hexo依赖Git来推送布署网站，所以要生成一对密钥给Git用。当我push源码到仓库时，workflow被触发，在云端Action上clone我的网站源码并执行Hexo，这样就能更新我的网站了。

还有个坑没搞明白，Action上运行Hexo布署网站后，仓库的git log只剩两条了，而我在本地布署并不会这样，~~猜测和clone \-\-depth=1有关~~(没有关系)。

### Aplayer

网页左下角的音乐播放器是Aplayer实现的，参考了这篇文章[https://blog.csdn.net/weixin_58068682/article/details/116612364](https://blog.csdn.net/weixin_58068682/article/details/116612364)

这篇文章中使用的Hexo主题是Butterfly，和我的并不一样。不过我的主题也支持pjax，应该是能实现全局音乐播放的，最后折腾了一番才把我的整好。

遇到一个坑：Aplayer的\<div\>代码一开始是放footer的，但一切换页面左下角播放器就消失了，音乐倒是还在放。然后思考了一下决定把代码放body里，于是修改layout.ejs，成功。

### Jpegoptim

因为博客采用Github Page，所以访问速度有够慢的，live2D经常加载不出来(倒是和Page无关)。考虑到后期上的图可能比较多，不可能每次都手动压缩，我设置了jpg压缩程序，使用的是Jpegoptim，配合find就能实现批量操作。另外，每次加图片都要跑到主题module文件夹里去，因为生成网页源码就从那个地方加载，不知道怎么调，干脆就写了个shell命令从外面文件夹复制图片进去，这样加图片会比较方便。

```Shell
find ./public/images/post_imgs/ -not -iname "*_raw.jpg" -not -iname "*_raw.jpeg" -iname "*.jpg" -o -iname "*.jpeg" | xargs jpegoptim -m 80
```

上述代码为设置jpg质量为80，jpegoptim会默认跳过一些不需要优化压缩的图片。另外这个优化并不是对原图片进行修改，而是对hexo g之后生成的public文件夹中图片进行修改，原图能得到比较妥善的保管。文件名最后带有_raw的jpg/jpeg图片不会被压缩。

后续待更新
