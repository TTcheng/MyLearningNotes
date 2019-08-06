#!/bin/bash
appName=hdsp-core
echo "Stopping SpringBoot Application [$appName.jar] Starting...."
pid=`ps -ef | grep hdsp-core.jar | grep -v grep | grep -v hap-* | awk '{print $2}'`
if [ -n "$pid" ]
then
   echo "[$appName.jar]Force Kill -9 pid:" $pid
   kill -9 $pid
fi
echo "Stopping SpringBoot Application [$appName.jar] Finished...." 
