#!/bin/bash
#
#********************************************************************
#Author:            shijian
#Date:              2019-08-06
#FileName:          zabbix-api-additem.sh
#URL:               http://www.shijianphp.com
#Description:       The test script
#Copyright (C):     2019 All rights reserved
#********************************************************************

ZABBIX_SERVER=zabbix.shijianphp.com
TOKEN=$(./zabbix-api-token.sh| awk -F'"' '{print $8}')

curl -s -XPOST -H "Content-Type: application/json-rpc" -d '
{
    "jsonrpc": "2.0",
    "method": "item.create",
    "params": {
        "name": "tcp_state_LISTEN",
        "key_": "tcp_state[LISTEN]",
        "hostid": "10416",
        "type": 7,
        "value_type": 3,
        "interfaceid": "2",
        "delay": "30s"
    },
    "auth": "'$TOKEN'",
    "id": 1
}' http://${ZABBIX_SERVER}/zabbix/api_jsonrpc.php | python3 -m json.tool
