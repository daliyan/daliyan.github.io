---
title: （android文档原创翻译）管理Activity的生命周期
tags:
  - android
  - 生命周期
id: 7
categories:
  - 文章翻译
date: 2015-04-03 18:40:38
---

([英文原文链接地址](http://developer.android.com/training/basics/activity-lifecycle/starting.html))

### **1.启动你的Activity**

不同其它的应用程序通过main()方法来启动，android系统是按照一定的顺序通过调用其生命周期（lifecycle）的回调方法来启动或者结束一个[activity](http://developer.android.com/reference/android/app/Activity.html)。本节简要介绍了Activty的最为重要的生命周期，并且示意了怎样处理一个Activity的生命周期.

#### **理解什么叫做生命周期的callbacks**

在Activity的生命周期中，android系统会按顺序调用一系列类似于金字塔形排列的生命周期方法，即activity生命周期的每个阶段都属于金字塔的某一层.当系统创建一个Activity的时候，生命周期中的每一个方法的调用都会让Activity让生命周期金字塔的状态发生跳转（改变），而处于金字塔顶端的状态即为activity当前生命周期的可见和可交互的阶段。
当用户需要离开Activity的时候，系统会调用其它的一些方法让Activity的生命周期跳转到其它方法中.在一些cases中，Activity仅会部分的沿着金字塔进行跳转和等待（例如当用户切换到其它的APP时候）.如图

￼![](http://img.blog.csdn.net/20141113104754843?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvSVRiYWlsZWk=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

<span style="color: #999999;">_图1.为活动周期的简化图示，表示activity的生命周期金字塔，显示了activity的生命周期之间的变化，以及生命周期的各个状态之间的转换_ </span>

根据你Activity的复杂性，你不需要implement生命周期中的所有方法，但是你要明确的知道每一个生命周期的意义,确保应用是以用户期望的方式运行，为了实现确保你的应用能够满足用户的期望，你需要注意但不限于以下几点：

*   当用户接到一个电话或者切换到其它的应用，应用不会被crash掉.当用户没有使用一些资源的时候，记得释放掉它们
*   当离开你的应用后再返回，你的应用不应该丢失掉前面的状态信息
*   当应用发生横竖屏切换的时候，确保应用不被crash掉并且不要丢失前面的状态信息
在随后的学习的课程中，有几种状态用于表示图1中不同状态之间的转换，但是只有三种状态时处于静态的，也就是说activity能够长时间的存活在这三个状态中:
**        Resumed**   在这个生命周期中，Activity是处于前台，并且用户能够与之交互（有时我们也叫做"运行"状态）
**        paused        **在这个状态中，Activity被其它的Activity部分覆盖，其它处于前台状态Activity是半透明或者不会全部遮盖，被覆盖的activity是不能接受用户的输入也不会执行任何代码.
**        Stopped**     在这个状态中，Activity完全被隐藏而且用户是不可见的,Activity是被认为是处于后台的，当进入stop状态时，这个Activity的所有状态信息如成员变量会被保留，但是不能够执行任何的代码
至于其它的状态（Creaded and Stated）应用的生命周期会快速的进行转换，如系统调用[onCreate()](http://developer.android.com/reference/android/app/Activity.html#onCreate%28android.os.Bundle%29)后，它会立即调用[onStart()](http://developer.android.com/reference/android/app/Activity.html#onStart%28%29),然后快速的跳转到[onResume()](http://developer.android.com/reference/android/app/Activity.html#onResume%28%29) 以上是关于Activity的生命周期的基本知识，接下来我们将学习到关于Activity的特殊的行为。

#### <a name="t1"></a>**指定你APP的启动Activity**

当用户在home屏幕中点击你应用的图标时，系统会调用你声明作为程序入口的"launcher activity""的onCreate方法，你有几种方法可以指定你APP的入口。
你可以在AndroidManifest.xml中指定APP的main activity，[AndroidManifest.xml](http://developer.android.com/guide/topics/manifest/manifest-intro.html)是在你项目的根目录下面.
这个[main](http://developer.android.com/reference/android/content/Intent.html#ACTION_MAIN) activity必须被显式的在mainfest 下面的&lt;intent-filter&gt;中声明，在[&lt;intent-filter&gt;中](http://developer.android.com/guide/topics/manifest/intent-filter-element.html)包括了MAIN action 和[LAUNCHER ](http://developer.android.com/reference/android/content/Intent.html#CATEGORY_LAUNCHER)category.例如：
<pre class="lang:xhtml decode:true">&lt;activity android:name=".MainActivity" android:label="@string/app_name"&gt;
&lt;intent-filter&gt;
&lt;action android:name="android.intent.action.MAIN" /&gt;
&lt;category android:name="android.intent.category.LAUNCHER" /&gt;
&lt;/intent-filter&gt;
&lt;/activity&gt;</pre>
<span style="color: #999999;"> _提示：当你使用android SDK创建一个android project的时，系统会在项目文件夹下面创建一个默认的启动activity_</span>

如果你没有显式的声明MAIN Action或者LAUNCHER catgory的时候，你的APP的icon将不会出现在Home屏幕（也就是我们手机的桌面上）列表中.

#### **创建一个新的实例**

绝大多数的APP中都包含了多个activity，他允许用户在多个Activity中进行切换，当用户点击APP的icon时一个mian activity将会被创建，系统会调用onCreate()方法来创建一个activity的实例。
你必须实现onCreate方法来开始一个activity的逻辑和这个activity的生命周期，例如，你在onCreate中定义用户的界面并实例化一些变量.
例如，你在下面的例子的onCreate的方法中显式的声明了用户的用户接口（定义在XML文件），定义了成员变量,并且配置了一些UI配置。
<pre class="width:800 inline-margin:3 scroll:true lang:java decode:true">    TextView mTextView; // Member variable for text view in the layout

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Set the user interface layout for this Activity
        // The layout file is defined in the project res/layout/main_activity.xml file
        setContentView(R.layout.main_activity);

        // Initialize member TextView so we can manipulate it later
        mTextView = (TextView) findViewById(R.id.text_message);

        // Make sure we're running on Honeycomb or higher to use ActionBar APIs
        if (Build.VERSION.SDK_INT &gt;= Build.VERSION_CODES.HONEYCOMB) {
            // For the main activity, make sure the app icon in the action bar
            // does not behave as a button
            ActionBar actionBar = getActionBar();
            actionBar.setHomeButtonEnabled(false);
        }
    }</pre>
一旦onCreat()执行完毕，系统会快速的调用onStart()和onResume()方法，你的Activity不会停留在Created和Stated状态，当系统调用onStart()方法时候activity是变成可见的状态，但是onResume()方法会快速的被调用并处于Resumed状态直到某些事情发生或者改变，例如当电话被呼叫时候，应用被切换到其它的Activty或者屏幕发生横竖排改变时.
在接下来的其它的课程中，你讲学习到当用户从Stoped和Paused状态回到resumed状态的过程中onStart()和onResume()方法非常有用的。
*Note:onCreate()方法中包含了一个savedInstanceState参数,这个问题在后面的[Recreating an Activity](http://developer.android.com/training/basics/activity-lifecycle/recreating.html).课程中进行讨论

![](http://img.blog.csdn.net/20141113105517251?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvSVRiYWlsZWk=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

_**Figure 2**. Another illustration of the activity lifecycle structure with an emphasis on the three main callbacks that the system calls in sequence when creating a new instance of the activity: onCreate(), onStart(), and onResume(). Once this sequence of callbacks complete, the activity reaches the Resumed state where users can interact with the activity until they switch to a different activity._

#### **销毁(Destroy)Activity**

当Activity第一次创建的时候会调用OnCreate()方法，它最终会调用[onDestroy()](http://developer.android.com/reference/android/app/Activity.html#onDestroy%28%29)方法，当onDestroy()方法执行完后系统会将Activity的实例从内存中移除.
大多数的app应用不需要实现onDestroy这个方法，因为Activity的实例引用会随着Activity的销毁而回收，在onPause()和onStop()的状态中而被清除.然而，如果你的Activity中有后台线程或者长时间被引用的资源，那么你必须在onDestroy()中进行清除回收，否则会造成内存泄漏.
<pre class="lang:java decode:true ">   @Override
    public void onDestroy() {
        super.onDestroy();  // Always call the superclass

        // Stop method tracing that the activity started during onCreate()
        android.os.Debug.stopMethodTracing();
    }</pre>
pS:以上链接请自备VPN账号，作为一个android开发的没有VPN账号很多信息只能是二手信息，这里推荐使用（[红杏软件](http://honx.in/i/VGLY_uz5NGNEJw8T)）