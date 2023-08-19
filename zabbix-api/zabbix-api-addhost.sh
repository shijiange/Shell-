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
HOST=10.0.0.106

curl -s -XPOST -H "Content-Type: application/json-rpc" -d '
{
"jsonrpc": "2.0",
"method": "host.create",
"params": {
    "host": "'web-api-$HOST'",
    "name": "'web-api-$HOST'",
    "interfaces": [
        {
        "type": 1,
        "main": 1,
        "useip": 1,
        "ip": "'$HOST'",
        "dns": "",
        "port": "10050"
        }
    ],
    "groups": [ 
        {
            "groupid": "2" 
        }
    ],
    "templates": [ 
        {
            "templateid": "10001" 
        } 
    ]
 },
"id": 1,
"auth": "'$TOKEN'"
}' http://${ZABBIX_SERVER}/zabbix/api_jsonrpc.php | python3 -m json.tool
