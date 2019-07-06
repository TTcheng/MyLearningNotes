## 查看MySQL时间/时区

```sql
SELECT now();
show variables like '%time_zone%'
```

## 解决方案

### 修改Spring的配置

```yml
spring:
  jackson:
    time-zone: GMT+8
```

### 修改mysql时区

**方法一**

```mysql
set global time_zone = '+8:00'; ##修改mysql全局时区为北京时间，即我们所在的东8区
set time_zone = '+8:00'; ##修改当前会话时区
flush privileges; #立即生效, 重启失效
```

**方法二**

```shell
nano /etc/my.cnf 
##在[mysqld]区域中加上 default-time_zone = '+8:00'
/etc/init.d/mysqld restart ##重启mysql使新时区生效
```

### 在连接URL中指定时区

jdbc:mysql://db.mygroup.com:3306/dbname?serverTimezone=GMT%2B8
或者`UTC`/`HongKong`/`Asia/Shanghai`

