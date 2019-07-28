## run mysql
```shell
sudo docker run --name=mysql -it -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root \
	-v $PWD/mysql_db.cnf:/etc/mysql/conf.d/mysql_db.cnf \
	-v $PWD/logs:/logs \
	-v $PWD/mysql_data:/var/lib/mysql	\
	-d registry.saas.hand-china.com/tools/mysql:5.7.17 
# -v $PWD/mysql_db.cnf:/etc/mysql/conf.d/mysql_db.cnf
# 将当前目录下的 conf/my.cnf 挂载到容器的/etc/mysql/my.cnf 
# -v $PWD/logs:/logs 
# 挂载当前目录logs到容器内/logs 
# -v $PWD/mysql_data:/var/lib/mysql	
# 将主机当前目录下的data目录挂载到容器的/var/lib/mysql 
```

sudo docker run --name=mysql -it -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root -d mysql

## Stop mysql

docker ps -a # find containerId

docker stop $containerId 

可能还需要 docker rm $containerI

## login 
docker exec -it mysql mysql -uroot -p
