# InfluxDB

## 基本操作

### 增与查

- 命令行

```SQL
use testDB
INSERT weather,altitude=1000,area=北 temperature=11,humidity=-4
SELECT * FROM weather ORDER BY time DESC LIMIT 3
```
- HTTP API

```shell
curl -i -XPOST 'http://localhost:8086/write?db=testDB' 
	--data-binary 'weather,altitude=1000,area=北 temperature=11,humidity=-4'
	
curl -G 'http://localhost:8086/query?pretty=true' 
	--data-urlencode "db=testDB" --data-urlencode "q=SELECT * FROM weather ORDER BY time DESC LIMIT 3"
```

### 删与改

在InfluxDB中并没有提供数据的删除与修改方法。
不过我们可以通过数据保存策略（Retention Policies）来实现删除。

### 数据保存策略（Retention Policies）

InfluxDB没有提供直接删除Points的方法，但是它提供了Retention Policies。
主要用于指定数据的保留时间：当数据超过了指定的时间之后，就会被删除。

```mysql
# 查看当前数据库的Retention Policies
SHOW RETENTION POLICIES ON "testDB"
# 创建新的数据保存策略. 
# rp_name：策略名,30d：保存30天,其他参数h（小时），w（星期），REPLICATION 1：副本个数，DEFAULT 设为默认的策略
CREATE RETENTION POLICY "rp_name" ON "db_name" DURATION 30d REPLICATION 1 DEFAULT
# 修改数据保存策略. 
ALTER RETENTION POLICY "rp_name" ON db_name" DURATION 3w DEFAULT
# 删除
DROP RETENTION POLICY "rp_name" ON "db_name"
```

### 数据库与表操作

```mysql
# 创建数据库
CREATE DATABASE "db_name"
# 显示所有数据库
SHOW DATABASES
# 删除数据库
DROP DATABASE "db_name"

# 使用数据库
USE mydb

# 显示该数据库中的表
SHOW MEASUREMENTS

# 创建表
# 直接在插入数据的时候指定表名（weather就是表名）
insert weather,altitude=1000,area=北 temperature=11,humidity=-4

# 删除表
DROP MEASUREMENT "measurementName"
```

### 连续查询（Continuous Queries）

当数据超过保存策略里指定的时间之后，就会被删除。
如果我们不想完全删除掉，比如做一个数据统计采样：把原先每秒的数据，存为每小时的数据，让数据占用的空间大大减少（以降低精度为代价）。  

这就需要InfluxDB提供的：连续查询（Continuous Queries）。

```mysql
# 当前数据库的连续查询，这条命令得在命令行下输入，在web管理界面不能显示。
SHOW CONTINUOUS QUERIES
# 删除连续查询策略
DROP CONTINUOUS QUERY <cq_name> ON <database_name>
# 新增连续查询
CREATE CONTINUOUS QUERY cq_30m ON testDB BEGIN SELECT mean(temperature) INTO weather30m FROM weather GROUP BY time(30m) END  
```

解释

1. cq_30m：连续查询的名字
2. testDB：具体的数据库名
3. mean(temperature): 算平均温度
4. weather： 当前表名
5. weather30m： 存新数据的表名
6. 30m：时间间隔为30分钟

**当我们插入新数据之后，可以发现数据库中多了一张名为weather30m(里面已经存着计算好的数据了)。这一切都是通过Continuous Queries自动完成的。**

```bash
> SHOW MEASUREMENTS
name: measurements
------------------
name
weather
weather30m
```

### 用户管理

```mysql
# 显示用户
SHOW USERS
# 创建用户
CREATE USER "username" WITH PASSWORD 'password'
# 创建管理员权限的用户
CREATE USER "username" WITH PASSWORD 'password' WITH ALL PRIVILEGES

# 删除用户
DROP USER "username"
# 设置密码
SET PASSWORD FOR <username> = '<password>'
# 为用户授权
GRANT [READ,WRITE,ALL] ON <database_name> TO <username>
# 取消授权
REVOKE [READ,WRITE,ALL] ON <database_name> FROM <username>
# 展示用户在不同数据库上的权限
SHOW GRANTS FOR <user_name>
```