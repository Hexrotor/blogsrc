---
title: 视频小技巧
date: 2022-12-20 20:19:55
tags:
---

最近不得不制作一些视频，所以趁此机会写一些视频方面的花招

本文中使用的视频编辑器为Vegas

## 帧数处理

Vegas渲染时可以调整帧数和比特率，对于我的视频，这两样不需要太高。

在渲染时，建议采用720P、12fps

![渲染](https://test1.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/xrrj.jpg)

为何要将帧数调低？因为帧数低更容易去掉视频中的不和谐感

另外，在生成低帧数视频后，可以使用各种工具插帧，生成高帧数视频

比如ffmpeg自带的光流算法插帧，但此方式不适合现实事物等画面高速移动的视频

```Shell
ffmpeg -i in.mp4 -filter_complex "minterpolate='fps=30'" out.mp4
```

现在有很多AI插帧，效果都是比较好的

## 模拟对焦

早些时候的手机，录视频时会时不时出现模糊，那是在对焦。我们可以模拟对焦，并利用模糊来去除视频中的不和谐感。

要注意的是，既然决定使用这种方式，那整个视频中必须出现多次对焦画面，不然那一次对焦会显得很突兀。

Vegas中的散焦特效：

![散焦](https://test1.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/fx_sj.jpg)

为画面加上这个FX，就能模拟对焦了。配置中有时钟样式的按钮，点击就能按时间轴来配置各个时候的焦点参数。

![config](https://test1.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/fx_sj_config.jpg)

早期手机的对焦方式是被动对焦，也就是根据镜头的成像来判断是否对准，所以在对焦时，往往会越过焦点后才能确认到焦点。

模拟的时候也要模拟这个行为：

![](https://test1.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/fx_sj_wave.jpg)

如上图，在配置页面的右下脚选择曲线就能这样配置了。模拟对焦并不存在空间的概念，所以数值只有正没有负。

## 平移和裁剪

![](https://test1.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/pkyi_cdjm.jpg)

如图为Vegas的平移裁剪功能，是非常简陋的，但配合散焦特效也能消除不和谐感。其中的蒙板功能在平时编辑时也是非常有用的，可以去掉素材中的某个部分，或只显示某个部分。

暂时只写这些。最近事情多，但天天宅家里到现在还没阳。我好怕过年的时候阳了，那得难受死。

## Virtual Camera

更新于2022/12/22

有时我们需要虚拟摄像头，将视频文件推流出去。

要在一些会议类软件使用虚拟摄像头，可以使用OBS，具体使用方法网上有很详细的教程。

要在Chrome中将摄像头内容替换为视频文件，只需要添加启动参数：

```Config
chrome.exe --use-fake-device-for-media-stream --use-file-for-fake-video-capture="path2VideoFile"
```

此处的视频文件不能使用常见的mp4文件，而要使用yuv420p编码形式的视频文件。我们可以使用ffmpeg将普通mp4视频转为该类文件：

```Shell
$ ffmpeg -i inputFile.mp4 -an -pix_fmt yuv420p outputFile.y4m
```

视频将会循环推流，如何消除视频重新播放时的不和谐感呢？

首先录制视频时，内容要减少移动，这样会比较容易实现拼接，且对倒放法比较友好，下面介绍一下倒放法

倒放法，也就是将视频倒着放。在Vegas中，可以一键将视频倒放：

![反转](https://test1.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/fjvr.jpg)

右键素材，选择反转，素材就变成倒放了。

![反转](https://test1.jsdelivr.net/gh/hexrotor/hexrotor.github.io/images/post_imgs/fjvr_1.jpg)

像上图这样，左侧正放，右侧倒放，中间交叉连接，视频就能比较自然地拼在一起，而且连接后的视频，头尾是一致的，重新播放的时候大大降低不和谐感

就写这些。最近每天只能待家里，感觉快疯了，唉


