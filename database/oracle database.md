Oracle数据库使用手册

## 开始之前

1、oracle database default users:

超级管理员：sys/chang_on_install;  用户名/密码

普通管理员：system/manager;

普通用户：scott/tiger;

大数据用户：sh/sh；

2、使用超级管理员用户管理：

cmd中输入：sqlplus sys/change_on_install as sysdba;

3、默认角色

|   role   |                 subscription                 |
| :------: | :------------------------------------------: |
| connect  | 主要应用在临时用户。只有连接权限，无法建表。 |
| resource |   连接，创建表、序列、过程、触发器、索引等   |
|   dba    |                 所有系统权限                 |

## 1、用户管理

1、创建用户

```sql
create user username identified by password;
create user usename identified by password
default tablespace dbsp_1 --默认表空间
temporary tablespace temp --临时表空间
quota unlimited on tbsp_1;--表空间不受限制
```

2、删除用户

```sql
drop user user_name cascade;
```

3、修改用户

```sql
--修改用户的磁盘配额
alter user username quota 20m on tbsp_1;
--改用户的口令
alter user usename identified by 123456;
--锁定用户
alter user username account lock;
--解锁被锁住的用户
alter user usename account unlock;
```

4、用户授权与撤销

````sql
--授权
grant priv_list to username;
--撤销
revoke priv_list from username;
--授予角色(权限组)
grant rolename to username;
--撤销角色
revoke rolename from username;
````

5、查询用户、角色列表

```sql
--查看所有用户
select * from dba_users;
select * from all_users;
select * from user_users;
--查看所有角色：
select * from dba_roles;
```

## 2、权限查询

```sql
--产看用户或角色系统权限
select * from dba_sys_privs;
select * from user_sys_privs(当前用户拥有的权限);
--查看角色(只能查看登陆用户拥有的角色)所包含的权限
sql>select * from role_sys_privs;
--查看用户对象权限：
select * from dba_tab_privs;   
select * from all_tab_privs;   
select * from user_tab_privs;
--查看某个用户所拥有权限
select * from dba_sys_privs where grantee='username';

```

## 3、查看数据库和表信息


```sql
-- 查看ORACLE 数据库中本用户下的所有表
SELECT table_name FROM user_tables;

-- 查看ORACLE 数据库中所有用户下的所有表
select user,table_name from all_tables;

-- 查看ORACLE 数据库中本用户下的所有列
select table_name,column_name from user_tab_columns;

-- 查看ORACLE 数据库中本用户下的所有列

select user,table_name,column_name from all_tab_columns;
-- 查看ORACLE 数据库中的序列号

select * from user_sequences;
-- 上面的所有对象，都可以通过下面的SQL语句查询得到

-- 查询所有的用户生成的ORACLE对象

SELECT * FROM user_objects;

-- 查看ORACLE 数据库中所有表的注释
select table_name,comments from user_tab_comments;

-- 查看ORACLE 数据库中所有列的注释
select table_name,column_name,comments from user_col_comments;

-- 给表加ORACLE的注释
COMMENT ON TABLE aa10 IS '系统参数表';

-- 给列加ORACLE的注释
COMMENT ON COLUMN aa10.aaa100 IS '参数类别';

-- 查看表中列的属性，包括 数据类型，是否非空等
DESC aa10;

-- 通过系统表，查看表中列的属性，包括 数据类型，是否非空等
SELECT table_name,COLUMN_ID,column_name,data_type,data_length,DATA_PRECISION,NULLABLE FROM user_tab_columns ORDER BY table_name,COLUMN_ID;

--查看所有表空间
select tablespace_name,sum(bytes)/1024/1024 from dba_data_files group by tablespace_name

--查看未使用表空间大小
select tablespace_name,sum(bytes)/1024/1024 from dba_free_space group bytablespace_name;

-- 查看数据库中表、索引占用的数据库空间大小
SELECT * FROM user_segments;

-- 查看所有表的记录数
CREATE TABLE table_count(table_name VARCHAR2(50),columns NUMBER(20));

-- 通过PB运行下面的语句，得到结果集，将结果集在PB下执行，最后提交
select 'insert into table_count values('''||table_name||''', (select  count(1)from '||table_name||'));//'||comments from user_tab_comments;

-- 所有表的记录都在table_count了
SELECT * FROM table_count;

```

## 4、数据类型

|      类型       |                             含义                             |
| :-------------: | :----------------------------------------------------------: |
|  CHAR(length)   | 固定长度的字符串。如果存储的字符串小于length，用space填充。默认长度是1，最长不超过2000字节。 |
| VARCHAR(length) | 可变长度的字符串。length指定了该字符串的最大长度。默认长度是1，最长不超过4000字符。 |
|   BUMBER(p,s)   | 浮点/整数。p代表数字的最大位数(浮点数包含小数点在内，默认值38)，s指小数位数。 |
|      DATE       | 日期和时间。存储纪元、4位年、月、日、时、分、秒。从公元前4712年1月1日到公元后4712年12月31日。 |
|    TIMESTAMP    |   不但存储日期的年月日时分秒、以及秒后6位，同时包含时区。    |
|      CLOB       |                大文本。如非结构化的XML文档。                 |
|      BLOB       |              二进制对象。如图形、声音、视频等。              |
|                 |                                                              |

