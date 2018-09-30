## sonar集成方法

------

### **sonarLint插件方式本地检测**

- idea、Eclipse需要安装sonarLint插件
- sonarLint配置公司sonarQube服务(serverUrl:[http://47.93.118.224:9000](http://47.93.118.224:9000/) token:6520a8b874e3021582751661b67bfaa697c931d7) ，默认不需要选择项目
- [idea方式运行](https://www.cnblogs.com/0201zcr/archive/2017/04/17/6722932.html),[eclipse方式运行](https://blog.csdn.net/songer_xing/article/details/76691148),(统一使用token方式配置)

### **sonarRunner服务端检测**

- 在pom文件中增加以下2段配置

```
<profile>
    <id>sonar</id>
    <activation>
        <activeByDefault>true</activeByDefault>
    </activation>
    <properties>
        <sonar.host.url>http://47.93.118.224:9000</sonar.host.url>
    </properties>
</profile>
<plugin>
    <groupId>org.sonarsource.scanner.maven</groupId>
    <artifactId>sonar-maven-plugin</artifactId>
    <version>3.3.0.603</version>
</plugin>
```

- 配置`jdk1.8`做为编译版本，运行maven，sonar:sonar
- 访问[sonarQube](http://47.93.118.224:9000/projects?sort=-analysis_date)查看报告

> 可在pom中加入exclusions节点，过滤掉不需要检测的文件
>
> ```
> <properties>
>     <sonar.exclusions>
>       src/main/java/com/.../domain/model/**/*,
>       src/main/java/com/.../exchange/**/*
>     </sonar.exclusions>
> </properties>
> ```