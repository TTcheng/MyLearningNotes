# 重写路由不生效

## 错误的配置    

    ......
    location /powerbi {
        rewrite ^/powerbi/(.*)$ /xpbi/powerbi/$1 break;
        proxy_pass http://192.168.11.200:8080;
    }
    location /pbirs {
        # 加上服务路由
        rewrite ^/pbirs/(.*)$ /xpbi/pbirs/$1 break;
        # 配gateway的地址
        proxy_pass http://192.168.11.200:8080;
    }
    ......

## 原因

上面这种匹配方式的优先级是最低的，而后面还有一个配置：

```
location ~* \.(css|js)$ {
    expires 1y;
    access_log off;
    add_header Cache-Control "public";
}
```

这个配置比上面的配置的优先级要高，所以所有的js和css都按照这个的规则来了。

### location表达式类型

- ~ 表示执行一个正则匹配，区分大小写
- ~* 表示执行一个正则匹配，不区分大小写
- ^~ 表示普通字符匹配。使用前缀匹配。如果匹配成功，则不再匹配其他location。
- = 进行普通字符精确匹配。也就是完全匹配。
- @ 它定义一个命名的 location，使用在内部定向时，例如 error_page, try_files

### 优先级说明

在nginx的location和配置中location的顺序没有太大关系。正location表达式的类型有关。相同类型的表达式，字符串长的会优先匹配。

以下是按优先级排列说明：

1. 等号类型（=）的优先级最高。一旦匹配成功，则不再查找其他匹配项。
2. ^~类型表达式。一旦匹配成功，则不再查找其他匹配项。
3. 正则表达式类型（~ ~*）的优先级次之。如果有多个location的正则能匹配的话，则使用正则表达式最长的那个。
4. 常规字符串匹配类型。按前缀匹配。

## 解决办法

使用优先级更高的表达式匹配，即加上`^~`

```
......
location ^~ /powerbi {
    rewrite ^/powerbi/(.*)$ /xpbi/powerbi/$1 break;
    proxy_pass http://192.168.11.200:8080;
}
location ^~ /pbirs {
    # 加上服务路由
    rewrite ^/pbirs/(.*)$ /xpbi/pbirs/$1 break;
    # 配gateway的地址
    proxy_pass http://192.168.11.200:8080;
}
......
```

