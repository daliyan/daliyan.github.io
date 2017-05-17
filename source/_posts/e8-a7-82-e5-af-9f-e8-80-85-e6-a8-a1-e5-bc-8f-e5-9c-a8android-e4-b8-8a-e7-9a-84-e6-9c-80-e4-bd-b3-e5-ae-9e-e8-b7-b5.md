---
title: 观察者模式在android 上的最佳实践
tags:
  - android
  - 动态更新
  - 最佳实践
  - 观察者模式
id: 40
categories:
  - android
date: 2015-05-09 23:02:36
---

在上一篇文章中介绍了介绍了观察者模式的定义和一些基本概念，观察者模式在 android开发中应用还是非常广泛的，例如android按钮事件的监听、广播等等，在任何类似于新闻-订阅的模式下面都可以使用。从某种意义上面来说android有点像JAVA EE的WEB页面，在都需要提供View层用于进行操作，在多个页面之间传递数据发送通知都是一件很麻烦的事情。

在android中从A页面跳转到B页面，然后B页面进行某些操作后需要通知A页面去刷新数据，我们可以通过startActivityForResult来唤起B页面，然后再B页面结束后在A页面重写onActivityResult来接收返回结果从而来刷新页面。但是如果跳转路径是这样的A-&gt;B-&gt;C-&gt;.....，C或者C以后的页面来刷新A，这个时候如果还是使用这种方法就会非常的棘手。使用这种方法可能会存在以下几个弊端：

1.  **多个路径或者多个事件的传递处理起来会非常困难。**
2.  **数据更新不及时，往往需要用户去等待，降低系统性能和用户体验。**
3.  **代码结构混乱，不易编码和扩展。**

因此考虑使用观察者模式去处理这个问题。

## **一.需求确定**

在APP中我们有一些设置项目，我们希望在设置完了以后，在主页面能够立即响应，例如QQ的清空聊天记录，我们希望设置了以后回到主页面后会自动清理，有些人可能会认为这是一件很简单的事情，认为回到主页面直接读缓存就好了，缓存里面是什么就是什么，课时这种方案存在2个问题：

*   什么时候读取缓存，是每次回到主页面都去刷新吗，这样会太消耗资源，用户体验也不好。
*   不能局部刷新数据。

因此行功能和代码结构上面来看我的需求主要有以下几点：

1.  **能够在某些页面设置完了后直接通知其他监听了这个事件的页面立即刷新，而不需要用户回到某些页面的时候再刷新。**
2.  **能够区分是哪些事件通知的，从而针对不同的事件进行不同的处理。**
3.  **能够动态的扩展事件类型，可以让调用者很快的注册和监听事件。**

## 二.系统设计

从上一篇文章中我们知道一个完整的观察者模式需要这些对象：

1.  **Subject 抽象主题角色：也就是抽象的被观察者对象，里面保存了所有的观察者对象引用列表，提供了注册和反注册的功能。**
2.  **ConcreteSubject具体的主题角色：<span class="comment">将有关状态存入各ConcreteObserver对象</span> <span class="comment">   当它的状态发送改变时，向它的各个观察者发出通知</span> 。**
3.  **Observer 抽象观察者 ：为所有的具体观察者定义一个接口，在得到通知时更新自己。**
4.  **ConcreteObserver 具体观察者：<span class="comment">维护一个指向ConcreteObserver对象的引用</span> ，<span class="comment">存储有关状态，这些状态应与目标的状态保持一致，</span><span class="comment">实现Observer的更新接口是自身状态与目标的状态保持一致</span>**

![](http://www.yesky.com/20020603/observer.gif)

针对在android我们需要设计一个一个**抽象的BaseObserverActivity**，让所有的Activity页面都去继承它，从本质上来看继承这个类的所有的Activity都是一个观察者，然后再观察者对象中去定义需要监听是什么类型的事件和根据对应的事件的处理。

**三.具体实现方案**

（1）EventSubjectInterface：抽象的主题角色实现

<pre class="lang:java decode:true">/**
 * 抽象的主题角色
 * @author zhiwu_yan
 * @since 2015年04月06日
 * @version 1.0
 */
public interface EventSubjectInterface {
  /**
     * 注册观察者
     * @param observer
     */
    public void registerObserver(String eventType,EventObserver observer);

    /**
     * 反注册观察者
     * @param observer
     */
    public void removeObserver(String eventType,EventObserver observer);

    /**
     * 通知注册的观察者进行数据或者UI的更新
     */
    public void notifyObserver(String eventType);
}</pre>

主要包括了观察者的注册方法和反注册方法以及通知观察者去更新UI的方法，我们来看看具体的实现。

（2）EventSubject：具体的主题角色的实现

<pre class="lang:java decode:true">/**
 * 具体的主题角色的实现，这里用来监听事件的发生，采用单例模式来实现
 * @author zhiwu_yan
 * @since 2015年04月06日
 * @version 1.0
 */
public class EventSubject implements EventSubjectInterface{
private static final String TAG="EventSubject";
    private Map<String,ArrayList<EventObserver>> mEventObservers=new HashMap<String,ArrayList<EventObserver>>();
    private static volatile EventSubject mEventSubject;
    private EventSubject(){

    }

    public synchronized static EventSubject getInstance(){
        if(mEventSubject ==null){
            mEventSubject =new EventSubject();
        }
        return mEventSubject;
    }

    @Override
    public void registerObserver(String eventType,EventObserver observer) {
        synchronized (mEventObservers){
            ArrayList<EventObserver> eventObservers = mEventObservers.get(eventType);
            if (eventObservers == null) {
                eventObservers = new ArrayList<EventObserver>();
                mEventObservers.put(eventType, eventObservers);
            }
            if(eventObservers.contains(observer)) {
                return;
            }
            eventObservers.add(observer);
        }

    }

    @Override
    public void removeObserver(String eventType,EventObserver observer) {
        synchronized (mEventObservers){
            int index = mEventObservers.get(eventType).indexOf(observer);
            if (index >= 0) {
                mEventObservers.remove(observer);
            }
        }
    }

    @Override
    public void notifyObserver(String eventType) {
        if(mEventObservers!=null && mEventObservers.size()>0 && eventType!=null){
            ArrayList<EventObserver> eventObservers=mEventObservers.get(eventType);
            if(eventObservers!=null){
                for(EventObserver observer:eventObservers){
                    observer.dispatchChange(eventType);
                }
            }else{
                Log.e(TAG,"eventObservers is null,"+eventType+" may be not register");
            }
        }

    }
}
</pre>

里面要注意的地方是：使用单例模式来控制只有一个主题角色，里面保存了所有的**观察者对象（EventObserver）列表，**也就是护士手中的名单（见上一章），值得一提的是使用synchronized去控制多线程操作的问题。

（3）EventObserverInterface：抽象观察者对象

<pre class="lang:java decode:true">/**
 * 观察者接口
 * @author zhiwu_yan
 * @since 2015年04月06日
 * @version 1.0
 */
public interface EventObserverInterface {
    /**
     * 根据事件进行数据或者UI的更新
     * @param eventType
     */
    public void dispatchChange(String eventType);
}</pre>

里面只有一个根据事件类型来跟新UI的方法，我们看看具体的抽象观察者。

（4）EventObserver：具体的抽线观察者

<pre class="lang:java decode:true ">/**
 * 用于更新UI，这里执行更新UI的onChange方法
 * @author  zhiwu_yan
 * @since   2015年04月06
 * @version 1.0
 */
public abstract class EventObserver implements EventObserverInterface {

    private Handler mHandler;

    public EventObserver(){
        mHandler=new Handler(Looper.getMainLooper());
    }

    public abstract void onChange(String eventType);

    @Override
    public void dispatchChange(String eventType){
        mHandler.post(new NotificationRunnable(eventType));
    }

    private final class NotificationRunnable implements Runnable{
        private String mEventType;
        public NotificationRunnable(String eventType){
            this.mEventType=eventType;
        }
        @Override
        public void run() {
            EventObserver.this.onChange(mEventType);
        }
    }
}</pre>

我们定义了一个抽象的onChange方法交给子类去实现，这个方法就是用来处理对应的事件类型，比如需要刷新数据等等。因为mHandler.post来跟新UI线程的，所以如果是耗时的操作需要另外开线程去处理。

（5）前面已经说过了，Android里面我们需要定义一个带观察者模式的BaseActivity用来给某些需要监听的业务的Activity使用，这样只要继承了该Activity的都是一个具体的观察者对象。

<pre class="lang:java decode:true">/**
 * 带有观察者模式的Activity,本质上就是观察者
 * @author  zhiwu_yan
 * @since  2015年04月6日 20:41
 * @version 1.0
 */
public abstract class BaseObserverActivity extends ActionBarActivity {

    private ActivityEventObserver mActivityEventObserver;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mActivityEventObserver=new ActivityEventObserver(this);
        registerObserver(mActivityEventObserver);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        removeObserver(mActivityEventObserver);
    }

    public void registerObserver(EventObserver observer) {
        final String[] observerEventTypes=getObserverEventType();//获取所有需要监听的业务类型
        if(observerEventTypes!=null && observerEventTypes.length>0){
            final EventSubject eventSubject=EventSubject.getInstance();
            for(String eventType:observerEventTypes){
                eventSubject.registerObserver(eventType,observer);
            }
        }
    }

    public void removeObserver(EventObserver observer) {
       final String[] observerEventTypes=getObserverEventType();//获取所有需要监听的业务类型
        if(observerEventTypes!=null && observerEventTypes.length>0){
            final EventSubject eventSubject=EventSubject.getInstance();
            for(String eventType:observerEventTypes){
                eventSubject.removeObserver(eventType, observer);
            }
        }
    }

    /**
     * 该方法会在具体的观察者对象中调用，可以根据事件的类型来更新对应的UI，这个方法在UI线程中被调用，
     * 所以在该方法中不能进行耗时操作，可以另外开线程
     * @param eventType 事件类型
     */
    protected abstract void onChange(String eventType);

    /**
     * 通过这个方法来告诉具体的观察者需要监听的业务类型
     * @return
     */
    protected abstract String[] getObserverEventType();

    private static class ActivityEventObserver extends EventObserver {
        //添加弱引用，防止对象不能被回收
        private final WeakReference&lt;BaseObserverActivity&gt; mActivity;
        public ActivityEventObserver(BaseObserverActivity activity){
            super();
            mActivity=new WeakReference&lt;BaseObserverActivity&gt;(activity);
        }

        @Override
        public void onChange(String eventType) {
            BaseObserverActivity activity=mActivity.get();
            if(activity!=null){
                activity.onChange(eventType);
            }
        }
    }

}</pre>

另外我们需要定义一个可以动态扩展的事件类型：EventType

<pre class="lang:java decode:true ">/**
 * 所有的业务类型，在这里写，方便管理
 * @author zhiwu_yan
 * @since 2015年04月06日
 * @version 1.0
 */
public class EventType {

    private static volatile EventType mEventType;
    private final static Set&lt;String&gt; eventsTypes = new HashSet&lt;String&gt;();

    public final static String UPDATE_MAIN="com.updateMain";
    public final static String UPDATE_Text="com.updateText";
    private EventType(){
        eventsTypes.add(UPDATE_MAIN);
        eventsTypes.add(UPDATE_Text);
    }

    public static EventType getInstance(){
       if(mEventType==null){
           mEventType=new EventType();
       }
        return mEventType;
    }

    public boolean contains(String eventType){
        return eventsTypes.contains(eventType);
    }

}
</pre>

我这里主要定义个2个事件类型，如果需要你可以定义N个事件类型，只要把你需要定义的事件添加到事件类表里面去就可以了。

我们在通知某个页面需要更新的时候只需呀调用如下方法：

<pre class="lang:java decode:true ">EventSubject eventSubject=EventSubject.getInstance();
        EventType eventTypes=EventType.getInstance();
        if(eventTypes.contains(eventType)){
            eventSubject.notifyObserver(eventType);
        }</pre>

为了便于管理我们也新建一个工具类：

<pre class="lang:java decode:true">/**
 * 通知中心，用来通知更新数据或者UI，采用单例模式
 * @author zhiwu_yan
 * @since 2015年04月6日
 * @version 1.0
 */
public class Notify {

    private static volatile Notify mNotify;
    private Notify(){

    }

    public static Notify getInstance(){
        if(mNotify==null){
            mNotify=new Notify();
        }
        return mNotify;
    }

    public void NotifyActivity(String eventType){
        EventSubject eventSubject=EventSubject.getInstance();
        EventType eventTypes=EventType.getInstance();
        if(eventTypes.contains(eventType)){
            eventSubject.notifyObserver(eventType);
        }
    }
}</pre>

到这里基本的框架就完成，我们看看怎么使用。

**四.使用方法**

定义一个A页面：MainActivity。这个页面是一个观察者，需要监听来自其他页面的一些通知，一旦有修改就根据对应的的事件来做出不同的处理：

<pre class="lang:java decode:true ">public class MainActivity extends BaseObserverActivity {

    private TextView mLableTv;
    private ImageView mPicIv;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        mLableTv=(TextView) findViewById(R.id.label_tv);
        mPicIv=(ImageView) findViewById(R.id.pic_iv);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();
        switch (id){
            case R.id.go_other_activity:
                goActivity(OtherActivity.class);
                return true;
        }
        return super.onOptionsItemSelected(item);
    }

    private void goActivity(Class&lt;?&gt; activity){
        Intent intent=new Intent(this,activity);
        startActivity(intent);
    }

    @Override
    protected void onChange(String eventType) {
        if(EventType.UPDATE_MAIN==eventType){
            mPicIv.setImageResource(R.mipmap.pic_two);
        }else if(EventType.UPDATE_Text==eventType){
            mLableTv.setText("图片被更新");
        }
    }

    @Override
    protected String[] getObserverEventType() {
        return new String[]{
                EventType.UPDATE_MAIN,
                EventType.UPDATE_Text
        };
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        startActivityForResult();
    }
}
</pre>

主要看一下：onChange 方法：根据事件类型来更新不同的图片，而在getObserverEventType()中我们定义了该观察者需要观察的业务类型，其它业务类型则会被忽略。

我们的B页面：也就是发出通知的页面，APP上面的设置页面，唯一的作用就是通知观察者：

<pre class="lang:java decode:true ">public class OtherActivity extends ActionBarActivity {
    private Button mUpdateBtn;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.other_activity);
        mUpdateBtn=(Button) findViewById(R.id.update_edit_btn);
        mUpdateBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Notify.getInstance().NotifyActivity(EventType.UPDATE_Text);
                Notify.getInstance().NotifyActivity(EventType.UPDATE_MAIN);
            }
        });
    }

}
</pre>

好，大功告成！

源码下载地址：[ObserverUpdateUiExp](http://www.akiyamayzw.com/wp-content/uploads/2015/05/ObserverUpdateUiExp.rar)

&nbsp;

&nbsp;