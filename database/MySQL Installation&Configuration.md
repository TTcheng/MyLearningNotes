# MySQL安装配置

## 安装

[MySQL Community Downloads](https://dev.mysql.com/downloads/)

### Linux

#### debian

```shell
wget https://dev.mysql.com/get/mysql-apt-config_0.8.15-1_all
.deb
sudo dpkg -i mysql-apt-config_0.8.15-1_all
.deb
# apt install lsb-release gnupg
sudo apt update
sudo apt install mysql-server
# sudo systemctl start mysqld
sudo service mysqld start
# 初始化root密码
sudo mysql_secure_installation
```

#### redhat

```shell
wget http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm 
rpm -ivh mysql-community-release-el7-5.noarch.rpm
yum -y install mysql mysql-server mysql-devel
sudo mysql_secure_installation
```

### Docker

```shell
# 拉取镜像
docker pull mysql:5.7
# 创建实例
docker run -d -p 3306:3306 --name mysql -e MYSQL_ROOT_PASSWORD=root -v /hzero/data-server/mysql/mysql_data/:/var/lib/mysql/:rw -v /hzero/data-server/mysql/mysql_cnf:/etc/mysql/:rw --privileged=true 954
# 启动停止
docker start mysql
docker stop mysql
```

```
[mysqld]
lower_case_table_names=l
max_connections=1000
```

## 配置

my.cnf

```
[mysqld]
lower_case_table_names=1
character_set_server=utf8
init_connect='SET NAMES utf8'
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

## 卸载

```shell
# apt
sudo apt-get autoremove --purge mysql-server
# yum
sudo yum remove mysql-server
```

## 备份及恢复（迁移）

```shell
mysqldump -u root -p hdp > hdp.sql
mysql -u root -p --default-character-set=utf8 hdp < hdp.sql
```

