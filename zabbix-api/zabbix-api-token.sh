#!/bin/bash
#
#********************************************************************
#Author:		shijian
#Date: 			2019-09-08
#FileName:		zabbix-api-token.sh
#URL: 			http://www.shijianphp.com
#Description:		The test script
#Copyright (C): 	2019 All rights reserved
#********************************************************************

ZABBIX_SERVER=zabbix.shijianphp.com

curl -s -XPOST -H "Content-Type: application/json-rpc" -d '                                           
{
"jsonrpc": "2.0",
"method": "user.login",
"params": {
"user": "Admin",
"password": "zabbix"
},
"id": 1,
"auth": null
}' http://${ZABBIX_SERVER}/zabbix/api_jsonrpc.php 
