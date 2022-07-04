#!/bin/sh

if [ -z "$2" ] || ( [ "$1" != "rdp" ] && [ "$1" != "console" ] ) ; then
    echo "Usage: $0 <rdp>|<console> <vm name>"
    exit 1
fi

if [ "$1" = "rdp" ] ; then
    qvm-features "$2" gui ''
else
    qvm-features --unset "$2" gui
fi

qvm-start --quiet --skip-if-running "$2"

if [ "$1" = "rdp" ] ; then
    IP=$(qvm-prefs ${2} | grep ip | head -n 1 | tr -s ' ' | cut -d' ' -f3)
    for COUNT in 3 2 2 1 1 1 ; do
        sleep "${COUNT}"
        qvm-run -q -a --service core-rdp "alte.RDP+${IP}" &
        sleep 2
        xlsclients -l | grep core-rdp:xfreerdp >/dev/null 2>&1 && exit 0
    done
fi

echo "debug('Failed to connect to <b>$2</b>')" | awesome-client

exit 1
