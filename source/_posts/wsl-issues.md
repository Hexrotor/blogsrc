---
title: WSL疑难杂症记录
date: 2023-10-09 17:53:52
tags: [Windows, WSL, Linux, TroubleShooting]
categories: [技术]
excerpt: "WSL就是依托答辩"
---

### WSL疑难杂症

把总结写在前面：WSL 真的依托答辩，新手最好不要用，能折腾死

WSL2的网络配置是雷区，非大佬者闲得没事千万不要乱调，否则搞坏了就等着重装吧

我的主系统是 Windows 11，WSL 是 Ubuntu + kali(推荐)

### wslhost.exe 调用 mstsc.exe 崩溃导致屏幕闪烁

解决方法写在最前面：

win11 系统直接 `wsl --update` 升级到最新版 wsl 就行了

之前用 winhex 看文件的时候发现看着看着 winhex 的界面就开始闪烁了，一秒闪一下。打开任务管理器，发现任务管理器界面也开始闪了，除了有点费眼睛之外倒是没影响其他软件使用。

当时没有找到原因，直到今天闲着没事看任务管理器，突然看见 `mstsc.exe` (远程桌面连接) 这个进程出现了，这个进程一般是用户手动打开才会出现的，我寻思不会是有人在爆破我的远程桌面吧，难道是中毒了？因为之前有需求用 flash ，我就在 gitlab 上找了个纯净版的 flash 安装了，不会真有病毒吧。

随后我看了下进程关系，发现居然是 `wslhost.exe` 在启动 `mstsc.exe` ，且 mstsc 的 PID 在不断变化，说明进程刚启动又退出了。随后搜索发现有微软官方仓库里有这个[issue](https://github.com/microsoft/wslg/issues/676)，同款问题一模一样。

### WSL安装32位运行库

某天在 WSL 里运行某 32 位单文件程序，居然提示我 No such file or dict，我思来想去哪里出了问题，但迫于时间关系最后还是尝试用Vm开虚拟机，结果可以运行该程序。

既然这样那肯定就是依赖有问题，不会吧 WSL 不自带 32 位依赖吗，有点迷

Ubuntu 解决方法：

```bash
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install libc6:i386 libncurses5:i386 libstdc++6:i386
sudo apt install gcc-multilib
```

其他系统的解决方法网上应该能搜到。

### WSL 迁移数据

WSL 默认安装在 C 盘，可以通过 export 命令将其导出，然后重新 import 时就能设置安装位置

重要提示：一定要在 unregister 前 export ，否则就会像我一样丢失当前系统里的所有数据 :\)

具体的操作顺序如下：

```PowerShell
wsl --shutdown #关闭运行中的实例
wsl --export Ubuntu D:\wsl_export\export.tar #导出为文件
wsl --unregister Ubuntu #注销系统，相当于删除卸载，数据就没有了
wsl --import Ubuntu D:\wsl\ D:\wsl_export\export.tar --version 2 
#第一个路径是存放WSL虚拟磁盘vhdx文件的目录，相当于安装目录
```

迁移完成后会发现登录用户默认变成 root 了，而最初安装系统的时候应该有提示让设置一个普通用户，所以使用此命令进行将之前的普通用户设置为默认：

```PowerShell
ubuntu config --default-user yourusername
```

### WSL Windows 网络互相访问方案

WSL2使用内部VLAN进行网络连接，而且IP地址是动态的，Windows有时候想要访问WSL要去查IP，很麻烦。

#### Windows 访问 WSL

多数情况下，我们的需求只有 Windows 访问 WSL 。一个可行的思路是获取 WSL 的 IP ，并写入到 Windows 的 hosts 文件中，然后就可以通过域名来访问 WSL。

最简单有效的方法：

- 首先在 Windows 中打开 `C:\Windows\System32\drivers\etc` 这个目录，右键属性，进入安全选项卡，在高级设置中将该文件夹的所有者改为你的账户，然后就可以对这个文件夹的权限进行更改了，我们需要将自己的账户对此文件夹的权限修改为完全控制。
- 进入 WSL 系统，编辑 `~/.bashrc` 文件，该文件是每次运行 bash 时会运行的脚本，具体操作如下：
```Shell
$ vim ~/.bashrc
```

在文件末尾添加如下代码：

```Shell
# Add wsl ip to Windows hosts
line="$(ifconfig eth0 | grep 'inet ' | awk '{print $2}') wsl.ubuntu" # 生成替换内容
sed -i "s/.*wsl.ubuntu.*/$line/g" /mnt/c/Windows/System32/drivers/etc/hosts # 执行替换
```

配置好后保存，重新进一下 WSL ，随后在 PowerShell 中 ping 一下看看：

```PowerShell
PS C:\Users\hexrotor> ping wsl.ubuntu

正在 Ping wsl.ubuntu [172.18.210.143] 具有 32 字节的数据:
来自 172.18.210.143 的回复: 字节=32 时间<1ms TTL=64
```

上面这种方法是依赖 WSL 来写入，我自己最初想的是用 Windows 来写入(废案，仅供参考)：

```cmd
@echo off
for /f "delims=" %%t in ('arp -a ^| findstr  00-11-9d-81-3c-1e') do set list=%%t
echo %list%
for /f "tokens=1 delims= " %%a in ("%list%") do set ip=%%a
echo %ip% WSL>%SystemRoot%\system32\drivers\etc\hosts
```

上面这个脚本依赖 arp 命令和 MAC 地址来获取 WSL 的 IP，其局限性在于，我们难以得知什么时候应该运行此脚本，即运行此脚本时 WSL 是否正在运行且有网络访问。否则 arp 命令将无法获取到 WSL 主机的 IP 信息。而如果不依赖 arp 而使用文件来间接传递 IP 信息，那为何不直接用 WSL 来写入 hosts 呢？

#### WSL 访问 Windows

WSL 其实自带访问 Windows 的域名，那就是当前的计算机名

比如我的计算机名为 HEXROTOR ，那么在 WSL 中直接 ping HEXROTOR，应该是可以通的。但不幸的是，WSL 会自动生成 hosts 文件，将 HEXROTOR 指向 127.0.1.1 ，虽然这个地址也能通往 Windows ，但几乎没有程序会 bind 这个地址，访问这个地址通常没有什么意义

不过好在，这个功能可以关闭。我们需要创建 `/etc/wsl.conf` ，并写入如下信息：

```vim
[network]
generateHosts = false
```

随后我们重启计算机，刚才的配置就生效了，我们可以编辑 `/etc/hosts` ，删除行 `127.0.1.1       HEXROTOR.   HEXROTOR` 。

到这里还没完，理论上还要配置 Windows 防火墙，这个网上教程挺多的。

#### 2024.10.09 WSL 支持配置网络类型

最近不知道哪次更新后开始菜单多了个 WSL Settings，我一看好家伙，很多东西都能调，甚至能自定义 Linux 内核。不过最重要的是它支持了调整网络类型，以前 WSL 2 默认是 Nat 模式，Windows 层 System Proxy 要同步进去还蛮麻烦的，而现在可以直接把网络类型更改为 mirror 模式，

![WSL Settings](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/wsl_settings.png.avif)

如图上图，网络有 4 种模式，选择 mirror 的话 IP 会全部继承 Windows，包括 IPv6。并且直接通过 localhost+端口号就能实现双方互相访问，而且能自动同步 Windows 层配置的 localhost System Proxy，省去了人工步骤。

![WSL Mirror](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/wsl_mirror.jpg.avif)

### WSL 与 Windows PATH 冲突问题

默认情况下，WSL 的 PATH 中会包含 Windows 的 PATH，这可能会导致很多问题，最常见的是运行 npm 时，Windows 和 WSL 都安装了 node，就会出现冲突问题。

同时这样的设置也可能会使 ZSH 用户感到困扰，因为 WSL 访问 Windows 目录有速度衰减，而 ZSH 用户往往会使用类似 AutoSuggestion 插件对输入的命令进行实时检查是否可用，这导致ZSH会疯狂对所有 PATH 进行遍历查找，表现出来就是输命令一卡一卡的，回显很慢。

解决方法：在 `/etc/wsl.conf` 中加入 

```
[interop]
appendWindowsPath=false
```

但这样也许有点一刀切，有些目录是有用的，比如 VSCode 就能实现快速编辑 WSL 中的文件而不用去手动修改目录

以及 Pwntools 的分屏功能，Pwntools 会在使用 gdb.* 系列代码时尝试调用系统中的终端(仅测试过 WSL kali-linux)，如果你的 PATH 中有 Windows Terminal，那么配合 Pwndbg 展现出来的就是原生的分屏调试，非常好用

~/.zshrc 参考：

```vim
# Windows PATH
export WIN_PATH=/mnt/c/WINDOWS/system32:/mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/:/mnt/c/Users/hex/AppData/Local/Microsoft/WindowsApps:"/mnt/d/Microsoft VS Code/bin"

PATH=$PATH:$WIN_PATH
```

### 休眠/睡眠后 WSL 时间出现问题

今天突然发现又有这个问题了，我kernel版本可是已经升到了5.15.90.1，而微软2021年说在5.10.16就修复了这个问题，看来还是没修好

尝试 `sudo hwclock -s` ，并没有作用，随后尝试重启 WSL ，问题解决

搜索相关内容得知除了同步硬件时间，还可以通过 ntp 服务器来同步网络时间

安装ntpdate : `sudo apt install ntpdate`

同步：`sudo ntpdate pool.ntp.org`

### 附录

以下问题与 WSL 无关，与 Linux 软件配置有关

#### vim

设置缩进4，显示行号等

```/etc/vim/vimrc
set tabstop=4 
set softtabstop=4 
set shiftwidth=4 
set noexpandtab 
set nu #行号，看个人需求，会影响多行复制
set autoindent 
set cindent
```

禁用视觉模式(不检测鼠标事件)

打开配置文件：

```
sudo vim /usr/share/vim/vim90/defaults.vim
```

搜索找到 mouse 行，用`"`将其注释

```
"if has('mouse')
"  if &term =~ 'xterm'
"    set mouse=a
"  else
"    set mouse=nvi
"  endif
"endif
```

#### docker

kali 的 docker-compose 版本过低，故从 Github 下载安装

```shell
sudo curl -SL https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose && sudo chmod 755 /usr/local/bin/docker-compose
```

而 Ubuntu 的 docker 本身支持性就有问题，使用如下命令安装：

```shell
curl https://get.docker.com | sh
```