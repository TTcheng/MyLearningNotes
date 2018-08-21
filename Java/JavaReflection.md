# Java反射 JavaReflection

## 认识反射

反射被视为是动态语音的关键，通过反射可以获取类的完整结构

 - 1、实现的全部接口

 - 2、所继承的父类

 - 3、全部的构造器

 - 4、全部的方法
 
 - 5、全部的属性

**主要API**

 - java.lang.Class

 - java.lang.reflect.Method -Field -Constructor

## 获取Class实例的几种方式

```java
Person person = new Person();
Class aClass;
//1、调用类本身的class属性
aClass = Person.class;

//2、通过对象的getClass方法获取
aClass = person.getClass();

//3、通过Class.forName()获取
aClass = Class.forName("com.java.entity.Person");

 //4、使用classLoader
ClassLoader classLoader = this.getClass().getClassLoader();
classLoader.loadClass("com.java.entity.Person");
```
**ClassLoader还能做什么？**
1、获取资源流，方便读取包下的文件
```java
InputStream is = loader.getResourceAsStream("com\\xxx\\xxx");
Properties props = new Properties();
props.load(is);
String name = props.getProperty("name");
```
## 满足条件：

注意

1）运行时创建对象的类必须有无参构造方法。

2）无参构造器的权限修饰符必须满足条件

```java
@Test
public void testReflection() throws IllegalAccessException, InstantiationException, NoSuchFieldException, NoSuchMethodException, InvocationTargetException {
    /**
     * 创建对象
     */
    Class<Person> c = Person.class;
    Person person = c.newInstance();
    /**
     * 运行时操作属性
     */
    //1.保留封装性，通过反射获取属性，然后赋值.需要属性为public
    /*
    Field name = c.getField("name");
    name.set(person,"Jesse");
    */
    //2.无视封装性，获取属性赋值
    Field name = c.getDeclaredField("name");
    name.setAccessible(true);
    name.set(person, "Jessie");
    person.sayHello();
    //3.调用对象方法赋值
    person.setAge(15);
    person.setName("Jesse");
    person.sayHello();

    /**
     * 运行时操作方法
     */
    Method setName = c.getMethod("setName", String.class);//获取有参方法
    setName.invoke(person, "Jessica");
    Method sayHello = c.getMethod("sayHello");//获取无参方法
    sayHello.invoke(person);//执行
}
```

## 动态代理
com.java.reflection.*