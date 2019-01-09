# ES6

## let-const

**const**:常量不可更改，指的是变量名不可再次赋值。变量如果是个对象，是允许更改变量内部内容的。

```js
const a = 4;
a = 5;//报错
const b = {a:6};
b.a = 7;//正常运行
b = {name:'Jesse'};//报错
```

**let** 变量

let与var的区别

| 语法 | 作用域     |
| ---- | ---------- |
| let  | 块级作用域 |
| var  | 函数作用域 |

## 模板字符串

简化了多字符串拼接的复杂程度

```js
let name = "Jesse";
//字符串拼接
let html = '<p>'+name+'</p>';
// 模板字符串
let html = `<p>${name}<p>`;
```

## 函数的扩展

- **函数默认值**

```js
function add(a,b=6){
    return a+b;
}
```

- 箭头函数(labmda)

```js
var add = (a,b=7)=>a+b;
```

 **关于箭头函数的this**
==箭头函数的this始终指向函数创建时的this(函数上下文，简单对象是没有执行上下文的)==

a.普通函数

```js
var obj = {
    a:5,
    func:function(){
        console.log(this.a);//this = obj
    },
    test:function(){
        var that = this;
        setTimeout(function(){
            //this.func();//this = window
            that.func();
        },1);
    }
}
obj.test();
```

b.箭头函数

```js
var obj = {
    a:5,
    func:()=>{
        //this = window
        console.log(this.a);
    },
    test:function(){
        setTimeout(()=>{
        	//this = obj
        	this.func();
    	},1)
    }
}
obj.test();
```

## 对象扩展

- 对象的简写

```js
var a = 5;
var obj = {
    a,	//属性简写，等同于 a:a,
    b(){
        console.log(this.a);
    }
    //方法简写，等同于b:function(){...}
}
```

- Object.keys(targetObj);

```js
var obj = {a:5,b(){....}};
var keys = Object.keys(obj);
// keys = ['a','b']
```

- Object.assign(obj1,obj2);

合并obj2到obj1

```js
var obj1 = {a:1}
var obj2 = {b:10}
Object.assign(obj1,obj2);
//obj1 = {a:1,b10}
```

- Object.defineProperty(targetObj,{...})

```js
Object.defineProperty(targetObj,{
    value:14,
    writable:false,
    configurable:false,
    enumerable:false,//是否能被遍历
    get(){...},
  	set(){...}
    
})
```

## Class简介

ES6新增class，extends关键字，使面向对象更加接近Java等面向对象的语法。

```js
class Person{
    constructor(name,age){
        this.name = name;
        this.age = age;
    }
    showName(){
        console.log(this.name);
    }
    static sayHello(){
        console.log("Hello ");
    }
}
let jesse = new Person("Jesse",16);
console.log(jesse.name);
jesse.showName();
Person.sayHello();
```

## 解构赋值

- 数组解构

```js
let [a,b,c] = [1,2,3];
console.log(a)//output 1
```

- 对象解构

```js
let obj = {a:1,b:2,c:3}
let {a} = obj;
console.log(a)//output 1

function a_plus_b)({a,b}){
    return a+b;
}
let res = a_plus_b(obj);//res = 3
```

- 字符串解构

```js
let [a,b]="张三"; // a = "张",b="三"
```

## Babel — ES转码器

1、安装Babel

`npm install babel-cli --save-dev`

2、定义转码规则

`npm install --save-dev label-preset-es2015`

修改.babelrc配置转码规则

3、 编写package.json使用命令转码

## 模块

export

```js
//common.js
export var firstName = "Jesse";
export var lastName = "pinkman";
// export {firstName,lastName}
```

==需要注意的是，对外导出的必须是个接口==

以下两种方式都是错误的

```js
var name = "Jesse";
export 1;		//错误
export name;	//错误
```

import 

```js
//test.js
import {firstName} from './common'
console.log(firstName);//output Jesse
```



