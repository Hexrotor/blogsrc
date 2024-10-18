---
title: 计算机通用技能进阶扫盲
date: 2024-09-04 19:54:17
tags: [Windows, Linux, CTF, Misc]
categories: [技术]
excerpt: "计算机、网络安全通用知识进阶扫盲 (CTF Misc)"
sticky: 999
---

# 简介

最近决定把自己会的计算机操作技巧记录下来，如果文章中有任何错误，请告知我。

**本文章是一个知识集合，我会持续扩充本文章的内容，所以本文章会变得越来越长**

**若读者只想要了解某一方面的知识点，请善用目录和搜索功能！**

**目录功能需要在 PC 端使用**

# 本文章正在施工中

~2024.10.18

# 搜索引擎篇

要想学习一个新事物，首先得搞明白它到底是什么东西，是干什么的。对于计算机使用者，学会使用搜索引擎是非常重要的，与其在群里问东问西，不如自己上网搜索解决。

## 各大搜索引擎简介

1. **Baidu**
  对于国内来说，搜索引擎做得最大的是 [百度 www.baidu.com](https://www.baidu.com/)，但是百度的搜索内容质量一言难尽，懂的都懂，在搜索技术性问题时，不推荐使用百度。此外百度有个功能叫 [百度学术 xueshu.baidu.com](https://xueshu.baidu.com/)，专门用来搜索国内外学术文章的，但是笔者也未曾使用过，其搜索质量未知。

2. **Bing**
   [必应 www.bing.com](https://www.bing.com/) 是微软旗下的一款搜索引擎，可以在国内使用，搜索内容质量中上。需要注意的是必应为了进入中国市场而区分了 [国内版 cn.bing.com](https://cn.bing.com/) 和国际版，在国内访问会被强制跳转到国内版，国内版缺少了一些功能，比如 Copilot AI，此外国内版还有一些广告，但是和百度的一比都不值一提了。即使有这个区分，国内版的搜索质量也非常之高，笔者一直使用必应作为默认搜索引擎。但必应国内版其实出现过多次宕机的情况，还有好几次针对其的 DNS 污染/劫持攻击，不过这种事情都是小概率事件，遇到了可以先用其他的搜索引擎代替。

3. **Google**
   [谷歌 www.google.com](https://www.google.com/) 可以算是搜索引擎的开山鼻祖，是其他各大搜索引擎一座不可逾越的大山。谷歌的搜索质量非常高，并且可以搜索到国内外各种内容 (主要是国外)。缺点是国内无法直接访问，但是作为一个计算机相关专业从业人员，必须学会使用谷歌搜索引擎。

除此之外还有一些搜索引擎就不再列出，本文只是一个引导作用，如果有想深入了解的内容可以自行搜索。

### 文字搜索引擎使用技能

使用搜索引擎是有技巧的，平常直接输入文字只是其最简单的操作，下面介绍一些常用技巧

1. `"双引号"`
   双引号内的字符表示完全匹配，比如搜索时输入 `"CTF"`，则会返回完全匹配该字符的页面。使用场景：有时输入一长串文字，搜索引擎可能会将其分开搜索，若有完全匹配的需求则可以使用

2. `- 排除`
   符号 `-` 的作用是排除存在某关键字的网页，使用方式如：`"CTF" -web`，这样搜出来的页面就没有 `web` 这个关键字

3. `site:example.com` 站内搜索
   表示匹配某个域名下网站的搜索结果

以上技巧以及一些未列出的技巧都可以在 Google 的高级搜索中找到

![高级搜索](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/skills_img/advantage_search.png)

## 图片搜索引擎

上面介绍了文字搜索，现在介绍图片搜索。图片搜索大致可以分为**以图搜图**(找原图，溯源)、**图像识别**(AI识物、地点等)

1. 百度识图
   说到图片搜索，百度还是有一席之地的，使用其搜索国内互联网图片、地点照片等是非常好用的，但是搜索国外的图片、绘画就拉了。使用方式：在电脑端百度主页搜索框右侧有个照片图标，点击即可上传图片。

2. Google 识图
   谷歌作为世界上最大的搜索引擎，其图像匹配功能也非常强大，常用于图片溯源。靠低分辨率图片找原图出处，用残缺的图片或被传播过程中抹除部分的图片搜索到完整图片，谷歌都可以做到。如果一张图连谷歌都搜不到，那基本就很难确定其来源了。

3. 二次元图片搜索
   Q 群中经常有非常多的二次元插画图片，这些图片大多来自国外二次元插画网站 Pixiv，少部分来自 Twitter。由于 Twitter 是开放性社交媒体，上面的图片用谷歌就可以搜到，而 Pixiv 的插画非常多，有些是谷歌搜不到的。遇到这种情况就可以使用以下网站：
   - [二次元画像詳細検索 ascii2d.net](https://ascii2d.net/)
   - [SauceNAO saucenao.com](https://saucenao.com/)
   - [Multi-service image search iqdb.org](https://iqdb.org/)
   - [Anime Scene Search Engine trace.moe](https://trace.moe/) (以图搜番)
    
    这些网站专门用于搜索上述情况的图片，即使是图片被删了，只要在它数据库里，也能搜到图片被删之前的来源。

还有一些网站可能未列出，读者可自行探索。

## Bittorrent 搜索引擎

BT 的时代几乎已经过去，但很多使用场景仍然只有它能胜任，比如日漫 RAW 源发布、字幕组翻译作品发布，几乎所有在线看动漫的网站的资源源头都来自 BT 站。就综合情况来看，BT 几乎是性价比最高的资源发布方式，只需要一串唯一的磁力 Hash 就能进行下载，其去中心化的设计也使其脱离了监管，妥妥的网络小灰色地带。

本节主要介绍搜索引擎，关于 BT 技术不过多深入。

### 中文区

中文区有好几个专门发布翻译前/后动漫源的 BT 站点，这几个站点好像是互相扒资源，又或者是都去扒的最上层某网站的资源，我并不清楚，总之他们的资源列表几乎一致。他们分别是：

- [动漫花园 share.dmhy.org](http://share.dmhy.org/)
  疑似中文区最老那一批 BT 网站，我懒得考据了。

- [MioBT www.miobt.com](https://www.miobt.com/) 等镜像站
  国内 BT 发布网站，他们搞了个联盟，导致有长得几乎一模一样的镜像站，主站进去有个人机校验，所以我平时喜欢用镜像站 [漫猫 comicat.org](https://comicat.org/)

![漫猫](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/skills_img/comicat.png)

不仅是动漫，国内还有很多爱好者喜欢去 PT 站点下载各种资源，尤其是电影原盘爱好者。但是本文章不会介绍任何 PT 站点，下面介绍一些电影相关站点。

- 音范丝
   [音范丝 www.yinfans.me](https://www.yinfans.me/)，一个专门发布电影 BT 资源的站点，有着极其丰富的 BT 资源。

内容待补充

### 国际区

- Nyaa
   [Nyaa.si](https://nyaa.si/) 是国外很出名的动漫 BT 下载站，日漫 RAW 源几乎都能在上面找到，不仅如此还有各国字幕组在上面发布资源。

- YTS
   [YTS.mx](https://yts.mx/) 是国外很出名的电影 BT 下载站点，电影资源非常丰富，各国的电影在上面都能找到。

- 東京図書館
   [东京图书馆 www.tokyotosho.info](https://www.tokyotosho.info/) 正如其名字，是专门收集发布日本媒体资源的 BT 站点。其内容包括日漫 RAW 源、同人志、DLSite 内容、无损音乐和 MV，以及其他很多不可描述的东西，总之它也算个搜索引擎就写上来了 (

## 互联网档案馆 archive.org

[互联网档案馆 archive.org](https://archive.org/) 是一个互联网存档项目，该网站收集了众多互联网产物，其中最多的是它的 [Web 档案馆 web.archive.org](https://web.archive.org/)，俗称 Wayback Machine，该分类收集了数量难以想象的网页快照，这使得它成为了互联网历史溯源的一个重要工具。

如下图，在输入框中输入域名 `mikufans.cn` (B 站早期) 即可搜索到诸多快照点，其中有 2009 年的快照。

![Search](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/skills_img/wayback_searchExample.png)

点开最早时间为 July 14, 2009 20:20:42 的快照，就能看到早期 B 站的网页大致内容。由于当时 B 站不允许抓取 CSS 样式表，所以快照的排版效果不太好，但是依旧能看到视频标题等诸多内容。

![mikufans.cn](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/skills_img/wayback_mikufans.png)

虽然上述例子中快照没有图片，但实际上是会抓取图片的，将域名换成 `bilibili.us` 重新找一个快照：

![bilibili.us](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/skills_img/wayback_bilibili.jpg)

虽然能保存图片快照，但并不是所有图片都可以，有些图片会失效，可能是外链导致的。

# 媒体篇

本篇的“媒体”表示图片、视频、音乐等网络信息传播文件形式，了解了这些媒体文件的本质就能更好地处理相关问题。

摄影常识将在视频小节后介绍。

## 图片

要了解一张图片，可以从这几点入手：像素、分辨率、格式。

### 像素

像素 (Pixel) 是图片的最小单元，一个像素就是一个颜色点，很多个像素拼在一起就组成了图片。一般来说图片的宽高都以像素为单位，比如一台显示器的分辨率是 `1920x1080`，就表示宽 `1920` 像素，高 `1080` 像素，截个全屏图就是 `1920x1080` 像素的图片。

像素的颜色这里只讲 RGB(RED GREEN BLUE)，即红绿蓝三原色，每个像素点都是由这三种颜色的不同比例组成的，一般用一个字节(即数字`0~255`)表示一个三原色的量，比如红色 `255`，绿色 `0`，蓝色 `0`，就是红色，全 `255` 就是白色。

在 Web 页面等开发中经常使用十六进制表示 RGB 颜色，比如红色就是 `#FF0000`。这里额外补充一下像素的透明度实现，即 Alpha 通道，合称 RGBA，用十六进制表示就是 `#39C5BBFF`，`FF` 表示不透明，`00` 表示完全透明。

#### DPI

与像素有关的概念还有 DPI (Dots Per Inch)，即每英寸的像素数，这个概念不太好用文字描述，可以去 B 站搜视频看，主要是代表了计算机图片对应到现实的尺寸应该有多大。DPI 一般在打印时会涉及到，DPI 越高，代表在物理层相同尺寸的一处二维空间上能容纳的像素越多，图片也就越清晰。

一张图片像素不变，DPI 设置得越大，打印出来尺寸就越小。

#### 位深度

位深度这个概念可能大多数人就没有了解过了。最直观的理解就是，图片的位深度越大，它所能显示的色彩范围就越广。

位深度就是指一个像素用了多少位二进制来进行表示，具体的规定如下

![位深度](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/skills_img/color_depth.png)

比如一张没有透明像素的 PNG 图片可以以 24 位深度进行编码保存，若给它增加了透明像素 (增加 Alpha 通道)，它就必须以 32 位深度进行保存。

### 分辨率

当我们日常谈论一张图片文件的分辨率 (Image Resolution)，实际上是在谈论它的尺寸，也就是像素宽高。除此之外这个概念好像没啥好说的了。

### 格式

在我们访问 Web 页面时会看到非常多的图像，假设一个网页上有一个图片，其大小为 `1MB`，那么每当有一个人访问该网页，服务器就会向用户发送 `1MB` 的图片数据。

我举这个例子只是想说，如果存储一张图片是把每个像素点的 RGB 值很直接地存储下来的话，效率实在是太低了。这张 `1MB` 的图片哪怕体积减小 `10%`，累计下来也能节省不少带宽。

读者可以在自己电脑上随便点一张图看下属性，算出其像素数量，再用其位深度除以 `8` 算出每个像素需要多少字节数据来表示，最后乘起来看看结果和其实际体积相比如何。你会发现现在流行的图片格式无一例外体积都一定远远小于你算出来的数字，这说明很多图片格式并不是直接存储像素的，而是经过了算法的优化。

#### JPEG
   
JPEG 格式是一种流行的有损压缩图片格式，其文件后缀为 `.jpg` 或 `.jpeg`。对于大多数图片，JPEG 都能有效地减少其体积，而人的肉眼几乎看不出太多变化 (视压缩程度而定)。

比如我博客的夜间模式首页图，分辨率也不算很小，但是其体积仅为 `33KB`，这就是 JPEG 压缩的强大之处。

![girl_dark](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/girl_dark.jpg)

JPEG 拥有四种压缩模式，本文稍微提一下前两种，分别是 **基于DCT的连续模式 Baseline JPEG** 与 **基于DCT的渐进式模式 Progressive JPEG**。

- 连续模式 Baseline JPEG
   这种模式是基本 JPEG 压缩模式，一次将图像由从左到右、由上到下进行处理，大部分软件保存 JPEG 默认都是这个模式。要直观地体验这个模式，可以在新标签页打开[上面那张图片](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/girl_dark.jpg)，再打开浏览器 F12 找到 Network 网络选项，选择模拟 3G 网络，勾选禁用缓存，然后刷新页面，注意观察图像的渲染状态。
- 渐进式模式 Progressive JPEG
   这种 JPEG 平常见得比较少，它在加载时可以先加载出一个大致的预览图，然后再慢慢变清晰，在网络传输较慢的场景可以为用户提供图像大致预览。

   我以前有个索尼的卡片式相机拍摄的照片就是这种 JPEG，因为相机的储存卡读取速度有限，浏览相册时并不能快速地加载整个图像，而这种渐进式 JPEG 又很适合快速翻阅照片预览的情况，若是使用普通 JPEG，从上到下加载的图片根本就没办法快速翻阅预览。

   [这张图片](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/skills_img/jpeg_prog_example.jpg)是一个渐进式 JPEG，读者可以用上述方法感受一下加载过程。

JPEG 的唯一缺点就是，它是有损压缩，正因如此，它是不支持透明像素 (Alpha 通道) 的，并且压缩程度过大就会产生明显的色块。放大我博客的夜间模式首页图可以发现，实际上它是很模糊的，有很多方形的色块。

#### PNG

PNG 格式是一种常用的无损压缩格式，它能 `100%` 还原出原始图片，同时也能减小文件体积。它支持 32 位深度，也就是支持透明像素，现在大部分带透明像素的图片都是这种格式。

对于细节比较统一的图片，比如随便截个白底黑字图，PNG 的图片体积也能压缩到很小，而如果用 PNG 去保存上面那张博客首页图，那么体积就会比 JPEG 大得多。这是因为 PNG 使用了 ZIP 格式压缩同款算法 Deflate 来压缩像素，这种算法使用字典来实现压缩，它将多次出现的同款长数据加入到字典中，然后就可以用标记来代替原数据了，像白底黑字图片中这种连续的白色像素非常多所以压缩效果比较好，而对于颜色细节都十分丰富的图片，这种算法节省的体积就十分有限了。

#### GIF
   
一种常用的动图格式，和 JPEG 一样都是表情包的专用格式。GIF 实现动图的原理就是让很多张图片进行快速切换，达到一定速度人脑就会认为是连续的动态画面了。值得一提的是，GIF 支持 1 bit Alpha 通道，也就是支持全透明/不透明像素，经过处理的表情包看起来很有意思。

由于 GIF 格式年代久远，其设计时采用了 8 位深度，也就是 256 色，所以其显示效果是很有限的。

#### Webp
   
一种静态/动态图片格式，由谷歌公司开发，使用 VP8 (谷歌的视频编码器，YouTube 专用，后面会介绍) 同款编码器算法对图片进行有损/无损压缩。

正如其名字，它是专门设计用于 Web 浏览器上的网络图像格式，拥有高压缩比，且显示效果优于 JPEG，它可以在 Web 上完全代替所有图片格式。

下面是一张无损动态 Webp 图片，体积仅为 `842KB`，而 GIF 要做到同等效果至少需要 `1.2MB`

![Webp example](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/skills_img/webp_example.webp)

#### AVIF

谷歌公司开发的最新图片格式，基于 AV1 编码器，而 AV1 是由 VP9 改进而来，该格式支持静态/动态图片，并且还支持 HDR 功能。

这是一个非常恐怖的格式，它不仅继承了 Webp 的优点，还比它更强。请看如下动图：

![Avif example](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/skills_img/avif_example.avif)

这是一个仅为 127KB 的有损 avif 动图，但是就画面上来看，它和上面的无损 Webp 完全一致。

该图片由我使用 FFmpeg 默认模式创建，若使用默认模式 (质量 75) 创建同款**有损** Webp 动图，大小约为 700KB，并且画面出现明显色块：

![Webp lossy exmaple](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/skills_img/webp_lossy_example.webp)

若要说该格式有什么缺点，那就是它的兼容性较差、编解码开销较大。

兼容性差是因为还没有推广开，软件适配得少，不过目前 Chrome 已经支持这种格式，并且其为开源，适配应当很容易。

而编解码问题是 AV1 的一大痛点，AV1 为了实现优秀的压缩性能使用了非常复杂的算法，编码过程非常非常慢。解码过程还好，但是与其他格式相比之下也消耗更多客户端计算资源并增加耗电，这对于移动端可能是一个问题。

若想了解该格式的更多内容，可以访问这位哥的博客：[https://blog.hentioe.dev/posts/getting-started-with-avif-format.html](https://blog.hentioe.dev/posts/getting-started-with-avif-format.html)

#### SVG
   
SVG 是一种矢量格式，和传统图片位图不同，它不是保存像素，而是靠代码来实现绘制线条路径等，所以它不像普通图片那样放大就变糊，因为它是实时绘制的。既然它是实时绘制并且依靠代码，那么完全可以将它设计成支持动态变换——事实上也确实如此。SVG 和 Web 离不开关系，它可以和 Web 控件互动，实现精美的网页效果。

下面是我用工具乱画的一个 SVG 矢量图以及网上找的一个动态 SVG 图，在 F12 中打开源文件可以看到路径代码。

![SVG example](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/skills_img/svg_example.svg)

![SVG animation exmaple](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/skills_img/svg_animated_exmaple.svg)

#### BMP
   
BMP 是由微软开发的一种图像格式，广泛应用于 Windows 系统中，支持 8~32 位色，几乎不压缩数据，也因此它的体积往往远大于其他格式。读者可以找张 BMP 图片用我本小节开头说的那个方法计算一下该图所有像素需要的字节表示量，你会发现结果差不多和 BMP 图片体积一样大。

### 图像元数据 - Exif

元数据 (Metadata) 是描述数据的数据，图片元数据是嵌入到图片文件中的一些信息，而 Exif 是相机记录拍摄日志的一种元数据。

Exif 可以记录相机 (手机) 型号、光圈、快门时长、图片尺寸、拍摄日期、焦距、ISO (感光度)、拍摄地 GPS 坐标。

现在的手机照相也会自动记录上述 Exif 信息，所以说千万不要在网络上上传手机拍摄的原图，否则可能直接被人通过 Exif 记录的 GPS 坐标定位。

### 图像处理工具

日常生活中经常会有处理图片、照片的需求，下面会介绍一些常用软件。

#### Adobe PhotoShop

没错就是大名鼎鼎的 PS，图像处理界霸主地位，几乎无可替代，有大神甚至用它画画，用过的都说好。

本文章是一个介绍性文章，不可能把 PS 的用法全部写下来，教程 B 站一抓一大把。本节只介绍一下现在常用的 Adobe 软件破解方式。

##### AdobeGenP

[AdobeGenP](https://github.com/wangzhenjjcn/AdobeGenp) 是目前主流的 Adobe 软件破解方式，它通过 patch Adobe Creative Cloud (相当于 Adobe 的应用商店兼软件包管理器，后简称 Adobe CC) 来实现破解。用户需要先安装 Adobe CC，然后从中安装自己需要的 Adobe 软件比如 PS、Ae、Pr，随后使用 GenP 进行破解即可。

#### ScreenToGif

[ScreenToGif](https://www.screentogif.com/) 是一个开源免费软件，正如其名字，它是专门用于编辑创建 GIF 图片的。它可以直接框选屏幕进行 GIF 录制，也可以编辑已有的 GIF 图片，还可以直接导入多张图片制作成 GIF。

它支持对帧进行处理，包括尺寸调整、帧延时 (每帧停留时间)、重复帧分析 (移除重复帧可以有效减少体积)、打码、文字、进度条、自由绘制

它提供了多种编码器，能够调整 GIF 颜色，控制质量和体积，还能编码保存 Webp、APNG 等动图格式，总的来说是一个不错的软件，下图为用其制作的一张 GIF 动图。

![GIF example](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/skills_img/gif_example.gif)

#### Microsoft Windows Paint (Windows 画图)

不要小看画图，在众多图像软件中它绝对能有一席之地。

首先它是 Windows 自带软件，不需要安装，点击即用；其次它简单易用，就是一个画板功能，同时也有内置图形模板 + 区域选择剪切功能，平时想给图片打个码或者写点文字直接用它方便又快捷。而且它也支持调整图片大小 + 存储格式，Windows 11 上最新的版本还新增了图层功能。有些网站限制图片尺寸和体积，比如 B 站上传封面强制要求图片尺寸大于多少我忘了，以及很常见的图片上传体积限制，都可以直接用它搞定。有些 PNG 图片另存为 JPEG 就可以缩小体积，或者调整图片尺寸也能有效缩小体积。

缺点：不支持透明像素、JPEG 压缩有点过分。带透明像素的 PNG 图片经过它处理后透明像素就没有了，会变成白色；PNG 的图片用它另存为 JPEG 后会有点糊，压缩调得比较狠。

#### Webp tools

此工具为 Linux 命令行工具，可以显示、创建静态 Webp 图片，使用 `sudo apt install webp` 即可安装。

<details>

<summary>其中 `cwebp` 工具用于创建图片</summary>

```plaintext
$ cwebp -longhelp
Usage:
 cwebp [-preset <...>] [options] in_file [-o out_file]

If input size (-s) for an image is not specified, it is
assumed to be a PNG, JPEG, TIFF or WebP file.
Note: Animated PNG and WebP files are not supported.

Options:
  -h / -help ............. short help
  -H / -longhelp ......... long help
  -q <float> ............. quality factor (0:small..100:big), default=75
  -alpha_q <int> ......... transparency-compression quality (0..100),
                           default=100
  -preset <string> ....... preset setting, one of:
                            default, photo, picture,
                            drawing, icon, text
     -preset must come first, as it overwrites other parameters
  -z <int> ............... activates lossless preset with given
                           level in [0:fast, ..., 9:slowest]

  -m <int> ............... compression method (0=fast, 6=slowest), default=4
  -segments <int> ........ number of segments to use (1..4), default=4
  -size <int> ............ target size (in bytes)
  -psnr <float> .......... target PSNR (in dB. typically: 42)

  -s <int> <int> ......... input size (width x height) for YUV
  -sns <int> ............. spatial noise shaping (0:off, 100:max), default=50
  -f <int> ............... filter strength (0=off..100), default=60
  -sharpness <int> ....... filter sharpness (0:most .. 7:least sharp), default=0
  -strong ................ use strong filter instead of simple (default)
  -nostrong .............. use simple filter instead of strong
  -sharp_yuv ............. use sharper (and slower) RGB->YUV conversion
  -partition_limit <int> . limit quality to fit the 512k limit on
                           the first partition (0=no degradation ... 100=full)
  -pass <int> ............ analysis pass number (1..10)
  -qrange <min> <max> .... specifies the permissible quality range
                           (default: 0 100)
  -crop <x> <y> <w> <h> .. crop picture with the given rectangle
  -resize <w> <h> ........ resize picture (*after* any cropping)
  -mt .................... use multi-threading if available
  -low_memory ............ reduce memory usage (slower encoding)
  -map <int> ............. print map of extra info
  -print_psnr ............ prints averaged PSNR distortion
  -print_ssim ............ prints averaged SSIM distortion
  -print_lsim ............ prints local-similarity distortion
  -d <file.pgm> .......... dump the compressed output (PGM file)
  -alpha_method <int> .... transparency-compression method (0..1), default=1
  -alpha_filter <string> . predictive filtering for alpha plane,
                           one of: none, fast (default) or best
  -exact ................. preserve RGB values in transparent area, default=off
  -blend_alpha <hex> ..... blend colors against background color
                           expressed as RGB values written in
                           hexadecimal, e.g. 0xc0e0d0 for red=0xc0
                           green=0xe0 and blue=0xd0
  -noalpha ............... discard any transparency information
  -lossless .............. encode image losslessly, default=off
  -near_lossless <int> ... use near-lossless image preprocessing
                           (0..100=off), default=100
  -hint <string> ......... specify image characteristics hint,
                           one of: photo, picture or graph

  -metadata <string> ..... comma separated list of metadata to
                           copy from the input to the output if present.
                           Valid values: all, none (default), exif, icc, xmp

  -short ................. condense printed message
  -quiet ................. don't print anything
  -version ............... print version number and exit
  -noasm ................. disable all assembly optimizations
  -v ..................... verbose, e.g. print encoding/decoding times
  -progress .............. report encoding progress

Experimental Options:
  -jpeg_like ............. roughly match expected JPEG size
  -af .................... auto-adjust filter strength
  -pre <int> ............. pre-processing filter

Supported input formats:
  WebP, JPEG, PNG, PNM (PGM, PPM, PAM), TIFF
```

</details>

从 PNG 图像创建无损 Webp 图像

```bash
cwebp -lossless -z 9 -m 6 input.png -o output.webp
# Saving file 'modem_pc.png.webp'
# File:      modem_pc.png
# Dimension: 1160 x 747
# Output:    506272 bytes (4.67 bpp)
# Lossless-ARGB compressed size: 506272 bytes
#   * Header size: 5457 bytes, image data size: 500790
#   * Lossless features used: PREDICTION CROSS-COLOR-TRANSFORM SUBTRACT-GREEN
#   * Precision Bits: histogram=5 transform=4 cache=10

# -lossless 无损压缩
# -z 9 最慢编码模式，效果最佳
# -m 6 压缩模式最慢，压缩率最高
# -o 输出文件名
```

创建有损压缩 Webp 文件：

```bash
cwebp -m 6 input.png -o output.webp
# Saving file 'output.webp'
# File:      input.png
# Dimension: 1160 x 747
# Output:    41678 bytes Y-U-V-All-PSNR 42.63 49.93 49.90   44.01 dB
#            (0.38 bpp)
# block count:  intra4:       1481  (43.17%)
#               intra16:      1950  (56.83%)
#               skipped:      1261  (36.75%)
# bytes used:  header:            271  (0.7%)
#              mode-partition:   6037  (14.5%)
#  Residuals bytes  |segment 1|segment 2|segment 3|segment 4|  total
#     macroblocks:  |       2%|       4%|      29%|      65%|    3431
#       quantizer:  |      36 |      34 |      29 |      23 |
#    filter level:  |      11 |       7 |       5 |      15 |
```

命令行工具可能使用不太方便，可以使用在线转化工具。

#### ImageMagick

待填坑

## 视频

在现代数字媒体中，编解码器和视频格式 (封装容器) 扮演着至关重要的角色。编解码器 (Codec) 是用于压缩和解压缩数字视频的技术，它决定了视频究竟是以何种方式进行编码存储，从而决定了其质量和大小。而视频格式则是用于存储视频、音频和其他数据的文件格式，如常见的 `MP4、AVI、MKV` 等。

几十年来，视频编码技术不断迭代，开发人员一直在努力通过更低的[码率](https://blog.csdn.net/qq_22833925/article/details/138151822)实现相同的显示质量。这意味着视频文件变得越来越小，从而节省了在线观看视频所需的带宽。节省带宽的原因显而易见：带宽费用较高，视频网站需要缩减成本，这也是无奈之举。

接下来我将从视频格式开始介绍各种常见的视频封装容器，顺便介绍常见的编解码器。最后再介绍硬解软解以及常用的视频处理工具。

**注意，笔者考证能力有限，以下内容全凭自身经验 + 简单搜索参考，若读者想进一步研究建议自行寻找更专业的资料。**

### 封装容器

普通用户一直存在一个常见的误区，那就是以为视频文件的后缀名就是视频的格式，但事实并不是那样的。

**一个文件的后缀和这个文件究竟是什么内容，并不是对应关系**，因为后缀属于文件名的一部分，而文件名并不属于文件数据。Windows 系统一直靠后缀名来区分文件，而 Linux 系统是靠文件头的数据标识来区分的。我随便找个标准 `.mp4` 文件把后缀改了，那么它就不是 MP4 文件了吗？反过来说我随便找个 PDF 文件改成 `.docx`，难道这个文件就转化成了 Word 文档？显然这是不正确的。

上述例子其实和“视频文件的后缀名不代表视频的格式”想表达的意思有点不一样，对于视频文件来说容器 (格式) 是次要的，编码器才是主要的。分析一个视频文件可以先从后缀简单辨认一下它的类型，然后再进一步查看其编码数据。

容器里包含了视频播放所需要的数据，包括视频流 (Video Stream)、音频流 (Audio Stream)、元数据 (Metadata)，前两个也可以称为XX轨道。当然，有的格式设计时就只支持他们自己那一套编解码方案，这与我上部分所述并不冲突，因为有其他格式可以支持多种编码器。

- MP4

   `.mp4` 几乎是最出名最常用的视频格式了，它属于 [MPEG-4](https://en.wikipedia.org/wiki/MPEG-4) 标准第 14 部分，但实际上是基于苹果的 QuickTime 格式修改而来。它可以封装 `H.264/AVC`、`H.265/HEVC`、`VP8/9` 等编码格式的视频，而音频编码格式通常为 `AAC`、`Opus` 等。

- MKV (Matroska Video File)

   `.mkv` 几乎是一种万能的封装格式，因为它的支持性非常好，并且能够封装多个轨道流。常见的使用场景如多语言配音的电影可以封装多音轨，当然也可以多视频轨。

   说到多语言就不得不提到字幕，目前的字幕实现方式无非两种，一种是内嵌字幕，也就是直接把字幕硬编码进视频中成为画面的一部分；另一种是外挂字幕，播放器自己实现一个字幕叠加显示在画面中，用户还可以自己调整字体大小、显示位置等参数，相比内嵌字幕更加灵活。

   MKV 也支持**封装字幕流**实现外挂字幕，这样字幕组就不再需要内嵌字幕，相比之下省去了一步。

- AVI、RMVB、MOV

   - AVI (Audio Video Interleaved) 
  
      该格式也是一种古老的格式，由微软推出，在 DVD 流行的年代非常常见。AVI 格式几乎不进行压缩，所以其编解码较简单，但也由于其不具备压缩功能，视频文件一般较大，不适合网络传输。再加上当今普遍 1080P 清晰度，生成出来的文件就更大了，因此逐渐淡出历史舞台，可能有一些摄像设备会使用这种格式来保存视频。

      该格式还有一个最大的问题是，它的编码压缩标准不统一，导致播放时经常出现问题。我依稀记得我的索尼数码相机录制格式就是 AVI，但是文件拿到 Windows Media Player 上播放时整个视频会快速一闪而过，除此之外可能还存在无法拖进度条、音画不同步等问题。

   - RMVB

      `.rmvb` 是一种视频文件格式，其中的 VB 指 Variable Bit Rate (可变比特率)。该格式风靡于 BT 流行的早期年代，由于它支持可变码率，所以能够将文件体积减小，在当年网速较慢的时代很多人选择将电影视频压制为该格式来传播。

   - MOV (QuickTime)

      `.mov` 即 QuickTime 格式，由苹果公司开发，剪辑行业应该对这个格式不陌生。它可以提供极佳的画质和音质效果，故常用于电影行业，但由于其体积庞大，在网络上很少使用。
      
      注意，MOV 之所以体积庞大，是因为该格式经常被用于高清晰度剪辑，所有软件导出为 MOV 格式时都会默认将码率设置得几乎无损，并且苹果自己开发的一些编解码器本身就是高码率类型。该格式也支持 H.264，笔者亲自使用 Adobe Media Encoder 测试导出，其码率不可调整，直接就是 1080P 均码 10M，这也印证了本小节开头提到的，编码器才是决定视频质量的主要因素，容器是次要的。

      为了让读者直观感受一下 MOV 格式到底有多大，我使用 Ae 导出了一个 4 分 04 秒的 1080P 视频，使用 Apple Pro Res 422 编码器，视频码率达到了惊人的 132 Mbps，整个文件体积为 3.7 GB。

      ![MOV example](https://testingcf.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/skills_img/mov_example.png)

- FLV (Flash Video)

   一种网络流媒体专用格式，曾经被 B 站、优酷、爱奇艺等众多网站所使用。它之所以叫 Flash Video，是因为它是依赖 Flash (没错就是当年那个 Flash 插件，现在已经退出历史舞台) 的一种格式。
      
   当年 Flash 是一项热门技术，想要在网页上实现精美的播放器控件，Flash 无疑是最好的选择。`.swf` 是 Flash 的动画格式，而若是将视频直接导入 `.swf`，体积又过于庞大，于是 `.flv` 应运而生。但是 Flash 技术被人批判已久，因为它存在非常多的安全漏洞，Adobe 修洞修得不想修了宣布要停止支持 Flash。后来 Google 直接把 Chrome 和 Flash 切割了不让用了，于是各大网站都开始“转型”，FLV 也就逐渐淡出历史舞台。

- 待补充更多格式

### 视频编解码器

#### H.264/AVC

H.264 编码器是 MPEG-4 标准的第 10 部分，称为 `Advanced Video Coding (H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10)`，首发于 2004 年。

在当今这个时代 H.264 已经算是视频编码器的最低标准了，它的压缩率中规中矩，几乎被所有视频硬件设备所支持，正因如此 H.264 可以称为是兼容性最高的一种编码器。20 多年以来，虽然不断有新的编码器问世，但 H.264 仍旧在被大量使用，笔者猜测原因可能有如下几点：

1. 无可挑剔的兼容性
   
   从软件层看，几乎所有浏览器/播放器/应用程序都支持解析 H.264 格式的视频，这很大程度是因为多年前，苹果公司毅然决然抛弃了 Adobe 的 VP6 编码，选择了 H.264，这一标准随着数亿台苹果设备走进了千家万户，其他厂商也随着苹果的脚步跟进，最终 H.264 才有了现在庞大的市场份额；上面也提到，几乎任何设备都支持 H.264 硬解 (什么是硬解软解，后面再介绍)，就算不能硬解，软解的算力也完全够用，因为其解码开销很少。

2. 编码开销相对较少

   H.264 标准制定已有 20 余年，这期间又诞生了各种各样的编码器，压缩效果比 H.264 强。但是强大的压缩效果是更加复杂的压缩算法换来的，这样做的结果就是编码开销普遍比 H.264 高出数倍。H.264 可能 5 分钟编码完一个视频，而其他编码器可能要花费 15 分钟甚至更多时间来编码，并且 CPU/GPU 占用还比 H.264 高出不少，这一点无论是对于个人还是企业都是一个问题，算力始终是有限的，算力不够就只能花钱来凑。

   需要接触视频编码的群体一般是：
   
   1. 视频网站/IM/社交媒体平台：二压用户上传的视频，并为观众提供多种清晰度选择，并且保证最大兼容性。
   
   2. 个人视频制作者：可能以多种媒介发布视频，自己压制视频以获得最佳效果。以前 B 站曾有过 UP 主自己压制到一定码率以下就能防止被二压的操作，可见个人创作者掌握这些技能非常有用。
   
   3. 字幕组：10 年前左右是字幕组的黄金时代，那时候 H.265 还没有开始推广，各路大神把 H.264 研究了个透，只求在合适的清晰度下实现最佳的压制效果。

   4. 摄影设备：如手机，其算力有限，实时编码使用 H.264 开销最低，兼容性最好，并且能提供一定程度的压缩。虽然 H.265 的开销也足以支持实时编码，但 H.265 的兼容性极差，一直到最近几年才慢慢普及。

3. 缺少替代产品

   其实现在市面上能使用的编码器就那么几个，和 H.264 性能接近的，都被它所替代；性能优于 H.264 的，硬件需求又太高。那么和 H.264 解码开销接近但压缩比更高的 H.265 使用率为什么也迟迟没有上去呢？其实主要原因是 H.265 的高昂专利费把自己玩死了，读者可以自行了解。

#### H.265/HEVC

High Efficiency Video Coding (HEVC) 是 H.264/AVC 编解码器的继任者。随着光纤的发明，互联网进入高速时代，视频清晰度由 4K 上限提升到了 8K。

H.264 的最高分辨率为 4K，为了解决这个问题，HEVC 应运而生。HEVC 最高支持的清晰度为 8K，并且它能在与 H.264 画质相同的情况下，将码率减少 50%，如此优越的性能也是更加复杂的算法实现的，所以 HEVC 的编解码开销都大于 H.264，对硬件的要求更高了。

HEVC 有着如此优秀的性能，为什么从 2013 年发布至今也未能达到 H.264 的高度呢？这个问题其实很有意思，让我们来详细探讨一下。想了解更多也可以看这篇文章：[【专访】 Chrome HEVC 硬解背后的字节开源贡献者](https://juejin.cn/post/7158700639030247460)

1. HEVC 专利问题错综复杂

据说 HEVC 的专利费非常高，并且涉及到多方势力，还闹出过许多问题，总之这也是 HEVC 推广度低的一大原因。HEVC 的专利问题非常复杂，我觉得营养价值不大没必要写太多。

2. Chrome 曾迟迟不支持 HEVC 硬解

在 2022 年以前，Chrome 浏览器是不支持 HEVC 硬解的，当时支持 HEVC 硬解的几乎只有苹果的 Safari 浏览器，但是论市场份额，Safari 绝对比不过 Chrome。

Chrome 迟迟不支持硬解导致了无数使用 Chrome 的设备一直无法播放 HEVC 格式的视频，网站为了兼容性肯定是不会考虑将 HEVC 大范围作为 Web 流媒体格式的，在 Web 这块大饼中，HEVC 甚至败给了落后的 H.264。

那么 Chrome 为什么迟迟不支持 HEVC 硬解呢？这个问题其实没有一个确切的结论，我们知道 Chrome 使用的是 Google 开源的浏览器内核 Chromium，而 Google 其实有自己的编码器 VP8/9，并且此前他们一直在 YouTube 上使用这一套编码器。据上面链接文章中所说，Google 在 HEVC 专利问题上没有占据到有利地位，所以可能是想推广自己的 VP9 编码器来“对抗” HEVC，毕竟 VP9 能提供与 HEVC 接近的性能，并且开源免费。

3. 转码成本

一旦视频网站选择了使用 HEVC，就必须从原格式进行迁移，这意味着他们需要对原库存视频进行转码。转码其实不是一件很难的事，但如果涉及到大规模转码，就很麻烦。对于一个视频网站，存储成本、带宽成本、编码 (计算) 成本这三样中，带宽成本占的才是大头，当选择迁移到 HEVC 后，总成本理应会降低。但是在转码这个过程中，时间成本和编码成本将会非常高，如果不是大厂商几乎搞不了，就算是大厂商，也需要进行详细的规划后才能启动。或者就直接不管库存内容，直接从新内容开始启用 HEVC，也不失为一种解决方法。

4. 更优的编解码器已经出现

HEVC 虽然迟迟没有推广开，但是技术发展不可能停下脚步，更优越的编解码器已经出现，他们就是 AV1 与 H.266/VVC。

VVC 到目前为止似乎还没有正式发布，并且由于它的前辈 HEVC 的事迹，各家心里都对它有数。于是 Google 主导了开源项目 [libaom](https://aomedia.googlesource.com/aom/)，即 AV1 编解码器，目的就是要防止 VVC 再一次垄断行业。

现在 av1 已经正式投入使用，B 站目前已经将所有视频强制使用 av1 编码器无法更改，YouTube 也已经将普通视频全部使用 av1 编码，高码率 4/8K 视频依旧使用 VP9。所以现在实际上已经进入了下一个时代，AV1 与 VVC 竞争的时代，而 HEVC 也注定不可能再有更多起色。

#### AV1

**以下内容部分摘自 [Wikipedia](https://zh.wikipedia.org/wiki/AOMedia_Video_1)**

AOMedia Video 1 (AV1) 是一个开放、免专利的影片编码格式，为网络流传输而设计。它由开放媒体联盟 (AOMedia) 开发，目标是取代其前身 VP9。

**本节内容较多，待补充**

## 持续更新中(10.18)