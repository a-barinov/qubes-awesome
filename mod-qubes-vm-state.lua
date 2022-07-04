local gears = require("gears")
local awful = require('awful')
local wibox = require('wibox')
local beautiful = require('beautiful')
local naughty = require('naughty')


widgets.vmstate = {
    -- plugin description
    name = "VM State",
    enabled = false,

    -- private interface
    vms = {},
    callbacks = {},

    -- run on startup
    startup = function()
        widgets.vmstate.load_list()
    end,

    -- update widget based on internal state
    update_widget = function()
        widgets.vmstate.alttext = ''
        for _, vm in ipairs(widgets.vmstate.vms) do
            if vm.state == 'starting' or vm.state == 'stopping' then
                if widgets.vmstate.alttext ~= '' then
                    widgets.vmstate.alttext = widgets.vmstate.alttext .. '\n'
                end
                widgets.vmstate.alttext = vm.name .. ': ' .. vm.state
            end
        end
        widgets.vmstate.enabled = (widgets.vmstate.alttext ~= '')
        widgets.indicator.set_state(widgets.vmstate)
    end,

    -- load vms list
    startup = function()
        if os.rename('/var/lib/qubes/qubes.xml', '/var/lib/qubes/qubes.xml') ~= true then
            return
        end

        local looking_for = 'color'
        local color

        widgets.vmstate.vms = {}
        for line in io.lines('/var/lib/qubes/qubes.xml') do
            if looking_for == 'color' and line:find('<property name="label">', 0, true) then
                local _,pos_start = line:find('<property name="label">', 0, true)
                local pos_end,_ = line:find('</property>', 0, true)
                color = line:sub(pos_start+1, pos_end-1)
                looking_for = 'name'
            elseif looking_for == 'name' and line:find('<property name="name">', 0, true) then
                local _,pos_start = line:find('<property name="name">', 0, true)
                local pos_end,_ = line:find('</property>', 0, true)
                local name = line:sub(pos_start+1, pos_end-1)
                local state = os.rename('/run/qubes/qrexec.' .. name, '/run/qubes/qrexec.' .. name) and 'running' or 'off'
                table.insert(widgets.vmstate.vms, { name = name, color = color, state = state })
                looking_for = 'color'
            elseif looking_for == 'name' and line:find('<feature name="gui-videoram-min">', 0, true) then
                looking_for = 'color'
            end
        end
    end,

    -- callback for external python script
    change = function(state, vm, color)
        local vm_record = nil
        for _, qube in ipairs(widgets.vmstate.vms) do
            if qube.name == vm then
                vm_record = qube
                break
            end
        end
        if vm_record == nil then
            vm_record = { name = vm, color = color or 'black', state = state }
            table.insert(widgets.vmstate.vms, vm_record)
        end

        if widgets.vmstate.callbacks["*"] ~= nil then
            for _, callback in pairs(widgets.vmstate.callbacks["*"]) do
                callback(vm, state)
            end
        end
        if widgets.vmstate.callbacks[vm] ~= nil then
            for _, callback in pairs(widgets.vmstate.callbacks[vm]) do
                callback(state)
            end
        end

        if state == 'domain-pre-start' then
            vm_record.state = 'starting'
            naughty.notify({ title = 'Qubes', text = 'Starting vm <b>' .. vm .. '</b>' })
        elseif state == 'domain-start' then
            vm_record.state = 'running'
            naughty.notify({ title = 'Qubes', text = 'Started vm <b>' .. vm .. '</b>' })
        elseif state == 'domain-start-failed' then
            vm_record.state = 'off'
            naughty.notify({ title = 'Qubes', text = 'Failed to start vm <b>' .. vm .. '</b>', preset = naughty.config.presets.critical })
        elseif state == 'domain-pre-shutdown' then
            vm_record.state = 'stopping'
            naughty.notify({ title = 'Qubes', text = 'Terminating vm <b>' .. vm .. '</b>' })
            local timer = gears.timer({ timeout = 1 })
            local count = 0
            timer:connect_signal('timeout', function()
                count = count + 1
                if count == 60 then
                    timer:stop()
                    naughty.notify({ title = 'Qubes', text = 'Failed to stop vm <b>' .. vm .. '</b>', preset = naughty.config.presets.critical })
                    vm_record.state = 'running'
                    widgets.vmstate.update_widget()
                end
                if vm_state(vm) ~= 'stopping' then
                    timer:stop()
                end
            end)
            timer:start()
        elseif state == "domain-shutdown" then
            vm_record.state = 'off'
            naughty.notify({ title = "Qubes", text = "Terminated vm <b>" .. vm .. "</b>" })
            if widgets.vmstate.timer ~= nil then
                widgets.vmstate.timer:stop()
            end
        else
            naughty.notify({ title = "Qubes", text = "Unknown srate <b>" .. state .. "</b> of vm <b>" .. vm .. "</b>", preset = naughty.config.presets.critical })
            return
        end

        widgets.vmstate.update_widget()
    end,
}
widgets.indicator.create(widgets.vmstate, "󰆧")


-- register callback for vm state changes
function vm_state_change(vm, callback)
    if widgets.vmstate.callbacks[vm] == nil then
        widgets.vmstate.callbacks[vm] = { callback }
    else
        table.insert(widgets.vmstate.callbacks[vm], callback)
    end
end


-- get vm list
function vms_list()
    widgets.vmstate.startup()
    list = {}
    for _, vm in ipairs(widgets.vmstate.vms) do
        table.insert(list, vm)
    end
    return list
end


-- get vm status
vm_state = function(name)
    for _,vm in ipairs(widgets.vmstate.vms) do
        if vm.name == name then
            return vm.state
        end
    end
    return nil
end
