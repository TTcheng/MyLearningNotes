## 一、安装和配置

1、安装： (下载了Xcode会安装生成git环境)

```shell
sudo apt-get install git
```

2、查看版本：

```shell
git --version
```

3、全局配置：就是为了在于提交代码的时候，知道是哪个家伙提交的!

```shell
git config --global user.name  "用户名"
git config --global user.email "你的邮箱"
```

4、配置SSH Key  。在git上创建项目后，本地克隆代码、推送代码都需要在GitHub配置密钥，获取权限。用以验证你是否是合法用户，省去每次都要输入密码的步骤，采用ssh公钥、私钥。在你的电脑生成一个唯一的ssh公钥和密钥，公钥放在GitHub上，当你推送的时候，Git就会匹配你的私钥是否跟GitHub上的公钥是配对的，正确就认为你是合法的，允许推送。ssh  key也可以简单的理解为你的身份标识，放在GitHub上面标明你是这个项目的一个开发人员，但是别人可以截获，但是你本机上的私钥无法截获，ssh  key也就保证了每次传输是安全的。

ssh-keygen-t  rsa-C  “你的GitHub邮箱” ---   这就生成了一个id_rsa.pub文件，控制台上面会有他的路径，找到他，打开，复制。然后登录你的github账号，右上角，设置，ssh key  ,title 起个名字，key 里面黏贴刚刚复制的密钥串，Add SSH key。欧了！接下来可以验证一下是否配置成功：ssh  -T git@github.com 回车、回车、回车，如果结果提示成功了，那么你就有权限用git一通操作了。

```shell
ssh-keygen -t  rsa -C  "你的GitHub邮箱" #生成SSH key
ssh  -T git@github.com #测试ssh密匙是否生效
```

## 二、常用操作

5、本地新建一个空仓库：mkdir testgit , cd testgit , git init  (这时打开testgit文件会看见一个.git的文件，这个文件里面会把所有的信息都存储在其中)

```shell
mkdir testgit
cd testgit
git init
```

6、从远程仓库拷贝现有代码：git clone  xxxxx(地址)

```shell
git clone  xxxxx(address)
```

7、本地仓库和远程仓库关联起来：git remote add origin git@.....(地址)   这样就不用每次推送的时候都要写远程服务器地址了git push origin master

```shell
git remote add origin git@github.com:TTcheng/xxx.git
```

8、增删改：git add . (. 是所有文件)  执行后修改内容都会被保存到本机的缓存里面

9、提交：git commit -m "日志信息"

10、推送到远程服务器：git push <远程主机名> <本地分支名>:<远程分支名> 

```shell
# 推送到远程分支
git push origin master
# 推送到指定远程分支
git push origin localbranch:remotebranch
```

11、 查看状态：git status

12、撤销对文件的修改：git checkout 文件名

## 三、版本回退

13、版本回退：

回到当前版本，放弃所有的没有提交的修改：git reset --hard HEAD

回到上一个版本：git reset --hard HEAD^

回到前三个版本：git rese

回到指定版本：git reset "版本号"

## 四、分支管理

14、新建分支：git branch “新分支名”

15、查看当前所有分支：git branch

16、查看远程分支：git branch -r

17、删除分支：git branch -d "分支名"

18、删除远程分支：git branch -r -d origin/“name”

19、切换分支：git checkout “name”

20、分支合并：git merge “分支名”