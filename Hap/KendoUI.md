## kendoUI validator 表单验证

### 实现方式一

**验证规则和提示信息写在input标签的属性中**

- 通过标签的`pattern`和`validationMessage` 实现

```html
<div id="page-content">
    <form id="mainform" class="form-horizontal" method="post"
        <input type="text" required style="width:100%" name="myId"
                pattern="^[0-9a-zA-Z]{1,64}$" validationMessage="{0}只包含字母和数字,且长度为1-64"
                data-bind="value:model.myId" class="k-textbox">
        <input type="text" required style="width:100%" name="myName"
                pattern=".{1,64}" validationMessage="{0}长度为1-64"
                data-bind="value:model.myName" class="k-textbox">
        <input type="text" required style="width:100%" name="myAge"
                pattern="^([1-9]|1\d{2}|[1-9]\d)$" validationMessage="{0}为1-200的自然数"
                data-bind="value:model.myAge" class="k-textbox">
    </form>
</div>
```

- 使用

```javascript
var validator = $("#page-content").kendoValidator().data("kendoValidator");
if (validator.validate()){
    //valid. do something
} else{
    //invalid. notify user
}
```

### 实现方式二

**验证规则和提示写在JavaScript代码中**

- html

```html
<div id="page-content">
    <form id="mainform" class="form-horizontal" method="post"
        <input type="text" required style="width:100%" name="myId"
               data-bind="value:model.myId" class="k-textbox">
        <input type="text" required style="width:100%" name="myName"
               data-bind="value:model.myName" class="k-textbox">
       <input type="text" required style="width:100%" name="myAge"
               data-bind="value:model.myAge" class="k-textbox">
    </form>
</div>
```

- 验证器和验证规则

```javascript
var validator = $("#page-content").kendoValidator({
    rules: {
        idRange: function (input) {
            if (input.is("[name=myId]")) {
                var value = input.val();
                return value && /^[0-9a-zA-Z]{1,64}$/.test(value);
            }
            return true;
        },
        ageRange: function (input) {
            if (input.is("[name=myAge]")) {
                var value = input.val();
                // 自然数<200
                return /^([1-9]|1\d{2}|[1-9]\d)$/.test(value);
            }
            return true;
        },
        nameRange: function (input) {
            if (input.is("[name=myName]")) {
                var value = input.val();
                return value.length <= 64;
            }
            return true;
        },
    },
    messages: {
        idRange: "{0}只包含字母和数字,且长度不能超过64位",
        ageRange: "{0}范围只能为1-199",
        nameRange: "{0}不能超过64个汉字"
    },
}).data("kendoValidator");

if (validator.validate()){
    //valid. do something
} else{
    //invalid. notify user
}
```

## kendoUI模板引擎：

[原文](https://www.jianshu.com/p/742df82da47d)

kendoUI中的模板引擎使用的语法叫做`#号语法`，或者`hash syntax（哈希语法）`。

它的主要作用是:

- `渲染数据`和`执行js表达式`

### 1. 渲染数据到html模板

- 第一种：使用`=号`渲染`原始值`
   `#= myVar #`
- 第二种：使用`:号`渲染`html编码值`
   `#: myVar #`
- 两者的区别：
   当数据值中`包含HTML标签`时，`冒号`方式会对值里的HTML标签进行`转义`，从而可以把标签作为字符串直接输出。

区别示例：

```css
//uses #= #
var myTemplateRaw = kendo.template("<p>#= name #</p>");
var newHTMLRaw = myTemplateRaw({name:"<strong>zmh</strong>"});
console.log(newHTMLRaw); //<p><strong>zmh</strong></p>
$("#container").append(newHTMLRaw);

//uses #: #
var myTempalteHTMLEncoded = kendo.template("<p>#: name #</p>");
var newHTMLEncoded = myTempalteHTMLEncoded({name:"<strong>zhouminghang</strong>"});
console.log(newHTMLEncoded); //<p>&lt;strong&gt;zhouminghang&lt;/strong&gt;</p>
$("#container").append(newHTMLEncoded);
```

页面结果：

```css
zmh
<strong>zhouminghang</strong>
```

> *很明显，=号过滤掉了html标签，但：号会将html标签作为字符串输出。*

### 2. 执行js表达式 # expression

- 示例1：

```css
<script type="text/x-kendo-template">
    <ul>
    # for (var i = 0; i < data.length; i++){ #
           <li>#= data[i] #</li>
    # } #
    </ul>
</script>
```

- 示例2：

```css
var template = "#if(foo) {# #= foo # is true #}#";
```

- 示例3：

```css
<script type="text/x-kendo-template">
    #if(isAdmin){#
        <li>#: name # is Admin</li>
    #}else{#
         <li>#: name # is not Admin</li>
    #}#
</script>
```

无论是在行内模板中，还是在外部模板中，都可以使用JS变量和表达式。

- 注意：
   js表达式中都要`以#开头`，`以#结束`，注意`单双引号`的`嵌套`，一般为`外双内单`。
   如果表达式中存在 `#号特殊字符`，比如style中颜色用#号值，注意使用`双斜杠\\`，进行`转义`，不是单斜杠，否则会报无效的模板错误。