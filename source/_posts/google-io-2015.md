---
title: Google I/O 2015主题演讲(分享)
id: 53
categories:
  - 备忘Google
date: 2015-05-29 10:23:59
tags:
---

作者 [杨赛](http://www.infoq.com/cn/author/%E6%9D%A8%E8%B5%9B) 发布于 2015年5月28日

本报道对Google I/O 2015大会的主题演讲进行概述。两个半小时的主题演讲覆盖了Android M、Android Wear、物联网、深度学习、Google Now、Google Photos、AndroidOne、ChromeBook、Google Maps、开发工具、App推广、在线教育、虚拟现实等话题。

## Android M开发者预览版

相比Android L引入的新设计material design，本次Android M主要在界面之下的层面做功课。据称Android M相比之前的版本修复了上千个bug，[功能相关的改变非常多](http://developer.android.com/preview/index.html)，主题演讲上重点只介绍了六个新增内容：

1.  App权限控制方式变更。以前在L版之前是安装的时候统一请求所有权限，而M版更改为安装时不请求权限，但在App运行中调用功能（比如摄像头）的时候询问用户。
2.  Chrome Custom Tabs。App内访问Web内容时，可以使用Chrome Custom Tabs作为页面显示的载体。
3.  App Links，在一个App中点击链接，直接在另一个App中打开该链接的实现方式。这需要开发者在自己的网站上添加一个叫做statements.json的文件，并且在AndroidManifest中进行声明。
4.  Android Pay支付平台。
5.  指纹识别API。
6.  省电模式Doze，有效减少设备长期闲置不动情况下的电力消耗。

## Android Wear

2015年5月的Android Wear系统更新将带来Always-on App的支持。Always-on即“保持常亮”，这种保持常亮为了减少电能消耗而做成了纯黑白的显示模式。主题演讲上展示了时间显示、地图显示、购物清单显示等场景的保持常亮功能。

目前Android Wear上已经有四千多个应用。

## 物联网（IoT）

Google将IoT的技术实现划分为三个层面：底层的操作系统（OS层），中间的通讯层，上层的用户交互（UX层）。

Google将在OS层面发布新的操作系统，[Project Brillo](https://developers.google.com/brillo/)，该系统基于Android，当然要更加精简了很多。其开发者预览版预计在2015年Q3公布。对于通讯层，Google则计划推出Weave通讯协议，用于在云端、手机端、以及Brillo设备端之间进行通讯。Weave的规范预计将在2015年Q4公布。

## 开发工具

Android Studio 1.3预览版改进了Gradle的准确性和性能，加入了新的CPU和内存的profiler，并且开始支持C/C++。

Web开发方面，Polymer升级到1.0。

测试方面提供了Cloud Test Lab服务，该服务的入口将出现在Google开发者控制台界面里。

Google SDK as Cocoapods：面向iOS平台提供Google服务的SDK。

后端的Firebase，目前已经支持19万个App。Firebase为应用提供计算（Server）、数据、存储等后端服务，其背后依赖于Google Cloud Platform资源。

## 应用推广

Cloud Messaging消息服务现在支持Android、iOS与Chrome平台，并支持按主题订阅的选项。

对于在搜索、YouTube、Google Play等平台上的应用推广，本次Google推出了Universal App Campaigns，可以实现不限定推广平台的推广效果。此外，Google Play开发者控制台新增了Conversion Funnel，可以看到用户的转化路径。另外，Google Play现在允许开发者建立自己的开发者主页了。

## 虚拟现实（VR）

去年发布的VR观看设备[CardBoard](http://www.google.com/get/cardboard/)今年做了一点改进，主要是把尺寸做大了一圈，现在可以支持6寸屏的手机。Google推出了面向学校的Expeditions服务，简单来说就是给一个班的学生人手一台CardBoard戴在头上，老师这边可以控制学生那里看到的画面，可以在一瞬间把一整个班的学生都带到长城或者意大利去郊游。老师们现在可以通过网络注册Expeditions服务。

对于VR素材的摄像，Google公布了[JUMP项目](https://www.google.com/get/cardboard/jump/)。VR素材是带有深度信息的360度全景图像，Google提出的摄像方案是用16个摄像头排列成一圈，再把它们拍摄的图像通过算法合成（这个方案需要在合成阶段使用较多的计算资源，但好处是摄像的成本很低）。

![](http://cdn.infoqstatic.com/statics_s2_20150526-0157/resource/news/2015/05/google-io-2015-keynotes/zh/resources/jump.jpg)

Google正在和GoPro合作制作符合JUMP规范的设备，16个摄像头的光学几何设计将在夏季公布，同时Google也会在YouTube上启动专门的JUMP频道播放这些VR视频。

&nbsp;

&nbsp;

视频链接：[https://events.google.com/io2015/videos](https://events.google.com/io2015/videos "google IO")

                  http://www.ifanr.com/526337