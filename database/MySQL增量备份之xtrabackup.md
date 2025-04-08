# XtraBackup增量备份

## 说明

本文已容器部署为例，非容器部署的方式更简单；

使用之前需要先确认版本是否支持对应的数据库

```shell
docker run --name percona-backup nexus.scgsdsj.com/percona/percona-xtrabackup:8.0 xtrabackup --version
```

## 先全量备份
说明： 

--user mysql:input 解决目录权限问题，如果对应数据目录的用户mysql，则不需要加，我这边容器启动的mysql默认是polkitd:input

```shell
docker run \
  --name percona-backup \
  --user mysql:input \
  -v /backup/mysql/:/backup/mysql/ \
  --rm \
  --network host \
  -t \
  -e TZ=Asia/Shanghai \
  -w /backup/mysql/ \
  --volumes-from mysql-3306 \
  --entrypoint=/usr/bin/xtrabackup \
  "nexus.scgsdsj.com/percona/percona-xtrabackup:8.0.35" \
  --defaults-file="/etc/mysql/conf.d/my.cnf" \
  --backup \
  --parallel 4 \
  --user="root" \
  --password="123456" \
  --compress=zstd --compress-threads=4 \
  --target-dir="mysql-backup-manual-20250402-full" >> mysql-backup-manual-20250402-full.log
```

## 再增量备份

1. 在上次全量备份的基础上做增量备份

```shell
docker run \
  --name percona-backup \
  --user mysql:input \
  -v /backup/mysql/:/backup/mysql/ \
  --rm \
  --network host \
  -t \
  -e TZ=Asia/Shanghai \
  -w /backup/mysql/ \
  --volumes-from mysql-3306 \
  --entrypoint=/usr/bin/xtrabackup \
  "nexus.scgsdsj.com/percona/percona-xtrabackup:8.0.35" \
  --defaults-file="/etc/mysql/conf.d/my.cnf" \
  --backup \
  --parallel 4 \
  --user="root" \
  --password="123456" \
  --compress=zstd --compress-threads=4 \
  --incremental-basedir="mysql-backup-manual-20250402-full" \
  --target-dir="mysql-backup-manual-20250403-incremental-01" \
  >> mysql-backup-manual-20250403-incremental-01.log
```

2. 在上次增量的基础上再做增量备份

```shell
docker run \
  --name percona-backup \
  --user mysql:input \
  -v /backup/mysql/:/backup/mysql/ \
  --rm \
  --network host \
  -t \
  -e TZ=Asia/Shanghai \
  -w /backup/mysql/ \
  --volumes-from mysql-3306 \
  --entrypoint=/usr/bin/xtrabackup \
  "nexus.scgsdsj.com/percona/percona-xtrabackup:8.0.35" \
  --defaults-file="/etc/mysql/conf.d/my.cnf" \
  --backup \
  --parallel 4 \
  --user="root" \
  --password="123456" \
  --compress=zstd --compress-threads=4 \
  --incremental-basedir="mysql-backup-manual-20250403-incremental-01" \
  --target-dir="mysql-backup-manual-20250404-incremental-01" \
  >> mysql-backup-manual-20250404-incremental-01.log
```

## 全量恢复

假设将备份文件传输到测试环境的/home/backup目录

### Decompress

```shell
docker run \
  --name percona-backup \
  --user root:input \
  -v /home/backup/:/backup/mysql/ \
  --rm \
  --network host \
  -t \
  -e TZ=Asia/Shanghai \
  -w /backup/mysql/ \
  --entrypoint=/usr/bin/xtrabackup \
  "nexus.scgsdsj.com/percona/percona-xtrabackup:8.0.35" \
  --parallel 4 \
  --decompress --compress-threads=4 --remove-original \
  --target-dir="mysql-backup-manual-20250402-full"
```
### Prepare

一般情况下，在备份完成后，数据尚且不能用于恢复操作，因为备份的数据中可能会包含尚未提交的事务或者已经提交但尚未同步至数据文件中的事务。因此，此时数据文件仍处于不一致状态。"准备"的主要作用正是通过回滚未提交的事务及同步已经提交的事务至数据文件也使用得数据文件处于一致性状态。

```shell
docker run \
  --name percona-backup \
  --user root:input \
  -v /home/backup/:/backup/mysql/ \
  --rm \
  --network host \
  -t \
  -e TZ=Asia/Shanghai \
  -w /backup/mysql/ \
  --entrypoint=/usr/bin/xtrabackup \
  "nexus.scgsdsj.com/percona/percona-xtrabackup:8.0.35" \
  --prepare \
  --parallel 4 \
  --target-dir="mysql-backup-manual-20250402-full"
```

**注意：如果还要应用后续的增量备份文件，则需要添加--apply-log-only选项**

### Restore

#### 恢复之前

```shell
# 必须停止mysql实例
docker stop mysql
# 清空数据目
rm -rf /data/mysql/data/

```

#### 恢复命令

通过xtrabackup恢复，或者通过文件复制的方法都可以

保留源文件，使用copy-back，不保留使用move-back

```shell
docker run \
  --name percona-backup \
  --user root:input \
  -v /home/backup/:/backup/mysql/ \
  --rm \
  --network host \
  -t \
  -e TZ=Asia/Shanghai \
  -w /backup/mysql/ \
  --volumes-from mysql-3306 \
  --entrypoint=/usr/bin/xtrabackup \
  "nexus.scgsdsj.com/percona/percona-xtrabackup:8.0.35" \
  --defaults-file="/etc/mysql/conf.d/my.cnf" \
  --move-back \
  --target-dir="mysql-backup-manual-20250402-full"
```

#### 启动之前

```shell
# ！！！我这里是docker部署，映射的数据目录、文件权限、启动命令可能都有所不同，根据实际情况来！！！
# 修正权限
chown -R polkitd:input /data/mysql/data/
# 启动
docker start mysql-3306
```



## 增量恢复

### Decompress

同全量恢复，多个按顺序来

### Prepare

#### 先准备基础备份

**和全量恢复不同的是，准备基础备份时需要添加--apply-log-only选项，否则将不能应用后续的增量，如果是最后一个增**

```shell
docker run \
  --name percona-backup \
  --user root:input \
  -v /home/backup/:/backup/mysql/ \
  --rm \
  --network host \
  -t \
  -e TZ=Asia/Shanghai \
  -w /backup/mysql/ \
  --entrypoint=/usr/bin/xtrabackup \
  "nexus.scgsdsj.com/percona/percona-xtrabackup:8.0.35" \
  --prepare --apply-log-only \
  --parallel 4 \
  --target-dir="mysql-backup-manual-20250402-full"
```

#### 再准备增量备份（多个则按顺序来）

**注意：最后一个增量不加--apply-log-only选项，前面的每一个全都要加**

应用第一个增量备份（20250403）

```shell
docker run \
  --name percona-backup \
  --user root:input \
  -v /home/backup/:/backup/mysql/ \
  --rm \
  --network host \
  -t \
  -e TZ=Asia/Shanghai \
  -w /backup/mysql/ \
  --entrypoint=/usr/bin/xtrabackup \
  "nexus.scgsdsj.com/percona/percona-xtrabackup:8.0.35" \
  --prepare --apply-log-only \
  --parallel 4 \
  --target-dir="mysql-backup-manual-20250402-full" \
  --incremental-dir="mysql-backup-manual-20250403-incremental-01"
```

应用第二个增量备份（20250404）

```shell
docker run \
  --name percona-backup \
  --user root:input \
  -v /home/backup/:/backup/mysql/ \
  --rm \
  --network host \
  -t \
  -e TZ=Asia/Shanghai \
  -w /backup/mysql/ \
  --entrypoint=/usr/bin/xtrabackup \
  "nexus.scgsdsj.com/percona/percona-xtrabackup:8.0.35" \
  --prepare \
  --parallel 4 \
  --target-dir="mysql-backup-manual-20250402-full" \
  --incremental-dir="mysql-backup-manual-20250404-incremental-01"
```

### Restore

同全量恢复

