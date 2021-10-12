#!/usr/bin/env bash
## 用来查看端口的命令：
## netstat -tunpl
## lsof -i

echo "Please select:"
echo "1: show all ports"
echo "2: show specified port"
read select
if [ 1 -eq $select ] ;then
	netstat -tunpl	
	exit 0;
fi
echo "which port?"
read port
netstat -tunpl |grep $port
