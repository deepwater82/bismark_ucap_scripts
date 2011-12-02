#!/bin/sh

# Manipulate config for changing bridging for ucap
uci set wireless.@wifi-iface[0].network=''
uci set wireless.@wifi-iface[1].network=''
uci set network.lan.ifname=''
uci commit wireless
uci commit network

# restart network
/etc/init.d/network restart

# enable openflow
/etc/init.d/openflow restart
