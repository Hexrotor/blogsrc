---
title: Linux Mint - Linux 主系统 + Windows 虚拟机双系统方案踩坑
date: 2024-06-01 16:55:01
tags: [Linux, Windows, TroubleShooting]
categories: [技术]
---

### For what

先说一下为什么我要用 Linux 当主系统。因为最近需要编译一些项目，vm 的性能实在是有点拉了。考虑到以后一直有这方面的需求，干脆决定装一个 Linux 主机 + Windows 虚拟机的工作环境

然后是为什么要用 Linux Mint 这个系统，而不是 Ubuntu、Kali、Deepin 啥的。原因很简单，我一个一个试的，试了很多发行版(除了 Deepin 没试)。这些系统无一例外都有一些奇怪的 bug，比如 Ubuntu 的死机，我不信邪还装了两次，结果就是用着用着桌面就会卡死，没有任何征兆; Kali 的双屏适配有问题，GPU 驱动适配不了，装着试了但是效果不行，还把图形界面搞炸了。总之最后机缘巧合之下想起来初中的时候用过这个 Linux Mint，然后装着试下了，用着居然还不错。

我的机子是幻16 2022款，显卡是3060，除了没有 RGB 所有硬件都工作正常

### Introduction

简单介绍一下 Linux Mint 这个系统，它是基于 Ubuntu 改的，算是简约派但是该有的基本都有

桌面用的是他们自己开发的 cinnamon。任务栏上面允许放置小插件(温度监控之类的)，QQ 小图标也可以正常地显示在任务栏中。但是这个桌面有个大槽点是，它开始菜单里左侧可以固定一些快捷应用，但是当你右键这些应用图标，它并不会显示出设置(取消固定之类的)，而是必须在列表里翻到原本的那个应用图标，然后右键才能取消固定。桌面图标有时候会错位，其实问题不大全选拖一下就行了。但是它还有个最严重的问题是，有时候会突然寄掉，然后自己会恢复。虽然它寄掉不会影响正在跑的东西，但是突然出现还是让人心头一紧。寄的原因尚不清楚，可能是爆内存了。开发人员或许知道这个桌面也有美中不足的地方，于是很贴心地在任务栏右键中给了一个疑难解答 debug 模式，可以快速重启桌面。

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/mint_taskbar.png)

它自带有软件商店，支持 SystemPackage 和 Flathub，使用体验还是不错的，图片和评论功能都有

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/mint_install.png)

### 踩坑记录

#### Fcitx 5 输入法
中文输入法要自己装，我用的是 Fcitx5，但是这玩意儿在双屏上有 bug，它可能会获取不到屏幕的 DPI 大小，从而显示出错，打个字出来的候选界面能把占个屏幕占完

[https://github.com/fcitx/fcitx5/issues/642](https://github.com/fcitx/fcitx5/issues/642)

解决方案：更改 `~/.config/fcitx5/conf/classicui.conf`，设置 `PerScreenDPI=False`

#### N 卡驱动

你说得对，但是这个系统专门有个页面管理 N 卡驱动，可以在设置里进去

![](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/mint_gpu.png)

驱动直接装上，一点毛病没有，浏览器都能调用，甚至任务栏小图标还给个显卡图标，可以调模式。但是建议不要调，亲测调成 Intel 节能模式后图形界面启动不了，就用 Nvidia 性能模式就行了

但是比较难受的是，笔记本屏幕怎么搞都只能 60 帧，外接屏能 165 帧没问题。没有外接屏又想装这个系统的要多考虑下了。

#### QQ 登录

每次重启系统，QQ 都会给识别成新设备，这个是 QQ 的问题不是系统的问题。QQ 会采集一些指纹来标识机子，比如网卡啥的，在 Linux 下有些东西不像 Windows 那样一成不变，很明显他们搞的采集点有问题，解决方案暂时没有。

#### CPU 调度

在 Linux 下没有奥创中心，CPU 模式调不了，调度疑似是比较激进的，因为风扇经常吹，开个博客网页风扇都一直吹，这点在 Windows 下从未出现过

可能有人会说直接 `/sys/devices` 设置啊，Linux 下万物皆可调，但是当我 `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`，出来的居然是 "powersave"？？然后我读了下 `scaling_driver` 这个文件内容是 "intel_pstate"，搜了下原来是一种新的调度技术，它这个 powersave 模式就是兼顾省电和性能的模式。

但是风扇为什么一直吹呢？我研究了一下，发现居然是 Intel 大小核的问题，计算任务基本上全分给大核了，小核的使用率曲线就如同平静的河面一般毫无波澜。

执行 `uname -a` 回显为

```plaintext
Linux Zephyrus 5.15.0-107-generic #117-Ubuntu SMP Fri Apr 26 12:26:49 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux
```

这个内核版本似乎没有对大小核进行优化，导致我开个网页 CPU 温度都能上 80，后续可能研究一下能不能升级内核

#### 科学上网

科学上网我选择使用 [v2raya](https://github.com/v2rayA/v2rayA)，使用 web 页面进行管理

#### Windows 虚拟机

一开始用的 Virt-manager，这玩意儿性能不错，但是分辨率不能随意调整，鼠标还是卡，有些细节还是不太行，就换成 VirtualBox 了，使用体验非常好