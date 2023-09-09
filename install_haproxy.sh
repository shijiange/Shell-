#!/bin/bash
#
#******************************************************************************
#Author:            wangxiaochu
#Date:              2020-07-03
#FileName:          install_haproxy.sh
#URL:               www.shijianphp.com
#Description:       install haproxy for centos 7/8 & ubuntu 18.04/20.04
#Copyright (C):     2020 All rights reserved
#******************************************************************************

#只支持离线下载源码安装，不支持在线下载安装

HAPROXY_VERSION=2.8.2
#HAPROXY_VERSION=2.8.0
#HAPROXY_VERSION=2.6.6
#HAPROXY_VERSION=2.6.1
#HAPROXY_VERSION=2.2.12

HAPROXY_INSTALL_DIR=/apps/haproxy

STATS_AUTH_USER=admin
STATS_AUTH_PASSWORD=123456

HAPROXY_FILE=haproxy-${HAPROXY_VERSION}.tar.gz

LUA_VERSION=5.4.4
#LUA_VERSION=5.4.3
LUA_FILE=lua-${LUA_VERSION}.tar.gz


SRC_DIR=/usr/local/src
CWD=`pwd`
CPUS=`lscpu |awk '/^CPU\(s\)/{print $2}'`
LOCAL_IP=$(hostname -I|awk '{print $1}')



VIP=192.168.10.100
MASTER1=192.168.10.101
MASTER2=192.168.10.102
MASTER3=192.168.10.103

. /etc/os-release

color () {
    RES_COL=60
    MOVE_TO_COL="echo -en \\033[${RES_COL}G"
    SETCOLOR_SUCCESS="echo -en \\033[1;32m"
    SETCOLOR_FAILURE="echo -en \\033[1;31m"
    SETCOLOR_WARNING="echo -en \\033[1;33m"
    SETCOLOR_NORMAL="echo -en \E[0m"
    echo -n "$1" && $MOVE_TO_COL
    echo -n "["
    if [ $2 = "success" -o $2 = "0" ] ;then
        ${SETCOLOR_SUCCESS}
        echo -n $"  OK  "    
    elif [ $2 = "failure" -o $2 = "1"  ] ;then 
        ${SETCOLOR_FAILURE}
        echo -n $"FAILED"
    else
        ${SETCOLOR_WARNING}
        echo -n $"WARNING"
    fi
    ${SETCOLOR_NORMAL}
    echo -n "]"
    echo 
}


check_lua_file (){
    if [ ! -e ${LUA_FILE} ];then
        color "缺少${LUA_FILE}文件!" 1
        exit
    else
        color "相关文件已准备!" 0
    fi
}

check_haproxy_file (){
    if [ ! -e ${HAPROXY_FILE} ];then
        color "缺少${HAPROXY_FILE}文件!" 1
        exit
    else
        color "相关文件已准备!" 0
    fi
}


install_packs () {
    if [ $ID = "centos" -o $ID = "rocky" ];then
        yum -y install gcc make gcc-c++ glibc glibc-devel pcre pcre-devel openssl openssl-devel systemd-devel libtermcap-devel ncurses-devel libevent-devel readline-devel 
        
    elif [ $ID = "ubuntu" ];then
        apt update 
        #apt -y install gcc make openssl libssl-dev libpcre3 libpcre3-dev zlib1g-dev  libreadline-dev libsystemd-dev liblua5.3-dev 
		apt -y install gcc make openssl libssl-dev libpcre3 libpcre3-dev zlib1g-dev  libreadline-dev libsystemd-dev liblua5.4-dev
    else
        color "不支持此操作系统!" 1
    fi
    [ $? -eq 0 ] ||  { color '安装软件包失败,退出!' 1; exit; }
}

install_lua () {
    cd ${CWD}
    check_lua_file
    tar xf ${LUA_FILE} -C ${SRC_DIR}
    LUA_DIR=${LUA_FILE%.tar*}
    cd ${SRC_DIR}/${LUA_DIR}
    make all test
}

install_haproxy(){
    check_haproxy_file
    cd ${CWD}
    tar xf ${HAPROXY_FILE} -C ${SRC_DIR}
    HAPROXY_DIR=${HAPROXY_FILE%.tar*}
    cd ${SRC_DIR}/${HAPROXY_DIR}
    if [[ ${VERSION_ID} =~ ^(7|8) ]] ;then
        install_lua
        cd ${SRC_DIR}/${HAPROXY_DIR}
        make -j ${CPUS} ARCH=x86_64 TARGET=linux-glibc  USE_PROMEX=1 USE_PCRE=1 USE_OPENSSL=1 USE_ZLIB=1 USE_SYSTEMD=1 USE_CPU_AFFINITY=1 USE_LUA=1 LUA_INC=${SRC_DIR}/${LUA_DIR}/src/ LUA_LIB=${SRC_DIR}/${LUA_DIR}/src/ PREFIX=${HAPROXY_INSTALL_DIR}
    else
        make -j ${CPUS} ARCH=x86_64 TARGET=linux-glibc  USE_PROMEX=1 USE_PCRE=1 USE_OPENSSL=1 USE_ZLIB=1 USE_SYSTEMD=1 USE_CPU_AFFINITY=1 USE_LUA=1 
    fi
    make install PREFIX=${HAPROXY_INSTALL_DIR}
    [ $? -eq 0 ] && color "HAPROXY编译安装成功" 0 ||  { color "HAPROXY编译安装失败,退出!" 1;exit; }
    [ -L /usr/sbin/haproxy ] || ln -s ${HAPROXY_INSTALL_DIR}/sbin/haproxy /usr/sbin/ 
    [ -d /etc/haproxy ] || mkdir /etc/haproxy 
    #[ -d /var/lib/haproxy/ ] || mkdir -p /var/lib/haproxy/ 
    cat > /etc/haproxy/haproxy.cfg <<-EOF
global
maxconn 100000
stats socket /var/lib/haproxy/haproxy.sock mode 600 level admin
uid 99
gid 99
daemon

#pidfile /var/lib/haproxy/haproxy.pid
log 127.0.0.1 local2 info

defaults
option http-keep-alive
option forwardfor
maxconn 100000
mode http
timeout connect 300000ms
timeout client 300000ms
timeout server 300000ms

listen stats
    mode http
    bind 0.0.0.0:9999
    stats enable
    log global
    stats uri /haproxy-status
    stats auth ${STATS_AUTH_USER}:${STATS_AUTH_PASSWORD}

#listen kubernetes-6443
#    bind ${VIP}:6443
#    mode tcp
#    log global
#    server ${MASTER1} ${MASTER1}:6443 check inter 3000 fall 2 rise 5
#    server ${MASTER2} ${MASTER2}:6443 check inter 3000 fall 2 rise 5
#    server ${MASTER3} ${MASTER2}:6443 check inter 3000 fall 2 rise 5

EOF
    
	groupadd -g 99 haproxy
	useradd -u 99 -g haproxy -d /var/lib/haproxy -m -r -s /sbin/nologin haproxy
}

start_haproxy () {
	cat > /lib/systemd/system/haproxy.service <<-EOF
[Unit]
Description=HAProxy Load Balancer
After=syslog.target network.target

[Service]
ExecStartPre=/usr/sbin/haproxy -f /etc/haproxy/haproxy.cfg -c -q
ExecStart=/usr/sbin/haproxy -Ws -f /etc/haproxy/haproxy.cfg -p /var/lib/haproxy/haproxy.pid
ExecReload=/bin/kill -USR2 \$MAINPID

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable --now haproxy 
    systemctl is-active haproxy &> /dev/null && color 'HAPROXY安装完成!' 0 ||  { color 'HAPROXY 启动失败,退出!' 1; exit; }
    echo "-------------------------------------------------------------------"
    echo -e "请访问链接: \E[32;1mhttp://${LOCAL_IP}:9999/haproxy-status\E[0m"
    echo -e "用户和密码: \E[32;1m${STATS_AUTH_USER}/${STATS_AUTH_PASSWORD}\E[0m" 
}


install_packs

install_haproxy

start_haproxy
