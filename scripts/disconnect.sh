#!/bin/sh

reliable_shutdown () {
    VM="${1}"
    if xentop -bfi 1 | grep "${VM}" 1>/dev/null 2>&1 ; then
        qvm-shutdown --wait "${VM}"
    fi
    if xentop -bfi 1 | grep "${VM}" 1>/dev/null 2>&1 ; then
        if qvm-run --no-autostart --no-gui --user root --service "${VM}" alte.Shutdown ; then
            for TIMEOUT in 5 3 1 1 1 1 1 1 1 1 1 1 1 1 ; do
                sleep "${TIMEOUT}"
                if ! xentop -bfi 1 | grep "${VM}" 1>/dev/null 2>&1 ; then
                    break
                fi
            done
        fi
    fi
    if xentop -bfi 1 | grep "${VM}" 1>/dev/null 2>&1 ; then
        qvm-kill "${VM}"
        for TIMEOUT in 5 3 1 1 1 1 1 1 1 1 1 1 1 1 ; do
            sleep "${TIMEOUT}"
            if ! xentop -bfi 1 | grep "${VM}" 1>/dev/null 2>&1 ; then
                break
            fi
        done
    fi
    if xentop -bfi 1 | grep "${VM}" 1>/dev/null 2>&1 ; then
        dbus-send --dest=org.awesomewm.awful --type=method_call --print-reply / org.awesomewm.awful.Remote.Eval string:"local naughty = require('naughty'); naughty.notify({ preset = naughty.config.presets.critical, title = '${VM}', text = 'Failed to shut down vm' })" 1>/dev/null 2>&1
    fi
}

reliable_start () {
    VM="${1}"
    for TIMEOUT in 5 5 5 5 5 ; do
        qvm-start --quiet --skip-if-running "${VM}"
        sleep "${TIMEOUT}"
        if xentop -bfi 1 | grep "${VM}" 1>/dev/null ; then
            break
        fi
        if ! xentop -bfi 1 | grep "${VM}" 1>/dev/null 2>&1 ; then
            dbus-send --dest=org.awesomewm.awful --type=method_call --print-reply / org.awesomewm.awful.Remote.Eval string:"local naughty = require('naughty'); naughty.notify({ preset = naughty.config.presets.critical, title = '${VM}', text = 'Completely unable to start vm' })" 1>/dev/null 2>&1
        fi
    done
}




if qvm-device block list | grep "core-net" | grep -e "dvm-archive" -e "core-decrypt" 1>/dev/null 2>&1 ; then
    VM_NET="1"
fi
if qvm-device block list | grep "core-usb" | grep -e "dvm-archive" -e "core-decrypt" 1>/dev/null 2>&1 ; then
    VM_USB="1"
fi

reliable_shutdown "dvm-archive"
reliable_shutdown "core-decrypt"

if ! [ -z "${VM_NET}" ] ; then
    reliable_shutdown "core-net"
fi
if ! [ -z "${VM_USB}" ] ; then
    reliable_shutdown "core-usb"
fi

dbus-send --dest=org.awesomewm.awful --type=method_call --print-reply / org.awesomewm.awful.Remote.Eval string:"disconnect_done()" 1>/dev/null 2>&1

reliable_start "core-usb"
reliable_start "core-net"
if ! [ -z "${VM_NET}" ] ; then
    qvm-kill "fw-net"
    qvm-start "fw-net"
fi
