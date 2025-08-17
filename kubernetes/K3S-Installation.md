# Almalinux 9安装k3s集群

本文适用于在Almalinux 9版本的服务器中安装K3S集群。

k3s集群规模如下，三个主节点，一个工作节点，每个节点都是2c4g的规格（最低要求），更多工作节点的方法都一样。

| 角色               | 主机名         | IP地址          |
| ------------------ | -------------- | --------------- |
| server（即master） | Alma-cluster-1 | 192.168.100.111 |
| server（即master） | Alma-cluster-2 | 192.168.100.112 |
| server（即master） | Alma-cluster-3 | 192.168.100.113 |
| agent（即worker）  | Alma-cluster-4 | 192.168.100.114 |

## 初始化

```shell
sudo su - root
# 配置国内源
sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^# baseurl=https://repo.almalinux.org|baseurl=https://mirrors.aliyun.com|g' \
    -i.bak \
    /etc/yum.repos.d/almalinux*.repo

# 恢复 (sysin)
# sed -e 's|^#mirrorlist=|mirrorlist=|g' \
#    -e 's|^baseurl=https://mirrors.aliyun.com|# baseurl=https://repo.almalinux.org|g' \
#    -i.bak \
#    /etc/yum.repos.d/almalinux*.repo
# 升级并安装基础软件
yum update
yum install curl vim sysstat net-tools lsof nc wget lrzsz yum-utils
# 设置主机名（省略）
# 配置主机名映射，每台都要执行
cat >> /etc/hosts << EOF
192.168.100.111 Alma-cluster-1
192.168.100.112 Alma-cluster-2
192.168.100.113 Alma-cluster-3
192.168.100.114 Alma-cluster-4
EOF
```

## docker

v1.24版本开始，k8s默认不使用docker，大于该版本不建议在继续使用docker

```shell 
yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sed -i 's+https://download.docker.com+https://mirrors.tuna.tsinghua.edu.cn/docker-ce+' /etc/yum.repos.d/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## k3s cluster

### 第一个主节点

```shell
# 指定 K3s 版本
export INSTALL_K3S_VERSION=v1.22.17+k3s1
# 自定义启动执行命令
export INSTALL_K3S_EXEC="server --cluster-init --docker"
# 只安装不启动
export INSTALL_K3S_SKIP_START=true
# 为您添加到集群的每个节点设计一个独特的名称
# export K3S_NODE_NAME=k3s-master-01
# 设置了 K3S_URL，它将默认为“agent”。如果未设置K3S_URL，它将默认为“server”
export K3S_URL=
# 用于将 server 或 agent 加入集群的共享 secret
export K3S_TOKEN=Test12321
# 使用阿里云镜像源安装
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn sh -

# 启动 K3s 服务
systemctl enable --now k3s

# 查看 K3s 服务状态
systemctl status k3s
```

### 加入主节点（ Server）

同上，只是主机名和环境变量`INSTALL_K3S_EXEC`不一样，不设置`INSTALL_K3S_EXEC`也可以，安装脚本运行命令指定对应参数也可以

```shell
# 指定 K3s 版本
export INSTALL_K3S_VERSION=v1.22.17+k3s1
# 自定义启动执行命令
export INSTALL_K3S_EXEC="server --server https://Alma-cluster-1:6443 --docker"
# 只安装不启动
export INSTALL_K3S_SKIP_START=true
# 为您添加到集群的每个节点设计一个独特的名称
# export K3S_NODE_NAME=k3s-master-02
# 设置了 K3S_URL，它将默认为“agent”。如果未设置K3S_URL，它将默认为“server”
export K3S_URL=
# 用于将 server 或 agent 加入集群的共享 secret
export K3S_TOKEN=Test12321
# 使用阿里云镜像源安装
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn sh -
# 启动 K3s 服务
systemctl enable --now k3s

# 查看 K3s 服务状态
systemctl status k3s
```

### 加入工作节点（Agent）

```shell
# 指定 K3s 版本
export INSTALL_K3S_VERSION=v1.22.17+k3s1
# 自定义启动执行命令
export INSTALL_K3S_EXEC="agent --docker"
# 只安装不启动
export INSTALL_K3S_SKIP_START=true
# 为您添加到集群的每个节点设计一个独特的名称
# export K3S_NODE_NAME=k3s-worker-01
# 设置了 K3S_URL，它将默认为“agent”。如果未设置K3S_URL，它将默认为“server”
export K3S_URL=https://Alma-cluster-1:6443
# 用于将 server 或 agent 加入集群的共享 secret
export K3S_TOKEN=Test12321
# 使用阿里云镜像源安装
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn sh -

# 启动 K3s 服务
systemctl enable --now k3s-agent

# 查看 K3s 服务状态
systemctl status k3s-agent
```

### 验证

```shell
kubectl get nodes
```

输出如下

```log
NAME             STATUS   ROLES                       AGE     VERSION
alma-cluster-1   Ready    control-plane,etcd,master   9m34s   v1.22.17+k3s1
alma-cluster-2   Ready    control-plane,etcd,master   8m31s   v1.22.17+k3s1
alma-cluster-3   Ready    control-plane,etcd,master   8m4s    v1.22.17+k3s1
alma-cluster-4   Ready    <none>                      6m47s   v1.22.17+k3s1
```

## 注意事项

### cgroups不兼容

如果k3s启动失败，并且`journalctl -xeu k3s.service`查到错误信息如下

```log
misconfiguration: kubelet cgroup driver: \"cgroupfs\" is different from docker cgroup driver: \"systemd"
```

错误日志说的很清楚，两边cgroup驱动不一样，可以修改k3s的cgroup驱动，也可以修改docker的group驱动

k3s的修改方法如下，docker的更简单，自行百度即可。

```shell
sudo su -
mkdir -p /etc/rancher/k3s
touch /etc/rancher/k3s/config.yaml
cat >> /etc/rancher/k3s/config.yaml << EOF
kubelet-arg:
  - "cgroup-driver=systemd"
EOF
```

建议先卸载k3s，然后配置好了再重新安装

备注：k8s从v1.22版本开始使用的默认cgroup驱动为systemd，而在这之前默认为cgroupfs，但实际安装情况来看，此版本的k3s默认为cgroupfs

## 版本升级

TODO

## 存储

### 本地存储

TODO

### 分布式存储Longhorn

**注意：**版本要求Kubernetes >= v1.25，本文装的v1.22，需要升级到v1.25

TODO



