# 导入导出

> 本文针对Oracle 11g，其他版本可能会有所不同

## 逻辑导入导出（imp/exp/impdp/expdp）

### 导出

源数据库主机实例上执行

1. 定义备份目录
   
    ```sql
    -- 查看已经定义的目录
    SELECT * FROM dba_directories;
    -- 若没有合适的，则创建一个
    CREATE directory EXPDP_BK_DIR_JG AS '/home/oracle/backup';
    ```
2. 导出数据

    命令形式
    ```shell
    expdp SCOTT/scott@2024 schemas=SCOTT dumpfile=scott202410251525.dmp directory=EXPDP_BK_DIR_JG logfile=scott202410251525.log
    # oracle用户下
    expdp \"/ as sysdba\" schemas=FR dumpfile=FR-stage-v2-$(date +%F).dmp directory=EXPDP_BK_DIR_JG logfile=FR-stage-v2-$(date +%F).log
    ```

    网络环境允许的话，以通过dblink实现远程导入，避免导入导出文件。（需要先建好DB_LINK，这里不解释，可搜索其他参考文档）

    ```shell
    impdp SCOTT/scott@2024 network_link=SCOTT_LINK_TEST schemas=SCOTT exclude=statistics 
    # 其中exclude=statistics表示跳过统计信息，可以在导入后调用存储过程生成：exec dbms_stats.gather_schema_stats(ownname=>"SCOTT");
    ```
    
    脚本形式
    
    ```shell
    #!/bin/bash
    ORACLE_HOME=
    oracle_user=
    oracle_password=
    filename="ora-bak-${oracle_user}-$(date +%y%m%d)"
    ${ORACLE_HOME}/bin/expdp "${oracle_user}/${oracle_password}" \
            PARALLEL=4  \
            cluster=no \
            COMPRESSION=ALL \
            DUMPFILE="${filename}.dmp" \
            DIRECTORY=EXPDP_BK_DIR_JG \
            logfile="${filename}.log" \
            SCHEMAS="${oracle_user}"
    ```

3. 详细参考文档

   https://docs.oracle.com/cd/E11882_01/server.112/e22490/dp_export.htm#i1007466

### 导入

1. 导入前检查：

    检查导入文件的路径变量是否已定义；
    检查用户表空间，临时表空间等是否已经创建，空间是否足够，用户是否已经授权。

2. 导入
   

    将备份文件放置在定义好的路径下，在目标数据库实例上执行以下命令

    ```shell
    impdp SCOTT/scott@2024 dumpfile=scott202410251525.dmp directory=EXPDP_BK_DIR_JG logfile=scott202410251525.log table_exists_action=replace
    ```

3. 详细参考文档

   https://docs.oracle.com/cd/E11882_01/server.112/e22490/dp_import.htm#SUTIL300

## 物理备份恢复（rman）

### 前提

1. 安装好数据库并配置了环境变量`ORACLE_HOME`和`ORACLE_SID`
2. 需要开启归档模式

开启归档
`su - orcale && sqlplus / as sysdba`

```sql
-- 谨慎操作，这会关闭数据库
SHUTDOWN IMMEDIATE;
startup mount;
alter database archivelog;
-- ALTER DATABASE ARCHIVELOG OFF;
alter database open;
```

### 全量备份

vim /home/oracle/backup/manual/backup_all.sh

```shell
#!/bin/bash
source ~/.bash_profile
DATE=`date +%Y%m%d`
mkdir -p "/home/oracle/backup/manual/${DATE}"
# 远程目标sys/password@remoate_database，本地目标直接斜杠
rman target / msglog /home/oracle/backup/manual/${DATE}/rlog_$DATE append << EOF 
run{ 
   allocate channel c1 device type disk;
   allocate channel c2 device type disk;
   allocate channel c3 device type disk;
   allocate channel c4 device type disk;
   allocate channel c5 device type disk;
   crosscheck backup;
   sql 'alter system archive log current';
   backup as compressed backupset database format '/home/oracle/backup/manual/%T/db_%d_%T_%U.bak';
   sql 'alter system archive log current';
   backup as compressed backupset archivelog all format '/home/oracle/backup/manual/%T/arc_%t_%s.bak'; 
   backup current controlfile format '/home/oracle/backup/manual/%T/cntrl_%p_%s.bak';
   crosscheck archivelog all;
   delete noprompt expired archivelog all;
   delete noprompt expired backup;
   delete noprompt backup of database completed before 'sysdate - 7';
   delete noprompt backup of archivelog all completed before 'sysdate - 7';
   delete noprompt archivelog all completed before 'sysdate - 15';
   delete noprompt obsolete;
   delete noprompt obsolete redundancy 1;
   release channel c1;
   release channel c2;
   release channel c3;
   release channel c4;
   release channel c5;
}
EOF

```
### 全量恢复

指定备份文件所在位置，这样数据库会自动在该路径下找备份文件进行恢复。

```rman
catalog start with '/home/oracle/bak/';
LIST BACKUP;
LIST BACKUP SUMMARY;
STARTUP MOUNT;
crosscheck backup;
delete expired backup;
RESTORE DATABASE;
RECOVER DATABASE;
ALTER DATABASE OPEN;
```
如果目标端数据文件路径和源端不一致，还需要指定下新路径，示例：

#### 表空间恢复

表空间离线 => 恢复表空间 => 表空间在线

```rman
SQL 'ALTER TABLESPACE users OFFLINE IMMEDIATE';
RESTORE TABLESPACE users;
RECOVER TABLESPACE users;
SQL 'ALTER TABLESPACE users ONLINE';
```
#### 数据文件恢复


### 增量备份

```rman
backup archivelog all '/home/oracle/backup/manual/%T/arc_%t_%s.bak' not backed up 1 times;　　
```

### 增量恢复

TODO
