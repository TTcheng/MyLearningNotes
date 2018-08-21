## 什么是 jQuery ？

jQuery是一个JavaScript函数库。

jQuery是一个轻量级的"写的少，做的多"的JavaScript库。

jQuery库包含以下功能：

- HTML 元素选取
- HTML 元素操作
- CSS 操作
- HTML 事件函数
- JavaScript 特效和动画
- HTML DOM 遍历和修改
- AJAX
- Utilities

## 为什么使用 jQuery ？

目前网络上有大量开源的 JS 框架, 但是 jQuery 是目前最流行的 JS 框架，而且提供了大量的扩展。

Write less，do more.

## jQuery选择器

### 1.基本选择器

```js
$("#id")            //ID选择器
$("div")            //元素选择器
$(".classname")     //类选择器
$(".classname,.classname1,#id1")     //组合选择器
```

### 2.层次选择器

```js
$("#id>.classname ")    //子元素选择器
$("#id .classname ")    //后代元素选择器
$("#id + .classname ")    //紧邻下一个元素选择器
$("#id ~ .classname ")    //兄弟元素选择器
```

### 3.过滤选择器(重点)

```js
$("li:first")    //第一个li
$("li:last")     //最后一个li
$("li:even")     //挑选下标为偶数的li
$("li:odd")      //挑选下标为奇数的li
$("li:eq(4)")    //下标等于4的li
$("li:gt(2)")    //下标大于2的li
$("li:lt(2)")    //下标小于2的li
$("li:not(#runoob)") //挑选除 id="runoob" 以外的所有li
```

#### **3.2内容过滤选择器**

```js
$("div:contains('Runob')")    // 包含 Runob文本的元素
$("td:empty")                 //不包含子元素或者文本的空元素
$("div:has(selector)")        //含有选择器所匹配的元素
$("td:parent")                //含有子元素或者文本的元素
```

#### **3.3可见性过滤选择器**

```js
$("li:hidden")       //匹配所有不可见元素，或type为hidden的元素
$("li:visible")      //匹配所有可见元素
```

#### **3.4属性过滤选择器**

```js
$("div[id]")        //所有含有 id 属性的 div 元素
$("div[id='123']")        // id属性值为123的div 元素
$("div[id!='123']")        // id属性值不等于123的div 元素
$("div[id^='qq']")        // id属性值以qq开头的div 元素
$("div[id$='zz']")        // id属性值以zz结尾的div 元素
$("div[id*='bb']")        // id属性值包含bb的div 元素
$("input[id][name$='man']") //多属性选过滤，同时满足两个属性的条件的元素
```

#### **3.5状态过滤选择器**

```js
$("input:enabled")    // 匹配可用的 input
$("input:disabled")   // 匹配不可用的 input
$("input:checked")    // 匹配选中的 input
$("option:selected")  // 匹配选中的 option
```

### 4.表单选择器

```js
$(":input")      //匹配所有 input, textarea, select 和 button 元素
$(":text")       //所有的单行文本框，$(":text") 等价于$("[type=text]")，推荐使用$("input:text")效率更高，下同
$(":password")   //所有密码框
$(":radio")      //所有单选按钮
$(":checkbox")   //所有复选框
$(":submit")     //所有提交按钮
$(":reset")      //所有重置按钮
$(":button")     //所有button按钮
$(":file")       //所有文件域
```

## jQuery选择器举例

jQuery 选择器允许您对 HTML 元素组或单个元素进行操作。

jQuery 选择器基于元素的 id、类、类型、属性、属性值等"查找"（或选择）HTML 元素。 它基于已经存在的 [CSS 选择器](https://www.runoob.com/cssref/css-selectors.html)，除此之外，它还有一些自定义的选择器。

jQuery 中所有选择器都以美元符号开头：$()。

### 元素选择器

jQuery 元素选择器基于元素名选取元素。

在页面中选取所有 <p> 元素:

```js
 $("p") 
```

**实例**

用户点击按钮后，所有 <p> 元素都隐藏： 

```javascript
$(document).ready(function(){   
    $("button").click(function(){     
        $("p").hide();   
    }); 
});
```

### id选择器

jQuery #id 选择器通过 HTML 元素的 id 属性选取指定的元素。

页面中元素的 id 应该是唯一的，所以您要在页面中选取唯一的元素需要通过 #id 选择器。

通过 id 选取元素语法如下：

` $("#test") `

**实例**

当用户点击按钮后，有 id="test" 属性的元素将被隐藏：

```js
$(document).ready(function(){
  $("button").click(function(){
    $("#test").hide();
  });
});
```

###  .class 选择器

jQuery 类选择器可以通过指定的 class 查找元素。

语法如下：

` $(".test") `

**实例**

用户点击按钮后所有带有 class="test" 属性的元素都隐藏：

```js
$(document).ready(function(){   
    $("button").click(function(){     
        $(".test").hide();   
    }); 
});
```

## 实用案例集

```js
$('#employee option:not(:first)').remove();//选择除第一个子元素以外的所有元素
```




