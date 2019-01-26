# Thymeleaf 简易教程

> 作者：codergege
>
> 链接：https://www.jianshu.com/p/a7056b023df0
>
> 來源：简书
>
> 简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。

本文源码可以在这里下载: [https://github.com/codergege/springmvc-thymeleaf-demo.git](https://link.jianshu.com?t=https://github.com/codergege/springmvc-thymeleaf-demo.git)

```shell
git clone https://github.com/codergege/springmvc-thymeleaf-demo.git
cd springmvc-thymeleaf-demo
./gradlew appRun
```

我没在 windows 中试过, 如果运行不起来, 看源码吧 ...

## 1.1 SpringMVC 中整合 Thymeleaf

首先要加入 thymeleaf 依赖. 如果你用 gradle, 加入这样的依赖就可以了:

```groovy
// thymeleaf 视图
compile group: 'org.thymeleaf', name: 'thymeleaf-spring4', version: thymeleafVersion
```

version 那里可以换成自己想用的版本.

Demo 项目中使用 gradle + springmvc + thymeleaf

根据需要可以将 gradle 换成 maven.

三个必须配的 bean.

Demo 项目中使用 JavaConfig 的方式, 你也可以使用 xml 方式配置.

```java
@Configuration
public class ThymeleafConfig implements ApplicationContextAware {

    private static final String UTF8 = "UTF-8";
    private ApplicationContext applicationContext;

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        this.applicationContext = applicationContext;
    }

    /* **************************************************************** */
    /*  THYMELEAF-SPECIFIC ARTIFACTS                                    */
    /*  TemplateResolver <- TemplateEngine <- ViewResolver              */
    /* **************************************************************** */

    @Bean
    public SpringResourceTemplateResolver templateResolver(){
        // SpringResourceTemplateResolver automatically integrates with Spring's own
        // resource resolution infrastructure, which is highly recommended.
        SpringResourceTemplateResolver templateResolver = new SpringResourceTemplateResolver();
        templateResolver.setApplicationContext(this.applicationContext);
        templateResolver.setPrefix("/WEB-INF/templates/");
        templateResolver.setSuffix(".html");
        // HTML is the default value, added here for the sake of clarity.
        templateResolver.setTemplateMode(TemplateMode.HTML);
        // Template cache is true by default. Set to false if you want
        // templates to be automatically updated when modified.
        // Template 缓存, 如果设置为 false, 那么当 templates 改变时会自动更新
        templateResolver.setCacheable(false);
        return templateResolver;
    }

    @Bean
    public SpringTemplateEngine templateEngine(){
        // SpringTemplateEngine automatically applies SpringStandardDialect and
        // enables Spring's own MessageSource message resolution mechanisms.
        SpringTemplateEngine templateEngine = new SpringTemplateEngine();
        templateEngine.setTemplateResolver(templateResolver());
        // Enabling the SpringEL compiler with Spring 4.2.4 or newer can
        // speed up execution in most scenarios, but might be incompatible
        // with specific cases when expressions in one template are reused
        // across different data types, so this flag is "false" by default
        // for safer backwards compatibility.
        templateEngine.setEnableSpringELCompiler(true);
        return templateEngine;
    }

    @Bean
    public ThymeleafViewResolver viewResolver(){
        ThymeleafViewResolver viewResolver = new ThymeleafViewResolver();
        viewResolver.setTemplateEngine(templateEngine());
        viewResolver.setCharacterEncoding(UTF8);
        return viewResolver;
    }
}
```

准备就绪, 可以愉快的玩耍 thymeleaf 了, let's go!

## 1.2 Spring boot中整合Thymeleaf

maven依赖

```xml
<dependency>
     <groupId>org.springframework.boot</groupId>
     <artifactId>spring-boot-starter-thymeleaf</artifactId>
</dependency>
```

配置application.properties

```properties
#thymeleaf start
spring.thymeleaf.prefix=classpath:/templates/
spring.thymeleaf.suffix=.html
spring.thymeleaf.enabled=true
spring.thymeleaf.mode=HTML
spring.thymeleaf.encoding=UTF-8
spring.thymeleaf.check-template=true
spring.thymeleaf.enable-spring-el-compiler=false
#开发时关闭缓存,不然没法看到实时页面
spring.thymeleaf.cache=true
# ......
#spring.messages.basename=static/messages
#thymeleaf end
```

## 2. 使用 th:text

### 2.1 外部文本(消息)

```
<p th:text="#{index.welcome}">Welcome Message</p>
```

外部文本的概念: 外部文本抽取模板代码片段到模板文件外面, 使外部文本可以存在另一个
 文件中(比如 properties 文件). 通常把外部文本叫做消息(messages).

Thymeleaf 通过 `#{...}` 语法来使用消息.

在 springmvc 中使用消息要额外配置 ResourceBundleMessageSource 这个 bean:

```
    // 用于外部文本及国际化消息
    @Bean
    public ResourceBundleMessageSource messageSource() {
        ResourceBundleMessageSource messageSource = new ResourceBundleMessageSource();
        messageSource.setBasename("messages");
        return messageSource;
    }
```

这个 bean 会去 classpath 根目录下去寻找 messages 为基名的 properties 文件. 比如,
 messages.properties, messages_en_US.properties, messages_zh_CN.properties.

`th:text` 外部文本会替换 p 标签内的内容.

### 2.2 使消息不转换 html 标签

如果我们在 messages.properites 中这么写: `index.welcome=Welcome to <b>SpringMVC</b>`
 那么 thymeleaf 会转成 `<p>Welcome to &lt;b&gt;SpringMVC&lt;/b&gt;</p>` 这显然不是
 我们想要的. 这时候就可以用 `th:utext`(for “unescaped text)

### 2.3 使用并显示变量

变量概念: 存在 java web 上下文中的变量. 比如 request, session, application, page ...

用 `${...}` 语法可以用来显示变量. 花括号内使用的是 ognl 表达式语言.

springmvc 中用 spel 语言代替 ognl 语言.

## 3. 标准表达式语法

概览:

- 简单表达式
  - 变量表达式: `${...}` 
  - 选择变量表达式: `*{...}` 
  - 消息表达式: `#{...}` 
  - URL 表达式: `@{...}` 
  - 代码段表达式: `~{...}` 
- 字面量
  - 文本字面量: `'some text'` 
  - 数值字面量: `0, 34, 3.0, 12.3` 
  - 布尔值字面量: `true, false` 
  - Null 值字面量: `null` 
  - Tokens 字面量: `one, content, sometext, ...` 
- 文本操作符
  - 字符串连接: `+` 
  - 字面量替换: `|The name is ${name}|` 
- 算术操作符
  - 二元操作符: `+, -, *, /, %` 
  - 减号(一元操作符): `-` 
- 布尔操作符(逻辑操作符)
  - 二元操作符: `and, or` 
  - 非(一元操作符): `!, not` 
- 比较操作符
  - 比较: `>, <, >=, <= (gt, lt, ge, le)` 
  - 相等性: `==, != (eq, ne)` 
- 条件操作符
  - if-then: `(if) ? (then)` 
  - if-then-else: '(if) ? (then) : (else)'
  - 默认: (value) ?: (defaultvalue)
- 特殊符号
  - 忽略 Thymeleaf 操作: `_` 

所有这些特性都可以组合, 嵌套使用.

### 3.1 消息

消息中也可以包含变量, 比如在 `index.welcome` 中, 想打印出时间:

```
# 在 messages.properties 文件中用 {0}, {1}, {2}, ... 占位符
index.welcome=Welcome to <b>SpringMVC</b>, time is: {0}
```

那么在 index.html 模板文件中就可以这样写:

```
<p th:utext="#{index.welcome(${date})}">Welcome message</p>
```

其中 `${date}` 就像一个参数那样被传进去了.

### 3.2 变量

变量表达式 `${...}` 用的是 ognl(对象图导航语言). 在 springmvc 中用 spel(spring 表达式语言)
 代替. 其实两者在大部分情况下用法是相同的.

Ognl, spel 不在本文范围, 不展开讨论了.

下面看几个例子就知道变量表达式的大部分用法了.

```
<!-- springmvc 保存了一个 model 对象: departments -->

<!-- 获取所有 departments -->
<p th:text="${departments}"></p>
<!-- 获取 departments 的第一个元素 -->
<p th:text="${departments[0]}"></p>
<!-- 获取第一个 department 对象的 name 属性 -->
<p th:text="${departments[0].name}"></p>
<!-- 也可以用 ['name'] 来获取第一个 department 对象的 name 属性 -->
<p th:text="${departments[0]['name']}"></p>
<!-- 甚至可以调用方法! -->
<p th:text="${departments[0].getId()}"></p>
<p th:text="${departments[0]['name'].substring(0, 1)}"></p>
```

#### 3.2.1 内置基本对象

下面是一些内置的基本对象, 可以用 `#` 符号直接使用

- # ctx: the context object.

- # vars: the context variables.

- # locale: the context locale.

- # request: (only in Web Contexts) the HttpServletRequest object.

- # response: (only in Web Contexts) the HttpServletResponse object.

- # session: (only in Web Contexts) the HttpSession object.

- # servletContext: (only in Web Contexts) the ServletContext object.

使用例子:

```
country: <span th:text="${#locale.country}"></span>
```

#### 3.2.2 内置工具对象

除了基本对象, thymeleaf 还提供了一组工具对象.

- # execInfo: information about the template being processed.

- # messages: methods for obtaining externalized messages inside variables expressions, in the same way as they would be obtained using #{…} syntax.

- # uris: methods for escaping parts of URLs/URIs

- # conversions: methods for executing the configured conversion service (if any).

- # dates: methods for java.util.Date objects: formatting, component extraction, etc.

- # calendars: analogous to #dates, but for java.util.Calendar objects.

- # numbers: methods for formatting numeric objects.

- # strings: methods for String objects: contains, startsWith, prepending/appending, etc.

- # objects: methods for objects in general.

- # bools: methods for boolean evaluation.

- # arrays: methods for arrays.

- # lists: methods for lists.

- # sets: methods for sets.

- # maps: methods for maps.

- # aggregates: methods for creating aggregates on arrays or collections.

- # ids: methods for dealing with id attributes that might be repeated (for example, as a result of an iteration).

例子, 格式化时间:

```
<!-- 时间格式化 -->
time:<span th:text="${#dates.format(date, 'yyyy-MM-dd HH:mm:ss')}"></span><br>
```

### 3.3 选择变量表达式

获取变量可以使用 `${...}` 语法外, 还可以使用 `*{...}`, 称为选择变量表达式.

选择变量表达式与变量表达式的不同之处在于, 如果前面有一个选择对象了, 那么用它获取
 这个选择对象的属性或方法时, 可以不写对象名.

那么选择对象的概念是什么呢? 选择对象是用 `th:object` 表示的对象.

看例子:

```
<p>选择变量表达式</p>
<div th:object="${departments[1]}">
    <p th:text="*{id}"></p>
    <p th:text="*{name}"></p>
</div>
<p>等价的变量表达式</p>
<div>
    <p th:text="${departments[1].id}"></p>
    <!-- 如果没有 "选择对象", 那么 * 和 $ 是等价的 -->
    <p th:text="*{departments[1].name}"></p>
</div>
```

如果存在选择对象了, 那么在 `${...}` 中也可以用 `#object` 来使用选择对象.

```
<p>${...} 中使用 #object 引用 "选择对象"</p>
<div th:object="document[2]">
    <!--　以下三种方式在这种情况下是等价的 -->
    <p th:text="${#object.id}"></p>
    <p th:text="*{id}"></p>
    <p th:text="${document[2].id}"></p>
</div>
```

### 3.4 Link URL 表达式

链接 URL 表达式语法是 `@{...}`

有不同类型的 URLs:

- 绝对路径 URLs: `http://localhost:8888/demo/index`
- 相对路径 URLs:
  - 页面相对: `user/login.html` 
  -  **上下文相对**: `/employee/emps` 注意用 `/` 打头, 会自动把上下文路径(比如 [http://localhost:8888/demo](https://link.jianshu.com?t=http://localhost:8888/demo)) 路径加上去.
  - 服务器相对(不重要)
  - 协议相对(不重要)

例子:

```html
<!-- Common styles and scripts -->
<link rel="stylesheet" type="text/css" media="all" th:href="@{/assets/css/base.css}">
<script type="text/javascript" th:src="@{/assets/ext/jquery-3.1.1-min.js}"></script>
<script type="text/javascript" th:src="@{/assets/js/codergege.js}"></script>

<!-- ... -->

<a href="#" th:href="@{/}">返回首页</a> <br>
<a href="#" th:href="@{/thymeleaf/demo1}">去 demo1 页面</a> <br>
<!-- 会生成 url: http://localhost:8888/demo/thymeleaf/demo1?username=赵波 -->
<a href="#" th:href="@{/thymeleaf/demo1(username=${employees[0].name})}">去 demo1 页面, 带参数</a> <br>
<!-- 会生成 url: http://localhost:8888/demo/thymeleaf/demo1/2 RESTful 风格的 url -->
<a href="#" th:href="@{/thymeleaf/demo1/{empId}(empId=${employees[1].id})}">去 demo1 页面, 带 RESTful 风格参数</a> <br>
```

中文会自动转码; 如果有多个参数，用逗号隔开.

### 3.5 代码段(fragment)

定义fragment

```html
<footer th:fragment="copy">  
   the content of footer 
</footer>
```

语法: `~{...}`

最常见的用法是与 `th:insert` 或 `th:replace` 配合使用. 例如:

```html
<!-- ~{...} 可以省略不写 -->
<header id="header" th:replace="fragment :: header"></header>

<footer id="footer" th:replace="~{fragment :: footer}"></footer>
```

### 3.6 字面量

#### 3.6.1 文本字面量

很简单, 用单引号包裹起来就是一个文本字面量了. 文本字面量可以包含任意字符, 但是如
 果想包含 `'` , 得用 \ 进行转意.

```
<p th:text="'Any characters, <br>Let\'s</br> go!'"></p>
```

页面上显示效果:

```
Any characters, <br>Let's</br> go!
```

可以看到 `<br>` 不会被 html 解析, 按字面量显示了!

#### 3.6.2 数字字面量

```
<p>
    今年是 <span th:text="2017"></span> <br>
    明年是 <span th:text="2017 + 1"></span>
</p>
```

页面显示效果:

```
今年是 2017 
明年是 2018
```

#### 3.6.3 布尔值字面量

布尔值字面量直接用 true, false 就可以了.

```html
<p>
    <div th:if="${departments.size() > 0} == true">条件是真, div 内会被解析, 内容会显示<div>
    <div th:if="${departments.size() > 0} == false">条件是假, 这个 div 元素不会被解析, 所以不会显示<div>
    <div th:if="${(departments.size() > 0) == true}">
        == 可以放在 {} 内部, 这种情况下, 表达式计算用的是 ognl/spel 引擎. 条件是真, div 内会被解析, 内容会显示
    </div>
</p>
```

页面显示效果:

```
条件是真, div 内会被解析, 内容会显示
== 可以放在 {} 内部, 这种情况下, 表达式计算用的是 ognl/spel 引擎. 条件是真, div 内会被解析, 内容会显示
```

注意看第二个 div, `th:if` 返回 false 后, 这个 div 元素就不会在页面中存在了.

第三个 div, == 放在了 {} 内部, 此时整个 {} 内的表达式用 ognl/spel 引擎计算; 如果
 == 放在外部, 那么 thymeleaf 引擎负责计算是否相等.

#### 3.6.4 null 字面量

```
<div th:if="${departments} != null">会显示</div>
<div th:if="${departments != null}">用 ognl/spel 引擎, 会显示</div>
```

页面显示效果:

```
会显示
用 ognl/spel 引擎, 会显示
```

#### 3.6.5 字面量 tokens

数值, 布尔值, null 实际上是 tokens 字面量的特别情况.

Tokens 字面量允许省略单引号, 只要符合: 由 A-Z, a-z, 0-9, 方括号([, ]), 点(.), 连字符(-),
 下划线(_) 组成.

所以, 没有空格, 逗号等等.

```
<div th:text="content">...</div>
<!-- 上面就等价于 -->
<div th:text="'content'">...</div>
```

### 3.7 连接字符串

文本, 不管是文本字面量还是通过 ognl/spel 计算出来的文本, 都能用 + 操作符连接.

```
<span th:text="'Some literal text and ' + ${departments[0].name}"></span>
```

### 3.8 字面量替换

使用字面量替换, 可以省去 '...' + '...' 这种麻烦. 语法是 `|...|`

```
<p th:text="|一共有 ${departments.size()} 个部门|"></p>
<!-- 等价于下面 -->
<p th:text="'一共有 ' + ${departments.size()} + ' 个部门'"></p>
<!--还可以混合使用-->
<p th:text="'一共有 ' + |${departments.size()} 个部门|"></p>
```

`|...|` 内部只允许使用变量表达式, 不能有其他的 '...' 字面量, 布尔值数值字面量, 以及
 条件表达式等等.

### 3.9 算术操作符

```
<div th:with="isEven = (${employees.size()} % 2 == 0)"></div>
<!-- 也可以包含在 {} 内, 那么 {} 内的整体就是一个 ognl/spel 表达式, 由 ognl/spel 引擎负责计算 -->
<div th:with="isOdd = ${employees.size() % 2 == 1}">
    <span th:if="${isOdd}">是奇数</span>
    <span th:if="!${isOdd}">是偶数</span>
</div>
```

注意 `th:with` 的作用是声明一个局部变量. 这个局部变量的作用域是 声明时的元素及其
 子元素.

所以如果放在 声明 isOdd 变量的 div 外面, isOdd 变量就不存在了.

### 3.10 比较与相等操作符

```
<!-- >, <, 必须转意才能用 -->
<div th:if="${departments.size()} &gt; 1">
    <span th:text="|部门数量是 ${departments.size()}|"></span>
</div>
<!-- 可以用 gt, lt, ge, le 来代替, 这种比较好 -->
<div th:if="${departments.size()} ge 3">
    <span>至少有 3 个部门</span>
</div>
```

### 3.11 条件表达式与默认表达式

条件表达式由 3 个部分组成, condition, then, else. 每个部分自身又是一个表达式, 即
 它们分别可以用变量(`${...}, *{...}`), 消息(`#{...}`), URLs(`@{...}`), 字面量等来
 表示.

```
<!-- else 部分可以省略, 这种情况下, 如果条件为 false, null 值会被返回 -->
<p th:class="${employees[0].id % 2 == 0}? 'even'" th:text="${employees[0].name}"></p>
<p th:class="${employees[1].id % 2 == 0}? 'even': 'odd'" th:text="${employees[1].name}"></p>
<p th:class="${employees[2].id % 2 == 0}? 'even': 'odd'" th:text="${employees[2].name}"></p>

<!-- ?: 默认表达式 -->
<span th:text="${employees[0].getGender()}?: '没有指定性别'"></span> <br>
<span th:text="${employees[2].getEmail()}?: '没有指定邮箱'"></span> <br>

<!-- 可以嵌套混合, 嵌套的话用 () 包起来 -->
<span th:text="(${employees[0].getGender()} == 1 ? '男': '女')?: '没有指定性别'"></span>
```

### 3.12 No-Op 操作符(_)

No-Op 操作符指明期待的表达式结果不做任何事情. 比如说 th:text 中最后计算结果是 `_`
 那么 th:text 元素根本就不会生成.

```
<p th:text="_">这里的内容不会被 th:text 替换</p>
<p th:text="${employees[0].email}?: _">没有指定电子邮箱</p>
```

### 3.13 数据转换与格式化

Thymeleaf 的变量表达式(`${...}, *{...}`)使用 `{{...}}` 来表示需要进行转换. 允许我
 们使用自定义的数据转换服务来转换表达式返回结果.

使用 thymeleaf-spring3 和 thymeleaf-spring4 的话, 会自动调用 spring 的 Conversion
 Service.

### 3.14 预处理表达式

用双下划线 `__...__` 包裹普通的表达式就可以.

## 4. 设置属性值

本章学习 thymeleaf 如何设置或修改 html 元素属性.

### 4.1 设置任意属性 th:attr

可以用 `th:attr` 来设置任意属性.

```html
<!-- 替换 action 属性 -->
<form action="#" th:attr="action=@{/suscribe}">
    <input type="text" name="name">
    <input type="text" name="gender">
    <input type="text" name="birthday">
    <input type="text" name="email">
    <!-- todo select departments -->
    <!-- 一次替换多个属性值 1) submit 按钮的 value 属性; 2) class 属性  -->
    <input type="submit" value="Submit" th:attr="value=#{form.submit}, class='sep'">
</form>
```

### 4.2 设置指定属性

一般 `th:attr` 很少会用到, 而是会直接使用指定的 `th:*`.

比如已经用过的 `th:href, th:text, th:value, th:action ...`

几乎所有的 html 元素属性都有对应的 `th:*` 版本.

### 4.3 追加属性

可以使用 `th:attrappend, th:attrprepend` 来追加(不是替换)属性值.

这个不常用.

但是 `th:classappend` 比较常用:

```
<p class="row" th:classappend="odd">aaaaa</p>
<p class="row" th:classappend="${employees[0].id % 2 == 1} ? 'odd'">aaaaa</p>
```

### 4.4 固定值布尔属性

典型代表就是 checkbox, radio 中的 checked 属性了.

可以使用 `th:checked` 来设置, 如果表达式返回 true, checked 就被设置, 返回 false,
 checked 属性就不会加上去.

```
<form action="#" th:object="${employees[0]}">
    男 <input type="radio" name="gender" th:checked="*{gender} == 1">
    女 <input type="radio" name="gender" th:checked="*{gender} == 0">
</form>
```

### 4.5 任意属性处理器

`th:*` 中, * 如果不是 html 中的属性, 也会当成属性加进去.

```
<span th:xxx="${employees[2].name}"></span>
```

通过查看页面源码, 可以看到:

```
<span xxx="aa"></span>
```

## 5. 迭代

### 5.1 迭代初步

#### 使用 `th:each` 

```html
<ul>
    <li>
        <span class="list">编号</span>
        <span class="list">姓名</span>
        <span class="list">性别</span>
        <span class="list">生日</span>
        <span class="list">部门</span>
        <span class="list">编辑</span>
        <span class="list">删除</span>
    </li>
    <li th:each="emp : ${employees}">
        <span class="list" th:text="${emp.id}"></span>
        <span class="list" th:text="${emp.name}"></span>
        <span class="list" th:text="${emp.gender == 1} ? '男': '女'"></span>
        <span class="list" th:text="${{emp.birthday}}"></span>
        <span class="list" th:text="${emp.department.name}"></span>
        <span class="list"><a href="#">编辑</a></span>
        <span class="list"><a href="#">删除</a></span>
    </li>
</ul>
```

`th:each` 用起来很方便, 就像 java 中的 for 循环一样.

```
for(Employee emp: employees) {
    // Do something
}
```

在 thymeleaf 中使用迭代太方便了! 回想 jstl 那些坑爹的标签, 泪都留下来...

#### 可以用 `th:each` 迭代的 java 类型

`th:each` 不仅仅可以对 java.util.List 类型迭代, 实际上大部分的 java 集合类型都可
 以使用它来迭代.

- 实现了 java.util.Iterable 接口的对象
- 实现了 java.util.Enumeration 接口的对象
- 实现了 java.util.Iterator 接口的对象, 不会一次性读入内存, 返回一个读一个.
- 实现了 java.util.Map 接口的对象, 这时候迭代的值是 java.util.Map.Entry.
- 任何数组

### 5.2 保存迭代状态

```
th:each` 还提供了一个变量可以保存迭代状态. 用法是 `th:each="emp, status: ${employees}"
```

状态变量保存了以下数据:

- index 属性, 0 开始的索引值
- count 属性, 1 开始的索引值
- size 属性, 集合内元素的总量
- current 属性, 当前的迭代对象
- even/odd 属性, boolean 类型的, 用来判断是否是偶数个还是奇数个
- first 属性, boolean 类型, 是否是第一个
- last 属性, boolean 类型, 是否是最后一个

看例子:

```
<ul>
    <li>
        <span class="list">编号</span>
        <span class="list">姓名</span>
        <span class="list">性别</span>
        <span class="list">生日</span>
        <span class="list">部门</span>
        <span class="list">编辑</span>
        <span class="list">删除</span>
        <span class="list status">当前迭代状态</span>
    </li>
    <li th:each="emp, status: ${employees}" th:class="${status.odd} ? 'odd': 'even'">
        <span class="list" th:text="${emp.id}"></span>
        <span class="list" th:text="${emp.name}"></span>
        <span class="list" th:text="${emp.gender == 1} ? '男': '女'"></span>
        <span class="list" th:text="${{emp.birthday}}"></span>
        <span class="list" th:text="${emp.department.name}"></span>
        <span class="list"><a href="#">编辑</a></span>
        <span class="list"><a href="#">删除</a></span>
        <span class="list status" th:text="|index: ${status.index}; count: ${status.count}; size: ${status.size}; first: ${status.first}|"></span>
    </li>
</ul>
```

也可以不显式声明 status 变量, thymeleaf 会自动创建一个, 状态变量的名称是你声明的
 变量加上 Stat, 比如上面的例子 `emp: ${emplopyees}` 会创建一个 `empStat` 的状态变量

## 6. 控制表达式

### 6.1 if 和 unless

`th:unless` 是 `th:if` 的相反条件, 所以只用 `th:if` 就可以了.

`th:if` 如果返回 true, 其所在的 html 元素会被 thymeleaf 解析. 返回 false, 就当这
 个 html 元素不存在了.

不只是布尔值的 true 和 false, `th:if` 表达式返回其他值时也会被认为是 true 或 false.

规则如下:

- 值是非 null:
  - boolean 类型并且值是 true, 返回 true
  - 数值类型并且值不是 0, 返回 true
  - 字符类型(Char)并且值不是 0, 返回 true
  - String 类型并且值不是 "false", "off", "no", 返回 true
  - 不是 boolean, 数值, 字符, String 的其他类型, 返回 true
- 值是 null, 返回 false

看例子:

```
<div th:if="${employees}">
    todo 显示 employees 列表
</div>
<div th:if="not ${employees}">
    这里不会显示
</div>
```

### 6.2 switch 语句

使用 `th:switch` 然后在子元素中 `th:case` 进行选择. 默认是 `th:case="*"`.

```html
<div th:switch="${employees.size()}">
    <p th:case="1">1 个</p>
    <p th:case="2">2 个</p>
    <p th:case="3">3 个</p>
    <p th:case="*">很多个</p>
</div>
```

------

## 7 使用Javascript

在 javascript 代码中使用 Thymeleaf 模板引擎：

```js
<script th:inline="javascript">
    $("#content").html(
        "<select name='status'>"+
        "   <option value=''>[[#{admin.common.choose}]]</option>"+
        "   <option value="+[[${status}]]+">[[#{'Order.Status.' + ${value}}]]</option>"+
        "</select>");
</script>
```

`script` 标签中的 `th:inline="javascript"` 属性值表示可以使用内联 js ，即可以在 js 代码中使用 `[[]]` 取值：

```
 var user = [[${user}]];
```

以上是在 Javascript 代码中使用 Thymeleaf 模板引擎的简单示例，但有时也会遇到不可解决或者说很难解决的问题。例如，如果要在 js 代码中输出一个段 html 代码，并且要在 html 代码中作循环操作，而 html 本身并没有提供这种功能的实现，这时要使用 Thymeleaf 的 `th:each` 属性，但是如何使用 `th:each` 在 js 中实现？ 这时就不能像上面那样的使用字符串拼接内联 js 来实现了，因为 `th:xx` 是要作为标签的属性放在标签内部的，js 解析不了。解决的方案是将 html 代码放在一个使用 `text/html` 解析的 `script` 标签中，这样就会使用 html 的解析方式来解析这些代码，示例如下：

```html
<script type="text/html" id="thymeleafTable">
    <table>
        <tr>
            <th th:text="#{Order.type}"></th>
            <td>
                <select name="type">
                    <option value="" th:text="#{admin.common.choose}"></option>
                    <option th:each="value : ${types}" th:value="${value}" th:attr="selected = ${value == type} ? 'selected' : ''" th:text="#{'Order.Type.' + ${value}}"></option>
                </select>
            </td>
        </tr>
    </table>
</script>  
```

然后在 js 代码中使用脚本的 id 来调用该脚本：

```
$("#content").html($("#thymeleafTable").html());
```

Note:`text/css`、`text/html` 和 `text/javascript` 等属性值规定脚本的 MIME 类型，它表示浏览器的解释方式，例如，`text/javascript`告诉浏览器按照 Javascript 来解析执行。

到此为止, 使用 thymeleaf 的大部分场景都涉及到了. 还有 fragment 部分看 demo 项目吧.

