

### 环境准备

两台机器分别做主机和备机，两台机器都是nginx的负载，且配置相同，要实现当主机故障后备机自动接替主机，提供负载均衡的功能。

| IP                       | 用途                   |
| ------------------------ | ---------------------- |
| 10.253.60.64（物理机IP） | 负载主机               |
| 10.253.60.45（物理机IP） | 负载备机               |
| 10.253.60.109（虚拟IP）  | 服务入口，高可用承载IP |



### 下载

keepalived官网下载最新源码包

https://www.keepalived.org/download.html

keepalived-2.2.4.tar.gz

### 安装

```shell
su cmccapp
tar xzvf keepalived-2.2.4.tar.gz
cd keepalived-2.2.4
./configure --prefix=/cmcc/data1/keepalived
make && make install
cp keepalived/keepalived.service /cmcc/data1/keepalived
cd /cmcc/data1/keepalived
sudo ln -s /cmcc/data1/keepalived/keepalived.service /usr/lib/systemd/system/
sudo ln -s /cmcc/data1/keepalived/etc/sysconfig/keepalived /etc/sysconfig/
sudo mkdir /etc/keepalived
sudo ln -s /cmcc/data1/keepalived/etc/keepalived/keepalived.conf /etc/keepalived/
```

### 配置

#### 配置文件

vim /cmcc/data1/keepalived/etc/keepalived/keepalived.conf

**主机**

```conf
global_defs {
    router_id CMCC_UAT
    script_user cmccapp
}
#检测脚本
vrrp_script chk_http_port {
    script "/cmcc/data1/keepalived/check_nginx_pid.sh" #心跳执行的脚本，检测nginx是否启动
    interval 2              #（检测脚本执行的间隔，单位是秒）
    weight 2                #权重
}
#vrrp 实例定义部分
vrrp_instance VI_1 {
    state MASTER            # 指定keepalived的角色，MASTER为主，BACKUP为备
    interface bond1         # 当前进行vrrp通讯的网络接口卡(当前centos的网卡) 用ifconfig查看你具体的网卡
    virtual_router_id 66    # 虚拟路由编号，主从要一直
    priority 100            # 优先级，数值越大，获取处理请求的优先级越高
    advert_int 1            # 检查间隔，默认为1s(vrrp组播周期秒数)
    #授权访问
    authentication {
        auth_type PASS      #设置验证类型和密码，MASTER和BACKUP必须使用相同的密码才能正常通信
        auth_pass cmcc
    }
    track_script {
        chk_http_port       #（调用检测脚本）
    }
    virtual_ipaddress {
        10.253.60.109 dev bond1            # 定义虚拟ip(VIP)，可多设，每行一个
    }
}
```

**备机** (除state、priority不一样以外，其他配置均保持一致)

```shell
global_defs {
    router_id CMCC_UAT
    script_user cmccapp
}
#检测脚本
vrrp_script chk_http_port {
    script "/cmcc/data1/keepalived/check_nginx_pid.sh" #心跳执行的脚本，检测nginx是否启动
    interval 2              #（检测脚本执行的间隔，单位是秒）
    weight 2                #权重
}
#vrrp 实例定义部分
vrrp_instance VI_1 {
    state BACKUP            # 指定keepalived的角色，MASTER为主，BACKUP为备
    interface bond1         # 当前进行vrrp通讯的网络接口卡(当前centos的网卡) 用ifconfig查看你具体的网卡
    virtual_router_id 66    # 虚拟路由编号，主从要一直
    priority 90             # 优先级，数值越大，获取处理请求的优先级越高
    advert_int 1            # 检查间隔，默认为1s(vrrp组播周期秒数)
    #授权访问
    authentication {
        auth_type PASS      #设置验证类型和密码，MASTER和BACKUP必须使用相同的密码才能正常通信
        auth_pass cmcc
    }
    track_script {
        chk_http_port       #（调用检测脚本）
    }
    virtual_ipaddress {
        10.253.60.109 dev bond1            # 定义虚拟ip(VIP)，可多设，每行一个
    }
}
```

#### 检测脚本

vim /cmcc/data1/keepalived/check_nginx_pid.sh

```shell
#!/bin/bash
#检测nginx是否启动了
cnt=`ps aux|grep nginx-hdp |grep -v grep |wc -l`
if [ $cnt -eq 0 ];then    #如果nginx没有启动就启动nginx
	  # 可能有残留进程，先杀掉
	  pkill nginx-hdp
      /usr/local/nginx-hdp/sbin/nginx-hdp                #重启nginx
      if [ `ps aux|grep nginx-hdp|grep -v nginx |wc -l` -eq 0 ];then    #nginx重启失败，则停掉keepalived服务，进行VIP转移
              pkill keepalived
      fi
fi
```

### 启动

```shell
sudo systemctl start keepalived 
sudo systemctl enable keepalived 
```

### 验证

```shell
ip add
```

输出以下地址信息：可以看到bond1绑定了两个IP地址，一个物理ip，一个虚拟IP。当停止主机的keepalived服务之后，虚拟IP会切换到备机。

```log
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens4f0: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1450 qdisc mq master bond1 state UP qlen 1000
    link/ether 3c:fd:fe:bc:76:38 brd ff:ff:ff:ff:ff:ff
3: ens3f0: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq master bond0 state UP qlen 1000
    link/ether b4:96:91:29:26:94 brd ff:ff:ff:ff:ff:ff
4: ens4f1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1450 qdisc mq master bond1 state UP qlen 1000
    link/ether 3c:fd:fe:bc:76:38 brd ff:ff:ff:ff:ff:ff
5: ens3f1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq master bond0 state UP qlen 1000
    link/ether b4:96:91:29:26:94 brd ff:ff:ff:ff:ff:ff
6: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP qlen 1000
    link/ether b4:96:91:29:26:94 brd ff:ff:ff:ff:ff:ff
    inet 10.135.92.142/26 brd 10.135.92.191 scope global bond0
       valid_lft forever preferred_lft forever
    inet6 fe80::b696:91ff:fe29:2694/64 scope link 
       valid_lft forever preferred_lft forever
7: bond1: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP qlen 1000
    link/ether 3c:fd:fe:bc:76:38 brd ff:ff:ff:ff:ff:ff
    inet **10.253.60.64**/25 brd 10.253.60.127 scope global bond1
       valid_lft forever preferred_lft forever
    inet **10.253.60.109**/32 scope global bond1
       valid_lft forever preferred_lft forever
    inet6 fe80::3efd:feff:febc:7638/64 scope link 
       valid_lft forever preferred_lft forever
8: bond1.1101@bond1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP qlen 1000
    link/ether 3c:fd:fe:bc:76:38 brd ff:ff:ff:ff:ff:ff
    inet 10.135.32.142/26 brd 10.135.32.191 scope global bond1.1101
       valid_lft forever preferred_lft forever
    inet6 fe80::3efd:feff:febc:7638/64 scope link 
       valid_lft forever preferred_lft forever
```



