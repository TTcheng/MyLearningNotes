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
redis_running=`docker ps | grep redis`
contains_redis=`docker ps -a| grep redis`
if [ ! -z $redis_running ];then
    echo "redis is running"
elif [[ ${#redis_running} -eq 0 && ${#contains_redis} -gt 0 ]] ;then
    echo "redis container exists,it will be restart"
    docker start redis
elif [ -z $redis_running ];then
    sudo docker run --name=redis -it -p 6379:6379 -d registry.saas.hand-china.com/tools/redis
    sudo docker start redis
fi
exit 0
