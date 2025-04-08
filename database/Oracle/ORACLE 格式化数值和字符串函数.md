#  格式化数值和字符串函数

[TOC]

## 1、格式化数值---to_char()函数

### 1.1 格式字符‘0’：

   “0”代表一个数字位，当原数值没有数字位与之匹配的时候，强制添加0 
​    如 ：	

```plsql
to_char(46.12,'0000.000') -- 输出0046.120
to_char(46.12,'00') --输出46，因为没有给小数部分
to_char(46.12,'0') --输出##，因为没有足够的整数位给他
```

### 1.2 格式字符“9”： 

   “9”代表一个数字位，当原数字部分中的整数没有数字位匹配时，不填充任何字符
   如  

```plsql
to_char(46.12,'99.9')--输出46.1
to_char(46.12,'999.999')--输出46.120，整数多余的部分不加任何字符
```

### 1.3 格式字符 “，” 

   逗号是分组符号。常见的应用为千位分隔符

```plsql
to_char(4006.12,'99,999') --输出4，006
to_char(4006.12,'99,999.00')--输出4，006.12
```

### 1.4 格式字符“FM” 

   他的意义在于屏蔽掉所有不必要的0

```plsql
to_char(46,'FM99.99') --输出46. 后面的0 屏蔽掉了
```

### 1.5 格式字符“L”

   他表示中国货币 ￥ ，在数值面前添加     ￥

```plsql
to_char(46,'L99.99')	-- 输出 ￥46.00
to_char(46,'FML99.99')	-- 输出 ￥46.
```

### 1.6 格式字符 “C” 

   在其最后添加 “CNY”-->china yuan

```plsql
to_char(46,'FM99.99C')	-- 输出 46.NCY
```

## 2、字符串函数

### 2.1 去空格

- ltrim（）函数：用于去除字符串前面的所有空格

- rtrim（）函数：用于去除字符串尾部的所有空格

- trim（）函数 ：用以去除字符串两侧的所有空格

```plsql
select distinct trim(colum) str from table_name;  --去除列1两边的空格
```

### 2.2 取长度 length（）

 select distinct length('') len from a 输出为null
 select distinct length('42.12') len from a 输出为5，他是按字符串计算的

### 2.3 码值转换

 ASCII()  将第一个字符转化为ASCII（）码值
 chr（n）求对应的ASCII（）字符 ，n为数字
 如  ：

```plsql
select chr(65) from dual; --输出为A;为ASCII()反向操作
select ASCII('A') from dual; --输出为65;
```

2.4 大小写转换

- lower（）函数  ：把字符串全部转换为小写

- upper（）函数  ：把字符串全部转换为大写

- initcap（）函数：单词的首歌字符大写

### 2.5 字符串连接

 concat（）函数：把提供的两个参数连接起来，返回连接后的字符串

```plsql
select concat('nihao','shijie') hao from  dual;;--输出nihaoshijie;
```

 ||运算符，表连接，可连接多个

```plsql
 select concat('nihao','shijie'||'wo'||'ta') hao from dual;
 --输出nihaoshijiewota.连接是不用逗号隔开。
```

### 2.6 子串、查找和替换

- instr()函数：instr(列名或字符串，'查找的字符串') 检索字符串出现的位置，有出现输出1，没有找到就输出0

- substr（）函数：substr（列名或字符串，i，j） i，j 均为整数，如果j=0，就输出到最后一位，  

  ```plsql
  select substr('nihao',3) sub from dual;--输出  hao
  ```

- replace（）函数：以指定的字符串代替需要替换的字符串   
   replace（ 列名，1，2）用2来替换1  ,如

  ```plsql
  select replace('nihao','ni','ta') sub from dual;--输出为 tahao。
  ```

### 2.7 字符填充

-  lpad（）：左填充函数  lpad（'字符串1'，i，'字符串2'），i为整数，字符串1的长度小于i的话，用字符串2来就行填充，填充在左边，如果字符串1>i的话，留下i个

  ```plsql
  select distinct lpad('nihao','3','ta') sub from a;--输出nih
  select distinct lpad('nihao','7','ta') sub from a;--输出tanihao
  ```

-  rpad（）函数：用法同lpad（）函数类似，为右填充函数，其他同上一样  

