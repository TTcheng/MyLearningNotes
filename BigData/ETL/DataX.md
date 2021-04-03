# DataX

## 安装部署

### 系统要求

- Linux
- [JDK(1.8以上，推荐1.8) ](http://www.oracle.com/technetwork/cn/java/javase/downloads/index.html)
- [Python(推荐Python2.6.X) ](https://www.python.org/downloads/)
- [Apache Maven 3.x](https://maven.apache.org/download.cgi) (Compile only)

### 部署

```shell
# 下载
wget http://datax-opensource.oss-cn-hangzhou.aliyuncs.com/datax.tar.gz
# 解压
tar xzvf datax.tar.gz
# 验证
cd datax
python bin/datax.py job/job.json
```

### 实践

```shell
# 查看配置模板
cd ${DATAX_HOME}
# python bin/datax.py -r streamreader -w streamwriter
# 1.stream reader/writer
python bin/datax.py -r streamreader -w streamwriter # > template.json
# 2.mysql reader/writer
python bin/datax.py -r mysqlreader -w mysqlwriter # > template.json
```

#### Hello World

```shell
{
  "job": {
    "content": [
      {
        "reader": {
          "name": "streamreader",
          "parameter": {
            "sliceRecordCount": 10,
            "column": [
              {
                "type": "long",
                "value": "10"
              },
              {
                "type": "string",
                "value": "hello，你好，世界-DataX"
              }
            ]
          }
        },
        "writer": {
          "name": "streamwriter",
          "parameter": {
            "encoding": "UTF-8",
            "print": true
          }
        }
      }
    ],
    "setting": {
      "speed": {
        "channel": 5
       }
    }
  }
}
```

#### MySQL

##### 原理

MysqlWriter/MysqlReader插件通过JDBC连接访问数据库，Reader执行SELECT语句；Writer根据write_mode的配置分别执行insert(INSERT INTO)、replace(REPLACE INTO)、update(ON DUPLICATE KEY UPDATE)语句，另外Writer要求数据库引擎为InnoDB

##### 示例

以下两种增量同步的示例，尽可能多的使用了配置参数。

- 置一个从Mysql数据库同步抽取数据到本地的作业:

  ```json
  {
      "job": {
          "setting": {
              "speed": {
                   "channel": 3
              },
              "errorLimit": {
                  "record": 0,
                  "percentage": 0.02
              }
          },
          "content": [
              {
                  "reader": {
                      "name": "mysqlreader",
                      "parameter": {
                          "username": "root",
                          "password": "root",
                          "column": [
                              "id",
                              "batch",
                              "templateCode",
                              "data_status",
                              "sheet_index",
                              "error_msg",
                              "data",
                              "back_info",
                          ],
                          "where": [
                              "creation_date > $bizdate ",
                              // "creation_date > DATE_ADD(CURDATE(),  INTERVAL -1 DAY )"
                          ],
                          "splitPk": "id",
                          "connection": [
                              {
                                  "table": [
                                      "himp_data"
                                  ],
                                  "jdbcUrl": [
       "jdbc:mysql://127.0.0.1:3306/database"
                                  ]
                              }
                          ]
                      }
                  },
                 "writer": {
                      "name": "mysqlwriter",
                      "parameter": {
                          "writeMode": "insert",
                          "username": "root",
                          "password": "root",
                          "column": [
                              "id",
                              "batch",
                              "templateCode",
                              "data_status",
                              "sheet_index",
                              "error_msg",
                              "data",
                              "back_info",
                          ],
                          "session": [
                          	"set session sql_mode='ANSI'"
                          ],
                          "preSql": [
                              "truncate table himp_data_imp"
                          ],
                          "postSql": [
                              "INSERT INTO himp_data(id, batch, template_code, data_status, sheet_index, error_msg, data, back_info) SELECT * FROM himp_data_imp"
                          ],
                          "connection": [
                              {
                                  "jdbcUrl": "jdbc:mysql://127.0.0.1:3306/datax?useUnicode=true&characterEncoding=utf8",
                                  "table": [
                                      "himp_data_imp"
                                  ]
                              }
                          ]
                      }
                  }
              }
          ]
      }
  }
  ```

- 配置一个自定义SQL的数据库同步任务到本地内容的作业：

  ```json
  {
      "job": {
          "setting": {
              "speed": {
                   "channel":1
              }
          },
          "content": [
              {
                  "reader": {
                      "name": "mysqlreader",
                      "parameter": {
                          "username": "root",
                          "password": "root",
                          "connection": [
                              {
                                  "querySql": [
                                      "SELECT hi.batch, hi.template_code, hi.status AS batch_status, hi.data_count AS batch_count, hi.creation_date AS import_time , hd.sheet_index, hd.data_status, hd.data, hd.error_msg FROM himp_import hi JOIN himp_data hd ON hd.batch = hi.batch WHERE hi.creation_date > DATE_ADD(CURDATE(), INTERVAL -1 DAY);"
                                  ],
                                  "jdbcUrl": [
                                      "jdbc:mysql://bad_ip:3306/database"
                                  ]
                              }
                          ]
                      }
                  },
                  "writer": {
                      "name": "mysqlwriter",
                      "parameter": {
                          "writeMode": "update",
                          "username": "root",
                          "password": "root",
                          "column": [
                              "batch",
                              "templateCode",
                              "batch_status",
                              "batch_count",
                              "import_time",
                              "sheet_index",
                              "data_status",
                              "data",
                              "error_msg",
                          ],
                          "session": [
                          	"set session sql_mode='ANSI'"
                          ],
                          "preSql": [
                              "DELETE FROM himp_import_all WHERE import_time > DATE_ADD(CURDATE(), INTERVAL -1 DAY)"
                          ],
                          "connection": [
                              {
                                  "jdbcUrl": "jdbc:mysql://127.0.0.1:3306/datax?useUnicode=true&characterEncoding=utf8",
                                  "table": [
                                      "himp_import_all"
                                  ]
                              }
                          ]
                      }
                  }
              }
          ]
      }
  }
  ```

##### FAQ

- 有部分脏数据导入数据库，如果影响到线上数据库怎么办?

  A: 目前有两种解法，第一种配置 pre 语句，该 sql 可以清理当天导入数据， DataX 每次导入时候可以把上次清理干净并导入完整数据。第二种，向临时表导入数据，完成后再 rename 到线上表。

##### 参数说明

[MysqlReader](https://github.com/alibaba/DataX/blob/master/mysqlreader/doc/mysqlreader.md)

[MysqlWriter](https://github.com/alibaba/DataX/blob/master/mysqlwriter/doc/mysqlwriter.md)

