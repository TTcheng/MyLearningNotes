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

![image-20210306233359029](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210306233359029.png)