#!/bin/bash

while true;do
    if [ ! -n "$(ps fax | grep '/ttnode/ttnode -p' | egrep -v 'grep|echo|rpm|moni|guard')" ]; then
        /root/ttnode -p /ttnode
    fi
    sleep 60
done
