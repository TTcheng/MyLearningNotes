# Linux安装MySQL数据库

## CentOS

### 安装

```shell
yum list installed mysql*  			# 列出已安装
# 1.删除已有的mysql
sudo yum remove mysql-community-* 	
rm -rf /var/lib/mysql
rm /etc/my.cnf
# 2.安装yum源
# 这里el6、el7、el8各版本是不同的，取决于操作系统的版本，可以使用uname -a命令查看，如：Linux ecs-332869 4.18.0-240.10.1.el8_3.x86_64 #1 SMP Mon Jan 18 17:05:51 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux
# 这里以el7为例，全部的repo清单可以访问https://dev.mysql.com/downloads/repo/yum/
wget https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
sudo yum install mysql80-community-release-el7-1.noarch.rpm
# 3.查看是否安装成功
sudo yum repolist all|grep mysql
# 4.安装mysql
sudo yum-config-manager --disable mysql80-community
sudo yum-config-manager --enable mysql57-community
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

### 设置用户密码

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

### 其他配置

修改配置文件`vim /etc/my.cnf`

```properties
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.6/en/server-configuration-defaults.html

[mysqld]
bind-address=0.0.0.0
port=13307
user=mysql
#basedir=/usr/local/mysql
datadir=/data/mysql
socket=/tmp/mysql.sock
transaction-isolation = READ-COMMITTED
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
lower_case_table_names=1
max_connections = 1000
character_set_server=utf8mb4
init_connect='SET NAMES utf8'

# Recommended in standard MySQL setup
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES 

# mysqld中后面这部分配置，是内存比较大的配置。如果不清楚，建议全部注释使用默认

key_buffer_size = 32M
max_allowed_packet = 16M
thread_stack = 256K
thread_cache_size = 64
query_cache_limit = 8M
query_cache_size = 64M
query_cache_type = 1

#expire_logs_days = 10
#max_binlog_size = 100M
#log_bin should be on a disk with enough free space.
#Replace '/var/lib/mysql/mysql_binary_log' with an appropriate path for your
#system and chown the specified folder to the mysql user.
log_bin=/data/mysql/mysql_binary_log

#In later versions of MySQL, if you enable the binary log and do not set
#a server_id, MySQL will not start. The server_id must be unique within
#the replicating group.
server_id=1
binlog_format = mixed

read_buffer_size = 2M
read_rnd_buffer_size = 16M
sort_buffer_size = 8M
join_buffer_size = 8M

# InnoDB settings
innodb_file_per_table = 1
innodb_flush_log_at_trx_commit  = 2
innodb_log_buffer_size = 64M
innodb_buffer_pool_size = 4G
innodb_thread_concurrency = 8
innodb_flush_method = O_DIRECT
innodb_log_file_size = 512M

[mysqld_safe]
log-error=/data/mysql/mysql.err
pid-file=/data/mysql/mysql.pid

[client]
default-character-set=utf8

[mysql]
default-character-set=utf8
```

## Debian

### 安装MySQL的APT软件源

下载地址：

https://dev.mysql.com/downloads/repo/apt/

如：

https://repo.mysql.com//mysql-apt-config_0.8.17-1_all.deb

安装：

```shell
apt install ./mysql-apt-config_0.8.17-1_all.deb
```

配置，选择操作系统，debian 10对应 buster

![image-20210427203324479](%E5%AE%89%E8%A3%85MySQL.assets/image-20210427203324479.png)

选择版本：选择5.7

![image-20210427203730117](%E5%AE%89%E8%A3%85MySQL.assets/image-20210427203730117.png)

接下来OK就行了

### 安装MySQL

```shell
# 安装mysql，安装时会要求输入ROOT密码，安装完会自动启动
sudo apt install mysql-server mysql-client
# 启动
sudo systemctl start mysql   # 手动启动，安装会自动启动
sudo systemctl status mysql  # 查看mysql状态
sudo systemctl enable mysql  # 配置开机启动
```

### 添加普通用户

root用户默认是不支持远程登陆的，可以设置，但是建议不要直接使用root，而是按项目新建用户用以远程登录。

使root能任意host访问（不建议）

`update user set host = '%' where user = 'root'`

建议创建用户

```shell
CREATE USER 'username'@'ip/%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON dbname.tablename TO 'username'@'ip/%';
DELETE FROM USER WHERE user='';	#解决登陆失败的问题 : Access denied for user 'wcc'@'localhost' 
flush privileges;
```

### 其它配置

修改my.cnf，参考Cent OS部分

配置自己的数据目录：

- 方法一

  ```shell
  mv /usr/lib/mysql /data/mysql
  ```

- 重新生成一个

  ```shell
  # 初始化
  ./mysqld --datadir=/data/mysql/ --user=mysql --initialize
  # 查看临时密码 
  cat /data/mysql/error.log
  # 使用临时密码登录，设置密码
  mysql -uroot –p
  mysql> SET PASSWORD = PASSWORD('new password');
  mysql> ALTER USER 'root'@'localhost' PASSWORD EXPIRE NEVER;
  mysql> FLUSH PRIVILEGES; 
  ```

注意，如果修改了mysql.sock这个文件的路径，记得在[mysql]标签下同步同时添加一个

## 其它Linux

### 下载

https://dev.mysql.com/downloads/mysql/5.7.html

选择5.7，操作系统选择Generic Linux

下载tar包

### 安装配置

```shell
# 下载
wget https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.29-linux-glibc2.12-x86_64.tar.gz
su root
# 解压
tar zxvf mysql-5.7.29-linux-glibc2.12-x86_64.tar.gz
# 移动并重命名为/usr/local/mysql
mv mysql-5.7.29-linux-glibc2.12-x86_64 /usr/local/mysql
# 添加用户和用户组
groupadd mysql
useradd -r -g mysql mysql
# 创建数据目录，并修改用户
mkdir -p /data/mysql
chown mysql:mysql -R /data/mysql
vim /etc/my.cnf
# 编辑配置，参考cent os安装部分的其它配置
```

### 初始化

```shell
cd /usr/local/mysql/bin/
# 安装可能用到的依赖
# rhel
yum -y install perl perl-devel autoconf libaio
# debian
sudo apt install libncurses5
# 初始化
./mysqld --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql/  --datadir=/data/mysql/ --user=mysql --initialize
# 查看密码，搜索temporary password ,记录备用
cat /data/mysql/mysql.err |grep temporary password
# 安装服务
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql
# 启动
service mysql start
# 链接命令
ln -s /usr/local/mysql/bin/mysql /usr/bin
# 使用临时密码登录，设置密码
mysql -uroot –p
mysql> SET PASSWORD = PASSWORD('new password');
mysql> ALTER USER 'root'@'localhost' PASSWORD EXPIRE NEVER;
mysql> FLUSH PRIVILEGES; 
```

添加普通用户

```shell
# %代表所有IP，或者不用%指定IP
CREATE USER 'username'@'ip/%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON dbname.tablename TO 'username'@'ip/%';
DELETE FROM mysql.USER WHERE user='';	#解决登陆失败的问题 : Access denied for user 'wcc'@'localhost' 
flush privileges;
```

## Arch/Manjaro

Note：大部分和其他Linux操作步骤一样。多出安装依赖库，以及启动方式略有不同

```shell
# 安装依赖库(需要archlinuxcn源)
sudo pacman -S libaio numactl libxcrypt-compat ncurses5-compat-libs
# 初始化
# ./mysqld --defaults-file=/etc/my.cnf --basedir=/opt/mysql/  --datadir=/data/mysql/ --user=mysql --initialize

# 修改mysql.server启动脚本
sudo -u mysql vim /opt/mysql/support-files/mysql.server
# 如果默认配置文件不是MySQL支持的/etc/my.cnf或者，默认安装目录不是/usr/local，则需要修改其内容如下
# basedir=/opt/mysql
# datadir=/data/mysql

# 启动
sudo -u mysql /opt/mysql/support-files/mysql.server start
```


# 安装MySQL8

## Linux通用

**如缺少相关依赖库，可参考前面各系统安装5.7的依赖安装步骤**

```shell
# 下载
wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.31-linux-glibc2.17-x86_64-minimal.tar.xz
# 添加用户组和用户
groupadd mysql
useradd -r -g mysql -s /bin/false mysql
# 解压
tar xvf /path/to/mysql-VERSION-OS.tar.xz
sudo mv /path/to/mysql-VERSION-OS /opt/mysql8
# 可选，创建命令链接
ln -s /opt/mysql8/bin/mysql mysql8

# 创建数据目录，并修改用户
mkdir -p /data/mysql8
chown mysql:mysql -R /data/mysql8
# 编辑配置，完整配置参考下一个代码块
# ！！注意：如果不是默认的my.cnf，则几乎所有mysql的命令都需要带上参数--defaults-file=/path/to/my.cnf
vim /etc/my8.cnf
# 初始化
/opt/mysql8/bin/mysqld --defaults-file=/etc/my8.cnf --basedir=/opt/mysql8/  --datadir=/data/mysql8/ --user=mysql --initialize
# 查看临时root密码
cat /data/mysql/mysql.err |grep temporary password

# 安装服务，可以支持使用service命令启动
ln -s /opt/mysql8/support-files/mysql.server /etc/init.d/mysql.server
# 如果默认配置文件不是MySQL支持的/etc/my.cnf或者，默认安装目录不是/usr/local，则需要修改其内容如下
sed -i 's basedir= basedir=/opt/mysql8' /opt/mysql8/support-files/mysql.server
sed -i 's datadir= datadir=/data/mysql8' /opt/mysql8/support-files/mysql.server
sed -i 's conf=/etc/my.cnf conf=/etc/my8.cnf g' /opt/mysql8/support-files/mysql.server
sed -i 's extra_args="" extra_args="--defaults-file=/etc/my8.cnf" g' /opt/mysql8/support-files/mysql.server
sed -i 's lockdir='/var/lock/subsys' lockdir='/data/mysql8' g' /opt/mysql8/support-files/mysql.server
sed -i 's lock_file_path="$lockdir/mysql" lock_file_path="/data/mysql8/mysql.lock" g' /opt/mysql8/support-files/mysql.server
# 替换启动命令，增加默认配置文件选项。这里sed命令修改分隔符为井号（#），因为替换字符串中含有空格
sed -i 's#$bindir/mysqld_safe --datadir#$bindir/mysqld_safe --defaults-file=/etc/my8.cnf --datadir#g' /opt/mysql8/support-files/mysql.server

# 启动
sudo -u mysql /opt/mysql8/support-files/mysql.server start

# 使用临时密码登录，设置密码
/opt/mysql8/bin/mysql -uroot –p -S /tmp/mysql8.sock
mysql> ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'PASSWORD';
mysql> ALTER USER 'root'@'localhost' PASSWORD EXPIRE NEVER;
mysql> FLUSH PRIVILEGES; 
```

参考配置文件

```properties
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/5.6/en/server-configuration-defaults.html

[mysqld]
bind-address=0.0.0.0
port=23306
user=mysql
#basedir=/usr/local/mysql
datadir=/data/mysql8
socket=/tmp/mysql8.sock
log-error=/data/mysql8/mysql.err
pid-file=/data/mysql8/mysql.pid
transaction-isolation = READ-COMMITTED
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
lower_case_table_names=1
max_connections = 1000
character_set_server=utf8mb4
init_connect='SET NAMES utf8'

# Recommended in standard MySQL setup
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

# mysqld中后面这部分配置，是内存比较大的配置。如果不清楚，建议全部注释使用默认

key_buffer_size = 32M
max_allowed_packet = 16M
thread_stack = 256K
thread_cache_size = 64

#expire_logs_days = 10
#max_binlog_size = 100M
#log_bin should be on a disk with enough free space.
#Replace '/var/lib/mysql/mysql_binary_log' with an appropriate path for your
#system and chown the specified folder to the mysql user.
log_bin=/data/mysql8/mysql_binary_log

#In later versions of MySQL, if you enable the binary log and do not set
#a server_id, MySQL will not start. The server_id must be unique within
#the replicating group.
server_id=1
binlog_format = mixed

read_buffer_size = 2M
read_rnd_buffer_size = 16M
sort_buffer_size = 8M
join_buffer_size = 8M

# InnoDB settings
innodb_file_per_table = 1
innodb_flush_log_at_trx_commit  = 2
innodb_log_buffer_size = 64M
innodb_buffer_pool_size = 4G
innodb_thread_concurrency = 8
innodb_flush_method = O_DIRECT
innodb_redo_log_capacity = 512M

[mysqld_safe]

[client]
default-character-set=utf8

[mysql]
default-character-set=utf8
```