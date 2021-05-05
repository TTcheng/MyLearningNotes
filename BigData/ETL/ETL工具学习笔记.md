# 关于ETL

**ETL**，是英文Extract-Transform-Load的缩写，用来描述将[数据](https://baike.baidu.com/item/数据/5947370)从来源端经过抽取（extract）、[转换](https://baike.baidu.com/item/转换/197560)（transform）、加载（load）至目的端的过程。**ETL**一词较常用在[数据仓库](https://baike.baidu.com/item/数据仓库)，但其对象并不限于数据仓库。

# ETL工具

## ETL工具分类

因为ETL包括抽取（extract）、转换（transform）、加载（load）三个环节，因此在任意环境起作用的工具都可以称为ETL工具。

因此ETL至少应包含以下几大类：

- 数据集成

  日志采集(Flume/Logstash)、爬虫等

- 数据同步

  sqoop、DataX

- 数据转换

  这个是ETL中最复杂的部分。往往通过写SQL、Python、Java来编码实现

- 整合ETL

  如kettle、Apatar、Talend、Informatica

## 常用ETL工具对比

![image-20210413202814312](ETL工具学习笔记.assets/image-20210413202814312.png)

# 数据同步策略

### 增量策略

适用增量策略的前提条件

- 时间戳

  针对每一条数据的新增、更新、删除(逻辑删除)等操作更新时间戳(如last_update_date)的的应用，适用此方法。通过主键或唯一索引覆盖更新。例如：

  ```mysql
  SELECT * 
  FROM test_table
  WHERE last_update_date > ${LAST_DAY}
  ```

- 自增ID

  对于新增流水型数据（数据一旦产生不发生改变），可以WHERE条件后跟上一阶段最大自增ID即可。

### 全量策略

以下情况适用于全量同步，否则应该考虑**增量同步**

- 数据量（小）
- 同步时间（短）
- 源数据库（无压力）
- 数据量大但不适用增量（无法确定增量数据、没有时间戳，没有自增ID的无序数据）
- 数据量大但离线处理快

### 实时策略