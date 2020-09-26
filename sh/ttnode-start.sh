#!/bin/bash

    if [ ! -n "$(ps fax | grep '/ttnode/ttnode -p')" ]; then
        /root/ttnode -p /ttnode
    fi

