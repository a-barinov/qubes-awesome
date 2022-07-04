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

reliable_shutdown "$1"
reliable_start "$1"
