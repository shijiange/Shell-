#!/bin/bash
#
#********************************************************************
#Author:		shijian
#Date: 			2019-09-08
#URL: 			http://www.shijianphp.com
#Description:		The test script
#Copyright (C): 	2019 All rights reserved
#********************************************************************

ZABBIX_SERVER=zabbix.shijianphp.com
TOKEN=$(./zabbix-api-token.sh| awk -F'"' '{print $8}')

curl -s -XPOST -H "Content-Type: application/json-rpc" -d '
{
"jsonrpc": "2.0",
"method": "host.get",
"params": {
    "output": [ "host" ]
 },
"id": 1,
"auth": "'$TOKEN'"
}' http://${ZABBIX_SERVER}/zabbix/api_jsonrpc.php | python3 -m json.tool
