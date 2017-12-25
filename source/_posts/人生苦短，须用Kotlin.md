---
title: 人生苦短，须用Kotlin
date: 2017-05-19 21:34:00
categories:
- 杂谈
- Android
tags:
- 杂谈
- Android
comments: true
---
## 人生苦短，须用Kotlin


 就在昨天谷歌2017 IO大会宣布将Kotlin列为Android开发的一级语言，Android Studio 3.0也将在不使用插件的情况下自动兼容Kotlin语言。这也就意味着谷歌在专利流氓“甲骨文”公司的逼迫下有慢慢放弃使用Java的想法，当然，短期内想谷歌完全摒弃Java那是不可能，因为当前Android所有的开发生态基本都建立在Java语言之上，但是，某种意义来说这是谷歌对后面Android开发的一种态度或者一种趋势。而且Kotlin本身是一个非常优秀的语言，其简洁的语法，无缝对接Java都是非常吸引人的。
 
 ### 什么是Kotlin?
 
 Kotlin是一种在Java虚拟机上执行的静态类型语言，它是由JetBrains开发团队创造的，目前它能够支持在服务端、JavaScript、Android上使用，今天我们主要介绍它在Android上面的一些特性。
 
 Kotlin无缝对接Android开发
 
 + 兼容性：Kotlin能够运行在JDK6以上，意味它能够运行在更老的设备上面
 + 性  能：由于和Java具有相似的字节码结构，所以Kotlin语言和Java运行一样快，而且由于对内联函数和lambdas 表达式的支持，甚至有些时候比Java运行还要快
 + 大 小：Kotlin的Runtime lib非常小，小于100K。所以运行出来的APK文件和原生的差不多大
 + 编 译：对增量编译支持非常好，它和Java的增量编译一样快
 + 易用性：学习非常简单，和Java的语法很相近，但是写起来又更爽利。借用一些插件能够自动让Java和Kotlin语言自由装换，这也意味着当前项目的代码能够无缝切换到Kotlin了。
 

它还有一些额外的优点，比如空安全（如果对象可以为null，必须显式声明），函数式编写等等。举个和简单的例子来证明Kotlin的易用和简洁性：

``` kotlin
data class Student(
        var id: Long,
        var name: String,
        var sex: String
)
```
这就已经新建了一个Student类，他会自动帮你建立好对各个属性的索引和基本方法.

在Android中，使用Kotlin的扩展，能够提供一些额外的功能。比如你对一个view进行赋值，它是这样实现的：

```Kotlin

activity.hello_tv.setText("hello world")

```
其中hello_tv就是你在xml布局中对应的id。

### 怎么在Android Studio中使用？

如果你使用的是Android Studio 3.0，你可以直接使用。如果使用的是Android Studio 3.0以下，可以通过引入插件和依赖包的形式。

其它版本可以通过插件市场下载安装kotlin插件

![image](/images/kotlin_plugs.png)

安装成功后重启Android Studio。

这个时候按照正常的新建项目逻辑新建一个Android项目，自动生成MainActivity的java文件。在这个类中通过**help - find action -输入 Covert java file to kotlin file**点击，就可以发现当前的文件自动转换成kotlin类了。

![image](/images/kotlin_convert.png)


 安装完插件后其实开发环境已经基本搭建成功。我们根据右上角的提示，增加对应的build配置信息
 
![image](/images/kotlin-not-configured.png)
 
 
 在当前app的build文件中自动添加了
 
 ```
apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
...
dependencies {
    ...
    compile "org.jetbrains.kotlin:kotlin-stdlib-jre7:$kotlin_version"
}

 ```
 
 在当前项目的build 文件中自动添加了
 
 ```
 buildscript {
    ext.kotlin_version = '1.1.2-4'
   ...
    dependencies {
        ...
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        ...
     
    }
}
 ```
 
如果你需要扩展功能，需要在app下面引入扩展插件功能

```
apply plugin: 'kotlin-android-extensions'

```

引入插件功能后意味着你能够使用扩展功能，具体有那些功能，可以参考[官方文档](http://kotlinlang.org/docs/tutorials/android-plugin.html)。

接下来你就可以开心使用Android Studio撸代码啦。

### 怎么学习Kotlin?

由于Kotlin的语法和Java及其相像的，所以如果你有Java基础，学习起来应该是非常容易的。而且Kotlin也有一些开源社区提供的[中文同步网站](https://www.kotlincn.net/)，如果你英文不错建议直接看[英文原版本文档](https://kotlinlang.org/docs/reference/basic-syntax.html)，总的来说上手还是非常容易的。


### 总结

作为一名程序员，时刻保持学习新的东西和动力和热情是非常重要的品质，谷歌有推广Android Studio的成功经验，而且无缝对接Java语言的巨大优势，会让很多Android开发人员切换更加容易，所以有理由相信Kotlin语言可能是Android 的未来。