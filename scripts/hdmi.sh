#!/bin/sh

if grep i5-1130G7 < /proc/cpuinfo >/dev/null 2>&1 ; then
    # OneMix44
    PRIMARY="eDP-1"
    SECONDARY="DP-1"
else
    # L380
    PRIMARY="eDP1"
    SECONDARY="HDMI2"
fi

if xrandr | grep "${PRIMARY} connected primary (normal" > /dev/null ; then
    xrandr --output ${PRIMARY} --auto
    xrandr --output ${SECONDARY} --off
else
    if xrandr | grep -e "${SECONDARY} connected (normal" -e "DP-1 connected (normal" > /dev/null ; then
        xrandr --output ${SECONDARY} --auto
        xrandr --output ${PRIMARY} --off
    else
        xrandr --output ${PRIMARY} --auto
        xrandr --output ${SECONDARY} --off
    fi
fi

sleep 1
