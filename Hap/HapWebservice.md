## Webservice开发过程

### 1、编写webservice接口

```java
import javax.jws.WebService;

@WebService
public interface HelloWs {
    String publishHello(String message);
}
```
### 2、编写接口的实现
```java
import com.hand.hap.message.IMessagePublisher;
import org.springframework.beans.factory.annotation.Autowired;

import javax.jws.WebParam;
import javax.jws.WebService;

@WebService(endpointInterface = "wcc.core.demo.ws.HelloWs", serviceName = "hello")
public class HelloWsImpl implements HelloWs {

    @Override
    public String publishHello(@WebParam String message) {
        System.out.println("=====================");
        System.out.println("HelloWs 被访问了一次！");
        System.out.println("Hello " + message);
        System.out.println("=====================");
        return "success";
    }
}
```
### 3、配置webservice
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:jaxws="http://cxf.apache.org/jaxws"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.2.xsd http://cxf.apache.org/jaxws http://cxf.apache.org/schemas/jaxws.xsd">

    <bean id="helloService" class="wcc.core.demo.ws.HelloWsImpl"/>
    <jaxws:endpoint id="helloWs" implementor="#helloService" address="/helloWs"/>
</beans>
```
### 4、测试

- 请求消息

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.demo.core.wcc/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">  
    <soapenv:Body>  
        <ws:publishHello>  
            <arg0>张三</arg0>   
        </ws:publishHello>  
    </soapenv:Body>  
</soapenv:Envelope> 
```
- 响应消息

```xml
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    <soap:Body>
        <ns2:publishHelloResponse xmlns:ns2="http://ws.demo.core.wcc/">
            <return>success</return>
        </ns2:publishHelloResponse>
    </soap:Body>
</soap:Envelope>
```