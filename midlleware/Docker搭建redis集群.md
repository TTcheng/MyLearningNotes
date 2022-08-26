# Docker搭建Redis集群

最小集群为6节点，三主三从

## 准备

windows直接编辑复制以下脚本，替换6381为6382-6389

redis.conf

```nginx
#port（端口号）
port 6381
#masterauth（设置集群节点间访问密码，跟下面一致）
masterauth 123456
#requirepass（设置redis访问密码）
requirepass 123456
#cluster-enabled yes（启动集群模式）
cluster-enabled yes
#cluster-config-file nodes.conf（集群节点信息文件）
cluster-config-file nodes.conf
#cluster-node-timeout 5000（redis节点宕机被发现的时间）
cluster-node-timeout 5000
#cluster-announce-ip（集群节点的汇报ip，防止nat，预先填写为网关ip后续需要手动修改配置文件）
cluster-announce-ip 172.19.0.1
#cluster-announce-port（集群节点的汇报port，防止nat）
cluster-announce-port 6381
#cluster-announce-bus-port（集群节点的汇报bus-port，防止nat）
cluster-announce-bus-port 16381
#appendonly yes（开启aof）	
appendonly yes
```

分别放置到`H:\redis-cluster\node{idx}\redis.conf`索引`idx`从1-6

或者在linux平台，以脚本生成更方便

```shell
for node in $(seq 1 6); \
do \
mkdir -p ~/redis/node-${node}/conf
touch ~/redis/node-${node}/conf/redis.conf
cat << EOF > ~/redis/node-${node}/conf/redis.conf
port 6379
bind 0.0.0.0
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
cluster-announce-ip 172.28.0.1${node}
cluster-announce-port 6379
cluster-announce-bus-port 16379
appendonly yes
EOF
done
```

## 创建并运行容器

拉取redis镜像:docker pull redis

**指定前面准备的配置文件**

```shell
docker run --name redis-node1 --net host -v H:\redis-cluster\node1:/data redis:5.0.5 -p 6379:6379 -d redis redis-server /data/redis.conf
docker run --name redis-node2 --net host -v H:\redis-cluster\node2:/data redis:5.0.5 -p 6380:6380 -d redis redis-server /data/redis.conf  
  
docker run --name redis-node3 --net host -v H:\redis-cluster\node3:/data redis:5.0.5 -p 6381:6381 -d redis redis-server /data/redis.conf  
  
docker run --name redis-node4 --net host -v H:\redis-cluster\node4:/data redis:5.0.5 -p 6382:6382 -d redis redis-server /data/redis.conf  
  
docker run --name redis-node5 --net host -v H:\redis-cluster\node5:/data redis:5.0.5 -p 6383:6383 -d redis redis-server /data/redis.conf  
  
docker run --name redis-node6 --net host -v H:\redis-cluster\node6:/data redis:5.0.5 -p 6384:6384 -d redis redis-server /data/redis.conf
```

也可以以无配置文件启动集群

```shell
docker run -d --name redis-node-1 --net bridge --privileged=true -v H:\redis-cluster\node-1:/data redis --cluster-enabled yes --appendonly yes --port 6381
docker run -d --name redis-node-2 --net bridge --privileged=true -v H:\redis-cluster\node-2:/data redis --cluster-enabled yes --appendonly yes --port 6382
docker run -d --name redis-node-3 --net bridge --privileged=true -v H:\redis-cluster\node-3:/data redis --cluster-enabled yes --appendonly yes --port 6383
docker run -d --name redis-node-4 --net bridge --privileged=true -v H:\redis-cluster\node-4:/data redis --cluster-enabled yes --appendonly yes --port 6384
docker run -d --name redis-node-5 --net bridge --privileged=true -v H:\redis-cluster\node-5:/data redis --cluster-enabled yes --appendonly yes --port 6385
docker run -d --name redis-node-6 --net bridge --privileged=true -v H:\redis-cluster\node-6:/data redis --cluster-enabled yes --appendonly yes --port 6386

# --net bridge
# 使用桥接模式的网络
# --privileged=true
# 获取宿主机root权限
# -v H:\redis-cluster\node-5:/data
# 映射容器卷
# --cluster-enabled yes 
# 集群模式
# --appendonly yes 
# 开启aof持久化
# --port 6381
# redis端口号
```

```shell
# 每个节点都需要执行
config set masterauth 123456
config set requirepass 123456
# 重启会恢复，无配置文件的情况下也无法通过 config rewrite 的命令回写配置文件
```

## 配置集群

根据网络模式不通，访问方式有差异，查看网络模式`docker network ls`，查看网络使用情况`docker network inspect bridge`

### 桥接模式

> 桥接模式是docker 的默认网络设置，当Docker服务启动时，会在主机上创建一个名为docker0的虚拟[网桥](https://so.csdn.net/so/search?q=网桥&spm=1001.2101.3001.7020)，并选择一个和宿主机不同的IP地址和子网分配给docker0网桥

```shell
docker exec -it redis-node-1 /bin/bash
# 构建主从关系（桥接模式）:
redis-cli -a 123456 --cluster create 172.17.0.2:6381 172.17.0.3:6382 172.17.0.4:6383 172.17.0.5:6384 172.17.0.6:6385 172.17.0.7:6386 --cluster-replicas 1
# 注意，进入docker容器后才能执行一下命令，且注意自己的真实IP地址--cluster-replicas 1 表示为每个master创建一个slave节点
# 容器ip可以通过docker inspect redis-node-1查看
```

宿主机如何访问容器

> 桥接模式容器可以很容易的连接外网，但是无法直接访问容器内部

如果是Windows系统，安装的是Docker Desktop for Windows，那么可以下载最新的[docker-connector-win-x86_64.zip](https://github.com/wenjunxiao/mac-docker-connector/releases)解压。
首次安装还需要安装驱动驱动[tap-windows](http://build.openvpn.net/downloads/releases/latest/tap-windows-latest-stable.exe)。
在配置文件options.conf按照以下格式写入需要访问的bridge子网

    route 172.17.0.0/16

可以通过脚本start-connector.bat直接启动应用，也可以通过脚本install-service.bat把应用安装成服务，然后通过脚本start-service.bat启动服务。

这个docker-connector的原理是通过VPN实现的，具体可以查看github官网。

**这种方式网络带宽较低，实测从外部写入效率低，容易超时**

### 宿主机模式

> docker启动时添加`--net=host`，此模式下容器不会拥有自己的ip，而是使用宿主机的ip和端口。网络性能好，占用主机端口

```shell
docker exec -it redis-node-1 /bin/bash
# 构建主从关系（host模式）:
redis-cli -a 123456 --cluster create 192.168.0.104:6381 192.168.0.104:6382 192.168.0.104:6383 192.168.0.104:6384 192.168.0.104:6385 192.168.0.104:6386 --cluster-replicas 1
# ifconfig取主机的ip
```

