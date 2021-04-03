#!/usr/bin/env bash

echo "请求地址：http://10.217.245.4:15020/，请求文档：index.html。使用cookie认证通过"
echo "近十次响应时间如下："
echo "   dns: connect:transfer:total"
for i in $(seq 1 10) ; do
  curl -o index${i}.html \
    -s -w %{time_namelookup}:%{time_connect}:%{time_starttransfer}:%{time_total} \
    --cookie "oneapmclientid=175681126ca18e-0fada82fbbf9eb8-4c3f257b-1fa400-175681126cb64; SESSIONID_HAP=bf362a70-bbc9-40fd-a430-f4535062dd96; route=10.253.60.31:15030; lastLoginedAt=1614742549000; lastLoginedIp=""; lastLoginedShow=false; lastLoginedCity=""; fr_remember=false; fr_password=""; fr_username="ningshunjiu@hand.wbcmcc"; AIPortal_Res_Account=hand_wbcmcc_ningshunjiu; ONEAPM_BI_sessionid=9477.948|1614913500477|hand_wbcmcc_ningshunjiu" \
    http://10.217.245.4:15020/
  echo ""
done

