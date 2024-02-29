# Docker

## 简介

Docker 是一个开源的应用容器引擎，基于 Go 语言   并遵从Apache2.0协议开源。 

Docker 可以让开发者打包他们的应用以及依赖包到一个轻量级、可移植的容器中，然后发布到任何流行的 Linux 机器上，也可以实现虚拟化。

容器是完全使用沙箱机制，相互之间不会有任何接口，更重要的是容器性能开销极低。

### Docker 的优点

- **1、简化程序：**
  Docker  让开发者可以打包他们的应用以及依赖包到一个可移植的容器中，然后发布到任何流行的  Linux  机器上，便可以实现虚拟化。Docker改变了虚拟化的方式，使开发者可以直接将自己的成果放入Docker中进行管理。方便快捷已经是  Docker的最大优势，过去需要用数天乃至数周的	任务，在Docker容器的处理下，只需要数秒就能完成。
- **2、避免选择恐惧症：**
  如果你有选择恐惧症，还是资深患者。那么你可以使用 Docker 打包你的纠结！比如 Docker  镜像；Docker 镜像中包含了运行环境和配置，所以 Docker 可以简化部署多种应用实例工作。比如 Web  应用、后台应用、数据库应用、大数据应用比如 Hadoop 集群、消息队列等等都可以打包成一个镜像部署。 
- **3、节省开支：**
  一方面，云计算时代到来，使开发者不必为了追求效果而配置高额的硬件，Docker 改变了高性能必然高价格的思维定势。Docker 与云的结合，让云空间得到更充分的利用。不仅解决了硬件管理的问题，也改变了虚拟化的方式。

### docker应用场景

- Web 应用的自动化打包和发布。
- 自动化测试和持续集成、发布。
- 在服务型环境中部署和调整数据库或其他的后台应用。
- 从头编译或者扩展现有的 OpenShift 或 Cloud Foundry 平台来搭建自己的 PaaS 环境。

## 架构

Docker 使用客户端-服务器 (C/S) 架构模式，使用远程API来管理和创建Docker容器。

Docker 容器通过 Docker 镜像来创建。

容器与镜像的关系类似于面向对象编程中的对象与类。

![img](assets/576507-docker1.png)

| Docker 镜像(Images)    | Docker 镜像是用于创建 Docker 容器的模板。                    |
| ---------------------- | ------------------------------------------------------------ |
| Docker 容器(Container) | 容器是独立运行的一个或一组应用。                             |
| Docker 客户端(Client)  | Docker 客户端通过命令行或者其他工具使用 Docker API (https://docs.docker.com/reference/api/docker_remote_api) 与 Docker 的守护进程通信。 |
| Docker 主机(Host)      | 一个物理或者虚拟的机器用于执行 Docker  守护进程和容器。      |
| Docker 仓库(Registry)  | Docker 仓库用来保存镜像，可以理解为代码控制中的代码仓库。 Docker Hub(https://hub.docker.com) 提供了庞大的镜像集合供使用。 |
| Docker Machine         | Docker Machine是一个简化Docker安装的命令行工具，通过一个简单的命令行即可在相应的平台上安装Docker，比如VirtualBox、 Digital Ocean、Microsoft Azure。 |

## 安装

> **Note**：要安装dokcer，需要linux内核大于3.10。可使用`uname -r`查看内核版本。

- linux通用安装：

```shell
# 安装命令，须已安装wget
wget -qO- https://get.docker.com/ | sh
# 启动服务
systemctl start docker 	# 单次启动
systemctl enable docker # 开机自启动
# 测试
docker --version	# 安装成功则显示版本
docker ps			# 可验证服务是否启动成功
```

- 常用发行版安装：

各发行版都有自己的包管理器，使用软件包管理器安装应用可以方便地升级和卸载

```shell
# centos
yum install docker
# debian/ubuntu/deepin
sudo apt-get install docker-engine
# arch/manjaro
sudo pacman -S docker
```

- 镜像加速

修改/etc/docker/daemon.json，使用国内镜像地址。

`sudo nano /etc/docker/daemon.json`

```json
{
  "registry-mirrors": ["http://hub-mirror.c.163.com"]
}
```

## 镜像管理

### 基本使用

```shell
docker images				# 列出本地镜像
docker pull ubuntu:13.10	# 获取镜像
docker search httpd			# 查找镜像
docker run httpd			# 使用镜像
```

### 高级运用

#### 创建镜像

当我们从docker镜像仓库中下载的镜像不能满足我们的需求时，我们可以通过以下两种方式对镜像进行更改。

##### 1.从已经创建的容器中更新镜像，并且提交这个镜像

```shell
# 更新镜像之前，我们需要使用镜像来创建一个容器。 
docker run -t -i ubuntu:15.10 /bin/bash
# 容器内更新
sudo apt update
# 退出容器
exit 
# 提交容器副本创建镜像
docker commit -m="description" -a="author" e218edb10161 wcc/ubuntu:v2
```

其中e218edb10161为容器id， wcc/ubuntu:v2为镜像名

##### 2.使用 Dockerfile 指令来创建一个新的镜像

首先查看一个dockerfile

```dockerfile
FROM    centos:6.7
MAINTAINER      Fisher "fisher@sudops.com"

RUN     /bin/echo 'root:123456' |chpasswd
RUN     useradd runoob
RUN     /bin/echo 'runoob:123456' |chpasswd
RUN     /bin/echo -e "LANG=\"en_US.UTF-8\"" >/etc/default/local
EXPOSE  22
EXPOSE  80
CMD     /usr/sbin/sshd -D
```

每一个指令都会在镜像上创建一个新的层，每一个指令的前缀都必须是大写的。

第一条FROM，指定使用哪个镜像源

RUN 指令告诉docker 在镜像内执行命令，安装了什么。。。

然后，我们使用 Dockerfile 文件，通过 docker build 命令来构建一个镜像。

使用`docker build -t runoob/centos:6.7 .`创建镜像

参数说明：

- **-t** ：指定要创建的目标镜像名
- **.** ：Dockerfile 文件所在目录，可以指定Dockerfile 的绝对路径

##### 3.设置镜像标签

```shell
# 给ID为860c279d2fec的镜像添加一个标签
docker tag 860c279d2fec runoob/centos:dev
```

## 容器管理

### 运行一个容器

```shell
docker pull training/webapp  # 载入镜像
docker run -d -P training/webapp python app.py
# 使用 -p 映射到指定端口
docker run -d -p 5000:5000 training/webapp python app.py
```

参数说明:

- **-d:**让容器在后台运行。
- **-P:**将容器内部使用的网络端口映射到我们使用的主机上。

#### 容器命名：

使用--name标识来命名容器

```shell
docker run -d -P --name runoob training/webapp python app.py
```

### 查看正在运行的容器

```shell
docker ps
```

### 查看端口的快捷方式

```shell
# docker port id/name
docker port bf08b7f2cd89
docker port wizardly_chandrasekhar
```

### 查看日志

```shell
# docker port id/name
docker logs -f bf08b7f2cd89
```

**-f:** 让 **docker logs** 像使用 **tail -f** 一样来输出容器内部的标准输出

### 检查容器

```shell
docker inspect wizardly_chandrasekhar
```

### 停止

```she
docker stop wizardly_chandrasekhar
```

### 重启

```shell
docker start wizardly_chandrasekhar
```

### 移除

> 删除时，容器必须为停止状态

```shell
docker rm wizardly_chandrasekhar
```

## 命令大全

### 容器

#### run

#### run

------

**docker run ：**创建一个新的容器并运行一个命令

**语法**

```
docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
```

OPTIONS说明：

- **-a stdin:** 指定标准输入输出内容类型，可选 STDIN/STDOUT/STDERR 三项；
- **-d:** 后台运行容器，并返回容器ID；
- **-i:** 以交互模式运行容器，通常与 -t 同时使用；
- **-P:** 随机端口映射，容器内部端口**随机**映射到主机的高端口
- **-p:** 指定端口映射，格式为：主机(宿主)端口:容器端口 
- **-t:** 为容器重新分配一个伪输入终端，通常与 -i 同时使用；
- **--name="nginx-lb":** 为容器指定一个名称；
- **--dns 8.8.8.8:** 指定容器使用的DNS服务器，默认和宿主一致；
- **--dns-search example.com:** 指定容器DNS搜索域名，默认和宿主一致；
- **-h "mars":** 指定容器的hostname；
- **-e username="ritchie":** 设置环境变量；
- **--env-file=[]:** 从指定文件读入环境变量；
- **--cpuset="0-2" or --cpuset="0,1,2":** 绑定容器到指定CPU运行；
- **-m :**设置容器使用内存最大值；
- **--net="bridge":** 指定容器的网络连接类型，支持 bridge/host/none/container: 四种类型；
- **--link=[]:** 添加链接到另一个容器；
- **--expose=[]:** 开放一个端口或一组端口； 
- **--volume , -v:**	 绑定一个卷

#### exec

------

**docker exec ：**在运行的容器中执行命令

**语法**

```
docker exec [OPTIONS] CONTAINER COMMAND [ARG...]
```

OPTIONS说明：

- **-d :**分离模式: 在后台运行
- **-i :**即使没有附加也保持STDIN 打开
- **-t :**分配一个伪终端

#### kill 

------

**docker kill** :杀掉一个运行中的容器。

语法

```
docker kill [OPTIONS] CONTAINER [CONTAINER...]
```

OPTIONS说明：

- **-s :****向容器发送一个信号**

#### rm 

------

**docker rm ：**删除一个或多少容器

语法

```
docker rm [OPTIONS] CONTAINER [CONTAINER...]
```

OPTIONS说明：

- **-f :**通过SIGKILL信号强制删除一个运行中的容器
- **-l :**移除容器间的网络连接，而非容器本身
- **-v :**-v  删除与容器关联的卷

#### ps

------

**docker ps :** 列出容器

语法

```
docker ps [OPTIONS]
```

OPTIONS说明：

- **-a :**显示所有的容器，包括未运行的。

- **-f :**根据条件过滤显示的内容。

  

- **--format :**指定返回值的模板文件。

- **-l :**显示最近创建的容器。

- **-n :**列出最近创建的n个容器。

- **--no-trunc :**不截断输出。

- **-q :**静默模式，只显示容器编号。

- **-s :**显示总的文件大小

#### inspect

------

**docker inspect :** 获取容器/镜像的元数据。

语法

```
docker inspect [OPTIONS] NAME|ID [NAME|ID...]
```

OPTIONS说明：

- **-f :**指定返回值的模板文件。
- **-s :**显示总的文件大小。
- **--type :**为指定类型返回JSON。

#### events

------

**docker events :** 从服务器获取实时事件

语法

```
docker events [OPTIONS]
```

OPTIONS说明：

- **-f ：**根据条件过滤事件；
- **--since ：**从指定的时间戳后显示所有事件;
- **--until ：**流水时间显示到指定的时间为止；

#### logs

------

**docker logs :** 获取容器的日志

语法

```
docker logs [OPTIONS] CONTAINER
```

OPTIONS说明：

- **-f :** 跟踪日志输出
- **--since :**显示某个开始时间的所有日志
- **-t :** 显示时间戳
- **--tail :**仅列出最新N条容器日志

#### 其他

```shell
docker create 		# 用法通docker run但是只创建，不启动
docker start/stop/restart
docker pause/unpause
docker port			# 列出指定的容器的端口映射
docker top
docker attach
docker diff 		# 检查容器里文件结构的更改。
docker commit 		# 从容器创建一个新的镜像。
docker cp 			# 用于容器与主机之间的数据拷贝。
docker wait			# 阻塞运行直到容器停止，然后打印出它的退出代码。
docker export 		# 将文件系统作为一个tar归档文件导出到STDOUT。
```

### 镜像

#### images

**docker images :** 列出本地镜像。

语法

```
docker images [OPTIONS] [REPOSITORY[:TAG]]
```

OPTIONS说明：

- **-a :**列出本地所有的镜像（含中间映像层，默认情况下，过滤掉中间映像层）；
- **--digests :**显示镜像的摘要信息；
- **-f :**显示满足条件的镜像；
- **--format :**指定返回值的模板文件；
- **--no-trunc :**显示完整的镜像信息；
- **-q :**只显示镜像ID

#### rmi

**docker rmi :** 删除本地一个或多少镜像。

语法

```
docker rmi [OPTIONS] IMAGE [IMAGE...]
```

OPTIONS说明：

- **-f :**强制删除；
- **--no-prune :**不移除该镜像的过程镜像，默认移除；

#### tag

**docker tag :** 标记本地镜像，将其归入某一仓库。

```shell
# example
docker tag ubuntu:15.10 runoob/ubuntu:v3
```

#### build

**docker build**  命令用于使用 Dockerfile 创建镜像。

语法

```
docker build [OPTIONS] PATH | URL | -
```

OPTIONS说明：

- **--build-arg=[] :**设置镜像创建时的变量；
- **--cpu-shares :**设置 cpu 使用权重；
- **--cpu-period :**限制 CPU CFS周期；
- **--cpu-quota :**限制 CPU CFS配额；
- **--cpuset-cpus :**指定使用的CPU id；
- **--cpuset-mems :**指定使用的内存 id；
- **--disable-content-trust :**忽略校验，默认开启；
- **-f :**指定要使用的Dockerfile路径；
- **--force-rm :**设置镜像过程中删除中间容器；
- **--isolation :**使用容器隔离技术；
- **--label=[] :**设置镜像使用的元数据；
- **-m :**设置内存最大值；
- **--memory-swap :**设置Swap的最大值为内存+swap，"-1"表示不限swap；
- **--no-cache :**创建镜像的过程不使用缓存；
- **--pull :**尝试去更新镜像的新版本；
- **--quiet, -q :**安静模式，成功后只输出镜像 ID；
- **--rm :**设置镜像成功后删除中间容器；
- **--shm-size :**设置/dev/shm的大小，默认值是64M；
- **--ulimit :**Ulimit配置。
- **--tag, -t:** 镜像的名字及标签，通常 name:tag 或者 name 格式；可以在一次构建中为一个镜像设置多个标签。
- **--network:** 默认 default。在构建期间设置RUN指令的网络模式

#### history

**docker history :** 查看指定镜像的创建历史。

语法

```
docker history [OPTIONS] IMAGE
```

OPTIONS说明：

- **-H :**以可读的格式打印镜像大小和日期，默认为true；
- **--no-trunc :**显示完整的提交记录；
- **-q :**仅列出提交记录ID。

#### save

**docker save :** 将指定镜像保存成 tar 归档文件。

语法

```
docker save [OPTIONS] IMAGE [IMAGE...]
```

OPTIONS 说明：

- **-o :**输出到的文件。

#### load

**docker load :** 导入使用 [docker save](https://www.runoob.com/docker/docker-save-command.html) 命令导出的镜像。

语法

```
docker load [OPTIONS]
```

OPTIONS 说明：

- **-i :**指定导出的文件。
- **-q :**精简输出信息。

#### import

**docker import :** 从归档文件中创建镜像。

语法

```
docker import [OPTIONS] file|URL|- [REPOSITORY[:TAG]]
```

OPTIONS说明：

- **-c :**应用docker 指令创建镜像；
- **-m :**提交时的说明文字；

#### login/logout

**docker login :** 登陆到一个Docker镜像仓库，如果未指定镜像仓库地址，默认为官方仓库 Docker Hub

**docker logout :** 登出一个Docker镜像仓库，如果未指定镜像仓库地址，默认为官方仓库 Docker Hub

语法

```
docker login [OPTIONS] [SERVER]
docker logout [OPTIONS] [SERVER]
```

OPTIONS说明：

- **-u :**登陆的用户名
- **-p :**登陆的密码

#### pull

**docker pull :** 从镜像仓库中拉取或者更新指定镜像

语法

```
docker pull [OPTIONS] NAME[:TAG|@DIGEST]
```

OPTIONS说明：

- **-a :**拉取所有 tagged 镜像
- **--disable-content-trust :**忽略镜像的校验,默认开启

#### push

**docker push :** 将本地的镜像上传到镜像仓库,要先登陆到镜像仓库

语法

```
docker push [OPTIONS] NAME[:TAG]
```

OPTIONS说明：

- **--disable-content-trust :**忽略镜像的校验,默认开启

#### search

**docker search :** 从Docker Hub查找镜像

语法

```
docker search [OPTIONS] TERM
```

OPTIONS说明：

- **--automated :**只列出 automated build类型的镜像；
- **--no-trunc :**显示完整的镜像描述；
- **-s :**列出收藏数不小于指定值的镜像。

### 其他

#### docker info

显示 Docker 系统信息，包括镜像和容器数。。

#### docker ps

显示 Docker 版本信息。
