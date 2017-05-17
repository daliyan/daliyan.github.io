---
title: Okhttp缓存解析
tags:
  - android
  - Okhttp
  - 缓存
id: 205
categories:
  - android
date: 2016-11-08 21:38:11
---

### HTTP缓存基础

![浏览器缓存](http://static.oschina.net/uploads/space/2015/0119/015353_P04w_568818.png)

看一张网上的关于浏览器缓存的流程图说明，先来明晰几个概念：

1.  Expires策略
HTTP1.0使用的过期策略，这个策略用使用时间戳来标识缓存是否过期。这个方式缺陷很明显，客户端和服务端的时间不同步，导致过期判断经常不准确。现在HTTP请求基本都使用HTTP1.1以上了，这个字段基本没用了。

2.  Cache-control策略
 Cache-Control与Expires的作用一致，区别在于前者使用过期时间长度来标识是否过期;例如前者使用过期为30天，后者使用过期时间为2016年10月30日。因此使用Cache-Control能够较为准确的判断缓存是否过期，现在基本上都是使用这个参数。基本格式如下：

    Cache-Control:max-age：
    `</pre>

    使用的参数类似如下：

    <pre>`Cache-Control: public\private, only-if-cached\no-store, max-stale\min-fresh=60 * 60 * 24 * 30
    `</pre>

1.  Last-Modified/If-Modified-Since
    Last-Modified最后修改时间，从服务端获取的最后修改时间，在请求HTTP的时候使用If-Modified-Since带上这个参数值，服务端根据这个参数值来决定是否需要返回更新值

    从上面流程图可以看出，是否能够使用缓存决定于3个方面，

*   请求体是否要求使用缓存(Cache-Control策略决定)
*   本地缓存是否过期(由max-age决定)
*   服务端这段时间内是否有更新(由Last-Modified/If-Modified-Since决定)

    ### OKhttp的缓存策略

    分析OKhttp的缓存可以从2个方面来理解，控制系统和存储系统。控制系统负责什么时候启动缓存、缓存是否过期、什么时候该保存缓存、什么时候读取缓存;而存储系统负责将缓存持久化到本地，供控制系统读取。通过控制系统和存储系统组成了一个小的缓存自治系统。

1.  拦截器处理机制
    OKhttp的原理在这里不多做解析（需要的可以参考[OKHttp源码解析](http://frodoking.github.io/2015/03/12/android-okhttp/)），我们只是关注缓存这一快，我们知道OKhttp的缓存试通过Interceptor来做，官方介绍这个类的作用是：

    <pre>`/**
     * Observes, modifies, and potentially short-circuits requests going out and the corresponding
     * requests coming back in. Typically interceptors will be used to add, remove, or transform headers
     * on the request or response.
     */
    `</pre>

    观察，修改以及可能短路的请求输出和响应请求的回来，通常情况下拦截器用来添加，移除或者转换请求或者回应的头部信息。通过拦截器我们可以添加缓存的一些头部信息，并重新修改response信息

    <pre>`new OkHttpClient.Builder().addInterceptor(new MyCacheInterceptor())
    `</pre>

    通过自己定义的MyCacheInterceptor来控制缓存的策略。我们跟踪一下addInterceptor源码，发现把我们的拦截器加入了一个List<Interceptor> interceptors列表中。

    <pre>`    public Builder addInterceptor(Interceptor interceptor) {
          interceptors.add(interceptor);
          return this;
        }
    `</pre>

    看看最终我们请求数据的方法：

    <pre>`Response response = mOkHttpClient.newCall(request).execute();
    `</pre>

    继续跟踪execute()可知道：

    <pre>`  @Override
       public Response execute() throws IOException {
        synchronized (this) {
          if (executed) throw new IllegalStateException("Already Executed");
          executed = true;
        }
        try {
          client.dispatcher().executed(this);
          Response result = getResponseWithInterceptorChain(false);
          if (result == null) throw new IOException("Canceled");
          return result;
        } finally {
          client.dispatcher().finished(this);
        }
      }
    `</pre>

    最关键的一句 Response result = getResponseWithInterceptorChain(false);

    <pre>` private Response getResponseWithInterceptorChain(boolean forWebSocket) throws IOException {
        Interceptor.Chain chain = new ApplicationInterceptorChain(0, originalRequest, forWebSocket);
        return chain.proceed(originalRequest);
      }
    `</pre>

    最终交给了ApplicationInterceptorChain（使用了全局拦截，可以看看拿全局拦截和网络拦截的区别）类的proceed方法来执行最终请求,我们看看源码：

    <pre>`@Override public Response proceed(Request request) throws IOException {
          // If there's another interceptor in the chain, call that.
          if (index &lt; client.interceptors().size()) {
            Interceptor.Chain chain = new ApplicationInterceptorChain(index + 1, request, forWebSocket);
            Interceptor interceptor = client.interceptors().get(index);
            Response interceptedResponse = interceptor.intercept(chain);

            if (interceptedResponse == null) {
              throw new NullPointerException("application interceptor " + interceptor
                  + " returned null");
            }

            return interceptedResponse;
          }

          // No more interceptors. Do HTTP.
          return getResponse(request, forWebSocket);
        }

    `</pre>

    看这一句

    <pre>`Response interceptedResponse = interceptor.intercept(chain);
    `</pre>

    我们最终会将请求体封装成Chain交给对应的拦截器处理，也就是我们在最开始add进去的，如果有多个拦截器它会循环读取所有的拦截器（其实是拦截器调用拦截器），在拦截器里我们对Request做了二次修改，添加缓头信息，继续将请求往下传递，到了return getResponse(request, forWebSocket);

    <pre>`  // Copy body metadata to the appropriate request headers.
        .....
          try {
            engine.sendRequest();
            engine.readResponse();
            releaseConnection = false;
          } catch (RequestException e) {
            // The attempt to interpret the request failed. Give up.
            throw e.getCause();
          } 
          .......
    }
    `</pre>

    先组装请求头信息，然后通过engine.sendRequest();发送请求，我们看看sendRequest()方法：

    <pre>` public void sendRequest() throws RequestException, RouteException, IOException {
        if (cacheStrategy != null) return; // Already sent.
        if (httpStream != null) throw new IllegalStateException();

        Request request = networkRequest(userRequest);

        InternalCache responseCache = Internal.instance.internalCache(client);
        Response cacheCandidate = responseCache != null
            ? responseCache.get(request)
            : null;

        long now = System.currentTimeMillis();
        cacheStrategy = new CacheStrategy.Factory(now, request, cacheCandidate).get();
        networkRequest = cacheStrategy.networkRequest;
        cacheResponse = cacheStrategy.cacheResponse;

       ......
      }

    `</pre>

    这个方法才是最核心的控制类，我们的缓存也在里面进行判断和封装，重点看这个2句，

    <pre>`....
    InternalCache responseCache 是 = Internal.instance.internalCache(client);
    ....
    cacheStrategy = new CacheStrategy.Factory(now, request, cacheCandidate).get();
    .....
    `</pre>

    responseCache 是internalCache(client);返回的，Internal是一个抽象类，看上面的说明知道OkHttpClient实现了这个类

    <pre>`static {
        Internal.instance = new Internal() {
          .......
          @Override public InternalCache internalCache(OkHttpClient client) {
            return client.internalCache();
          }
          .......
        };
      }
     .... 
    InternalCache internalCache() {
        return cache != null ? cache.internalCache : internalCache;
      }
    ....
    `</pre>

    最终返回了cache这个对象，这个对象在构造OkHttpClient时候加的参数（构造器模式），这个对象负责进行存储、解析等工作。
    第二句 cacheStrategy = new CacheStrategy.Factory(now, request, cacheCandidate).get();使用工厂模式获取cache策略，我们看看它们是怎么封装的：

    <pre>`this.nowMillis = nowMillis;
          this.request = request;
          this.cacheResponse = cacheResponse;

          if (cacheResponse != null) {
            Headers headers = cacheResponse.headers();
            for (int i = 0, size = headers.size(); i &lt; size; i++) {
              String fieldName = headers.name(i);
              String value = headers.value(i);
              if ("Date".equalsIgnoreCase(fieldName)) {
                servedDate = HttpDate.parse(value);
                servedDateString = value;
              } else if ("Expires".equalsIgnoreCase(fieldName)) {
                expires = HttpDate.parse(value);
              } else if ("Last-Modified".equalsIgnoreCase(fieldName)) {
                lastModified = HttpDate.parse(value);
                lastModifiedString = value;
              } else if ("ETag".equalsIgnoreCase(fieldName)) {
                etag = value;
              } else if ("Age".equalsIgnoreCase(fieldName)) {
                ageSeconds = HeaderParser.parseSeconds(value, -1);
              } else if (OkHeaders.SENT_MILLIS.equalsIgnoreCase(fieldName)) {
                sentRequestMillis = Long.parseLong(value);
              } else if (OkHeaders.RECEIVED_MILLIS.equalsIgnoreCase(fieldName)) {
                receivedResponseMillis = Long.parseLong(value);
              }
            }
          }
    `</pre>

    这些就是我们开始讲到的一些缓存参数设置了，通过读取request参数，取出里面的HTTP头缓存信息，因此我们可以得出推论，在缓存拦截器中我们添加了这些缓存参数信息。
    最终返回了CacheStrategy的策略处理，看看拿它的getCandidate()方法：

    <pre>`/** Returns a strategy to use assuming the request can use the network. */
        private CacheStrategy getCandidate() {
          // No cached response.
          if (cacheResponse == null) {
            return new CacheStrategy(request, null);
          }

          // Drop the cached response if it's missing a required handshake.
          if (request.isHttps() &amp;&amp; cacheResponse.handshake() == null) {
            return new CacheStrategy(request, null);
          }

          // If this response shouldn't have been stored, it should never be used
          // as a response source. This check should be redundant as long as the
          // persistence store is well-behaved and the rules are constant.
          if (!isCacheable(cacheResponse, request)) {
            return new CacheStrategy(request, null);
          }

          CacheControl requestCaching = request.cacheControl();
          if (requestCaching.noCache() || hasConditions(request)) {
            return new CacheStrategy(request, null);
          }

          long ageMillis = cacheResponseAge();
          long freshMillis = computeFreshnessLifetime();

          if (requestCaching.maxAgeSeconds() != -1) {
            freshMillis = Math.min(freshMillis, SECONDS.toMillis(requestCaching.maxAgeSeconds()));
          }

          long minFreshMillis = 0;
          if (requestCaching.minFreshSeconds() != -1) {
            minFreshMillis = SECONDS.toMillis(requestCaching.minFreshSeconds());
          }

          long maxStaleMillis = 0;
          CacheControl responseCaching = cacheResponse.cacheControl();
          if (!responseCaching.mustRevalidate() &amp;&amp; requestCaching.maxStaleSeconds() != -1) {
            maxStaleMillis = SECONDS.toMillis(requestCaching.maxStaleSeconds());
          }

          if (!responseCaching.noCache() &amp;&amp; ageMillis + minFreshMillis &lt; freshMillis + maxStaleMillis) {
            Response.Builder builder = cacheResponse.newBuilder();
            if (ageMillis + minFreshMillis &gt;= freshMillis) {
              builder.addHeader("Warning", "110 HttpURLConnection \"Response is stale\"");
            }
            long oneDayMillis = 24 * 60 * 60 * 1000L;
            if (ageMillis &gt; oneDayMillis &amp;&amp; isFreshnessLifetimeHeuristic()) {
              builder.addHeader("Warning", "113 HttpURLConnection \"Heuristic expiration\"");
            }
            return new CacheStrategy(null, builder.build());
          }

          Request.Builder conditionalRequestBuilder = request.newBuilder();

          if (etag != null) {
            conditionalRequestBuilder.header("If-None-Match", etag);
          } else if (lastModified != null) {
            conditionalRequestBuilder.header("If-Modified-Since", lastModifiedString);
          } else if (servedDate != null) {
            conditionalRequestBuilder.header("If-Modified-Since", servedDateString);
          }

          Request conditionalRequest = conditionalRequestBuilder.build();
          return hasConditions(conditionalRequest)
              ? new CacheStrategy(conditionalRequest, cacheResponse)
              : new CacheStrategy(conditionalRequest, null);
        }
    `</pre>

    这个方法基本实现了上面HTTP流程图中整个缓存的过期判断逻辑处理，包括过期判断、If-Modified-Since逻辑等处理。
    到这里就完成了整个请求过程，接下来我们看看OKhttp是怎么读取缓存结果的。

    ### 读取缓存

    在发送完请求后，接下来我们开始读取数据信息：
    通过cacheStrategy = new CacheStrategy.Factory(now, request, cacheCandidate).get()的get方法获取到了缓存信息，

    <pre>`Response get(Request request) {
        String key = urlToKey(request);
        DiskLruCache.Snapshot snapshot;
        Entry entry;
        try {
          snapshot = cache.get(key);
          if (snapshot == null) {
            return null;
          }
        } catch (IOException e) {
          // Give up because the cache cannot be read.
          return null;
        }

        try {
          entry = new Entry(snapshot.getSource(ENTRY_METADATA));
        } catch (IOException e) {
          Util.closeQuietly(snapshot);
          return null;
        }

        Response response = entry.response(snapshot);

        if (!entry.matches(request, response)) {
          Util.closeQuietly(response.body());
          return null;
        }

        return response;
      }

这个方法给出一下几个信息：

*   DiskLruCache是最终存储控制类
*   获取缓存信息是通过URL的MD5加密做为KEY-VALUE来进行存取的
*   想要存储信息，必须保持URL唯一，如果每次请求的URL都在发生变化，是不适合缓存的
*   DiskLruCache使用 缓存淘汰算法--LRU算法

DiskLruCache使用LRU算法（最近最少使用）采用的核心思想是“如果数据最近被访问过，那么将来被访问的几率也更高”,并使用一个链表保存缓存数据，类似的操作如下：
 - 新数据插入到链表头部；
 - 每当缓存命中，则将数据移到链表头部；
 - 当链表满的时候，将链表尾部的数据丢弃;
具体的原理可以看DiskLruCache是最终存储控制类源码，这里就不做展开讲解。
至此，整个OKhttp缓存的原理已经解析完毕，流程如下：
![浏览器缓存](http://www.akiyamayzw.com/wp-content/uploads/2016/11/untitled1.jpg)

## Github地址

废话少说上github ![okhttpCachce][https://github.com/daliyan/OkhttpCache]

*   实现4种缓存方式
*   颗粒度实现，便于调用，可以自由定制新的缓存方式