# Subversion

## 安装

- yum

  ```shell
  sudo yum install subversion
  ```

- apt

  ```shell
  sudo apt install svn
  ```

## 创建版本库

```shell
# 创建SVN根目录
mkdir -p /data/svn/
cd /data/svn/
# 建立版本仓库
svnadmin create study
```

## 配置用户及访问权限

svn的配置都是仓库独立的，每个仓库需要独立配置

涉及仓库目录下如下三个配置文件：

| 文件名称           | 描述                                                         |
| ------------------ | ------------------------------------------------------------ |
| conf/authz         | 用户授权配置。此配置文件采用“基于路径的授权”策略，中括号里指定路径，以下列出对各用户的授权。包括只读r，读写rw。没有列出的用户，则不允许访问 |
| conf/passwd        | 密码配置。                                                   |
| conf/svnserve.conf | 仓库服务配置。主要配置。可配置前两个文件的路径和名称。       |

### 配置授权

`conf/svnserve.conf`配置文件详解

```properties
[general]
### 匿名用户访问权限 read:只读 write：读写 none：拒绝访问
anon-access = none

### 授权用户访问权限 read:只读 write：读写 none：拒绝访问
auth-access = write

### 指定密码存储文件
password-db = passwd

### 指定基于路径访问控制的文件
authz-db = authz

### 指定存储库的身份验证域，一般不指定，默认为版本库的uuid。如果两个版本库相同，则必须指定相同的密码库
# realm =  My First Repository

### 用户名大小写格式（upper:大写，lower：小写，none：不区分）
force-username-case = none

[sasl]
### 另一种认证模式，不详细说明，可以参考官方文档
# use-sasl = true
# min-encryption = 0
# max-encryption = 256

```



### 配置用户

`conf/authz`配置文件详解

```properties
[aliases]
### 配置别名
# joe = /C=XZ/ST=Dessert/L=Snake City/O=Snake Oil, Ltd./OU=Research Institute/CN=Joe Average

[groups]
### 配置用户组,格式group=user1,user2
harry_and_sally = harry,sally
harry_sally_and_joe = harry,sally,&joe

[/foo/bar]
### 通用路径授权，配置文件可以多仓库公用
harry = rw
&joe = r
* =

[repository:/baz/fuz]
### 指定仓库，按路径授权
@harry_and_sally = rw
* = r
```

一般配个用户组，按路径授权即可。

- 示例

```properties
[groups]
admin = jesse,wcc

[/]
@admin = rw
[wcc:/]
wcc = rw
```

### 配置密码

这个很简单，直接在`conf/passwd`文件的users标签下按`username=password`的形式添加即可

```properties
[users]
harry = harryssecret
sally = sallyssecret
```

## 启动svn服务

```shell
svnserve -d -r /data/svn/
```

## 常用客户端命令

svn checkout svn://192.168.xxx.xxx/repo_name

svn update

svn add filepath

svn commit -m "commit message"  filepath

svn lock filepath

svn log

svn cleanup

svn list

svn status

svn help.......



