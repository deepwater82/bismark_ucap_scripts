#!/bin/sh 

# check for existing ip rules
local wlan0_num=`ip rule show | grep 'iif wlan0 lookup' -c`
local wlan1_num=`ip rule show | grep 'iif wlan1 lookup' -c`
local eth01_num=`ip rule show | grep 'iif eth0.1 lookup' -c`

local wlan_0=`ip rule show | grep 'iif wlan0 lookup' | awk '{print $4,$5,$6,$7}'`
local wlan_1=`ip rule show | grep 'iif wlan1 lookup' | awk '{print $4,$5,$6,$7}'`
local eth_01=`ip rule show | grep 'iif eth0.1 lookup' | awk '{print $4,$5,$6,$7}'`

for i in $(seq 1 1 $wlan0_num)
do 
	ip rule del iif wlan0
done

for i in $(seq 1 1 $eth01_num)
do 
	ip rule del iif eth0.1
done

for i in $(seq 1 1 $wlan1_num)
do 
	ip rule del iif wlan1
done

# clean routing table for "ucap_rt"
local rtbl=`ip route show table ucap_rt | grep 'blackhole' -c`
if [ $rtbl -ne 0 ]; then
	ip route del blackhole default table ucap_rt
	ip route flush cache
fi

# kill openflow
/etc/init.d/openflow stop

# ifconfig down veth devices
local veth0=`ifconfig | grep 'veth0' -c`
if [ $veth0 -ne 0 ]; then
	ifconfig veth0 down
fi
local veth1=`ifconfig | grep 'veth1' -c`
if [ $veth1 -ne 0 ]; then
	ifconfig veth1 down
fi

# revert back the bridging set (br-lan)
uci set wireless.@wifi-iface[0].network='lan'
uci set wireless.@wifi-iface[1].network='lan'
uci set network.lan.ifname='eth0.1'
uci commit wireless
uci commit network

/etc/init.d/network restart
ifconfig eth0.1 up
brctl addif br-lan eth0.1
