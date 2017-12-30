---
title: 将Gradle项目发布到maven仓库
id: 81
categories:
  - android
date: 2015-08-25 09:52:36
tags:
---

#### 1.Ant和Maven介绍

> 全称为Apache Maven，是一个软件（特别是Java软件）项目管理及自动构建工具，由Apache软件基金会所提供。

&emsp;在发布maven之前，android普遍使用ant的方式进行项目的构建和管理，它们均使用XML文件来配置描述项目的，相比较于ant maven提供的功能更加强大。主要表现在以下几点：
- 使用POM的方式来管理和描述项目
- 内置了更多的隐式规则，使得构建文件更简单
- **内置了依赖管理来和Repository来实现依赖管理**
- 内置了软件构建的生命周期
&emsp;然而在一些中大型项目中使用Maven方式构建软件会让XML配置文件越来越大，越来越笨重，而且灵活性不够，因此，出现了gradle.

#### 2.Gradle

> Gradle是一个基于Apache Ant和Apache Maven概念的项目自动化建构工具。它使用一种基于Groovy的特定领域语言来声明项目设置。

&emsp;很明显，Gradle的出现是为了弥补ant和maven构建方式的不足，它不是采用传统的xml文件构建方式，而是采用groovy方式来构建。具体映射到android中就是使用gradle脚本文件的构建方式。它贯穿了项目的整个生命周期，包括编译、检查、测试、打包、部署。
&emsp;因此，google将gradle方式作为了android项目管理的默认方式，使用android studio创建的项目下面会默认生成build.gradle文件作为默认构建。
更多的android Gradle介绍请看：
- [gradle-android](https://gradle.org/getting-started-android/)
- [wikipedia-gradle介绍](https://zh.wikipedia.org/zh/Gradle)
- [ant\maven\gradle比较](http://m.blog.csdn.net/blog/proud2005/43407265)

#### 1.2.常见的Maven仓库和Gradle依赖的使用

&emsp;在使用ant构建项目的时候我们要使用第三方库往往要下载对应的库并将其jar文件拷贝到项目文件夹下面，这样会显得很麻烦。在使用gradle构建方式以后我们只要需要一个坐标就能够引入项目库文件，例如：

    dependencies {
        compile fileTree(dir: 'libs', include: ['*.jar'])
        compile 'com.android.support:appcompat-v7:22.1.1'
    }
    `</pre>

    &emsp;这个就是gradle依赖使用方式。所谓的gradle依赖就是我们提供一个坐标然后它会自动帮我们从网络上下载对应的文件，甚至我们可以在本地看到库文件的源码。
    那我们到底是从哪里下载到对应的文件呢？我们通过跟踪项目文件顶级目录下面的buidle gradle文件：

    <pre>`allprojects {
        repositories {
            jcenter()
        }
    }
    `</pre>

    jcenter函数：

    <pre>`/**
         * Adds a repository which looks in Bintray's JCenter repository for dependencies.
         * &lt;p&gt;
         * The URL used to access this repository is {@literal "https://jcenter.bintray.com/"}.
         * The behavior of this repository is otherwise the same as those added by {@link #maven(org.gradle.api.Action)}.
         * &lt;p&gt;
         * Examples:
         * &lt;pre autoTested=""&gt;
         * repositories {
         *     jcenter()
         * }
         * &lt;/pre&gt;
         *
         * @return the added resolver
         * @see #jcenter(Action)
         */
        MavenArtifactRepository jcenter();
    `</pre>

    &emsp;我们知道我们的包是从一个叫做Bintray's JCenter repository中下载而来的，我们打开[jcenter库](https://jcenter.bintray.com)试试，
    [![2015-08-24 14:27:55的屏幕截图](http://www.akiyamayzw.com/wp-content/uploads/2015/08/2015-08-24-142755的屏幕截图-289x300.png)](http://www.akiyamayzw.com/wp-content/uploads/2015/08/2015-08-24-142755的屏幕截图.png)

    &emsp;看到了我们常见的一些库，这样我终于搞清楚gradle依赖是从哪里来的了。
    &emsp;事实上，这个Jcenter库是一家叫做bintray的机构维护，它作为google android官方默认的中央库.但在android studio的早期版本中默认使用的是[maven库](http://mvnrepository.com/)，它是由sonatype机构维护的。目前主要存在的三个依赖库为：
    <table>
    <thead>
    <tr>
      <th align="left">库名</th>
      <th align="left">维护机构</th>
      <th align="left">android studio调用</th>
    </tr>
    </thead>
    <tbody>
    <tr>
      <td align="left">jcenter</td>
      <td align="left">bintray</td>
      <td align="left">jcenter()</td>
    </tr>
    <tr>
      <td align="left">maven</td>
      <td align="left">sonatype</td>
      <td align="left">mavenCentral()</td>
    </tr>
    <tr>
      <td align="left">lvy</td>
      <td align="left">sonatype</td>
      <td align="left">//一般在ant中使用</td>
    </tr>
    </tbody>
    </table>

    三者都是基于Apache Maven的规则来进行依赖。

    #### 1.3\. aar库文件

    &emsp;aar文件其实和jar文件作用是一样的，唯一的区别在于aar是专门针对android项目优化过的jar文件，里面除了jar以外还包括了res\string等资源文件。

    ### 2\. 将项目发布到Jcenter Maven仓库中

    #### 2.1\. 发布Jcenter步骤

    ##### 2.1.1 注册bintray帐号

    &emsp;为了让自己的项目也能够被全世界的开发者使用，我们可以通过将lib项目发布到jcenter库中，在配置脚本之前我们需要先去官网注册一个帐号，传送门：[bintray](https://bintray.com/) 也可以使用第三方登录的方式来登录，包括github、google、facebook帐号等。注册成功后我们先要获取到一个api key。
    ![](http://img.blog.csdn.net/20150126092533531?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvbWFvc2lkaWFveGlhbg==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

    ##### 2.1.2.上传文件

    &emsp;在Jcenter库中要求上传到库中的项目必须包含4个文件：
    - javadoc.jar
    - sources.jar
    - aar或者jar
    - pom
    &emsp;如果少了审核可能不会通过，当然这几个文件都可一通过配置gradle脚本来自动生成。

    #### 2.2.配置Gradle脚本

    &emsp;为了创建上面所说的几个文件，我们需要构建脚本来自动生成对应的文件。具体可以参考：[github-SwipeView-build.gradle](https://github.com/daliyan/SwipeView/blob/master/library/build.gradle)

    ##### 2.2.1\. 配置项目依赖

    将项目文件根目录（Top-level）下面的buide.gradle文件增加依赖：

    <pre>` dependencies {
            classpath 'com.android.tools.build:gradle:1.0.0'
            classpath 'com.github.dcendents:android-maven-plugin:1.2'
            classpath 'com.jfrog.bintray.gradle:gradle-bintray-plugin:1.0'

            // NOTE: Do not place your application dependencies here; they belong
            // in the individual module build.gradle files
        }
    `</pre>

    > 注意： classpath 'com.android.tools.build:gradle:1.0.0' 在默认生成的文件下可能版本不一致，采用默认的有时候会导致构建失败，最好也修改成1.0.0版本的。

    ##### 2.2.2.增加gradle插件和版本号

    &emsp;在需要上传的library项目的build.gradle下增加插件引用和版本号：

    <pre>`apply plugin: 'com.android.library'
    apply plugin: 'com.github.dcendents.android-maven'
    apply plugin: 'com.jfrog.bintray'
    version = "1.0"
    `</pre>

    > 注意：版本号作为项目坐标的一部分，以后在升级项目的时候都需要升级版本号，否则会覆盖掉已经上传的版本.
>       &emsp;关于插件bintray的更详细的使用方式可以查看：[github-bintray](https://github.com/bintray/gradle-bintray-plugin)

    ##### 2.2.3.pom节点生成

    &emsp;生成POM文件build脚本

    <pre>`def siteUrl = 'https://github.com/daliyan/SwipeView'      // 项目的主页
    def gitUrl = 'https://github.com/daliyan/SwipeView.git'   // Git仓库的url
    group = "akiyama.swipe"
    // 根节点添加
    install {
        repositories.mavenInstaller {
            // This generates POM.xml with proper parameters
            pom {
                project {
                    packaging 'aar'
                    name 'swipeView For Android'
                    url siteUrl
                    licenses {
                        license {
                            name 'The Apache Software License, Version 2.0'
                            url 'http://www.apache.org/licenses/LICENSE-2.0.txt'
                        }
                    }
                    developers {
                        developer {
                            id 'akiyama'
                            name 'daliyan'
                            email 'dali_yan@yeah.net'
                        }
                    }
                    scm {
                        connection gitUrl
                        developerConnection gitUrl
                        url siteUrl
                    }
                }
            }
        }
    }
    `</pre>

    > 注意：group = "akiyama.swipe"作为项目坐标的前缀，packaging 'aar' 为arr包，其它的自己随意填写。

    ##### 2.2.4\. javadoc和sources文件的生成

    &emsp;添加生成任务：

    <pre>`task sourcesJar(type: Jar) {
        from android.sourceSets.main.java.srcDirs
        classifier = 'sources'
    }

    task javadoc(type: Javadoc) {
        source = android.sourceSets.main.java.srcDirs
        classpath += project.files(android.getBootClasspath().join(File.pathSeparator))
    }

    task javadocJar(type: Jar, dependsOn: javadoc) {
        classifier = 'javadoc'
        from javadoc.destinationDir
    }

    artifacts {
        archives javadocJar
        archives sourcesJar
    }
    `</pre>

    > 注意：在构建生成的时候有可能会报GBK编码等错误，可能需要添加UTF-8声明，如下：

    <pre>`//添加UTF-8编码否则注释可能JAVADOC文档可能生成不了
    javadoc {
        options{
            encoding "UTF-8"
            charSet 'UTF-8'
            author true
            version true
            links "http://docs.oracle.com/javase/7/docs/api"
            title "swipeJavaDoc"
        }
    }
    `</pre>

    ##### 2.2.5\. 构建上传jecnter库中脚本

    &emsp;使用前面的我们注册帐号和apikey上传对应的文件到jcenter库中：

    <pre>`Properties properties = new Properties()
    properties.load(project.rootProject.file('local.properties').newDataInputStream())
    bintray {
        user = properties.getProperty("bintray.user")
        key = properties.getProperty("bintray.apikey")
        configurations = ['archives']
        pkg {
            repo = "maven"
            name = "swipeView"                // project name in jcenter
            websiteUrl = siteUrl
            vcsUrl = gitUrl
            licenses = ["Apache-2.0"]
            publish = true
        }
    }
    `</pre>

    &emsp;因为用户名和apikey是属于个人的隐私信息，故在local.properties（该文件不会上传到git库中）本地文件中配置用户名和apikey

    <pre>`sdk.dir=/home/android-sdk
    bintray.user=your username
    bintray.apikey=your apikey
    `</pre>

    #### 2.3.上传和审核

    在配置好了上述build.gradle文件后我们打开gradle控制面板就能看到如图所示的构建任务：
    [![2015-08-24 15:37:45的屏幕截图](http://www.akiyamayzw.com/wp-content/uploads/2015/08/2015-08-24-153745的屏幕截图-300x197.png)](http://www.akiyamayzw.com/wp-content/uploads/2015/08/2015-08-24-153745的屏幕截图.png)

    [![2015-08-24 15:38:01的屏幕截图](http://www.akiyamayzw.com/wp-content/uploads/2015/08/2015-08-24-153801的屏幕截图-300x101.png)](http://www.akiyamayzw.com/wp-content/uploads/2015/08/2015-08-24-153801的屏幕截图.png)

    我们只需要双击bintrayUpload就能自动上传到jcenter库中了。
    到官网找到我们刚刚上传的文件，提交审核就行了（别跟我说你找不到），一般2-3个小时就能审核成功。
    成功后可以通过http://jcenter.bintray.com/ 查询到你的库文件，例如我的项目文件路径为：http://jcenter.bintray.com/akiyama/swipe/library/2.1

    #### 2.4.同步项目到mvnrepository

    在jcenter中提供了将项目同步到mvnrepository库中,这样就不需要操作上传到mvnrepository库的繁琐步骤。在bintray构建脚本最后加上：

    <pre>` //Optional configuration for Maven Central sync of the version
                mavenCentralSync {
                    sync = true //Optional (true by default). Determines whether to sync the version to Maven Central.
                    user = 'userToken' //OSS user token
                    password = 'paasword' //OSS user password
                    close = '1' //Optional property. By default the staging repository is closed and artifacts are released to Maven Central. You can optionally turn this behaviour off (by puting 0 as value) and release the version manually.
                } 
    `</pre>

    > 注意：user和password即为mvnrepository中注册的用户名和密码。如果同步成功你也可以通过http://mvnrepository.com/ 查询到你上传的lib项目

    #### 2.5.常见问题

    在构建脚本过程中可能会出现一些问题：
    - GBK编码问题，前文已经提供了解决方案；
    - 依赖库问题，可能会报告一些警告，只要保证最后构建成功，直接忽略即可；
    - gradle依赖问题：可以参照[githug-bintray](https://github.com/bintray/gradle-bintray-plugin) 解决方案：
    Gradle >= 2.1

    <pre>`plugins {
        id "com.jfrog.bintray" version "1.3.1"
    }
    `</pre>

    Gradle &lt; 2.1

    <pre>`buildscript {
        repositories {
            jcenter()
        }
        dependencies {
            classpath 'com.jfrog.bintray.gradle:gradle-bintray-plugin:1.3.1'
        }
    }
    apply plugin: 'com.jfrog.bintray'

### 3\. 小结

本文学习了gradle的一些基本知识和基本的构建，学习了如何将lib库上传到中央仓库中，以及在这个过程中可能遇到的问题。