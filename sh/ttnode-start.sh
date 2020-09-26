#!/bin/bash

ps -ef |grep -w '/root/ttnode -p'|grep -v grep|wc -l
if [ $? -eq 0 ]; then
    /root/ttnode -p /ttnode
fi

