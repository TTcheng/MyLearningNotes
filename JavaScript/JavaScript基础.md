## 数据类型

**基本数据类型：**

字符串（String）、数字(Number)、布尔(Boolean)、数组(Array)、对象(Object)、空（Null）、未定义（Undefined）。 

```js
//Number 
var num = 3.145;
//String
var str = "Hello";
//数组Array
var nums = [1,2,3,4,5];	//literal array
var names = new Array("Jesse","Jack","Mary");//condensed array
var cars = new Array();
cars[0] = "BWM";
cars[1]="VW";
//Object
var person={firstname:"John", lastname:"Doe", id:5566};
//Object 寻址方式
var name = person.lastname;
var name=person["lastname"];
//null 和 undefined 的值相等，但类型不等：
typeof undefined             // 返回undefined
typeof null                  // 返回object
null === undefined           // false
null == undefined            // true
```

**注意**：typeof只返回这几种数据类型：number,boolean,string,function（函数）,object（NULL,数组，对象）,undefined

3种对象类型Object、Date、Array

**声明时指明变量类型：**

```js 
var carname=new String;  
var x=      new Number;  
var y=      new Boolean;  
var cars=   new Array;  
var person= new Object; 
```

**注意：**

-  NaN 的数据类型是 number
-  数组(Array)的数据类型是 object
-  日期(Date)的数据类型为 object
-  null 的数据类型是 object
-  未定义变量的数据类型为 undefined

**如何确定变量为Array、Date？**

1、你可以使用 constructor 属性来查看对象是否为日期或数组。

```javascript
function isArray(myArray) {
    return myArray.constructor.toString().indexOf("Array") > -1;
} 
function isDate(myDate) {
    return myDate.constructor.toString().indexOf("Date") > -1;
} 
```

2、使用**instanceof**

```javascript
arr = [1,2,3];
if(arr instanceof Array){
    document.write("arr 是一个数组");
} else {
    document.write("arr 不是一个数组");
}
```

## 数据转换

### 将其他类型转换为字符串

全局方法 **String()** 可以将数字转换为字符串。

该方法可用于任何类型的数字，字母，变量，表达式：

```js
String(x)         // 将变量 x 转换为字符串并返回
String(100 + 23)  // 将数字表达式转换为字符串并返回
String(false)	
String(new Date())// 返回 Thu Jul 17 2014 15:38:19 GMT+0200 
```

  **toString()** 也是有同样的效果。

```js
 x.toString()
(100 + 23).toString()
true.toString()      // 返回 "true" 
obj.toString() 
```
将其他类型转换为Number

```js
//方法1
Number("3.14");
Number(new Date());
//方法2
Number.paseInt("15");//整数
Number.paseFloat("15");//小数
d.getTime();
//方法3 使用一元运算符+
var y = "5";      // y 是一个字符串
var x = + y; 		//x 是一个数字 或 NaN(无法转换时)
```



## 函数

普通函数

```js
function functionname(argument1,argument2 )  { 
    //method body
    return vars;//return clause
} 
```

对象函数

```js 
var person={
    name : "Jesse"
    sayhello : function(){
    	alert("hello "+ this.name);
	} 
}
```

## JavaScript事件

HTML 事件是发生在 HTML 元素上的事情。

当在 HTML 页面中使用 JavaScript 时， JavaScript 可以触发这些事件。

------

### HTML 事件

 HTML 事件可以是浏览器行为，也可以是用户行为。

以下是 HTML 事件的实例：

-  HTML 页面完成加载
-  HTML input 字段改变时
-  HTML 按钮被点击

通常，当事件发生时，你可以做些事情。

在事件触发时 JavaScript 可以执行一些代码。

HTML 元素中可以添加事件属性，使用 JavaScript 代码来添加 HTML 元素。

**单引号**:

 ```js
 <some-HTML-element some-event='JavaScript 代码'>
 ```

**双引号:**

```js
<some-HTML-element some-event="JavaScript 代码">
```

在以下实例中，按钮元素中添加了 onclick 属性 (并加上代码):

```html
<button onclick="this.innerHTML=Date()">现在的时间是?</button>
```

### 常见的HTML事件

| 事件        | 描述                         |
| ----------- | ---------------------------- |
| onchange    | HTML 元素改变                |
| onclick     | 用户点击 HTML 元素           |
| onmouseover | 用户在一个HTML元素上移动鼠标 |
| onmouseout  | 用户从一个HTML元素上移开鼠标 |
| onkeydown   | 用户按下键盘按键             |
| onload      | 浏览器已完成页面的加载       |

更多事件列表: [ JavaScript 参考手册 - HTML DOM 事件](http://www.runoob.com/jsref/dom-obj-event.html)。 

## 正则表达式

语法：`/正则表达式主体/修饰符(可选)`

例如

```js
var patt = /runoob/i
```

[更多参考](http://www.runoob.com/js/js-regexp.html)

## 错误

**1、try catch**

```javascript
//在下面的例子中，我们故意在 try 块的代码中写了一个错字。
//catch 块会捕捉到 try 块中的错误，并执行代码来处理它。
var txt=""; 
function message() 
{ 
    try { 
        adddlert("Welcome guest!"); 
    } catch(err) { 
        txt="本页有一个错误。\n\n"; 
        txt+="错误描述：" + err.message + "\n\n"; 
        txt+="点击确定继续。\n\n"; 
        alert(txt); 
    } 
}
```

**2、throw**

```javascript
//本例检测输入变量的值。如果值是错误的，会抛出一个异常（错误）。catch 会捕捉到这个错误，并显示一段自定义的错误消息
function myFunction() {
    var message, x;
    message = document.getElementById("message");
    message.innerHTML = "";
    x = document.getElementById("demo").value;
    try { 
        if(x == "")  throw "值为空";
        if(isNaN(x)) throw "不是数字";
        x = Number(x);
        if(x < 5)    throw "太小";
        if(x > 10)   throw "太大";
    }
    catch(err) {
        message.innerHTML = "错误: " + err;
    }
}
```

常用对象：

window

document

console

