truncate（清空数据空间，保留表结构，数据不可恢复） DELETE（只删除数据，类似于标记复位） DROP 的区别

## 数据类型

mysql常用**数据类型**：

date datatime

int integer bigint long smallint 

char varchar text

blob



> note: rowid特点和应用  



## **操作符**

Null与其他数据的运算结果仍为null

字符连接  Oracle：` ||`		MySQL： `concat()`  `CONCAT_WS()`

`between and`  等同于 	 `<=  and  >=`

IN 

```sql
-- 支持多列
SELECT * FROM user_table WHERE (id,name) in((1,'jesse'),(2,'jack'));
```



模糊匹配

_ %

可以指定通配符 

ESCAPE

```sql
SELECT * FROM user_table WHERE name LIKE '%\%%' escape '\';
-- 找出含有%的记录
```



## 条件限制和排序

**null在排序中最大**，升序排序在最后，降序在最前



ORDER BY可以按真实列名、别名排序、顺序名(数字)排序，也可以使用合法的运算结果、 

```sql
SELECT id,name FROM user_table ORDER　BY　name; -- 真实列表
SELECT id,name FROM user_table ORDER　BY　2;-- 顺序名 即第二列
SELECT id,name as newname FROM user_table ORDER　BY　newname;-- 别名
SELECT id,name FROM user_table ORDER　BY　（id||name);-- 运算结果
```

## **分组及过滤**

group by comlums having condition 

note:  having 不同于order ，不支持使用别名



## 时间日期



## 函数

count(*)  count(1)  不忽略null值，count(col_name)忽略null值

|      |      |      |
| ---- | ---- | ---- |
|      |      |      |
|      |      |      |
|      |      |      |



## 多表关联

外连接存在传递性

## 事务

锁：显示锁(for update nowait)，隐式锁

## 视图

创建单表视图不能使用group by语句。

单表视图在使用DML操作时存在很多限制

## 数据库对象

- 序列

  序列是oracle提供的用于产生一系列唯一数字的数据库对象。通常用来产生非空唯一的主键

```sql
--创建序列
create sequence emp_eid_seq increment by 1 start with 1001 maxvalue 99999 minvalue 1001 nocycle nochache 
--使用序列
select emp_eid_seq.nextval from dual;--下一个
select emp_eid_seq.currval from dual;--当前
INSERT INTO HR_EMPLOYEE VALUES(emp_eid_seq.nextval,'Jesse'.....)
```

cache size 可以提高批量插入的效率

- 索引

  普通索引

  函数索引：在普通索引上使用函数会破坏索引，这时需要函数索引

- 同义词

  同义词即数据库对象的别名

```sql
CREATE SYNONYM HR_EMPLOYEE for HAP_DEV.HR_EMPLOYEE;
SELECT * FROM HR_EMPLOYEE;
DROP SYNONYM HR_EMPLOYEE;
```

## 集合操作

UNION／UNION　ALL

INTERSACT

MINUS

note：进行集合操作的查询结果之间必须有相同的列数，并且第二个查询结果数据类型能够隐式转化为第一个查询结果相对应的数据类型。



子查询

存在比较关系的情况下，子查询可以引用外层查询的字段，否则不能。



## 进阶

**全局临时表**

基于会话

> CREATE GLOBAL TEMPORARY TABLE temp_table_session (...) ON COMMIT **PRESERVE** ROWS;
> 基于会话的临时表，在会话断开之前，或者通过一个delete 或truncate 物理地删除行之前 ，
> 这些 行会一直存在于这个临时表中。只有我的会话能看到这些行，即使我已经提交，其他会话也无法看到我的行。

基于事务

> CREATE GLOBAL TEMPORARY TABLE temp_table_session (...) ON COMMIT **DELETE** ROWS;
> 基于事务的临时表，我的会话提交时，临时表中的行就不见了。只需把分配给这个表的临时区段交回 ，
> 这些



物化视图

-数据库的快照

用于跨数据库的数据访问，或者临时的数据库保存