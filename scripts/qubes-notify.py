#!/usr/bin/python3

import asyncio
import pyinotify
import libvirt
import time
import os
import qubesadmin
import qubesadmin.events


# Awesome communication tool for all the threads to use
def awesome(command):
    os.system("dbus-send --dest=org.awesomewm.awful --type=method_call --print-reply / org.awesomewm.awful.Remote.Eval string:\"%s\" >/dev/null 2>&1 &"%command)


# Main look
loop = asyncio.get_event_loop()


# Clipboard monitor
PATH = '/var/run/qubes'
NAME = 'qubes-clipboard.bin.source'

def clipboard_events(event):
    if event.name == NAME and event.maskname == 'IN_CLOSE_WRITE':
        with open(PATH + '/' + NAME, 'r') as source:
            vm = source.readline().strip('\n')
        if vm == "":
            awesome("require('naughty').notify({ title = 'Clipboard', text = 'Pasted text into VM' })")
        else:
            awesome("require('naughty').notify({ title = 'Clipboard', text = 'Copied text from <b>%s</b>' })"%vm)

wm = pyinotify.WatchManager()
notifier = pyinotify.AsyncioNotifier(wm, loop, default_proc_fun = clipboard_events)
wm.add_watch(PATH, pyinotify.IN_CLOSE_WRITE)


# VM state monitor
def vm_events(vm, event, **kwargs):
    awesome("widgets.vmstate.change('%s', '%s')"%(event, vm.name))

events = ('domain-pre-start', 'domain-start', 'domain-start-failed', 'domain-pre-shutdown', 'domain-shutdown')
dispatcher = qubesadmin.events.EventsDispatcher(qubesadmin.Qubes())
for event in events:
    dispatcher.add_handler(event, vm_events)
tasks = [  asyncio.ensure_future(dispatcher.listen_for_events()) ]


# xen stats polling
conn = libvirt.openReadOnly('xen')
mem_total = conn.getInfo()[1]
cpu_count = conn.getInfo()[2]
time_initial = time.time_ns()
usage_initial = 0
for domain_id in conn.listDomainsID():
    usage_initial += conn.lookupByID(domain_id).getCPUStats(True)[0]['cpu_time']

@asyncio.coroutine
def xen_reporter():
    yield from asyncio.sleep(60)

    time_final = time.time_ns()
    usage_final = 0
    for domain_id in conn.listDomainsID():
        usage_final += conn.lookupByID(domain_id).getCPUStats(True)[0]['cpu_time']

    global time_initial, usage_initial, mem_total, cpu_count
    cpu_time_passed = (time_final - time_initial)
    cpu_used = usage_final - usage_initial
    awesome('widgets.xen_cpu.set_status(%d, %d)'%(cpu_count, int(cpu_used/cpu_time_passed*100)))
    mem_free  = int(conn.getFreeMemory()/(1024*1024))
    awesome('widgets.xen_memory.set_status(%d, %d)'%(mem_total, mem_total - mem_free))

    time_initial = time_final
    usage_initial = usage_final
    asyncio.ensure_future(xen_reporter())
asyncio.ensure_future(xen_reporter())


# Run main loop
done, _ = loop.run_until_complete(asyncio.wait(tasks, return_when = asyncio.FIRST_EXCEPTION))
for d in done:
    d.result()


# Cleanup
conn.close()
for event in events:
    dispatcher.remove_handler(event, vm_events)
notifier.stop()
