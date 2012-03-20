#!/bin/sh

# monitor veth
while [ 1 ]; do
    local veth=`ifconfig | grep 'veth' -c`
    if [ $veth -eq 0 ]; then
        sleep 50
        local recheck=`ifconfig | grep 'veth' -c`
        if [ $recheck -eq 0 ]; then
            sh /root/enable_ucap.sh
        fi
    fi

	sleep 10
done
