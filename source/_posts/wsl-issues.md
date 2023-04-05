---
title: WSL疑难杂症记录
date: 2023-04-05 17:53:52
tags:
---

# WSL疑难杂症

把总结写在前面：WSL真的依托答辩，新手最好不要用，能折腾死

WSL2的网络配置是雷区，非大佬者闲得没事千万不要乱调，否则搞坏了就等着重装吧

我的主系统是Windows 11，WSL是Ubuntu

### wslhost.exe 调用 mstsc.exe 崩溃导致屏幕闪烁

解决方法写在最前面：

win11系统直接 `wsl --update` 升级到最新版wsl就行了

之前用winhex看文件的时候发现看着看着winhex的界面就开始闪烁了，一秒闪一下。打开任务管理器，发现任务管理器界面也开始闪了，除了有点费眼睛之外倒是没影响其他软件使用。

当时没有找到原因，直到今天闲着没事看任务管理器，突然看见 `mstsc.exe` (远程桌面连接) 这个进程出现了，这个进程一般是用户手动打开才会出现的，我寻思不会是有人在爆破 我的远程桌面吧，难道是中毒了？因为之前有需求用flash，我就在gitlab上找了个纯净版的flash安装了，不会真有病毒吧。

随后我看了下进程关系，发现居然是 `wslhost.exe` 在不断启动 `mstsc.exe` ，且mstsc的PID在不断变化，说明进程刚启动又退出了。随后搜索发现有微软官方仓库里有这个[issue](https://github.com/microsoft/wslg/issues/676)，同款问题一模一样。

### WSL安装32位运行库

某天在WSL里运行某32位单文件程序，居然提示我No such file or dict，我思来想去哪里出了问题，但迫于时间关系最后还是尝试用Vm开虚拟机，结果可以运行该程序。

既然这样那肯定就是依赖有问题，不会吧WSL不自带32位依赖吗，有点迷

Ubuntu解决方法：

```bash
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install libc6:i386 libncurses5:i386 libstdc++6:i386
sudo apt install gcc-multilib
```

其他系统的解决方法网上应该能搜到。