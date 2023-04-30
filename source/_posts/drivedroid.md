---
title: 使用Android手机(rooted)模拟USB或CD-ROM设备来引导电脑启动
date: 2022-12-24 20:44:42
tags: [Android, 操作系统]
categories: [技术]
thumbnail: "https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/drivedroid_setup.jpg"
excerpt: "使用软件DriveDroid实现"
---

最近老爸和我说他那边电脑老是启动时显英文字母，我一看就知道是硬盘快不行了，果断下单买了块机械。

今天硬盘倒是到了，我却发现我U盘忘在学校了，家里居然一个U盘都没有，这咋装系统呢？

我忽然想到以前在酷安上看见过一个大佬的帖子，用Android手机能模拟U盘来引导启动。

搜索了下，软件名字叫[Drivedroid](https://www.drivedroid.io/)，看上去很久没更新了。我以前用一台小米2测试成功过，但那台机子尾插有问题，传数据很容易中断。我翻出了我的小米5，准备尝试一波。官网的changelog写着软件最新版Target API是Android 9，我米5是10，应该问题不大，先下载安装看看。

进入软件，会请求root权限，让你设置存放镜像的目录，这些步骤都没什么说的，重点在于后面。先将手机连上电脑，然后选择USB模式为文件传输。回到软件，进入这个页面：

![Setup](https://gcore.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/drivedroid_setup.jpg)

这个页面是选择手机USB模拟的模式，这决定了这台手机是否能用于模拟USB/CD-ROM设备。大多数手机选第一个就行了，我的米5选第一个会一直Hosting image。这里我选第二个，先往后看：

![Setup](https://gcore.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/drivedroid_setup2.jpg)

这个页面是问你电脑上有没有显示手机设备。打开资源管理器，选择此电脑，就能看到是否有Android设备。

如果有，大概是这样的：

![thispc](https://gcore.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/thispc.jpg)

如果没有，我也不知道为什么，反正我的电脑上也没有，就选择No devices了

然后下一步，是要尝试用手机来引导电脑启动：

![boot](https://gcore.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/drivedroid_setup3.jpg)

就是重启电脑，然后选择BIOS启动项，这里不再赘述，不懂的可以搜下。反正是选比较可疑的那项，一般是带"Linux"字样的，选择后BIOS就会开始引导

如果你的手机引导成功了，那么屏幕上应该会出现Drivedroid的提示说成功了；如果是进了原系统了，或者就亮一行黑字提示重启、找不到设备之类的，那么说明引导失败了，可以在手机屏幕上选择相应的选项，按软件的提示来继续。或者我们可以直接回到之前选择USB SYSTEM那里，继续尝试其他选项。如果还是没法启动，那你的手机可能不支持作为USB/CD-ROM设备用于引导，又或者是你的数据线有问题，可以自己多尝试下。

至于我，我一开始压根没试，直接选的启动成功，进到了软件的主页面：

![main](https://gcore.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/drivedroid_main.jpg)

这里就可以选自己镜像了，建议选择模式为CD-ROM或Writable USB，镜像存放的目录就是一开始让你选的那个目录。图中我已经存了个win8.1的镜像，写这文的时候PE的镜像还在用毒盘以20KB/s的速率下载着。

最后提一嘴，我认为win8.1比win7更好用。