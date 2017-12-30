---
title: Android SVG初探
tags:
  - android
id: 118
categories:
  - android
date: 2015-10-19 16:10:21
---

##### 1\. 何为SVG？

##### 1.1 SVG基本特点

SVG（全称：可缩放矢量图形 Scalable Vector Graphics），是用于描述矢量图形的一种图形格式。SVG是W3C制定的，是一个W3C开放标准（该标准是2001年由太阳微系统、Adobe、苹果公司、IBM 以及柯达联合制定的）。
它主要有有以下几种特征：

*   SVG 用来定义用于网络的基于矢量的图形
*   SVG 使用 XML 格式定义图形
*   SVG 图像在放大或改变尺寸的情况下其图形质量不会有所损失
*   SVG 是万维网联盟的标准
*   SVG 与诸如 DOM 和 XSL 之类的 W3C 标准是一个整体

与其他图像格式相比，使用 SVG 的优势在于：

*   SVG 可被非常多的工具读取和修改（比如记事本）
*   SVG 与 JPEG 和 GIF 图像比起来，尺寸更小，且可压缩性更强。
*   SVG 是可伸缩的
*   SVG 图像可在任何的分辨率下被高质量地打印
*   SVG 可在图像质量不下降的情况下被放大
*   SVG 图像中的文本是可选的，同时也是可搜索的（很适合制作地图）
*   SVG 可以与 Java 技术一起运行
*   SVG 是开放的标准
*   SVG 文件是纯粹的 XML

> 现在几乎所有的浏览器都支持SVG浏览，除了少部分低版本的IE需要安装Adobe SVG Viewer。
>   矢量显示对象，基本矢量显示对象包括矩形、圆、椭圆、多边形、直线、任意曲线等嵌入式外部图像，包括PNG、JPEG、SVG、文字对象等

##### 1.2 SVG基本语法规则

关于SVG的基本语法规则和教程可以查看：[SVG教程](http://www.w3school.com.cn/svg/)

##### 2\. Android中为什么要使用SVG？

前面我们提到SVG的一些特性，这些特性能够很好的在Android中进行使用：

*   图片的完美适配。SVG 图像在放大或改变尺寸的情况下其图形质量不会有所损失。这样我们大大减少了适配所需要的多种分辨率图片，而且能够让图片完美适配多种分辨率，减少了APK包大小并提升了用户体验。
*   尺寸的减小。SVG 是使用XML文件描述的，这种文本格式的图片尺寸很小，而且便于修改。
*   设计上的轻便。在设计方面我们可以任意修改SVG图片的颜色，这对于某些情况下需要同一张图像但不同的颜色图片是非常方便的，只需要修改fill颜色就可以了。比如，单击下图片的不同状态、按钮的背景图片等等。
例如下面的SVG，可以很方便的修改大小、颜色：

<pre>
`
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
    <path d="M22 5.7l-4.6-3.9-1.3 1.5 4.6 3.9L22 5.7zM7.9 3.4L6.6 1.9 2 5.7l1.3 1.5 4.6-3.8zM12.5 8H11v6l4.7 2.9.8-1.2-4-2.4V8zM12 4c-5 0-9 4-9 9s4 9 9 9 9-4 9-9-4-9-9-9zm0 16c-3.9 0-7-3.1-7-7s3.1-7 7-7 7 3.1 7 7-3.1 7-7 7z" fill="#E91E63"/>
</svg>
`
</pre>

*   复杂动画的制作。在某些复杂动画，特别是一些不规则的图片动画的制作，如果使用普通的PNG图片实现是特别困难的。比如这种动画

    ![enter image description here](http://www.jcodecraeer.com/uploads/20151009/1444371714145232.gif)
比如金币图片的的一些路径闪光，而使用SVG相对就比较简单了，因为本身这些图片就是使用[PATH路径](http://www.w3school.com.cn/svg/svg_path.asp)来描述的，我们在代码中直接使用SVG文件在中的PATH路径      值就可构建出复杂的动画功能。</p>

<p>在最新的[android studio版本1.4](http://developer.android.com/intl/zh-cn/sdk/index.html)中是直接[支持编辑](http://android-developers.blogspot.com/2015/09/android-studio-14.html)SVG图片的

[![studio_vector_studio.png](http://www.akiyamayzw.com/wp-content/uploads/2015/10/studio_vector_studio.png-300x242.png)](http://www.akiyamayzw.com/wp-content/uploads/2015/10/studio_vector_studio.png.png)
这样我们将更加方便的使用SVG图片。

##### 3.怎么获取SVG图片

我们可以使用专业的设计工具设计SVG图片，例如VS、AI、CorelDRAW，也可以使用Android Studio1.4自带的SVG编辑器工具。
在个人的项目中，特别是对于没有设计功底的程序员来说，设计一个精美的APP是很困难的，我们需要遵循[android设计原则](https://www.google.com/design/spec/material-design/introduction.html)来设计一个APP。所幸的是google发布了大量开源的ICON图片来满足我们的基本设计需求,该项目的[github地址](https://github.com/google/material-design-icons)
在文件夹下面我们能找到对应PNG图片的SVG格式

[![2015-10-19 15:03:14的屏幕截图](http://www.akiyamayzw.com/wp-content/uploads/2015/10/2015-10-19-150314的屏幕截图-300x211.png)](http://www.akiyamayzw.com/wp-content/uploads/2015/10/2015-10-19-150314的屏幕截图.png)
这些图片能够很好的应用到我们的个人项目下面。

##### 4\. android中使用SVG

可惜的是Android官方目前（根据多方消息，估计不久会适配）对SVG格式的支持只是在Android 5.0 (LOLLIPOP) 以上,如果低版本需要使用SVG格式的图片，你需要使用第三方兼容包，目前比较流行的兼容库主要有以下几个：

*   [SVG-Android](https://github.com/japgolly/svg-android)
*   [Vector-Compat](https://github.com/wnafee/vector-compat)
*   [MrVector](https://github.com/telly/MrVector)

经过测试Vector-Compat和MrVector存在一些BUG，这些BUG直接导致了对很多SVG文件解析错误，特别是对一些浮点型的PATH路径解析存在这许多错误，而且在使用Vector的时候需要复制一些属性，冗余性很高，使用起来不是很方便。所以最终使用SVG-Android，但是它也存在一些缺陷：

*   该项目已经停止开发维护，后续不做升级，对动画支持很弱，以后也不会支持。
*   在为ImageView设置SVG图片的时候，必须将ImageView的硬件加速关闭，否则图片不能显示。
*   使用SAX方式对SVG格式进行解析，相比较与PNG图片占用CPU可能更高，但是内存占用更低.

所以在使用这些库的时候需要做一个取舍和比较，期待官方库的支持（据说官方V7包23已经支持，但是我目前还未找到[vectordrawable](https://android.googlesource.com/platform/frameworks/support/+/master/v7/vectordrawable/)
如果谁看到了请告知，谢谢。）

基本使用方法。
在项目的对应module下引用:

    compile 'com.github.japgolly.android:svg-android:2.0.6'

在目录下新建res/raw文件夹或者assets文件夹，选一个即可，将svg图片拷贝到对应文件夹下面，例如：
[![2015-10-19 15:42:38的屏幕截图](http://www.akiyamayzw.com/wp-content/uploads/2015/10/2015-10-19-154238的屏幕截图-300x250.png)](http://www.akiyamayzw.com/wp-content/uploads/2015/10/2015-10-19-154238的屏幕截图.png)

在布局文件中使用控件,例如ImageView:

<pre>
`

<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:orientation="horizontal"
    android:layout_width="match_parent"
    android:gravity="center"
    android:clickable="true"
    android:layout_height="50dip">

    <ImageView
        android:id="@+id/title_iv"
        android:layout_width="24dip"
        android:layout_height="24dip"
        android:layout_margin="10dip"/>

    <TextView
        android:id="@+id/title_tv"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_weight="1"
        android:textColor="@color/black"
        android:text="提醒"
        android:textSize="16sp"/>

</LinearLayout>

</pre>

`
在Activity中直接使用：

<pre>
`
ImageView imageView = (ImageView) findViewById(R.id.title_tv);
SVG svg = new SVGBuilder().readFromResource(AppContext.getInstance().getResources(), R.raw.ic_access_alarms_24px).build();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
            imageView.setLayerType(View.LAYER_TYPE_SOFTWARE, null);
        }
imageView.setImageDrawable(svg.getDrawable());
</pre>

`
这样就可以直接读出图片，图片的颜色可以到对应的文件下面任意修改。具体可见我的项目[MyKeep](https://github.com/daliyan/MyKeep)

##### 5.总结

SVG图片使用是Android的一大趋势，在Android Studio1.4支持对SVG图片的编辑让开发者能够更加方便的使用SVG来设计,因此掌握SVG的使用是非常有用的。