#!/usr/bin/python3
from pyzabbix import ZabbixAPI

zapi = ZabbixAPI("http://10.0.0.100/zabbix") #zabbix地址
zapi.login("Admin", "zabbix")  #zabbix用户名、密码
print("Connected to Zabbix API Version %s" % zapi.api_version())

for h in zapi.host.get(output="extend"):
    print(h['hostid'])
