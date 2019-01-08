
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