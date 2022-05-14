## 解决步骤

拨测报警

》》

界面接口报错

》》

![image-20220127103052280](%E6%95%B0%E6%8D%AE%E5%BA%93%E5%BC%82%E5%B8%B8waiting-for-table-flush.assets/image-20220127103052280.png)

》》

数据库存在大量Waiting for table flush的连接。

此时连接数已经达到1000

![image-20220127103133569](%E6%95%B0%E6%8D%AE%E5%BA%93%E5%BC%82%E5%B8%B8waiting-for-table-flush.assets/image-20220127103133569.png)

》》

找到一条可疑的长查询

```mysql
SELECT *
FROM information_schema.PROCESSLIST
where TIME > 10000
;
```

![image-20220127103445115](%E6%95%B0%E6%8D%AE%E5%BA%93%E5%BC%82%E5%B8%B8waiting-for-table-flush.assets/image-20220127103445115.png)

》》

问题解决：kill 182732

## 查找原因

### 从关键提示**waiting for table flush**排查

- 出现 Waiting for table flush的原因

​	 https://dev.mysql.com/doc/refman/5.6/en/general-thread-states.html

​	 The thread is executing [`FLUSH TABLES`](https://dev.mysql.com/doc/refman/5.6/en/flush.html#flush-tables) and is waiting for all threads to close their tables, or the thread got a notification that the underlying structure for a table has changed and it needs to reopen the table to get the new structure. However, to reopen the table, it must wait until all other threads have closed the table in question.          

This notification takes place if another thread has used [`FLUSH TABLES`](https://dev.mysql.com/doc/refman/5.6/en/flush.html#flush-tables) or one of the following statements on the table in question: `FLUSH TABLES tbl_name`, [`ALTER TABLE`](https://dev.mysql.com/doc/refman/5.6/en/alter-table.html), [`RENAME TABLE`](https://dev.mysql.com/doc/refman/5.6/en/rename-table.html), [`REPAIR TABLE`](https://dev.mysql.com/doc/refman/5.6/en/repair-table.html), [`ANALYZE TABLE`](https://dev.mysql.com/doc/refman/5.6/en/analyze-table.html), or [`OPTIMIZE TABLE`](https://dev.mysql.com/doc/refman/5.6/en/optimize-table.html).          

​	翻译一下：

​	因线程要执行`FLUSH TABLES`命令时需要等待所有线程去关闭他们的表，或者线程收到一个表的底层结构已更改的通知，它需要重新打开表以获取新结构。

但是，要重新打开该表，它必须等待所有其他线程关闭该表。

​	如果别的线程使用了flush tables或者 alter table，rename table，repair table，analyze table，optimize table 等DDL语句，就会收到Waiting for table flush这个通知。

​	而这些table可能会存在大的事务再执行，或者被锁住了，从而无法关闭table，所以就出现了状态：Waiting for table flush

​	也就是说：**需要执行 flush tables 的线程，因为某些原因无法关闭表，无法完成flush tables，所以就 waiting for table flush.**

### 结论：

- 长查询
- FLUSH TABLES（刷新所有表，刷新单表不会影响别的表的查询）

### 长查询分析

查询

```mysql
SELECT UUID(),
       '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',
       su.user_name,
       IFNULL(he.name, IFNULL(su.attribute1, su.USER_NAME)),
       IFNULL(he.mobil, su.PHONE),
       IFNULL(he.email, su.EMAIL)
FROM hdp.sys_user su
         LEFT JOIN hdp.hr_employee he ON he.employee_id = su.employee_id
LEFT JOIN fine.fr_t_user fu ON fu.userName = su.USER_NAME
WHERE fu.username is null
```

### 执行FLUSH TABLES的原因

可能的原因：

mysqldump没有添加single-transaction选项，隐含一个刷新所有表的flush tables命令

![image-20220127111213751](%E6%95%B0%E6%8D%AE%E5%BA%93%E5%BC%82%E5%B8%B8waiting-for-table-flush.assets/image-20220127111213751.png)

## 加固建议

中断长查询

凌晨不要执行长查询

如果有mysqldump ，一定要添加 --single-transaction

## MySQL健康检查相关SQL

```mysql
-- 查询正在运行的InnoDB表引擎的事务
select trx_id, trx_state, trx_started, trx_mysql_thread_id, trx_query, trx_operation_state
from information_schema.innodb_trx;
-- 杀掉某个线程
kill 794180;

-- 1、查询是否锁表
SHOW OPEN TABLES WHERE in_use > 0;
-- 2、查询进程
SHOW PROCESSLIST;
-- 加条件查询
SELECT *
FROM information_schema.PROCESSLIST
where 1=1
  AND HOST like 'crpprdmpp%'
  AND TIME > 10000
;
-- 慢查询
SELECT * FROM mysql.slow_log;
;

-- 查看正在锁的事务
SELECT *
FROM information_schema.innodb_locks;
-- 查看等待锁的事务
SELECT *
FROM information_schema.innodb_lock_waits;

-- 查询数据库数据量和所占空间
select
table_schema as '数据库',
sum(table_rows) as '记录数',
sum(truncate(data_length/1024/1024, 2)) as '数据容量(MB)',
sum(truncate(index_length/1024/1024, 2)) as '索引容量(MB)'
from information_schema.tables
where table_schema='hdp';

select TABLE_NAME,
       concat(truncate(data_length / 1024 / 1024, 2), ' MB')  as data_size,
       concat(truncate(index_length / 1024 / 1024, 2), ' MB') as index_size
from information_schema.tables
where TABLE_SCHEMA = 'hdp'
group by TABLE_NAME
order by data_length desc;
```