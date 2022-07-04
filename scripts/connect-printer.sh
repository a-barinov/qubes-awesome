#!/bin/sh

sleep 3

DEVICE=$(qvm-device usb list | grep -e C43x -e Pro_7740 | cut -d' ' -f1)

if ! [ -z "${DEVICE}" ] ; then
    qvm-device usb attach core-print "${DEVICE}"
fi
