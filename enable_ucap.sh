#!/bin/sh

# Manipulate config for changing bridging for ucap
local wl0=`uci get wireless.@wifi-iface[0].network -q`
local wl1=`uci get wireless.@wifi-iface[1].network -q`     
local ifname=`uci get network.lan.ifname -q`

if [ "$wl0" != "" ] || [ "$wl1" != "" ] || [ "$ifname" != "" ]; then
    uci set wireless.@wifi-iface[0].network=''
    uci set wireless.@wifi-iface[1].network=''
    uci set network.lan.ifname=''
    uci commit wireless
    uci commit network
    
    # restart network
    /etc/init.d/network restart
fi

# OpenFlow
uci set openflow.@ofswitch[0].dp=dp0
local dp_id=`ifconfig | grep "^eth0 " | grep HWaddr | awk -F 'HWaddr ' '{ print $2 }' | sed -e '/:/ s/://g'}`
uci set openflow.@ofswitch[0].dpid=$dp_id
uci set openflow.@ofswitch[0].ofports=wlan0,wlan1,eth0.1,veth0
uci set openflow.@ofswitch[0].ofctl=tcp:143.215.131.178:6633
uci set openflow.@ofswitch[0].mode=outofband
uci commit openflow

# enable openflow
/etc/init.d/openflow restart

# Start monitoring script
local check=`pgrep -fl monitor_veth`
if [ "$check" == "" ]; then
    sh /usr/bin/monitor_veth.sh &
fi
