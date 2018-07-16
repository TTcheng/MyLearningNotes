# MyBatis基础

## 一、一般步骤

![1530857728673](assets/1530857728673.png)

#### 1、创建xml配置文件

```xml
<configuration>
    <environments default="development">
        <environment id="development">
            <transactionManager type="JDBC"/>
            <dataSource type="POOLED">
                <property name="driver" value="oracle.jdbc.driver.OracleDriver"/>
                <property name="url" value="jdbc:oracle:thin:@xxx.xxx.xxx.xxx:1521:ORCL"/>
                <property name="username" value="xxxx"/>
                <property name="password" value="xxxx"/>
            </dataSource>
        </environment>
    </environments>
    <mappers>
        <mapper resource="sqlmap/PersonMapper.xml"/>
    </mappers>
</configuration>
```

#### 2、根据配置文件创建SqlSessionFactory

```java
String resource = "mybatis_config.xml";
InputStream inputStream = null;
try {
    inputStream = Resources.getResourceAsStream(resource);
} catch (IOException e) {
    e.printStackTrace();
}
SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
```

#### 3、配置一个sql映射文件

```xml-dtd
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.wangchuncheng.PersonMapper">
    <select id="selectPerson" resultType="com.wangchuncheng.beans.Person">
    SELECT "ID" id,"NAME" name,"GENDER" gender FROM JCJ.TEST_WCC_PERSON WHERE "ID" = #{id};
  </select>
</mapper>
```

#### 4、注册映射文件到全局配置文件

```xml
<configuration>
    ...
    <mappers>
        <mapper resource="sqlmap/PersonMapper.xml"/>
    </mappers>
    ...
</configuration>
```

#### 5、获取SqlSession并使用SqlSession来使用sql

```java
SqlSession sqlSession = sqlSessionFactory.openSession();//get sqlSession
Person person;
try {
    person = sqlSession.selectOne("selectPerson",1);//query
} finally {
    sqlSession.close();// close sqlSession is essential
}
...//now using person
```

#### 6、sql映射的另一种方式：接口式映射

除了使用步骤3的xml映射文件之外，MyBatis还支持接口式映射，并且我们推荐使用这种方式，因为这种方式有**安全的类型检查**。
##### （1）绑定配置文件(推荐)

不使用注解，绑定配置文件的sql语句。

①编写mapper接口

PersonMapper.class

```java
public interface PersonMapper {
    Person selectPerson(int id);
}
```

②绑定到映射文件PersonMapper.xml

```xml
<mapper namespace="com.wangchuncheng.mappers.PersonMapper">
    <select id="selectPerson" resultType="com.wangchuncheng.beans.Person">
        SELECT * FROM TEST_WCC_PERSON WHERE "ID" = #{id}
    </select>
</mapper>
```

③注册到配置文件

④使用mapper

```java
PersonMapper mapper = session.getMapper(PersonMapper.class);
Person person = mapper.selectPerson(101);
```

##### （2）基于注解（SQL语句复杂时不推荐）

①编写mapper接口

```java
public interface PersonMapper {
    @Select("SELECT * FROM person WHERE id = #{id}")
    Person selectPerson(int id);
}
```

②注册Mapper

```xml
<mappers>
    <!--<package name="com.wangchuncheng.mappers"/>--><!--批量-->
    <mapper class="com.wangchuncheng.mappers.PersonMapper"/>
</mappers>
```

③使用mapper

```java
PersonMapper mapper = session.getMapper(PersonMapper.class);
Person person = mapper.selectPerson(101);
```

对于简单语句来说，注解使代码显得更加简洁，**然而 Java 注解对于稍微复杂的语句就会力不从心并且会显得更加混乱**。因此，如果你需要做很复杂的事情，那么最好使用 XML 来映射语句。

## 二、MyBatis的几个重要概念

### 1、对象作用域与生命周期

#### SqlSessionFactoryBuilder

这个类可以被实例化、使用和丢弃，一旦创建了 SqlSessionFactory，就不再需要它了。因此  SqlSessionFactoryBuilder 实例的最佳作用域是**方法作用域**（也就是局部方法变量）。你可以重用  SqlSessionFactoryBuilder 来创建多个 SqlSessionFactory 实例，但是最好还是不要让其一直存在以保证所有的  XML 解析资源开放给更重要的事情。

#### SqlSessionFactory

SqlSessionFactory 一旦被创建就应该**在应用的运行期间一直存在**，没有任何理由对它进行清除或重建。使用  SqlSessionFactory 的最佳实践是在应用运行期间不要重复创建多次，多次重建 SqlSessionFactory  被视为一种代码“坏味道（bad smell）”。因此 SqlSessionFactory  的最佳作用域是**应用作用域**。有很多方法可以做到，最简单的就是使用单例模式或者静态单例模式。

#### SqlSession

每个线程都应该有它自己的 SqlSession 实例。**SqlSession  的实例不是线程安全的**，因此是**不能被共享**的，所以它的最佳的作用域**是请求或方法作用域**。绝对不能将 SqlSession  实例的引用放在一个类的静态域，甚至一个类的实例变量也不行。**也绝不能将 SqlSession 实例的引用放在任何类型的管理作用域中，比如  Servlet 架构中的 HttpSession**。如果你现在正在使用一种 Web 框架，要考虑 SqlSession 放在一个和 HTTP  请求对象相似的作用域中。换句话说，每次收到的 HTTP 请求，就可以打开一个  SqlSession，返回一个响应，就关闭它。这个关闭操作是很重要的，你应该把这个关闭操作放到 finally  块中以确保每次都能执行关闭。下面的示例就是一个确保 SqlSession 关闭的标准模式：

```java
SqlSession session = sqlSessionFactory.openSession();
try {
  // do work
} finally {
  session.close();
}
```

在你的所有的代码中一致性地使用这种模式来保证所有数据库资源都能被正确地关闭。 

#### 映射器实例（Mapper Instances）

映射器是一个你创建来绑定你映射的语句的接口。映射器接口的实例是从 SqlSession 中获得的。因此从技术层面讲，任何映射器实例的最大作用域是和请求它们的 SqlSession 相同的。尽管如此，映射器实例的最佳作用域是方法作用域。

### 2、接口式映射

原生:	dao 	====> daoImpl

mybatis: mapper	====> xxMapper.xml

**mapper接口无需编写实现类，与映射文件绑定后，MyBatis会为mapper接口生成代理对象**

### 3、两个重要的XML文件

MyBatis全局配置文件：包含数据源、连接池、事务管理。。。系统运行环境信息。

SQL映射文件：保存了所有SQL语句的映射信息。

## 三、全局配置文件

Batis 的配置文件包含了会深深影响 MyBatis 行为的设置（settings）和属性（properties）信息。文档的顶层结构如下： 

- Configuration 
  - [properties](#properties)
  - [settings](#settings)
  - [typeAliases](#typeAliases)
  - [typeHandlers](#typeHandlers)
  - [objectFactory](#objectFactory)
  - [plugins](#plugins)
  - [environments](#environments)
    - environment
      - [transationManager](#transationManager)
      - [dataSource](#datasource)
  - [databaseProvider](#databaseProvider)
  - [mappers](#mappers)

### properties

properties标签用于引入外部properties配置文件内容。有以下两种方式：

```xml
<properties resource="datasource.properties"></properties>
<properties url="D:\config\datasource.properties"></properties>
```

resource：引入类路径下的资源

URL：引入网络路径或者磁盘路径下的资源

**提示**：与Spring框架进行整合时，数据源一般由Spring管理。所以这个标签将很少用到。

### Settings

这是 MyBatis 中**极为重要**的调整设置 。典型的写法如下。

```xml
<settings>
    <setting name="mapUnderscoreToCamelCase" value="true"/>
    <setting name="cacheEnabled" value="true"/>
    ....
</settings>
```

这里有很多种设置参数，具体可查阅官方文档[settings](http://www.mybatis.org/mybatis-3/zh/configuration.html#settings)

### typeAliases

类型别名是为 Java 类型设置一个短的名字。它只和 XML 配置有关，存在的意义仅在于用来减少类完全限定名的冗余。 

```xml
<typeAliases>
  <typeAlias alias="Author" type="domain.blog.Author"/>
  <typeAlias alias="Blog" type="domain.blog.Blog"/>
  <typeAlias alias="Comment" type="domain.blog.Comment"/>
	...
</typeAliases>
```

也可以指定一个包名，MyBatis 会在包名下面搜索需要的 Java Bean，比如:         

```xml
<typeAliases>
  <package name="domain.blog"/>
</typeAliases>
```

每一个在包 `domain.blog` 中的 Java Bean**，在没有注解的情况下，会使用 Bean 的首字母小写的非限定类名来作为它的别名**。 比如 `domain.blog.Author` 的别名为 `author`；**若有注解，则别名为其注解值**。看下面的例子： 

```Java
@Alias("author")
public class Author {
    ...
}
```

**注意**：**别名不区分大小写**

内建别名:

> 基本类型是类型前加一个下划线：如int的别名为_int
>
> 包装类型是类名的全部小写形式：如BigInter的别名为biginteger

**注意**起别名的时候不要与这些内建别名相同

全部的内建别名可参考官方文档[typeAliases](http://www.mybatis.org/mybatis-3/zh/configuration.html#typeAliases)

### typeHandlers

Java与数据库之间的**类型转换**处理器。无论是 MyBatis 在预处理语句（PreparedStatement）中设置一个参数时，还是从结果集中取出一个值时， 都会用类型处理器将获取的值以合适的方式转换成 Java 类型。 

默认的类型处理器：参考官方文档[typeHandlers](http://www.mybatis.org/mybatis-3/zh/configuration.html#typeHandlers)

自定义类型处理器：参考官方文档[typeHandlers](http://www.mybatis.org/mybatis-3/zh/configuration.html#typeHandlers)

**提示** 从 3.4.5 开始，MyBatis 默认支持 JSR-310(日期和时间 API) ，JDK1.8支持。 

### objectFactory

MyBatis 每次创建结果对象的新实例时，它都会使用一个对象工厂（ObjectFactory）实例来完成。 默认的对象工厂需要做的仅仅是实例化目标类，要么通过默认构造方法，要么在参数映射存在的时候通过参数构造方法来实例化。 如果想覆盖对象工厂的默认行为，则可以通过创建自己的对象工厂来实现。参考官方文档[objectFactory](http://www.mybatis.org/mybatis-3/zh/configuration.html#objectFactory)

### plugins

MyBatis 允许你在已映射语句执行过程中的某一点进行拦截调用。默认情况下，MyBatis 允许使用插件来拦截的方法调用包括：         

- Executor (update, query, flushStatements, commit, rollback,  getTransaction, close, isClosed)  
- ParameterHandler (getParameterObject, setParameters)           
- ResultSetHandler (handleResultSets, handleOutputParameters)           
- StatementHandler (prepare, parameterize, batch, update, query)          

 参考官方文档[plugins](http://www.mybatis.org/mybatis-3/zh/configuration.html#plugins)

### environments

MyBatis 可以配置成适应多种环境，这种机制有助于将 SQL 映射应用于多种数据库之中 。

**不过要记住：尽管可以配置多个环境，每个 SqlSessionFactory 实例只能选择其一。** 

所以，如果你想连接两个数据库，就需要创建两个 SqlSessionFactory 实例，每个数据库对应一个。而如果是三个数据库，就需要三个实例，依此类推，记起来很简单： 

- **每个数据库对应一个 SqlSessionFactory 实例**

```java
SqlSessionFactory factory = new SqlSessionFactoryBuilder().build(reader, environment);//未指定环境参数，将加载默认环境
SqlSessionFactory factory = new SqlSessionFactoryBuilder().build(reader, environment, properties);//指定环境参数
```

典型的environment标签：

```xml
<environments default="development">
  <environment id="deployment">...</environment>
  <environment id="development">
    <transactionManager type="JDBC">
      ...
    </transactionManager>
    <dataSource type="POOLED">
      ...
    </dataSource>
  </environment>
</environments>
```

#### transationManager

事物管理器类型：

**JDBC**（JDBC TransactionFactory）

**MANAGED**（ManagedTransactionFactory）

**自定义事务管理器**：实现TransactionFactory接口.type指定为全类名

#### dataSource

数据源

type:数据源类型;

**UNPOOLED**(UnpooledDataSourceFactory) ：不使用连接池，这个数据源的实现只是每次被请求时打开和关闭连接 

**POOLED**(PooledDataSourceFactory) ： 这种数据源的实现利用“池”的概念将 JDBC 连接对象组织起来，避免了创建新的连接实例时所必需的初始化和认证时间。 这是一种使得并发 Web 应用快速响应请求的流行处理方式。 

**JNDI**(JndiDataSourceFactory) ：这个数据源的实现是为了能在如 EJB 或应用服务器这类容器中使用，容器可以集中或在外部配置数据源，然后放置一个 JNDI 上下文的引用 

**自定义数据源**：实现DataSourceFactory接口，type是全类名

 参考官方文档[environments](http://www.mybatis.org/mybatis-3/zh/configuration.html#environments)

### databaseProvider

用于支持多数据库厂商。

①配置databaseIdProvider

```xml
<!--DB_VENDOR是VendorDatabaseIdProvider的别名-->
<databaseIdProvider type="DB_VENDOR" >
    <!--为不同厂商起别名-->
	<property name"MySQL" value="mysql"/>
    <property name"Oracle" value="oracle"/>
    <property name"SQL Server" value="sqlserver"/>
</databaseIdProvider>
```

这里的 DB_VENDOR 会通过 `DatabaseMetaData#getDatabaseProductName()` 返回的字符串进行设置。 由于通常情况下这个字符串都非常长而且相同产品的不同版本会返回不同的值，所以最好通过设置属性别名来使其变短 

②映射文件中使用

使用时在映射文件中sql标签上使用databaseId属性指定语句适用的数据库

```xml
<select id="selectPersonByName"
        resultType="com.wangchuncheng.beans.Person"
        databaseId="oracle">
    SELECT * FROM TEST_WCC_PERSON WHERE "NAME" = #{name}
</select>
<select id="selectPersonByName"
        resultType="com.wangchuncheng.beans.Person"
        databaseId="mysql">
    SELECT * FROM person WHERE "NAME" = #{name}
</select>
```

### mappers

既然 MyBatis 的行为已经由上述元素配置完了，我们现在就要定义 SQL 映射语句了。但是首先我们需要告诉 MyBatis 到哪里去找到这些语句 。 Java 在自动查找这方面没有提供一个很好的方法，所以最佳的方式是告诉 MyBatis 到哪里去找映射文件。 

- 相对于类路径的资源引用resource

```xml
<mappers>
  <mapper resource="org/mybatis/builder/AuthorMapper.xml"/>
  <mapper resource="org/mybatis/builder/BlogMapper.xml"/>
  <mapper resource="org/mybatis/builder/PostMapper.xml"/>
</mappers>
```

- 使用完全限定资源定位符URL

```xml
<mappers>
  <mapper url="file:///var/mappers/AuthorMapper.xml"/>
  <mapper url="file:///var/mappers/BlogMapper.xml"/>
  <mapper url="file:///var/mappers/PostMapper.xml"/>
</mappers>
```

- 使用映射器接口实现类的完全限定名class

```xml
<mappers>
  <mapper class="org.mybatis.builder.AuthorMapper"/>
  <mapper class="org.mybatis.builder.BlogMapper"/>
  <mapper class="org.mybatis.builder.PostMapper"/>
</mappers>
```

- 将包内的映射器接口实现全部注册为映射器package

```xml
<mappers>
  <package name="org.mybatis.builder"/>
</mappers>
```

## 四、XML映射文件

MyBatis 的真正强大在于它的映射语句，也是它的魔力所在。由于它的异常强大，映射器的 XML  文件就显得相对简单。如果拿它跟具有相同功能的 JDBC 代码进行对比，你会立即发现省掉了将近 95% 的代码。MyBatis 就是针对 SQL  构建的，并且比普通的方法做的更好。

SQL 映射文件有很少的几个顶级元素（按照它们应该被定义的顺序）：

- `cache` – 给定命名空间的缓存配置。         
- `cache-ref`– 其他命名空间缓存配置的引用。         
- `resultMap`  – 是最复杂也是最强大的元素，用来描述如何从数据库结果集中来加载对象。
- `parameterMap`– 已废弃！老式风格的参数映射。内联参数是首选,这个元素可能在将来被移除，这里不会记录。 
- `sql` – 可被其他语句引用的可重用语句块。         
- `nsert`   – 映射插入语句         
- `update` – 映射更新语句         
- `delete` – 映射删除语句         
- `select` – 映射查询语句         

接下来看具体的元素。

