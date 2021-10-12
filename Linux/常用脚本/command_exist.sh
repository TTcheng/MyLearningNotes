#!/usr/bin/env bash

# 常用来查找命令的命令 whereis、which、command -v

echo "Which command?"
read cmd
# if command -v $cmd > /dev/null 2>&1; then 
res=`command -v $cmd`
if [ ! ${#res} -eq 0 ] ;then
command -v $cmd
else 
echo "command $cmd not found"
fi