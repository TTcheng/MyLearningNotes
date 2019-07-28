#!/bin/bash
cmd=`command -v docker`
if [ ${#cmd} -eq 0 ] ;then
    echo "command docker not exists"
    exit 1;
fi
docker_running=`systemctl status docker |grep "inactive"`
if [ ${#docker_running} -gt 0 ] ;then
    echo "start docker.service"
    systemctl start docker
else echo "docker is running"
fi
mysql_running=`docker ps | grep mysql`
mysql_contains=`docker ps -a| grep mysql`
if [ ! -z $mysql_running ];then
    echo "mysql is running"
elif [[ ${#mysql_running} -eq 0 && ${#mysql_contains} -gt 0 ]] ;then
    echo "mysql container exists,it will be restart"
    docker start mysql
elif [ -z $mysql_running ];then
    sudo docker run --name=mysql -it -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root \
	-v $PWD/mysql_db.cnf:/etc/mysql/conf.d/mysql_db.cnf \
	-v $PWD/logs:/logs \
	-v $PWD/mysql_data:/var/lib/mysql	\
	-d registry.saas.hand-china.com/tools/mysql:5.7.17
fi
unset cmd
unset docker_running
unset mysql_running
unset mysql_contains
exit 0
# -v $PWD/mysql_db.cnf:/etc/mysql/conf.d/mysql_db.cnf
# 将当前目录下的 conf/my.cnf 挂载到容器的/etc/mysql/my.cnf 
# -v $PWD/logs:/logs 
# 挂载当前目录logs到容器内/logs 
# -v $PWD/mysql_data:/var/lib/mysql	
# 将主机当前目录下的data目录挂载到容器的/var/lib/mysql 
