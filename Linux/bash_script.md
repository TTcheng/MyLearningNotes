# Shell Tutorial

[TOC]

## 1.变量

### 1.1定义变量

```shell
name=Jesse
```

**注意**：= 两侧不允许有空格

命名规则

> 命名只能使用英文字母，数字和下划线，首个字符不能以数字开头。
>
> 中间不能有空格，可以使用下划线（_）。
>
> 不能使用标点符号。
>
> 不能使用bash里的关键字（可用help命令查看保留关键字）。

除了显式地直接赋值，还可以用语句给变量赋值，如：

```shell
for file in `ls /etc`
# 或
for file in $(ls /etc)
```

### 1.2使用变量

使用一个定义过的变量，只要在变量名前面加美元符号即可，如：

```shell
your_name="qinjx"
echo $your_name
echo ${your_name}
```

变量名外面的花括号是可选的，加不加都行，加花括号是为了帮助解释器识别变量的边界，比如下面这种情况：

```shell
for skill in Ada Coffe Action Java; do
    echo "I am good at ${skill}Script"
done
```

如果不给skill变量加花括号，解释器就会把$skillScript当成一个变量（其值为空）。

另外当使用$符号获取传递参数时，大于等于10个参数时也必须使用{}，即${n}

**推荐给所有变量加上花括号，这是个好的编程习惯**

### 1.3只读变量

使用readonly命令可以将变量定义为只读变量，使其不可被修改

```shell
pi=3.14
readonly pi
```

### 1.4删除变量

使用 unset 命令可以删除变量。语法：

```shell
unset variable_name
```

### 1.5变量类型

运行shell时，会同时存在三种变量：

- 局部变量

  局部变量在脚本或命令中定义，仅在当前shell实例中有效，其他shell启动的程序不能访问局部变量。

- 环境变量

  所有的程序，包括shell启动的程序，都能访问环境变量，有些程序需要环境变量来保证其正常运行。必要的时候shell脚本也可以定义环境变量。

- shell变量

  shell变量是由shell程序设置的特殊变量。shell变量中有一部分是环境变量，有一部分是局部变量，这些变量保证了shell的正常运行

## 2 Shell字符串

字符串是shell编程中最常用最有用的数据类型（除了数字和字符串，也没啥其它类型好用了），字符串可以用**单引号**，也可以用**双引号**，也可以**不用引号**。单双引号的区别跟PHP类似。

### 2.1单引号字符串

```shell
str='this is a string'
```

单引号字符串的限制：

- 单引号里的任何字符都会原样输出，单引号字符串中的变量是无效的；
- 单引号字串中不能出现单独一个的单引号（对单引号使用转义符后也不行），但可成对出现，作为字符串拼接使用。

### 2.2双引号

```shell
your_name='runoob'
str="Hello, I know you are \"$your_name\"! \n"
echo -e $str
# 输出 Hello, I know you are "runoob"! 
```

双引号的优点：

- 双引号里可以有变量
- 双引号里可以出现转义字符

### 2.3字符串拼接

```shell
your_name="runoob"
# 使用双引号拼接
greeting="hello, "$your_name" !"
greeting_1="hello, ${your_name} !"
echo $greeting  $greeting_1
# 使用单引号拼接
greeting_2='hello, '$your_name' !'
greeting_3='hello, ${your_name} !'
echo $greeting_2  $greeting_3
```

获取字符串长度

```shell
string="abcd"
echo ${#string} #输出 4
```

### 2.4提取子字符串

以下实例从字符串第 **2** 个字符开始截取 **4** 个字符：

```shell
# 第一种
string="runoob is a great site"
echo ${string:1:4} # 输出 unoo
# 第二种
echo `expr substr "$string" 2 4`
```

### 2.5查找子字符串

查找字符 **i** 或 **o** 的位置(哪个字母先出现就计算哪个)：

```shell
string="runoob is a great site"
echo `expr index "$string" io`  # 输出 4
```

查找bbb在aaabbb中位置

```shell
a=aaabbb
b=bbb
subIndex=`awk 'BEGIN{print match("'$a'","'$b'")}'`
echo subIndex # 输出 4
```

## 3 Shell数组

bash支持一维数组（不支持多维数组），并且没有限定数组的大小。类似于 C 语言，数组元素的下标由 0 开始编号。

### 3.1定义数组

```shell
array_name=(value0 value1 ... valuen)
#或者
array_name=(
value0
value1
...
valuen
)
#或者
array_name[0]=value0
array_name[1]=value1
...
array_name[n]=valuen
##可以不使用连续的下标，而且下标的范围没有限制。
```

### 3.2读取数组

```shell
${array_name[index]}
```

使用 **@** 符号可以获取数组中的所有元素，例如：

```shell
echo ${array_name[@]}
```

### 3.3获取数组的长度

获取数组长度的方法与获取字符串长度的方法相同，例如：

```shell
# 取得数组元素的个数
length=${#array_name[@]}
# 或者
length=${#array_name[*]}
# 取得数组单个元素的长度
lengthn=${#array_name[n]}
```

## 4 Shell注释

- 单行注释：#
- 多行注释

```shell
:<<EOF
注释内容...
注释内容...
注释内容...
EOF

:<<'
注释内容...
注释内容...
注释内容...
'

:<<!
注释内容...
注释内容...
注释内容...
!
```



## 5.传递参数

我们可以在执行 Shell 脚本时，向脚本传递参数，脚本内获取参数的格式为：**$n**。**n** 代表一个数字，**$0** 为执行的文件名，1 为执行脚本的第一个参数，2 为执行脚本的第二个参数，以此类推……

### 实例

以下实例我们向脚本传递三个参数，并分别输出

```shell
#!/bin/bash
# author:菜鸟教程
# url:www.runoob.com

echo "Shell 传递参数实例！";
echo "执行的文件名：$0";
echo "第一个参数为：$1";
echo "第二个参数为：$2";
echo "第三个参数为：$3";
```

另外，还有几个特殊字符用来处理参数：

| 参数处理 | 说明                                                         |
| -------- | ------------------------------------------------------------ |
| $#       | 传递到脚本的参数个数                                         |
| $*       | 以一个单字符串显示所有向脚本传递的参数。 如"$*"用「"」括起来的情况、以"$1 $2 … $n"的形式输出所有参数。 |
| $$       | 脚本运行的当前进程ID号                                       |
| $!       | 后台运行的最后一个进程的ID号                                 |
| $@       | 与$*相同，但是使用时加引号，并在引号中返回每个参数。 如"$@"用「"」括起来的情况、以"$1" "$2" … "$n" 的形式输出所有参数。 |
| $-       | 显示Shell使用的当前选项，与[set命令](http://www.runoob.com/linux/linux-comm-set.html)功能相同。 |
| $?       | 显示最后命令的退出状态。0表示没有错误，其他任何值表明有错误。 |

**$* 与 $@ 区别**：

- 相同点：都是引用所有参数。
- 不同点：只有在双引号中体现出来。假设在脚本运行时写了三个参数 1、2、3，，则 " * " 等价于 "1 2 3"（传递了一个参数），而 "@" 等价于 "1" "2" "3"（传递了三个参数）。

```shell
#!/bin/bash

for i in "$*"; do
    echo $i
done
# 单行输出 1 2 3

for i in "$@"; do
    echo $i
done
# 多行输出
# 1
# 2
# 3
```

## 6.运算符

### 6.1算术运算符

下表列出了常用的算术运算符，假定变量 a 为 10，变量 b 为 20：

| 运算符 | 说明                                          | 举例                          |
| ------ | --------------------------------------------- | ----------------------------- |
| +      | 加法                                          | `expr $a + $b` 结果为 30。    |
| -      | 减法                                          | `expr $a - $b` 结果为 -10。   |
| *      | 乘法                                          | `expr $a \* $b` 结果为  200。 |
| /      | 除法                                          | `expr $b / $a` 结果为 2。     |
| %      | 取余                                          | `expr $b % $a` 结果为 0。     |
| =      | 赋值                                          | a=$b 将把变量 b 的值赋给 a。  |
| ==     | 相等。用于比较两个数字，相同则返回 true。     | [ $a == $b ] 返回 false。     |
| !=     | 不相等。用于比较两个数字，不相同则返回 true。 | [ $a != $b ] 返回 true。      |

**注意：**条件表达式要放在方括号之间，并且要有空格，例如: **[$a==$b]** 是错误的，必须写成 **[ $a == $b ]**。

​	   乘号(*)前边必须加反斜杠才能实现乘法运算；

### 6.2关系运算符

关系运算符只支持数字，不支持字符串，除非字符串的值是数字。

下表列出了常用的关系运算符，假定变量 a 为 10，变量 b 为 20：

| 运算符 | 说明                                                  | 举例                       |
| ------ | ----------------------------------------------------- | -------------------------- |
| -eq    | 检测两个数是否相等，相等返回 true。                   | [ $a -eq $b ] 返回 false。 |
| -ne    | 检测两个数是否不相等，不相等返回 true。               | [ $a -ne $b ] 返回 true。  |
| -gt    | 检测左边的数是否大于右边的，如果是，则返回 true。     | [ $a -gt $b ] 返回 false。 |
| -lt    | 检测左边的数是否小于右边的，如果是，则返回 true。     | [ $a -lt $b ] 返回 true。  |
| -ge    | 检测左边的数是否大于等于右边的，如果是，则返回 true。 | [ $a -ge $b ] 返回 false。 |
| -le    | 检测左边的数是否小于等于右边的，如果是，则返回 true。 | [ $a -le $b ] 返回 true。  |

### 6.3布尔运算符

下表列出了常用的布尔运算符，假定变量 a 为 10，变量 b 为 20：

| 运算符 | 说明                                                | 举例                                     |
| ------ | --------------------------------------------------- | ---------------------------------------- |
| !      | 非运算，表达式为 true 则返回 false，否则返回 true。 | [ ! false ] 返回 true。                  |
| -o     | 或运算，有一个表达式为 true 则返回 true。           | [ $a -lt 20 -o $b -gt 100 ] 返回 true。  |
| -a     | 与运算，两个表达式都为 true 才返回 true。           | [ $a -lt 20 -a $b -gt 100 ] 返回 false。 |

### 6.4逻辑运算符

以下介绍 Shell 的逻辑运算符，假定变量 a 为 10，变量 b 为 20:

| 运算符 | 说明       | 举例                                       |
| ------ | ---------- | ------------------------------------------ |
| &&     | 逻辑的 AND | [[ $a -lt 100 && $b -gt 100 ]] 返回 false  |
| \|\|   | 逻辑的 OR  | [[ $a -lt 100 \|\| $b -gt 100 ]] 返回 true |

### 6.5字符串运算符

下表列出了常用的字符串运算符，假定变量 a 为 "abc"，变量 b 为 "efg"：

| 运算符 | 说明                                      | 举例                     |
| ------ | ----------------------------------------- | ------------------------ |
| =      | 检测两个字符串是否相等，相等返回 true。   | [ $a = $b ] 返回 false。 |
| !=     | 检测两个字符串是否相等，不相等返回 true。 | [ $a != $b ] 返回 true。 |
| -z     | 检测字符串长度是否为0，为0返回 true。     | [ -z $a ] 返回 false。   |
| -n     | 检测字符串长度是否为0，不为0返回 true。   | [ -n "$a" ] 返回 true。  |
| str    | 检测字符串是否为空，不为空返回 true。     | [ $a ] 返回 true。       |

### 6.6文件测试运算符

文件测试运算符用于检测 Unix 文件的各种属性。

属性检测描述如下：

| 操作符 | 说明                                                         | 举例                      |
| ------ | ------------------------------------------------------------ | ------------------------- |
| -b     | 检测文件是否是块设备文件，如果是，则返回 true。              | [ -b $file ] 返回 false。 |
| -c     | 检测文件是否是字符设备文件，如果是，则返回 true。            | [ -c $file ] 返回 false。 |
| -d     | 检测文件是否是目录，如果是，则返回 true。                    | [ -d $file ] 返回 false。 |
| -f     | 检测文件是否是普通文件（非目录，也非设备文件），是返回 true。 | [ -f $file ] 返回 true。  |
| -g     | 检测文件是否设置了 SGID 位，如果是，则返回 true。            | [ -g $file ] 返回 false。 |
| -k     | 检测文件是否设置了粘着位(Sticky Bit)，如果是，则返回 true。  | [ -k $file ] 返回 false。 |
| -p     | 检测文件是否是有名管道，如果是，则返回 true。                | [ -p $file ] 返回 false。 |
| -u     | 检测文件是否设置了 SUID 位，如果是，则返回 true。            | [ -u $file ] 返回 false。 |
| -r     | 检测文件是否可读，如果是，则返回 true。                      | [ -r $file ] 返回 true。  |
| -w     | 检测文件是否可写，如果是，则返回 true。                      | [ -w $file ] 返回 true。  |
| -x     | 检测文件是否可执行，如果是，则返回 true。                    | [ -x $file ] 返回 true。  |
| -s     | 检测文件是否为空（文件大小是否大于0），不为空返回 true。     | [ -s $file ] 返回 true。  |
| -e     | 检测文件（包括目录）是否存在，如果是，则返回 true。          | [ -e $file ] 返回 true。  |

Example: show readme.txt

```bash
#!/usr/bin/env bash
readme="readme.txt"
if [ -f $readme ];then
	cat $readme
else echo "file $readme not found"
fi
```

## 7.Shell echo命令

Shell 的 echo 指令与 PHP 的 echo 指令类似，都是用于字符串的输出。命令格式：

```shell
echo string
echo "It is a test"
echo "\"It is a test\""
echo "$name It is a test"
echo -e "OK! \n"            	# -e 开启转义 换行
echo -e "OK! \c" 				# -e 开启转义 \c 不换行
echo "It is a test" > myfile	# 显示到文件
echo '$name\"'					# 单引号内容当做纯文本输出 $name\"
echo `date`						# 显示命令执行结果
```

## 8.Shell printf 命令

上一章节我们学习了 Shell 的 echo 命令，本章节我们来学习 Shell 的另一个输出命令 printf。

printf 命令模仿 C 程序库（library）里的 printf() 程序。

printf 由 POSIX 标准所定义，因此使用 printf 的脚本比使用 echo 移植性好。

printf 使用引用文本或空格分隔的参数，外面可以在 printf 中使用格式化字符串，还可以制定字符串的宽度、左右对齐方式等。默认 printf 不会像 echo 自动添加换行符，我们可以手动添加 \n。

printf 命令的语法：

```
printf  format-string  [arguments...]
```

**参数说明：**

- **format-string:** 为格式控制字符串
- **arguments:** 为参数列表。

**实例**

```shell
$ printf "a string, no processing:<%s>\n" "A\nB"
a string, no processing:<A\nB>

$ printf "a string, no processing:<%b>\n" "A\nB"
a string, no processing:<A
B>

$ printf "www.runoob.com \a"
www.runoob.com # 不换行

$ printf "%d %s %c\n" 1 "abc" "def"
1 abc d
```

## 9.Shell test 命令

Shell中的 test 命令用于检查某个条件是否成立，它可以进行数值、字符和文件三个方面的测试。

### 9.1数值测试

| 参数 | 说明           |
| ---- | -------------- |
| -eq  | 等于则为真     |
| -ne  | 不等于则为真   |
| -gt  | 大于则为真     |
| -ge  | 大于等于则为真 |
| -lt  | 小于则为真     |
| -le  | 小于等于则为真 |

实例演示：

```
num1=100
num2=100
if test $[num1] -eq $[num2]
then
    echo '两个数相等！'
else
    echo '两个数不相等！'
fi
```

输出结果：

```
两个数相等！
```

代码中的 [] 执行基本的算数运算，如：

```
#!/bin/bash

a=5
b=6

result=$[a+b] # 注意等号两边不能有空格
echo "result 为： $result"
```

结果为:

```
result 为： 11
```

------

### 9.2字符串测试

| 参数      | 说明                     |
| --------- | ------------------------ |
| =         | 等于则为真               |
| !=        | 不相等则为真             |
| -z 字符串 | 字符串的长度为零则为真   |
| -n 字符串 | 字符串的长度不为零则为真 |

实例演示：

```
num1="ru1noob"
num2="runoob"
if test $num1 = $num2
then
    echo '两个字符串相等!'
else
    echo '两个字符串不相等!'
fi
```

输出结果：

```
两个字符串不相等!
```

------

### 9.3文件测试

| 参数      | 说明                                 |
| --------- | ------------------------------------ |
| -e 文件名 | 如果文件存在则为真                   |
| -r 文件名 | 如果文件存在且可读则为真             |
| -w 文件名 | 如果文件存在且可写则为真             |
| -x 文件名 | 如果文件存在且可执行则为真           |
| -s 文件名 | 如果文件存在且至少有一个字符则为真   |
| -d 文件名 | 如果文件存在且为目录则为真           |
| -f 文件名 | 如果文件存在且为普通文件则为真       |
| -c 文件名 | 如果文件存在且为字符型特殊文件则为真 |
| -b 文件名 | 如果文件存在且为块特殊文件则为真     |

实例演示：

```
cd /bin
if test -e ./bash
then
    echo '文件已存在!'
else
    echo '文件不存在!'
fi
```

## 10.流程控制

### 10.1 选择

#### if

**多行**

```shell
if condition1 
then
	command
elif condition2 
then
	command
else
	command
fi
```

**单行**

```shell
if condition1; then command; fi
```

#### case

```shell
case var in
val1)
    command
    ;;
val2）
    command1
    ;;
esac
```

案例

```bash
echo '输入 1 到 4 之间的数字:'
echo '你输入的数字为:'
read aNum
case $aNum in
    1|3)  echo '你选择了 1或3'
    ;;
    2|4)  echo '你选择了 2活4'
    ;;
    *)  echo '你没有输入 1 到 4 之间的数字'
    ;;
esac
```

###　10.2循环

#### **for循环**

一般格式为：

```shell
for var in item1 item2 ... itemN
do
    command1
    command2
    ...
    commandN
done
```

写成一行：

```shell
for var in item1 item2 ... itemN; do command1; command2… done;
```

#### while循环

while循环用于不断执行一系列命令，也用于从输入文件中读取数据；命令通常为测试条件。其格式为：

```shell
while condition
do
    command
done
```

#### 无限循环

无限循环语法格式：

```shell
while :
do
    command
done
# 或者 while true ：
# 或者 for((;;))
```

#### until 循环

until 循环执行一系列命令直至条件为 true 时停止。

until 循环与 while 循环在处理方式上刚好相反。

一般 while 循环优于 until 循环，但在某些时候—也只是极少数情况下，until 循环更加有用。

until 语法格式:

```shell
until condition
do
    command
done
```

#### 跳出循环

- **break**

break命令允许跳出所有循环（终止执行后面的所有循环）。

- **continue**

continue命令仅仅跳出当前循环。

## 11.函数

### 11.1函数定义

linux shell 可以用户定义函数，然后在shell脚本中可以随便调用。

shell中函数的定义格式如下：

```
[ function ] funname [()]
{
    action;
    [return int;]
}
```

说明：

- 1、可以带function fun() 定义，也可以直接fun() 定义,不带任何参数。
- 2、参数返回，可以显示加：return 返回，如果不加，将以最后一条命令运行结果，作为返回值。 return后跟数值n(0-255

### 11.2函数参数

在Shell中，调用函数时可以向其传递参数。在函数体内部，通过 $n 的形式来获取参数的值，例如，$1表示第一个参数，$2表示第二个参数...

| 参数处理 | 说明                                                         |
| -------- | ------------------------------------------------------------ |
| ${n}     | 第n个参数，n<10时可省略{}                                    |
| $#       | 传递到脚本的参数个数                                         |
| $*       | 以一个单字符串显示所有向脚本传递的参数                       |
| $$       | 脚本运行的当前进程ID号                                       |
| $!       | 后台运行的最后一个进程的ID号                                 |
| $@       | 与$*相同，但是使用时加引号，并在引号中返回每个参数。         |
| $-       | 显示Shell使用的当前选项，与set命令功能相同。                 |
| $?       | 显示最后命令的退出状态。0表示没有错误，其他任何值表明有错误。 |

### 11.3案例：下载函数

```shell
function download(){
    local url=$1
    local name=$2
    if command -v wget > /dev/null 2>&1; then
        wget $url -O $name
    elif command -v curl > /dev/null 2>&1; then
        curl -L -o $name $url
    else
        echo "error: wget/curl not found. cannot download"
        exit 1
    fi
}
download https://codeload.github.com/TTcheng/React-HelloWorld/zip/master React-HelloWorld.zip
```

## 12.输入/输出重定向

大多数 UNIX 系统命令从你的终端接受输入并将所产生的输出发送回到您的终端。一个命令通常从一个叫标准输入的地方读取输入，默认情况下，这恰好是你的终端。同样，一个命令通常将其输出写入到标准输出，默认情况下，这也是你的终端。

重定向命令列表如下：

| 命令            | 说明                                               |
| --------------- | -------------------------------------------------- |
| command > file  | 将输出重定向到 file。                              |
| command < file  | 将输入重定向为 file。                              |
| command >> file | 将输出以追加的方式重定向到 file。                  |
| n > file        | 将文件描述符为 n 的文件重定向到 file。             |
| n >> file       | 将文件描述符为 n 的文件以追加的方式重定向到 file。 |
| n >& m          | 将输出文件 m 和 n 合并。                           |
| n <& m          | 将输入文件 m 和 n 合并。                           |
| << tag          | 将开始标记 tag 和结束标记 tag 之间的内容作为输入。 |

> 需要注意的是文件描述符 0 通常是标准输入（STDIN），1 是标准输出（STDOUT），2 是标准错误输出（STDERR）。

## 13.调用外部脚本

和其他语言一样，Shell 也可以包含外部脚本。这样可以很方便的封装一些公用的代码作为一个独立的文件。

Shell 文件包含的语法格式如下：

```shell
. filepath   # 注意点号(.)和文件名中间有一空格
#或
source filename
```