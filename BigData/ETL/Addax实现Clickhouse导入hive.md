# Addax实现Clickhouse导入hive

Addax是在DataX上修改开发的开源软件，相比DataX有更多免费可用的插件。例如ClickhouseReader插件DataX官方并不提供。

相比waterdrop不依赖spark环境，并且提供作业全链路的流量、数据量运行时监控，精准的速度控制和容错控制。

## 官方参考文档

https://wgzhao.github.io/Addax/develop/

## Addax安装路径

kettle服务器上都有安装：路径 /data/addax/

## 使用步骤

### 增量

以资金结算单据表(bsn.bsn_am_zjjsdj_distinct_all)为例

- 1、编辑并上传任务配置文件

```json
{
  "job": {
    "setting": {
      "speed": {
        "channel": 2,
        "bytes": 2000000,
        "record": 100000
      },
      "errorLimit": {
        "record": 0,
        "percentage": 0.02
      }
    },
    "content": {
      "reader": {
        "name": "clickhousereader",
        "parameter": {
          "username": "${P_CLICKHOUSE_USER}",
          "password": "${P_CLICKHOUSE_PASSWORD}",
          "column": ["zjjsdj_djnm","zjjsdj_glqtnm","zjjsdj_jsfs","zjjsdj_ywlx","zjjsdj_djzt","createdtime","zjjsdj_je","zjjsdj_yhzhkhhlhh","zjjsdj_dwbh","zjjsdj_yhrq","zjjsdj_djlx","zjjsdj_yhsh","creation_date"],
          "where": "part_period='${P_PARTITION_NAME}'",
          "connection": [
            {
              "table": [
                "bsn_am_zjjsdj_distinct_all"
              ],
              "jdbcUrl": [
                "${P_CLICKHOUSE_URL}"
              ]
            }
          ]
        }
      },
      "writer": {
        "name": "hdfswriter",
        "parameter": {
          "defaultFS": "${P_HDFS_DEFAULT_FS}",
          "fileType": "orc",
          "path": "${P_HDFS_HIVE_PATH}/warehouse/ods.db/ods_fms_zjjsdj",
          "fileName": "${P_PARTITION_NAME}",
          "column": [
            {"name":"zjjsdj_djnm","type":"string"},
            {"name":"zjjsdj_glqtnm","type":"string"},
            {"name":"zjjsdj_jsfs","type":"string"},
            {"name":"zjjsdj_ywlx","type":"string"},
            {"name":"zjjsdj_djzt","type":"string"},
            {"name":"createdtime","type":"string"},
            {"name":"zjjsdj_je","type":"decimal"},
            {"name":"zjjsdj_yhzhkhhlhh","type":"string"},
            {"name":"zjjsdj_dwbh","type":"string"},
            {"name":"zjjsdj_yhrq","type":"string"},
            {"name":"zjjsdj_djlx","type":"string"},
            {"name":"zjjsdj_yhsh","type":"string"},
            {"name":"creation_date","type":"date"}
          ],
          "writeMode": "overwrite",
          "fieldDelimiter": "\u0001",
          "compress": "NONE",
          "haveKerberos": "${P_KERBEROS_ENABLED}",
          "kerberosPrincipal": "${P_KERBEROS_PRINCIPAL}",
          "kerberosKeytabFilePath": "${P_KERBEROS_KEYTAB}",
          "hadoopConfig": {
            "dfs.nameservices": "${P_HDFS_HA_NAME}",
            "dfs.ha.namenodes.${P_HDFS_HA_NAME}": "nn1,nn2",
            "dfs.namenode.rpc-address.${P_HDFS_HA_NAME}.nn1": "${P_HDFS_HA_NN1}",
            "dfs.namenode.rpc-address.${P_HDFS_HA_NAME}.nn2": "${P_HDFS_HA_NN2}",
            "dfs.client.failover.proxy.provider.${P_HDFS_HA_NAME}": "org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider"
          }
        }
      }
    }
  }
}
```

- 2、通过命令启动任务

```shell
## kettle
hive -e "alter table ods.ods_fms_zjjsdj add if not exists partition(part_period='${P_PERIOD_NAME}');"
/data/addax/bin/addax.sh \
    -p"-DP_PARTITION_NAME=${P_PERIOD_NAME} -DP_CLICKHOUSE_PASSWORD=${P_CLICKHOUSE_PASSWORD} -DP_CLICKHOUSE_USER=${P_CLICKHOUSE_USER} -DP_CLICKHOUSE_URL=${P_CLICKHOUSE_URL} -DP_CLICKHOUSE_USER=${P_CLICKHOUSE_USER} -DP_HDFS_HIVE_PATH=${P_HDFS_HIVE_PATH} -DP_KERBEROS_ENABLED=${P_KERBEROS_ENABLED} -DP_KERBEROS_PRINCIPAL=${P_KERBEROS_PRINCIPAL} -DP_KERBEROS_KEYTAB=${P_KERBEROS_KEYTAB} -DP_HDFS_DEFAULT_FS=${P_HDFS_DEFAULT_FS} -DP_HDFS_HA_NAME=${P_HDFS_HA_NAME} -DP_HDFS_HA_NN1=${P_HDFS_HA_NN1} -DP_HDFS_HA_NN2=${P_HDFS_HA_NN2}" \
    /data/addax/job/ck2hive/bsn_am_zjjsdj_test.json

## 替换变量之后，示例
hive -e "alter table ods.ods_fms_zjjsdj add if not exists partition(part_period='202109');"
/data/addax/bin/addax.sh \
    -p "-DP_PARTITION_NAME='202109' -DP_CLICKHOUSE_PASSWORD=testpwd -DP_CLICKHOUSE_USER=ck_dev -DP_CLICKHOUSE_URL='jdbc:clickhouse://test.ttcheng.wang:8123/test?socket_timeout=300000' -DP_HDFS_HIVE_PATH='/apps/hive' -DP_KERBEROS_ENABLED=true -DP_KERBEROS_PRINCIPAL='test@HADOOP.COM' -DP_KERBEROS_KEYTAB='/home/test/user.keytab' -DP_HDFS_DEFAULT_FS='hdfs://tstdevhd01:8020' -DP_HDFS_HA_NAME=UATCLUSTER -DP_HDFS_HA_NN1='tstdevhd01:8020' -DP_HDFS_HA_NN2='tstdevhd02:8020'" \
    /data/addax/job/ck2hive/bsn_am_zjjsdj_test.json
```

### 全量

以资金账户表(bsn.bsn_am_zjzh_view,视图是去重)为例

- 编辑并上传任务配置文件

```json
{
  "job": {
    "setting": {
      "speed": {
        "channel": 2,
        "bytes": 2000000,
        "record": 100000
      },
      "errorLimit": {
        "record": 0,
        "percentage": 0.02
      }
    },
    "content": {
      "reader": {
        "name": "clickhousereader",
        "parameter": {
          "username": "${P_CLICKHOUSE_USER}",
          "password": "${P_CLICKHOUSE_PASSWORD}",
          "column": [
            "zjzh_zhnm",
            "zjzh_lbbh",
            "zjzh_hzyhbh",
            "zjzh_dwbh",
            "zjzh_zhxt",
            "zjzh_zhbh",
            "sync_date"
          ],
          "where": "1=1",
          "connection": [
            {
              "table": [
                "bsn_am_zjzh_view"
              ],
              "jdbcUrl": [
                "${P_CLICKHOUSE_URL}"
              ]
            }
          ]
        }
      },
      "writer": {
        "name": "hdfswriter",
        "parameter": {
          "defaultFS": "${P_HDFS_DEFAULT_FS}",
          "fileType": "orc",
          "path": "${P_HDFS_HIVE_PATH}/warehouse/ods.db/ods_fms_zjzh",
          "fileName": "ods_fms_zjzh",
          "column": [
            {
              "name": "zjzh_zhnm",
              "type": "string"
            },
            {
              "name": "zjzh_lbbh",
              "type": "string"
            },
            {
              "name": "zjzh_hzyhbh",
              "type": "string"
            },
            {
              "name": "zjzh_dwbh",
              "type": "string"
            },
            {
              "name": "zjzh_zhxt",
              "type": "string"
            },
            {
              "name": "zjzh_zhbh",
              "type": "string"
            },
            {
              "name": "creation_date",
              "type": "string"
            }
          ],
          "writeMode": "overwrite",
          "fieldDelimiter": "\u0001",
          "compress": "NONE",
          "haveKerberos": "${P_KERBEROS_ENABLED}",
          "kerberosPrincipal": "${P_KERBEROS_PRINCIPAL}",
          "kerberosKeytabFilePath": "${P_KERBEROS_KEYTAB}",
          "hadoopConfig": {
            "dfs.nameservices": "${P_HDFS_HA_NAME}",
            "dfs.ha.namenodes.${P_HDFS_HA_NAME}": "nn1,nn2",
            "dfs.namenode.rpc-address.${P_HDFS_HA_NAME}.nn1": "${P_HDFS_HA_NN1}",
            "dfs.namenode.rpc-address.${P_HDFS_HA_NAME}.nn2": "${P_HDFS_HA_NN2}",
            "dfs.client.failover.proxy.provider.${P_HDFS_HA_NAME}": "org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider"
          }
        }
      }
    }
  }
}
```

- 通过命令启动任务

```shell
## kettle
/data/addax/bin/addax.sh \
    -p"-DP_CLICKHOUSE_PASSWORD=${P_CLICKHOUSE_PASSWORD} -DP_CLICKHOUSE_USER=${P_CLICKHOUSE_USER} -DP_CLICKHOUSE_URL=${P_CLICKHOUSE_URL} -DP_CLICKHOUSE_USER=${P_CLICKHOUSE_USER} -DP_HDFS_HIVE_PATH=${P_HDFS_HIVE_PATH} -DP_KERBEROS_ENABLED=${P_KERBEROS_ENABLED} -DP_KERBEROS_PRINCIPAL=${P_KERBEROS_PRINCIPAL} -DP_KERBEROS_KEYTAB=${P_KERBEROS_KEYTAB} -DP_HDFS_DEFAULT_FS=${P_HDFS_DEFAULT_FS} -DP_HDFS_HA_NAME=${P_HDFS_HA_NAME} -DP_HDFS_HA_NN1=${P_HDFS_HA_NN1} -DP_HDFS_HA_NN2=${P_HDFS_HA_NN2}" \
    /data/addax/job/ck2hive/bsn_am_zjzh_test.json
# 加载数据，只是第一次时需要执行这个命令，后续覆盖不需要执行
hive -e "load data inpath '${P_HDFS_HIVE_PATH}/warehouse/ods.db/ods_fms_zjzh' into table ods.ods_fms_zjzh;"

## 替换变量之后，示例
/data/addax/bin/addax.sh \
    -p "-DP_CLICKHOUSE_PASSWORD=testpwd -DP_CLICKHOUSE_USER=ck_dev -DP_CLICKHOUSE_URL='jdbc:clickhouse://test.ttcheng.wang:8123/test?socket_timeout=300000' -DP_HDFS_HIVE_PATH='/apps/hive' -DP_KERBEROS_ENABLED=true -DP_KERBEROS_PRINCIPAL='test@HADOOP.COM' -DP_KERBEROS_KEYTAB='/home/test/user.keytab' -DP_HDFS_DEFAULT_FS='hdfs://tstdevhd01:8020' -DP_HDFS_HA_NAME=TSTCLUSTER -DP_HDFS_HA_NN1='tstdevhd01:8020' -DP_HDFS_HA_NN2='tstdevhd02:8020'" \
    /data/addax/job/ck2hive/bsn_am_zjzh_test.json
# 加载数据，只是第一次时需要执行这个命令，后续重复覆盖不需要执行
hive -e "load data inpath '/apps/hive/warehouse/ods.db/ods_fms_zjzh' into table ods.ods_fms_zjzh;"
```

