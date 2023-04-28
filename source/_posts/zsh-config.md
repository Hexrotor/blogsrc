---
title: zsh 配置
date: 2023-04-28 16:25:36
tags: [Linux, 操作系统, 技巧]
categories: [技术]
excerpt: 久闻zsh大名，但我半个月前才开始用，本文简单记录一下配置过程，算是一种备份？
thumbnail: "https://ohmyz.sh/img/themes/nebirhos.jpg"
---

久闻 zsh 大名，但我半个月前才开始用，本文简单记录一下配置过程，算是一种备份？

### oh-my-zsh

[oh-my-zsh](https://ohmyz.sh/) 是一个 zsh 配置管理器。有了它，配置 zsh ，安装插件、主题等等都不是难事。

安装 oh-my-zsh :

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

执行后会提示配置，照着它的提示选择就行

### 插件安装

oh-my-zsh 自带很多插件，但是需要在 `~/.zshrc` 的 plugins 中手动加入来选择要使用的插件

配置示例：

```
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)
```
每次修改完配置后，都需要执行 `source ~/.zshrc` 来更新配置，或者重新打开 zsh 终端

#### 自动补全 - zsh-autosuggestions

需要另安装插件 zsh-autosuggestions

```shell
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
```

#### 语法高亮 - zsh-syntax-highlighting

```shell
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
```

#### 交互式 cd - zsh-interactive-cd

作用是 `cd` 的时候自动列出文件夹，按 `TAB` 可以进行选择补全

需要安装 fzf ：`sudo apt install fzf -y`

修改 `~/.zshrc`

```
plugins=(
	...
	zsh-interactive-cd
)
```

#### thefuck - 命令纠错

按 `ESC` 键两次就能快速纠错上一次执行的命令

安装：`sudo apt install thefuck -y`

`plugins=(... thefuck)`

注意，该插件调用方式`ESC`-`ESC`和 sudo 插件冲突

#### sudo - 快速sudo

按 `ESC` 键两次就能快速将上一次执行的命令前加上 `sudo`

`plugins=(... sudo)`

注意，该插件调用方式 `ESC`-`ESC` 和 thefuck 插件冲突
