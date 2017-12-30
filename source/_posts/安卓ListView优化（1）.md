---
title: 安卓ListView优化（1）
id: 23
categories:
  - android
date: 2015-04-04 08:54:51
tags:
---

### **安卓ListView优化-使用缓存View**

最近在做项目的时候遇到了ListView大量数据加载问题,在数据量达到一定程度的时候，listView可能会出现卡顿甚至ANR或者OOM的错误，我们知道如果在UI线程（也叫Main线程）中如果你一个动作的时间超过5秒没有完成，主线程就会被堵塞，就会出现ANR（未响应）错误，而如果大量数据加载在内存中的时候，如果超出了虚拟机分配给该应用的最大内存就会出现OOM（内存溢出 ）的错误，为了再使用ListView加载大量数据时候不会出现上面的错误，我们可以从2个层次来优化：

我们知道ListView是加载数据的过程，是getCount()-&gt;getView()也就是首先得到你要加载数据的条数和你要加载的数据的View，在每次加载一条数据的时候就要创建一个View，我从别处下载了一张图来显示ListView的原理

![](http://img.blog.csdn.net/20140803214822921?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvSVRiYWlsZWk=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

那么我们可以每次生成View之前去判断系统是否已经缓存了这个View，如果已经缓存了就不需要自己在去生成，这样就会节省很多时间，看如下代码：
<pre class="lang:java decode:true">public class ListViewAdapter {

	public static void setListViewAdpter(final Context context,ListView lv){
		String[] mfrom=new String[]{"image","title"};
		int[] mto=new int[]{R.id.image,R.id.title};
		final List&lt;Map&lt;String,Object&gt;&gt; itemList=new ArrayList&lt;Map&lt;String,Object&gt;&gt;();
		Map&lt;String,Object&gt; mMap=null;
		for(int i=0;i&lt;1000000;i++){
			mMap=new HashMap&lt;String,Object&gt;();
			mMap.put("image", R.drawable.two);
			mMap.put("title", "美女：aspen");
			itemList.add(mMap);
		}
		SimpleAdapter sa=new SimpleAdapter(context,itemList,R.layout.listview_item,mfrom,mto){

			@Override
			public View getView(int position, View convertView, ViewGroup parent) {
				// TODO Auto-generated method stub
				 long startTime = System.nanoTime();
				LayoutInflater mInflater=LayoutInflater.from(context);

				if (convertView == null) {
					convertView = mInflater.inflate(R.layout.listview_item, parent, false);
				}
				((ImageView) convertView.findViewById(R.id.image)).setImageResource(Integer.parseInt(itemList.get(position).get("image").toString()));
				((TextView) convertView.findViewById(R.id.title)).setText(itemList.get(position).get("title").toString());
				// 停止计时
	            long endTime = System.nanoTime();
	            // 计算耗时
	            long val = (endTime - startTime) / 1000L;
	            System.out.println("位置："+position+":"+"时间："+val+""+convertView);
				return convertView;

			}

		};
		lv.setAdapter(sa);
	}
}</pre>
加载出来的列表时百万级的，会有一定的加载时间，但是没有出现ANR错误

![](http://img.blog.csdn.net/20140803220800505?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvSVRiYWlsZWk=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

看一下加载时间对比和对应的布局View：

![](http://img.blog.csdn.net/20140803215338307?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvSVRiYWlsZWk=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

我们可以看到在加载前面6列，也就一屏列表的时候他会出现它加载的时间比较长，而如果我们用手去滑动的时候加载的时间就会大大的缩短，这就是因为我们少了View的重复生成，利用了缓存机制，注意这句：
<pre class="lang:java decode:true ">if (convertView == null) {
					convertView = mInflater.inflate(R.layout.listview_item, parent, false);
				}</pre>
据谷歌开发者大会上所说，加载速度会快上200%左右。