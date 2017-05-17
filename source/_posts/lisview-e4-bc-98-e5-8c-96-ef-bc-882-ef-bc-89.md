---
title: lisView优化（2）
id: 26
categories:
  - android
date: 2015-04-04 08:58:11
tags:
---

接着上篇点击,我们使用了ListView 的缓存视图方法去节省加载时间，那么今天我们使用视图缓存+ViewHolder的方法来优化ListView

#### (1)什么是ViewHolder?

我们在使用ViewHolder之前我们先理清楚它的概念，从字面意思来理解它的意思是“视图持有者”，我们可以知道他是跟View有关的一个概念，从google文档的官方定义知道他是一个静态类，一般只有属性没有方法，它的作用就是一个临时存储器，存储视图的一些属性，那么他在ListView中有什么作用呢？

我们知道ListView在加载列表时候它需要的东西无非就是：列表长度、每一项的列表View，当前项的位置；有了这3个东西我们就能产生一个ListView列表，这个可以从适配器中获得，其中长度其实就是你得到数据的长度，而当前项的位置则由当前加载位置决定的，因此ListView的加载时间和内存消耗主要是在：View的产生上面，而View的优化我们可以从2个方面进行：

a.View的创建时间的优化，因此尽量的重复利用已经创建好的View

b.查找View上面控件的优化，一次尽可能的减少findViewById()的使用

前者我们可以通过convertView==null的判断来减少重复创建View的时间，后者则可以使用静态ViewHolder来减少findViewById()的使用。

（2）实例比较研究

我们来动手创建一个来试试：

首先我们来自定义一个Adapter,用来作为ListView的适配器：
<pre class="lang:java decode:true ">public class ListViewAdapterBas extends BaseAdapter{
	private Context context;
	private List&lt;Map&lt;String,Object&gt;&gt; data;
	/** 
	 * @param context  上下文
	 * @param data  你要加载到ListView上面的数据
	 */
	public ListViewAdapterBas(Context context){
		 List&lt;Map&lt;String,Object&gt;&gt; itemList=new ArrayList&lt;Map&lt;String,Object&gt;&gt;();
			Map&lt;String,Object&gt; mMap=null;
			for(int i=0;i&lt;10000;i++){
				mMap=new HashMap&lt;String,Object&gt;();
				mMap.put("image", R.drawable.two);
				mMap.put("title", "美女：aspen");
				itemList.add(mMap);
			}
		this.context=context;
		this.data=itemList;
	}

	static class ViewHolder{
		//此处就是你定义的中包含的 控件 Item
		ImageView image;
		TextView text;
	}

	@Override
	public int getCount() {
		//这里就是返回ListView的总长度
		return data.size();
	}

	@Override
	public Object getItem(int arg0) {
		// TODO Auto-generated method stub
		return arg0;//得到当前加载的项
	}

	@Override
	public long getItemId(int arg0) {
		// TODO Auto-generated method stub
		return arg0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		long startTime = System.nanoTime();
	    ViewHolder holder;
	    LayoutInflater mInflater=LayoutInflater.from(context);
	    //判断是否已经加载过视图了，如果加载过的话就直接使用，如果没有加载的话就重新加载
	    if(convertView==null){
	    	convertView = mInflater.inflate(R.layout.listview_item, null);
	    	holder = new ViewHolder();
	    	holder.image=(ImageView)convertView.findViewById(R.id.image);
	    	holder.text=(TextView)convertView.findViewById(R.id.title);
	    }else{
            holder = (ViewHolder)convertView.getTag();
        }

    	holder.image.setImageResource(Integer.parseInt(data.get(position).get("image").toString()));
        holder.text.setText(data.get(position).get("title").toString());
        // 停止计时
        long endTime = System.nanoTime();
        // 计算耗时
        long val = (endTime - startTime) / 1000L;
        //Log.e("Test", "Position:" + position + ":" + val);
		return convertView;
	}

}
</pre>
代码分析：viewHolder
<pre class="lang:java decode:true ">static class ViewHolder{
		//此处就是你定义的中包含的 控件 Item
		ImageView image;
		TextView text;
	}</pre>
定义了一个ViewHolder,这里面就是我们列表Item的对应控件，一个图片和一个标题，注意是静态的，静态的好处就是节省了实例化所花费的时间，调用速度回更快，不过占用的内存可能会更多。

getView代码
<pre class="lang:java decode:true ">if(convertView==null){
	    	convertView = mInflater.inflate(R.layout.listview_item, null);
	    	holder = new ViewHolder();
	    	holder.image=(ImageView)convertView.findViewById(R.id.image);
	    	holder.text=(TextView)convertView.findViewById(R.id.title);
	    }else{
            holder = (ViewHolder)convertView.getTag();
        }</pre>
判断当前的视图是否已经创建，如果创建了就直接加载，就直接使用getTag()来获取视图，另外使用holder避免了重复加载。

最后直接在Activity中引用：
<pre class="lang:java decode:true ">public class MainActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		ListView lv=(ListView)findViewById(R.id.listView1);
		long startTime = System.nanoTime();
		ListViewAdapterBas listViewAd=new ListViewAdapterBas(this);
	    lv.setAdapter(listViewAd) ; 
		//ListViewAdapter.setListViewAdpter(this, lv);
	    // 停止计时
        long endTime = System.nanoTime();
        // 计算耗时
        long val = (endTime - startTime) / 1000L;
        Log.e("总耗时：", "Position:" + val);

	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

}</pre>
我们来看看和前一篇文章对比消耗时间：

![](http://img.blog.csdn.net/20140804224830890?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvSVRiYWlsZWk=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

从图上可以看出，消耗的时间大概就是viewCach的40%左右的时间，这样大大优化了ListView.