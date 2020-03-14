# Linux安装MySQL数据库

## CentOS

#### 安装

```shell
yum list installed mysql*  			# 列出已安装
# 1.删除已有的mysql
sudo yum remove mysql-community-* 	
rm -rf /var/lib/mysql
rm /etc/my.cnf
# 2.安装yum源
wget https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
sudo yum instal   mysql80-community-release-el7-1.noarch.rpm
# 3.查看是否安装成功
sudo yum repolist all|grep mysql
# 4.安装mysql
sudo yum install mysql-community-server
# 5.启动
sudo service mysqld start
sudo service mysqld status   # 查看mysql状态
sudo systemctl enable mysqld # 配置开机启动
# 6.设置密码
grep 'temporary password' /var/log/mysqld.log   # 找到默认密码
mysql -uroot -p 								# 登录
set password for 'root'@'localhost'=password('NEWPASSWORD'); 
# 或者
ALTER USER 'root'@'localhost' IDENTIFIED BY 'NEWPASSWORD';
```

#### 设置用户密码

1. 设置密码

   查看默认密码`grep 'temporary password' /var/log/mysqld.log`，使用默认密码登录 `mysql -uroot -p`

   ```mysql
   use mysql
   set password for 'root'@'localhost'=password('NEWPASSWORD'); 
   ```

2. 添加远程用户

   ```mysql
   CREATE USER 'username'@'ip/%' IDENTIFIED BY 'password';
   GRANT ALL PRIVILEGES ON dbname.tablename TO 'username'@'ip/%';
   DELETE FROM USER WHERE user='';	#解决登陆失败的问题 : Access denied for user 'wcc'@'localhost' 
   flush privileges;
   ```

#### 其他配置

修改配置文件`vim /etc/my.cnf`

```
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.6/en/server-configuration-defaults.html

[mysqld]
lower_case_table_names=1
character_set_server=utf8
init_connect='SET NAMES utf8'

#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock

# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0

# Recommended in standard MySQL setup
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES 

[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

[client]
default-character-set=utf8

[mysql]
default-character-set=utf8
```

