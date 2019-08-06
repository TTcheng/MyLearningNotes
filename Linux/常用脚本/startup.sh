#!/bin/bash

appName=hdsp-core
SW_AGENT_NAME=$appName
export SW_AGENT_NAME

nohup java -Xmx500m -Xms500m \
                -javaagent:/opt/hdsp/infra/skywalking/agent/skywalking-agent.jar \
                -Dspring.cloud.inetutils.ignored-interfaces[0]=docker0 \
                -DSPRING_CLOUD_CONFIG_ENABLED=true \
                -DSPRING_PROFILES_ACTIVE=default \
                -DSPRING_DATASOURCE_URL='jdbc:mysql://192.168.11.200:7233/hdsp_core?useUnicode=true&characterEncoding=utf-8&useSSL=false' \
                -DSPRING_REDIS_PORT=7963 \
                -jar $appName.jar > ./logs/$appName.log 2>&1 &
