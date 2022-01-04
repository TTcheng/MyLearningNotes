# 消息中间件之RocketMQ

## 消息中间件

### 定义

消息中间件是基于**队列与消息**传递技术，在网络环境中为应用系统提供同步或异步、**可靠的消息传输**的支撑性软件系统 。它具有**低耦合、可靠投递、广播、流量控制、最终一致性**等一系列功能，成为异步RPC的主要手段之一。

### MQ特点

- 先进先出
- 发布订阅
- 持久化
- 分布式

### 模式

- 点对点（P2P）
- 发布订阅（Pub/Sub）

区别：是否支持重复消费

### 组成

* **Broker**

    消息服务器，作为server提供消息核心服务

- **Producer**

    消息生产者，业务的发起方，负责生产消息传输给broker，

- **Consumer**

    消息消费者，业务的处理方，负责从broker获取消息并进行业务逻辑处理

- **Topic**

    主题，发布订阅模式下的消息统一汇集地，不同生产者向topic发送消息，由MQ服务器分发到不同的订阅者，实现消息的    广播

- **Queue**

    队列，PTP模式下，特定生产者向特定queue发送消息，消费者订阅特定的queue完成指定消息的接收

-  **Message**

    消息体，根据不同通信协议定义的固定格式进行编码的数据包，来封装业务数据，实现消息的传输

### 协议



### 优势

- **系统解耦**

    交互系统之间没有直接的调用关系，只是通过消息传输，故系统侵入性不强，耦合度低。

- **异步通信、提高系统响应时间**

- **流量削峰**

## 各种消息中间件对比

主要从语言、性能、潮流、生态上分别来看各自的优缺点。

以下信息来源于网络，参考文章较多，但不保证完成正确，因为很多产品都在更新迭代。

### ActiveMQ

ActiveMQ 是Apache出品，最流行的，能力强劲的开源消息总线。

- 优点
    - 支持所有主流消息协议
    - 支持编程语言最丰富
    - 快速集成，易集成到Spring，支持JMS、CXF、Axis等
- 缺点
    - 吞吐量一般、太重了，包袱大
    - 诞生时间太长了，社区不活跃，国内不流行

### RabbitMQ

RabbitMQ是Pivot公司使用Erlang语言开发的开源消息队列系统，针对对数据一致性、稳定性和可靠性要求很高的场景，对性能和吞吐量的要求还在其次。

- 优点
    - 延迟最低，可达到微妙级
    - 支持事务的可靠传递
    - 易扩展，提供了许多插件，也可以编写自己的插件。
- 缺点
    - 基于Erlang开发，没有Erlang大神的时候出现问题不好排查，不好针对性优化
    - 由Pivot开源，并不是由开源组织维护，社区需求响应较差

### Kafka

Kafka是LinkedIn开源的Scala编写的分布式发布-订阅消息系统，目前归属于Apache顶级项目。

- 优点
    - 吞吐量最高
    - 为大数据集群设计，特别适用于大数据领域的实时计算和日志采集
- 缺点
    - 需要zookeeper
    - 太简单了
    - 无法保证有序

### RocketMQ

RocketMQ是阿里开源的消息中间件，它是纯Java编写，按Kafka的思想来实现，并在Kafka基础上优化，目前归属于Apache顶级项目。

- 优点
    - 吞吐量高同时可靠性最强
    - 支持大量队列
    - Java编写
- 缺点
    - 文档少，而且坑很多

### 总结

总体来看，ActiveMQ和RabbitMQ诞生较早，前者做的大而全，后者非常强调数据一致性、高可靠和低时延，在高堆积场景表现不如人意，随着互联网和大数据的爆发，高吞吐量变得越来越重要，因此Kafka/RocketMQ在各大公司越来越广泛的使用，因为轻量级的原因也更容易集成和二次开发。

通常情况下，分布式系统普通业务四者在使用上差别不大，但是各中间件都有各自擅长的场景

按场景选择：

- Kafka

    大数据ETL、日志采集ELK，简单业务性能强

- RocketMQ

    稳定性最好，功能丰富，性能接近Kafka，但能胜任更复杂的业务场景

- RabbitMQ

    数据一致性、稳定性、低延迟性和可靠性要求很高的场景

- ActiveMQ

    兼容性最好，适合做多个系统的集成，同构，可用于物联网

使用场景对各方面没有特殊要求的情况下，优先选择RocketMQ/Kafka这种新出来的产品，比较选新不选旧。

### 参考-RocketMQ官网的对比表

这个表格最后更新于2016年底，也许是过时的

| Messaging Product | Client SDK           | Protocol and Specification                           | Ordered Message                                              | Scheduled Message | Batched Message                                 | BroadCast Message | Message Filter                                          | Server Triggered Redelivery | Message Storage                                              | Message Retroactive                          | Message Priority | High Availability and Failover                               | Message Track | Configuration                                                | Management and Operation Tools                               |
| ----------------- | -------------------- | ---------------------------------------------------- | ------------------------------------------------------------ | ----------------- | ----------------------------------------------- | ----------------- | ------------------------------------------------------- | --------------------------- | ------------------------------------------------------------ | -------------------------------------------- | ---------------- | ------------------------------------------------------------ | ------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| ActiveMQ          | Java, .NET, C++ etc. | Push model, support OpenWire, STOMP, AMQP, MQTT, JMS | Exclusive Consumer or Exclusive Queues can ensure ordering   | Supported         | Not Supported                                   | Supported         | Supported                                               | Not Supported               | Supports very fast persistence using JDBC along with a high performance journal，such as levelDB, kahaDB | Supported                                    | Supported        | Supported, depending on storage,if using levelDB it requires a ZooKeeper server | Not Supported | The default configuration is low level, user need to optimize the configuration parameters | Supported                                                    |
| Kafka             | Java, Scala etc.     | Pull model, support TCP                              | Ensure ordering of messages within a partition               | Not Supported     | Supported, with async producer                  | Not Supported     | Supported, you can use Kafka Streams to filter messages | Not Supported               | High performance file storage                                | Supported offset indicate                    | Not Supported    | Supported, requires a ZooKeeper server                       | Not Supported | Kafka uses key-value pairs format for configuration. These values can be supplied either from a file or programmatically. | Supported, use terminal command to expose core metrics       |
| RocketMQ          | Java, C++, Go        | Pull model, support TCP, JMS, OpenMessaging          | Ensure strict ordering of messages,and can scale out gracefully | Supported         | Supported, with sync mode to avoid message loss | Supported         | Supported, property filter expressions based on SQL92   | Supported                   | High performance and low latency file storage                | Supported timestamp and offset two indicates | Not Supported    | Supported, Master-Slave model, without another kit           | Supported     | Work out of box,user only need to pay attention to a few configurations | Supported, rich web and terminal command to expose core metrics |

## RocketMQ的安装及配置

**！！！！避坑指南！！！！**：测试之前先放开防火墙的10909、10911、9876这三个端口的访问

**！！！！避坑指南！！！！**：启动之前先修改启动脚本中的jvm参数，小机器一般内存不够会直接报错

### QuickStart

```shell
# ！！安装OracleJDK，避免遇到乱七八糟问题
sudo yum -y remove java
# 地址到Oracle官网获取，需要认证
wget https://download.oracle.com/url/to/java -O jdk-8u311-linux-x64.rpm
sudo rpm -ivh jdk-8uversion-linux-x64.rpm

# 下载地址从官网获取
wget https://dlcdn.apache.org/rocketmq/4.9.2/rocketmq-all-4.9.2-bin-release.zip
unzip rocketmq-all-4.9.2-bin-release.zip
cd rocketmq-4.9.2

# 修改JVM参数,根据自己资源及业务配置合适的值
vim bin/runserver.sh # nameserver
vim bin/runbroker.sh # broker

# 启动NameSever
nohup sh bin/mqnamesrv -n "172.16.0.14:9876;119.3.52.162:9876:9876;127.0.0.1:9876" > ns.log 2>&1 &
tail -f ~/logs/rocketmqlogs/namesrv.log
# 编辑配置文件conf/broker.conf 添加namesrvAddr=119.3.52.162:9876 brokerIP1=119.3.52.162，注意使用公网ip
# 启动broker，一定要添加自动创建broker
nohup sh bin/mqbroker  -n "172.16.0.14:9876" -c conf/broker.conf autoCreateTopicEnable=true > bs.log 2>&1
tail -f ~/logs/rocketmqlogs/broker.log 
# OR 同时启动两个
# cd bin;sh play.sh

# 发送/接收示例消息（示例程序）
export NAMESRV_ADDR=localhost:9876 # 先设定名称服务器
sh bin/tools.sh org.apache.rocketmq.example.quickstart.Producer
sh bin/tools.sh org.apache.rocketmq.example.quickstart.Consumer
```

### 关闭服务组件

```shell
sh bin/mqshutdown broker
sh bin/mqshutdown namesrv
```

## 官方示例

### 避坑指南：

**！！！！避坑指南！！！！**：测试之前先放开防火墙的10909、10911、9876这三个端口的访问

**！！！！避坑指南！！！！**：客户端Consumer无法启动时，降低依赖版本到4.5.2既可

**！！！！避坑指南！！！！**：开通自动创建topic  `nohup sh bin/mqbroker -n "172.16.0.14:9876" autoCreateTopicEnable=true > broker-startup.log 2>&1 &`

**！！！！避坑指南！！！！**：producer的超时时间设置长一点，不然不会提示具体的错误信息

```java
producer.setSendMsgTimeout(15000);
// 避免发送完之前关闭producer
countDownLatch.await(15, TimeUnit.SECONDS);
```

**！！！！避坑指南！！！！**：

排查相关命令

```shell
# 检查broker状态是不是正常
bin/mqadmin clusterList -n localhost:9876
# 检查topicRoute是否正常，注意权限是否为6（RW：可读可写）至少为4（W：可写）
bin/mqadmin topicRoute -l -n localhost:9876 -t Jodie_topic_1023
# 检查消费者状态
bin/mqadmin consumerStatus -n localhost:9876 -g Jodie_Daily_test

```

