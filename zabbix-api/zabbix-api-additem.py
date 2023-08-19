#!/usr/bin/python3
from pyzabbix import ZabbixAPI, ZabbixAPIException

def get_api(url, user, pw):
    api = ZabbixAPI(url)  # api地址
    api.login(user, pw)  # Zabbix用户名、密码
    return api

def get_template_group_id(api, name):
    group_re = api.hostgroup.get(output=['groupid'], filter={"name": [name]})
    if group_re:
        group_id = group_re[0]['groupid']
    else:
        group_id = ''
    return group_id

def read_file(fn):
    data = get_data(fn)
    return data

def create_template(api, gid, name, alias):
    ret = api.template.create(
        host=name,
        name=alias,
        groups={
            'groupid': gid
        }
    )
    print("template_name:{}".format(name))
    return ret['templateids'][0]

def get_template_id(api,tpl_name):
    tpl_id = ''
    try:
        res = api.template.get(filter={'host':tpl_name}, output=['templateid'])
        if res:
            tpl_id = res[0]['templateid']

    except ZabbixAPIException as e:
            print(e)
    return tpl_id


def create_item(api, template_id, template_name,status=1, delay='10s', expression='=0', level=3, atime=3):

    item_name = 'tcp_state_LISTEN'   #监控项名称
    key = 'tcp_state[LISTEN]'  #键值 
    item_id = api.item.create(
        name=item_name,
        key_=key,
        hostid=str(template_id),
        type=0,
        value_type=3,
        delay=delay
    )['itemids'][0]
    print("{} created success!".format(item_name))

if __name__ == '__main__':
    template_name=template_alias="API_create_template"
    api=get_api("http://10.0.0.100/zabbix","Admin","zabbix")  #创建api对象
    gid=get_template_group_id(api, 'Templates/Applications') #获取模板分组id
    tpl_id=create_template(api, gid, template_name, template_alias) #创建模板
    tpl_id=get_template_id(api,template_name)           
    try:
        create_item(api,tpl_id,template_name) #创建监控项
    except Exception as e:
        print(e)
    
