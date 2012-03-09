#!/bin/sh

# Manipulate config for changing bridging for ucap
uci set wireless.@wifi-iface[0].network=''
uci set wireless.@wifi-iface[1].network=''
uci set network.lan.ifname=''
# OpenFlow
uci set openflow.@ofswitch[0].dp=dp0
local dp_id=`ifconfig | grep "eth0 " | grep HWaddr | awk -F 'HWaddr ' '{ print $2 }' | sed -e '/:/ s/://g'}`
uci set openflow.@ofswitch[0].dpid=$dp_id
uci set openflow.@ofswitch[0].ofports=wlan0,wlan1,eth0.1,veth0
uci set openflow.@ofswitch[0].ofctl=tcp:143.215.131.178:6633
uci set openflow.@ofswitch[0].mode=outofband
uci commit wireless
uci commit network
uci commit openflow

# restart network
/etc/init.d/network restart

# enable openflow
/etc/init.d/openflow restart
