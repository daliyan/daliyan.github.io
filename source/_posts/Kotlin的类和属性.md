---
title: Kotlin的类和属性
date: 2017-05-24 22:42:00
categories:
- 类和属性
- Kotlin
tags:
- Kotlin
- Android
comments: true
---
## 类声明
类的声明和Java是非常相近的，一般的类声明是这样的

```kotlin
class Invoice {
}
```
如果没有任何的类体，则可以省略花括号。

### 构造函数

构造函数和Java有很多不同的地方，Java允许同一个类中存在多个同级别的构造函数，**kotlin中则把构造函数分成主构造函数和次构造函数**。其中主构造函数直接声明在类体后面，

```kotlin
class Person constructor(firstName: String) {

}
```

简化写法：

```kotlin
class Person(firstName: String) {

}
```
主构造函数中不能包含代码，**如果你需要在主构造函数中添加代码，可以使用初始化init方法来替代**：

```kotlin
 init {
        // 可以看成是主构造函数的实现方法
        val customerKey = name.toUpperCase()
        print(customerKey)
        this.name = name
        s = 6
    }
```
如果有多个构造函数，则需要添加次构造函数：

```kotlin
class Person(val name: String) {
    constructor(name: String, parent: Person) : this(name) {
        parent.children.add(this)
    }
}
```

### 继承

每一个类都有一个子类Any(就像Java中的Object),如果需要继承其它类，则使用“:”
例如自定义View：

```Kotlin
open class MyView : View {
    constructor(ctx: Context) : super(ctx)

    constructor(ctx: Context, attrs: AttributeSet) : super(ctx, attrs)
}
```
其中，**open字段表示允许其它类继承它**。

**子类如果想要覆盖父类的方法或者属性，则必须声明override**

```kotlin

open class Base {
    open fun v() {}
    fun nv() {}
}

class Derived() : Base() {
    override fun v() {}
}

```

**如果存在主构造函数，次构造函数必须委托给主构造函数**，如例子中的this(name)
### 抽象类

抽象类的声明和Java一样的

```kotlin
abstract class Derived : Base() {
    override abstract fun f()
}
```

### 伴生对象
伴生对象可以理解成Java的内部类，类内部的对象声明可以用 companion 关键字标记：

```kotlin
class MyClass {
    companion object Factory {
        fun create(): MyClass = MyClass()
    }
}
```
## 属性的声明

声明一个属性的定义：

```
var <属性名称>[: <属性类型>] [= <初始值>]
    [<get>]
    [<set>]
```

需要注意几点：
 
  - 初始值、get、set方法都是可选的，如果，数据类型可以通过初始器或者get set方法推断出来，则可以省略。
  - 常量用val表示只读属性，变量用var表示可变属性
  - 如果需要改变一个访问器的可见性或者对其注解，但是不需要改变默认的实现，你可以定义访问器而不定义其实现。(**Get属性肯定是需要可见的，想想为什么？**)

## get 和 set 方法

### 两种写法

get和set写法上有2种，一种是完全写法，一种是简略写法，如下：

```kotlin
 var age: Int = 2 // 具有field字段才允许进行初始化
get() {
    return 3
}
set(value) {
    field = value
}
```

其中get方法也可以省略成：

```
get() = 3
```

但是，为了代码的一致性，推荐使用第一种写法。
其实，get方法还省略了方法的返回值类型，因为根据返回值可以自动推断出返回类型，所以可以省略掉。

在一些情况下，你可能希望set方法不给外部访问，这个时候你可以声明set方法位不可见,在set方法前面添加private关键字

``` kotlin
private set(value) {
    field = value
}
```

### backing字段

**kotlin语言种，类的属性是不允许外部直接访问的**，但是，我们在使用的时候往往是这样的：

``` kotlin

fun testStudent(){
        var stu = Student("1111",5)
        this.test_result_tv.text = "" + stu.age + "name:" + stu.name
    }
```

其中，直接使用了stu.age 和 stu.name，说好的不能直接访问呢？
假设，按照Java的写法，我们在get方法种直接这样写：

```
get() {
        return 3
    }
```

我们执行testStudent()方法，发现输出的值为 3。**因此使用xx.属性的写法，其本质还是调用了get方法，只不过是kotlin的一种简化写法。**
如果我们把get方法修改如下：
```
get() {
        return age
    }
```

同样执行上面的测试类，这个时候你会发现抛出了StackOverFlowError的错误，因为就算在类内部直接访问属性，其实也是访问get方法，所以这种写法其实是错误的。

那么有什么办法可以做到像Java一样直接返回字段当前的值呢？

**在kotlin种定义了一种被称之为backing属性的字段，我把它翻译成影子字**段，按照我的理解，其实是当前属性真正的赋值字段，所以你可以这么写：

```Kotlin
var age: Int = 2 // 具有field字段才允许进行初始化
get() {
    return field
}
set(value) {
    field = value
}
```

再次执行上面的测试方法，就不会报错了。


## 编译期常量

编译期常量和Java中的静态常量是非常相像的：

```java

 public static final String EXTRA_URL = "extra_url";
 
```

而在kotlin中，编译期常量的写法：

```kotlin

const val EXTRA_URL: String = "extra_url"

```
编译期常量需要满足以下几个条件：

- 位于顶层或者是 object(后面再讲) 的一个成员
- 用 String 或原生类型 值初始化
- 没有自定义 getter


## 类外属性

顾名思义，类外属性是位于类外面的一种属性，它主要包括两种类型：

- 写在类外并初始化的包级属性
- 编译期常量

```kotlin

const val SEX_MALE : Int = 0
const val SEX_FEMALE : Int = 1

private var grade : String = ""
// 先定义名称，再定义类型的规律
open class Student(name : String) {
...
}

```

类外属性，默认是全局可访问的，可以在其它类中直接访问。

## lateinit属性

虽然，kotlin要求我们必须初始化变量，但是再一些特殊情况下，我们想先不初始化，后面再进行赋值，例如，外部注入初始化。

```kotlin

public class MyTest {
    lateinit var helloWorld: String

    fun sayHello(helloWord: String) {
        this.helloWorld = helloWorld
    }
}

```

这样就实现了延迟初始化属性值。

## 总结

本文主要讲了类的定义个属性值定义个使用，kotlin的类和属性和Java还是有很多不同的，特别是对象的访问和初始化这一块，需要细细体会，在实战中多使用