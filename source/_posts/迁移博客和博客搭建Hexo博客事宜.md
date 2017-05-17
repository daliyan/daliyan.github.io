---
title: 迁移博客和搭建Hexo博客事宜
date: 2017-05-17 14:56:51
categories:
- 杂谈
tags:
- 杂谈
comments: true
---
### **为什么要迁移博客？**
 
 黑客与画家的译者说过，喜欢写博客的人会经历的三个境界
 
   - 第一阶段，刚接触Blog，觉得很新鲜，试着选择一个免费空间来写。
   - 第二阶段，发现免费空间限制太多，就自己购买域名和   空间，搭建独立博客。
   - 第三阶段，觉得独立博客的管理太麻烦，最好在保留控   制权的前提下，让别人来管，自己只负责写文章。
   
我从2012年开始在CSDN上写博客，不过那个时候写的不多，一般是一个月1篇到2篇，过了一两年感觉CSDN上限制太多，不能个性化自己的博客，提供的可定制化功能也有限，想着自己去搭建一个博客，所以在2014年左右直接去买了一个域名和主机，使用wordpress去搭建一个博客。
记得那个时候买的域名是100+/年，主机花费也差不多，一年下来大概花费200多，钱不多，但是有一些不好的地方：
 
  - 管理麻烦
  - 文本编辑功能不是很好
  - 访问缓慢（可能是自己主机的问题）
  - wordpress本身的一些缺陷
  
  

很多时候，自由和非自由没有明显的界限，过分追求自由就是不自由，好像常常思考代码的逻辑一样，无论你设计多么优雅的代码结构，逻辑永远是守恒。当你追求绝对自由的时候，那么实现这些自由逻辑的方法，就需要你牺牲其它的一些东西来弥补，老子的中庸之道或许是一种解决问题的方式。小到你搭建一个博客站点也一样，你希望能够保持绝对控制权自由的同时，也能让你只把主要精力放在写作方面，这个时候，你需要请一个“博客管家”，github page就是你的博客管家。

### 什么是github page?

 github page是github开源社区提供给github用户自己的站点
  
> You get one site per GitHub account and organization, 
and unlimited project sites

具体的介绍可以看官方的介绍(https://pages.github.com/)

### 搭建环境准备

你需要2个东西

  - git
  - Hexo (包括node.js)
 
**git**

如果你不知道git是什么，建议可以先去简单了解一下，因为接下来git的使用将非常频繁，推荐看看[廖雪峰的简明git教程](http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000/001373962845513aefd77a99f4145f0a2c7a7ca057e7570000)
  
**Hexo**

 Hexo 是一个快速、简洁且高效的博客框架。Hexo 使用 Markdown（或其他渲染引擎）解析文章，在几秒内，即 可利用靓丽的主题生成静态网页。

2个关键信息：

- 使用markdown写作）
- 几秒内自动渲染成静态网页（兼容性非常好）


关于它们的安装，从官网查看自己的系统匹配的安装方式
[git安装](https://git-scm.com/downloads) [Hexo安装](https://hexo.io/zh-cn/docs/)。


### **博客的生成**

假设你前面环境的配置都很顺利，接下来就简单了

#### 1.新建github io项目

在github上面新建一个repository，这个项目的名称格式一定{username}.github.io，这样github才会自动解析为一个site. 新建成功后再浏览器输入地址{your username}.github.io你会发现你的博客已经初步成形了。


### 2.Hexo初始化项目

使用一下命令来初始一个Hexo博客项目

```
hexo init <folder>
cd <folder>
npm install
```
进入到你的博客根目录文件下，执行 hexo init 来初始化目录，这个时候你会看到在这个目录下回生成很多hexo博客的初始化文件。安装成功后你会在目录下面看到这样的树形结构：

```
.
├── _config.yml
├── package.json
├── scaffolds
├── source
|   ├── _drafts
|   └── _posts
└── themes

```
 其中_config.yml文件即为你配置站点的信息文件，具体每个参数代表的含义可以看[这里](https://hexo.io/zh-cn/docs/configuration.html)
 
 配置好了信息后，如果你需要查看是否已经访问这个站点信息，执行发布信息的命令：
 
 ```
 hexo g （生成站点的命令）
 hexo d （删除缓存文件）
 hexo s （启动本地服务器预览）
 ```
 如果每一个命令没有报错，你可以在浏览器中输出入地址
 ```
 localhost:4000
 ```
 这个时候你可以看到博客的本地站点了
 
 > 注意：在windows环境下，如果在编辑文件的时候使用中文可能会出现乱码，解决方式是，在保存文件或者设置文件属性的地方，设置为UTF-8编码格式
 
 ### 3.把Hexo项目部署到github page
 
 前面我们已经在本地成功运行了博客站点，但是这只是本地站点而已，别人还访问不到，我们前面讲过了，我们应当把这个站点信息和github上的博客做关联，让本地的站点文件替代github上的默认站点文件信息，以后就可以直接使用Hexo的方式来编辑和书写博客了。
 
 部署方式可以通过点击[这里](https://hexo.io/zh-cn/docs/deployment.html)，在_config.yml的文件结尾添加信息：
 
 ```
 deploy:
  type: git
  repo: <repository url>
  branch: [branch]
  message: [message]
 ```
 保存，然后安装一下 hexo-deployer-git插件，否则在执行hexo g的时候不能正确识别git type
 
 ```
 npm install hexo-deployer-git --save

 ```
 
 Ok,以上步骤都成功了后，本地基本都配置好了，现在是把本地项目推送到github的项目上了，先做git项目的关联，执行一下命令：
 
 ```
 git remote add origin git@github.com:{username}/{username}.github.io.git

 ```
 这样本地项目和github上就已经关联成功了。然后执行部署命令：
 
 ```
 hexo deploy
 ```
 
部署成功后，在浏览器中输入网址
 ```
 {username}.github.io
 ```
 你就发现到了Hexo首页并且和你本地预览的结果一样，至此，Hexo博客已经搭建成功了。
 
 
 ### 4.发布文章
 
 前面把博客搭建好了，接下来就是学习如何发布一篇文章了。
 参考Hexo文档 ，[写作一节](https://hexo.io/zh-cn/docs/writing.html)。
 
Hexo推荐使用markdown方式写作，markdown写作的最大优点是使用简单的标记能够写出格式统一，简洁的文章，如果还不会使用markdown，推荐[这篇文章](http://wowubuntu.com/markdown/)

markdown的编辑我使用的是有道云笔记自带的编辑器，支持很不错，保存成功后，右键另存为md格式的文档。
使用命令来生成一个新的文章：

```
hexo new post 迁移博客和博客搭建Hexo博客事宜

```

然后我们可以在

```
├── source
|   ├── _drafts
|   └── _posts
        ├── hello-world.md
|       └── 迁移博客和博客搭建Hexo博客事宜.md 

```

可以看到多了一个md文档，这个文档就是我们新建的文章，打开看一下，其实就是多了如下信息：

```
title: 迁移博客和博客搭建Hexo博客事宜
date: 2017-05-17 14:56:51
tags: 博客迁移,Hexo
```

我们直接把这个信息拷贝到我们自己的md文件中，然后用自己的文件替换默认生成的md文档，这样我们的文章就放到源码中了，后面就是发布和部署了。

### 自动发布脚本

每次写文章都有一些重复性的工作，可以使用脚本的方式来实现自动发布文章，在mac/linux使用shell脚本，在windows下面使用bat脚本。
要实现自动发布，需要把自己的电脑的SSH key添加到github中，这样可以直接把文章推送到github远程服务器中，并且把_config.yml中的repo地址修改成SSH方式,例如

```
deploy:
  type: git
  repo: git@github.com:daliyan/daliyan.github.io.git
  branch: master
```

然后使用bat脚本
### 总结

Hexo+github page+markdown的方式来搭建博客极大的提高了博客的书写效率，同时也保持了博客的定制化和灵活性。文章很多细节没展开来讲，例如域名的绑定，具体生成原理等等，有兴趣可以自己去谷歌查找。