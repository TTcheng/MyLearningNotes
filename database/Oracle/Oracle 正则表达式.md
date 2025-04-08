#  			[Oracle 正则表达式](https://www.cnblogs.com/linbo3168/p/6016643.html) 		

### 一.    正则表达式简介:

​    正则表达式，就是以某种模式来匹配一类字符串。一旦概括了某类字符串，那么正则表达式即可用于针对字符串的各种相关操作。例如，判断匹配性，进行字符串的重新组合等。正则表达式提供了字符串处理的快捷方式。[Oracle](http://lib.csdn.net/base/oracle) 10g及以后的版本中也支持正则表达式.

### 二.    正则表达式相对通配符的优势:

\1.       正则表达式中不仅存在着代表模糊字符的特殊字符，而且存在着量词等修饰字符，使得模式的控制更加灵活和强大。

\2.       通配符的使用一般是在特定的环境下,不同的环境下，通配符有可能不同。而正则表达式，不但广泛应用于各种编程语言，而且在各种编程语言中，保持了语法的高度一致性。 

### 三.    元字符:

元字符是指在正则表达式中表示特殊含义的字符。

| 元字符 | 含义                                                     |
| ------ | ------------------------------------------------------------ |
| ^      | 匹配输入字符串的开始位置，在方括号表达式中使用，此时它表示不接受该字符集合。 |
| $      | 匹配输入字符串的结尾位置。如果设置了 RegExp 对象的 Multiline 属性，则 $ 也匹配 'n' 或 'r'。 |
| .      | 匹配除换行符 n之外的任何单字符。                             |
| ?      | 匹配前面的子表达式零次或一次。                               |
| +      | 匹配前面的子表达式一次或多次。                               |
| *      | 匹配前面的子表达式零次或多次。                               |
| \|     | 指明两项之间的一个选择。例子'^([a-z]+\|[0-9]+)$'表示所有小写字母或数字组合成的字符串。 |
| ()     | 标记一个子表达式的开始和结束位置(字符组)。                   |
| []     | 标记一个中括号表达式。                                       |
| {m,n}  | 一个精确地出现次数范围，m=<出现次数<=n，'{m}'表示出现m次，'{m,}'表示至少出现m次。 |

### 四.    量词

   量词用来指定量词的前一个字符出现的次数。量词的形式主要有“?”、“*”、“+”、“{}”。量词在用于匹配字符串时，默认遵循贪婪原则。贪婪原则是指，尽可能多地匹配字符。例如:字符串“Function(p),(OK)”，如果使用正则表达式“.∗”进行匹配，则得到字符串“(p),(OK)” ，而非“(p)”；若欲得到“(p)”，则必须取消量词的贪婪原则，此时只需要为量词后追加另外一个数量词“?”即可。如上面的正则表达式应该改为“.∗?”。

### 五.    字符转义:

​    元字符在正则表达式中有特殊含义。如果需要使用其原义，则需要用到字符转义。字符转义使用字符“\”来实现。其语法模式为：“\”+元字符。例如，“\.”表示普通字符“.”；     “\.doc”匹配字符串“.doc”；而普通字符“\”需要使用“\\”来表示。

### 六.    字符组.

字符组是指将模式中的某些部分作为一个整体。这样，量词可以来修饰字符组，从而提高正则表达式的灵活性。字符组通过()来实现.

许多编程语言中，可以利用“$1”、“$2”等来获取第一个、第二个字符组，即所谓的后向引用。在Oracle中，引用格式为“\1”、“\2”。

### 七.    正则表达式分支

​    可以利用“|”来创建多个正则表达式分支。例如，“\d{4}|\w{4}”可以看做两个正则表达式——“\d{4}”和“\w{4}”，匹配其中任何一个正则表达式的字符串都被认为匹配整个正则表达式。如果该字符串两个正则表达式分支都匹配，那么将被处理为匹配第一个正则表达式分支。

### 八.    字符类.

在Oracle中，正则表达式的用法与标准用法略有不同。这种不同主要体现在对于字符类的定义上。Orale中不使用字符“\”与普通字符组合的形式来实现字符类，而是具有其特殊语法. 

### 九.    ORACLE中的四个正则表达式相关函数.

\1.       regexp_like(expression, regexp)

   返回值为一个布尔值。如果第一个参数匹配第二个参数所代表的正则表达式，那么将返回真，否则将返回假。

 举例:   select * from people where regexp_like(name, '^J.*$'); 

相当于:  select * from people where name like 'J%'; 

\2.       regexp_instr(expression, regexp, startindex, times)

返回找到的匹配字符串的位置.

参数startindex表示开始进行匹配比较的位置；参数times表示第几次匹配作为最终匹配结果。

举例: select regexp_instr('12.158', '\.') position from dual; 

regexp_instr('12.158', '\.')用于获取第一个小数点的位置。

\3.       regexp_substr(expression, regexp)

   返回第一个字符串参数中，与第二个正则表达式参数相匹配的子字符串。

   举例:

```plsql
create table html(
    id integer, 
    html varchar2(2000)); 
insert into html values (1, '<a href="http://mail.google.com/2009/1009.html">mail link</a>'); 
```

表html中存储了HTML标签及内容。现欲从标签<a>中获得链接的url，那么可以利用regexp_substr()函数。

select id, regexp_substr(html, 'http[a-zA-Z0-9\.:/]*') url from html; 

 \4.  regexp_replace(expression, regexp, replacement)

​     将expression中的按regexp匹配到的部分用replacement代替.

​     在参数replacement中，可以含有后向引用，以便将正则表达式中的字符组重新捕获。例如，某些国家和地区的日期格式可能为“MM/DD/YYYY”，那么可以利用regexp_replace()函数来转换日期格式。

select regexp_replace('09/29/2008', '^([0-9]{2})/([0-9]{2})/([0-9]{4})$', '\3-\1-\2')  replace 

from dual; 

 

注: 在进行正则表达式匹配时，还可以忽略字符大小写形式进行匹配.但是不能解除[[:upper:]]和[[:lower:]]的作用.

select * from people where regexp_like(name, 'or'); 

select * from people where regexp_like(name, 'or', 'i');   --‘i’表示忽略大小写

### 十. 正则表达式练习 

第一： REGEXP_LIKE函数用法

EMP表结构如下：

SQL> desc emp;

 Name                                      Null?    Type

----------------------------------------- -------- ----------------------------

 

 EMPNO                                     NOT NULL NUMBER(4)

 ENAME                                              VARCHAR2(10)

 JOB                                                VARCHAR2(9)

 MGR                                                NUMBER(4)

 HIREDATE                                           DATE

 SAL                                                NUMBER(7,2)

 COMM                                               NUMBER(7,2)

 DEPTNO                                             NUMBER(2)

EMP表中部分数据如下：

SQL> select empno,ename,sal,hiredate from emp;

 

​     EMPNO ENAME             SAL HIREDATE

---------- ---------- ---------- --------------

​      7369 SMITH             800 17-12月-80

​      7499 ALLEN            1600 20-2月 -81

​      7521 WARD             1250 22-2月 -81

​      7566 JONES            2975 02-4月 -81 

 

下面给出几种REGEXP_LIKE函数的例子

1、查找员工编号为4位数字的员工信息

SQL> select empno,ename from emp where regexp_like(empno,'^[[:digit:]]{4}$');

 或者: select empno,ename from emp where regexp_like(empno,'^[0-9]$');

​     EMPNO ENAME

---------- ----------

​      7369 SMITH

​      7499 ALLEN

​      7521 WARD

​      7566 JONES

2、查找员工姓名为全英文的员工信息

SQL>  select empno,ename from emp where regexp_like(ename,'^[[:alpha:]]+$');

 或者:  select * from emp where regexp_like(ename,'^[a-zA-Z]+$');

​     EMPNO ENAME

---------- ----------

​      7369 SMITH

​      7499 ALLEN

​      7521 WARD

​      7566 JONES

​      7654 MARTIN

3、查找员工姓名以“a”字母开头，不区分大小写

SQL> select empno,ename from emp where regexp_like(ename,'^a','i');

 

​     EMPNO ENAME

---------- ----------

​      7499 ALLEN

​      7876 ADAMS

4、查找员工姓名为全英文，且以“N”结尾的员工信息

SQL> select empno,ename from emp where regexp_like(ename,'^[[:alpha:]]+N$');

 

​     EMPNO ENAME

---------- ----------

​      7499 ALLEN

​      7654 MARTIN

5、查找员工编号以非数字开头的员工信息

SQL> select empno,ename from emp where regexp_like(empno,'[^[:digit:]]');

 

no rows selected 

 

第二： REGEXP_INSTR函数用法

1、查找员工编号中第一个非数字字符的位置

SQL> select regexp_instr(empno,'[^[:digit:]]') position from emp;

 

 POSITION

\----------

​         0

​         0

​         0

2、从第三个字符开始，查找员工编号中第二个非数字字符的位置

SQL> select regexp_instr(empno,'[^[:digit:]]',3,2) position from emp;

 

 POSITION

\----------

​         0

​         0 

 

 

第三： REGEXP_SUBSTR函数用法

1、返回从ename的第二个位置开始查找，并且是以“L”开头到结尾的字串

SQL> select regexp_substr(ename,'L.*','2') substr from emp;

 

SUBSTR

\------------------

LLEN

LAKE

LARK 

 

 

第四：REGEXP_REPLACE函数用法

1、把ename中所有非字母字符替换为“A”

SQL> update emp set ename=regexp_replace(ename, '[^[:alpha:]]', 'A')

2 where regexp_like(ename, '[^[:alpha:]]');

 

1 row updated 

 

转载来源:<http://wenku.baidu.com/view/4d7fc0d126fff705cc170a58.html>

 

________________________________________________________________________________________________________________

Oracle  正则表达式   就是由普通字符（例如字符a到z）以及特殊字符（称为元字符）组成的文字模式。该模式描述在查找文字主体时待匹配的一个或多个字符串。正则表达式作为一个模板，将某个字符模式与所搜索的字符串进行匹配。    本文详细地列出了能在正则表达式中使用，以匹配文本的各种字符。当你需要解释一个现有的正则表达式时，可以作为一个快捷的参考。更多详细内容，请参考：Francois  Liger,Craig McQueen,Pal Wilton[刘乐亭译] C#字符串和正则表达式参考手册北京：清华大学出版社2003.2   一.     匹配字符  字符类 匹配的字符  举 例  \d 从０-９的任一数字  \d\d匹配72,但不匹配aa或7a  \D 任一非数字字符  \D\D\D匹配abc,但不匹配123  \w 任一单词字符，包括A-Z,a-z,0-9和下划线\w\w\w\w匹配Ab-2，但不匹配∑￡$%*或Ab_@  \W 任一非单词字符  \W匹配＠，但不匹配a  \s 任一空白字符，包括制表符，换行符，回车符，换页符和垂直制表符匹配在HTML,XML和其他标准定义中的所有传统空白字符  \S 任一非空白字符  空白字符以外的任意字符,如A%&g3;等  . 任一字符  匹配除换行符以外的任意字符除非设置了MultiLine先项  […] 括号中的任一字符  [abc]将匹配一个单字符,a,b或c.  [a-z]将匹配从a到z的任一字符  [^…] 不在括号中的任一字符[^abc]将匹配一个a、b、c之外的单字符,可以a,b或A、B、C  [a-z]将匹配不属于a-z的任一字符,但可以匹配所有的大写字母 
 二.     重复字符  重复字符 含 义   举 例  ｛n｝ 匹配前面的字符n次   x{2}匹配xx,但不匹配x或xxx  ｛n,｝ 匹配前面的字符至少n次x{2}匹配2个或更多的x,如xxx,xxx..  ｛n,m｝ 匹配前面的字符至少n次,至多m次。如果n为0，此参数为可选参数x{2,4}匹配xx,xxx,xxxx,但不匹配xxxxx   ? 匹配前面的字符0次或1次，实质上也是可选的x?匹配x或零个x   + 匹配前面的字符0次或多次x+匹配x或xx或大于0的任意多个x   * 匹配前面的字符0次或更多次x*匹配0,1或更多个x 
 三.     定位字符  定位字符 描 述   ^ 随后的模式必须位于字符串的开始位置，如果是一个多行字符串，则必须位于行首。对于多行文本（包含回车符的一个字符串）来说，需要设置多行标志   $ 前面的模式必须位于字符串的未端，如果是一个多行字符串，必须位于行尾   \A 前面的模式必须位于字符串的开始位置，忽略多行标志   \z 前面的模式必须位于字符串的未端，忽略多行标志   \Z 前面的模式必须位于字符串的未端，或者位于一个换行符前   \b 匹配一个单词边界，也就是一个单词字符和非单词字符中间的点。要记住一个单词字符是[a-zA-Z0-9]中的一个字符。位于一个单词的词首   \B 匹配一个非单词字符边界位置，不是一个单词的词首  注：定位字符可以应用于字符或组合，放在字符串的左端或右端 
 四.     分组字符  分组字符 定 义   举 例  （） 此字符可以组合括号内模式所匹配的字符，它是一个捕获组，也就是说模式匹配的字符作为最终设置了ExplicitCapture选项――默认状态下字符不是匹配的一部分输入字符串为：ABC1DEF2XY  匹配3个从A到Z的字符和1个数字的正则表达式：（[A-Z]{3}\d）  将产生两次匹配：Match 1=ABC1;Match 2=DEF2  每次匹配对应一个组：Match1的第一个组＝ABC;Match2的第1个组＝DEF  有了反向引用，就可以通过它在正则表达式中的编号以及C#和类Group,GroupCollection来访问组。如果设置了ExplicitCapture选项，就不能使用组所捕获的内容  （?:） 此字符可以组合括号内模式所匹配的字符，它是一个非捕获组，这意味着模式所的字符将不作为一个组来捕获，但它构成了最终匹配结果的一部分。它基本上与上面的组类型相同，但设定了选项ExplicitCapture输入字符串为：1A BB SA1 C  匹配一个数字或一个A到Z的字母，接着是任意单词字符的正则表达式为：（?:\d|[A-Z]\w）  它将产生3次匹配：每1次匹配＝1A；每2次匹配＝BB;每3次匹配＝SA  但是没有组被捕获  （?<name>） 此选项组合括号内模式所匹配的字符，并用尖括号中指定的值为组命名。在正则表达式中，可以使用名称进行反向引用，而不必使用编号。即使不设置ExplicitCapture选项，它也是一个捕获组。这意味着反向引用可以利用组内匹配的字符，或者通过Group类访问输入字符串为：Characters in Sienfeld included Jerry Seinfeld,Elaine Benes,Cosno Kramer and George Costanza能够匹配它们的姓名，并在一个组llastName中捕获姓的正则表达式为：\b[A-Z][a-z]+(?<lastName>[A-Z][a-z]+)\b  它产生了4次匹配：First Match=Jerry Seinfeld; Second Match=Elaine Benes; Third Match=Cosmo Kramer; Fourth Match=George Costanza  每一次匹配都对应了一个lastName组：  第1次匹配：lastName group=Seinfeld  第2次匹配：lastName group=Benes  第3次匹配：lastName group=Kramer  第4次匹配：lastName group=Costanza  不管是否设置了选项ExplictCapture，组都将被捕获  （?=） 正声明。声明的右侧必须是括号中指定的模式。此模式不构成最终匹配的一部分正则表达式\S+(?=.NET)要匹配的输入字符串为：The languages were [Java](http://lib.csdn.net/base/javaee),C#.NET,VB[.NET](http://lib.csdn.net/base/dotnet),C,Jscript[.Net](http://lib.csdn.net/base/dotnet),Pascal  将产生如下匹配：〕  C#   VB   JScript.  （?!） 负声明。它规定模式不能紧临着声明的右侧。此模式不构成最终匹配的一部分\d{3}(?![A-Z])要匹配的输入字符串为：123A 456 789111C  将产生如下匹配：  456   789  （?<=） 反向正声明。声明的左侧必须为括号内的指定模式。此模式不构成最终匹配的一部分正则表达式(?<=New)([A-Z][a-z]+)要匹配的输入字符串为：The following states,New Mexico,West Virginia,Washington, New England  它将产生如下匹配：  Mexico   England  （?<!） 反向正声明。声明的左侧必须不能是括号内的指定模式。此模式不构成最终匹配的一部分正则表达式(?<!1)\d{2}([A-Z])要匹配的输入字符串如下：123A456F789C111A  它将实现如下匹配：  56F   89C  （?>） 非回溯组。防止Regex引擎回溯并且防止实现一次匹配假设要匹配所有以“ing”结尾的单词。输入字符串如下：He was very trusing  正则表达式为：.*ing  它将实现一次匹配――单词trusting。“.”匹配任意字符，当然也匹配“ing”。所以，Regex引擎回溯一位并在第2个“t”停止，然后匹配指定的模式“ing”。但是，如果禁用回溯操作：(?>.*)ing  它将实现0次匹配。“.”能匹配所有的字符，包括“ing”――不能匹配，从而匹配失败 
 五.     决策字符  字 符 描 述 举 例  （?(regex)yes_regex|no_regex） 如果表达式regex匹配，那么将试图匹配表达式yes。否则匹配表达式no。正则表达式no是可先参数。注意，作出决策的模式宽度为0.这意味着表达式yes或no将从与regex表达式相同的位置开始匹配正则表达式(?(\d)dA|A-Z)B)要匹配的输入字符串为：1A CB3A5C 3B  它实现的匹配是：  1A   CB   3A  （?(group name or number)yes_regex|no_regex）   如果组中的正则表达式实现了匹配，那么试图匹配yes正则表达式。否则，试图匹配正则表达式no。no是可先的参数正则表达式   (\d7)?-(?(1)\d\d[A-Z]|[A-Z][A-Z]要匹配的输入字符串为：  77-77A 69-AA 57-B  它实现的匹配为：  77-77A  －AA  注：上面表中列出的字符强迫处理器执行一次if-else决策 
 六.     替换字符  字 符 描 述   $group 用group指定的组号替换   ${name} 替换被一个(?<name>)组匹配的最后子串   $$ 替换一个字符$   $& 替换整个的匹配   $^ 替换输入字符串匹配之前的所有文本   $’ 替换输入字符串匹配之后的所有文本   $+ 替换最后捕获的组   $_ 替换整个的输入字符串  注：以上为常用替换字符，不全 
 七.     转义序列  字 符 描 述   \\ 匹配字符“\”   \. 匹配字符“.”   \* 匹配字符“*”   \+ 匹配字符“+”   \? 匹配字符“?”   \| 匹配字符“|”   \( 匹配字符“(”   \) 匹配字符“)”   \{ 匹配字符“{”   \} 匹配字符“}”   \^ 匹配字符“^”   \$ 匹配字符“$”   \n 匹配换行符   \r 匹配回车符   \t 匹配制表符   \v 匹配垂直制表符   \f 匹配换面符   \nnn 匹配一个8进数字，nnn指定的ASCII字符。如\103匹配大写的C   \xnn 匹配一个16进数字，nn指定的ASCII字符。如\x43匹配大写的C   \unnnn 匹配由4位16进数字（由nnnn表示）指定的Unicode字符   \cV 匹配一个控制字符，如\cV匹配Ctrl-V 
 八.     选项标志  选项标志 名 称  I IgnoreCase   M Multiline   N ExplicitCapture   S SingleLine   X IgnorePatternWhitespace  注：选项本身的信作含义如下表所示：  标 志 名 称  IgnoreCase 使模式匹配不区分大小写。默认的选项是匹配区分大小写  RightToLeft 从右到左搜索输入字符串。默认是从左到右以符合英语等的阅读习惯，但不符合阿拉伯语或希伯来语的阅读习惯  None 不设置标志。这是默认选项  Multiline 指定^和$可以匹配行首和行尾，以及字符串的开始和结尾。这意味着可以匹配每个用换行符分隔的行。但是，字符“.”仍然不匹配换行符  SingleLine 规定特殊字符“.”匹配任意的字符，包括换行符。默认情况下，特殊字符“.”不匹配换行符。通常与MultiLine选项一起使用  ECMAScript. ECMA(European Coputer Manufacturer’s Association,欧洲计算机生产商协会)已经定义了正则表达式应该如何实现，而且已经在ECMAScript规范中实现，这是一个基于标准的[JavaScript](http://lib.csdn.net/base/javascript)。这个选项只能与IgnoreCase和MultiLine标志一起使用。与其它任何标志一起使用，ECMAScript都将产生异常  IgnorePatternWhitespace 此选项从使用的正则表达式模式中删除所有非转义空白字符。它使表达式能跨越多行文本，但必须确保对模式中所有的空白进行转义。如果设置了此选项，还可以使用“#”字符来注释下则表达式  Complied 它把正则表达式编译为更接近机器代码的代码。这样速度快，但不允许对它进行任何修改 
 oracle的正则表达式(regular expression)简单介绍 
 目前，正则表达式已经在很多软件中得到广泛的应用，包括*nix（[Linux](http://lib.csdn.net/base/linux), Unix等），HP等[操作系统](http://lib.csdn.net/base/operatingsystem)，[PHP](http://lib.csdn.net/base/php)，C#，Java等开发环境。 
 Oracle 10g正则表达式提高了SQL灵活性。有效的解决了数据有效性， 重复词的辨认, 无关的空白检测，或者分解多个正则组成  的字符串等问题。 
 Oracle 10g支持正则表达式的四个新函数分别是：REGEXP_LIKE、REGEXP_INSTR、REGEXP_SUBSTR、和REGEXP_REPLACE。  它们使用POSIX 正则表达式代替了老的百分号（%）和通配符（_）字符。 
 REGEXP_REPLACE(source_string,pattern,replace_string,position,occurtence,match_parameter)函数(10g新函数)      描述:字符串替换函数。相当于增强的replace函数。Source_string指定源字符表达式；pattern指定规则表达式；replace_string指定用于替换的字符串；position指定起始搜索位置；occurtence指定替换出现的第n个字符串；match_parameter指定默认匹配操作的文本串。      其中replace_string,position,occurtence,match_parameter参数都是可选的。 
 REGEXP_SUBSTR(source_string, pattern[,position [, occurrence[, match_parameter]]])函数(10g新函数)       描述：返回匹配模式的子字符串。相当于增强的substr函数。Source_string指定源字符表达式；pattern指定规则表达式；position指定起始搜索位置；occurtence指定替换出现的第n个字符串；match_parameter指定默认匹配操作的文本串。       其中position,occurtence,match_parameter参数都是可选的  match_option的取值如下：  ‘c’   说明在进行匹配时区分大小写（缺省值）；     'i'   说明在进行匹配时不区分大小写；     'n'   允许使用可以匹配任意字符的操作符；     'm'   将x作为一个包含多行的字符串。 
 REGEXP_LIKE(source_string, pattern[, match_parameter])函数(10g新函数)       描述：返回满足匹配模式的字符串。相当于增强的like函数。Source_string指定源字符表达式；pattern指定规则表达式；match_parameter指定默认匹配操作的文本串。       其中position,occurtence,match_parameter参数都是可选的 
 REGEXP_INSTR(source_string, pattern[, start_position[, occurrence[, return_option[, match_parameter]]]])函数(10g新函数)       描述: 该函数查找 pattern ，并返回该模式的第一个位置。您可以随意指定您想要开始搜索的 start_position。 occurrence 参数默认为 1，除非您指定您要查找接下来出现的一个模式。return_option 的默认值为 0，它返回该模式的起始位置；值为 1 则返回符合匹配条件的下一个字符的起始位置 
 特殊字符：   '^' 匹配输入字符串的开始位置，在方括号表达式中使用，此时它表示不接受该字符集合。   '$' 匹配输入字符串的结尾位置。如果设置了 RegExp 对象的 Multiline 属性，则 $ 也匹配 'n' 或 'r'。   '.' 匹配除换行符 n之外的任何单字符。   '?' 匹配前面的子表达式零次或一次。   '*' 匹配前面的子表达式零次或多次。   '+' 匹配前面的子表达式一次或多次。   '( )' 标记一个子表达式的开始和结束位置。   '[]' 标记一个中括号表达式。   '{m,n}' 一个精确地出现次数范围，m= <出现次数 <=n，'{m}'表示出现m次，'{m,}'表示至少出现m次。   ' |' 指明两项之间的一个选择。例子'^([a-z]+ |[0-9]+)$'表示所有小写字母或数字组合成的字符串。  num 匹配 num，其中 num 是一个正整数。对所获取的匹配的引用。  正则表达式的一个很有用的特点是可以保存子表达式以后使用， 被称为Backreferencing. 允许复杂的替换能力  如调整一个模式到新的位置或者指示被代替的字符或者单词的位置. 被匹配的子表达式存储在临时缓冲区中，  缓冲区从左到右编号, 通过数字符号访问。 下面的例子列出了把名字 aa bb cc 变成  cc, bb, aa.   Select REGEXP_REPLACE('aa bb cc','(.*) (.*) (.*)', '3, 2, 1') FROM dual；  REGEXP_REPLACE('ELLENHILDISMIT   cc, bb, aa   '' 转义符。 
 字符簇：   [[:alpha:]] 任何字母。   [[:digit:]] 任何数字。   [[:alnum:]] 任何字母和数字。   [[:space:]] 任何白字符。   [[:upper:]] 任何大写字母。   [[:lower:]] 任何小写字母。   [[:punct:]] 任何标点符号。   [[:xdigit:]] 任何16进制的数字，相当于[0-9a-fA-F]。 
 各种操作符的运算优先级  转义符   (), (?:), (?=), [] 圆括号和方括号   *, +, ?, {n}, {n,}, {n,m} 限定符   ^, $, anymetacharacter 位置和顺序   | “或”操作 