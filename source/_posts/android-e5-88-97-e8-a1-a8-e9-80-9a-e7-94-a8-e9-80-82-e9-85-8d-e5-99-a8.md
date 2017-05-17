---
title: android 列表通用适配器
tags:
  - Adapter适配器
  - android
id: 18
categories:
  - android
date: 2015-04-04 08:35:58
---

**一.需求分析**

在平常的android开发过程中，ListView、GridView适配的编写是一件很麻烦而且很重复的事情，每次都需要考虑性能的优化、item的编写、获取网络图片时候信息的错乱等问题，因此考虑写实现一个通用的适配器，主要考虑的功能：

（1）自适应item布局文件，每次使用的时候只需要传入布局的id编号即可；

（2）实现List列表的性能调优，能够复用item，使列表的加载速度大大提升；

（3）能够直接从网络上获取图片加载列表，这里考虑只需要传入图片的url地址，即可以实现图片的加载和图片的缓存；

（4）调用方便；

这是我实现通用适配器的github地址：[猛击这里](https://github.com/daliyan/GeneraAdapter)

![](http://img.blog.csdn.net/20141027101950906?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvSVRiYWlsZWk=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

其中GeneraAdapter是通用适配器的library，直接在Eclipse中添加引用即可（不知道添加引用的请自行百度），sample是调用这个库文件的例子。

**二.调用方法**

** ** 调用方法极其简单，跟平常使用的Adapter使用方法类似，主要有以下几步：

（1）新建item布局文件，这个跟你平常新建布局没有区别；

（2）新建item类，这里作为为通用适配器的item项，一个irem类就是一条数据

（3）定义一个List&lt;item&gt;,作为通用适配器的数据。

（4）new一个新的GeneraViewAdapter&lt;Item&gt;，它会自动继承convert方法

以上详情可以参看sample类**[点击打开链接](https://github.com/daliyan/GeneraAdapter/blob/master/Sample/src/com/example/sample/MainActivity.java)**

最终例子的效果是这样的：

![](http://img.blog.csdn.net/20141027103744921?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvSVRiYWlsZWk=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

以上只需要5-6行代码即可是一个这样的功能。

**GitHub地址:[猛击这里](https://github.com/daliyan/GeneraAdapter)**