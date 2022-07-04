local gears = require("gears")
local awful = require('awful')


local vm_groups = {
    { 'dvm.base', 'Templates' },
    { 'fw.base', 'Templates' },
    { 'debian%-', 'Templates' },
    { 'win%-base', 'Templates' },
    { '%-dvm', 'Templates' },
    { 'core%-', 'Service VMs' },
    { 'fw%-', 'Firewalls' },
    { 'my%-', 'Personal VMs' },
    { 'dvm%-', 'Disposable VMs' },
}

local vm_group_fallback = 'Other'

local vm_icons = {
    ['dvm-archive'] = '󰪶',
    ['dvm-chrome'] = '󰊯',
    ['dvm-chromium'] = '󰊯',
    ['dvm-chrome-tor'] = '󰊯',
    ['dvm-torbrowser'] = '󰈹',
    ['core-decrypt'] = '󰒒',
    ['core-net'] = '󰀂',
    ['core-iscsi'] = '󰪪',
    ['core-sound'] = '󰕾',
    ['core-usb'] = '󰘬',
    ['core-tor'] = '󰈸',
    ['core-vpn-ssh'] = '󰯅',
    ['core-update'] = '󰭽',
    ['core-rdp'] = '󰹘',
    ['core-xorg'] = '󰍹',
    ['core-keys'] = '󰌇',
    ['core-print'] = '󰐪',
    ['core-getmail'] = '󰇰',
    ['core-msmtp'] = '󰒊',
    ['fw-base'] = '󰘙',
    ['fw-dvm'] = '󰘙',
    ['fw-net'] = '󰳌',
    ['fw-tor'] = '󰳌',
    ['fw-vpn'] = '󰳌',
    ['debian-core'] = '󰣚',
    ['debian-core1'] = '󰣚',
    ['debian-full'] = '󰣚',
    ['debian-full1'] = '󰣚',
    ['core-dvm'] = '󰘙',
    ['dvm-base'] = '󰘙',
    ['my-devel'] = '󰙴',
    ['my-games'] = '󰺷',
    ['my-liferea'] = '󰑫',
    ['my-personal'] = '󰠥',
    ['my-vault'] = '󰒒',
}

vm_icon_fallback = '󰆧'


local vm_commands = {
    { '[fw][wi][%-n]', false, '.*', true, 'Terminal',
      function(vm) awful.util.spawn('qvm-run --quiet --no-gui --user root --service ' .. vm .. ' liteqube.Xterm') end }, -- terminal
    { 'win%-', false, 'off', true, 'Start',
      function(vm) awful.util.spawn('qvm-start --quiet --skip-if-running ' .. vm) end }, -- start
    { 'win%-', true, 'off', true, 'RDP',
      function(vm) awful.util.spawn(config.home .. 'scripts/start-win.sh rdp ' .. vm) end }, -- rdp
    { 'win%-', true, '.*', true, 'Console',
      function(vm) awful.util.spawn(config.home .. 'scripts/start-win.sh console ' .. vm) end }, -- console
    { '[fw][wi][%-n]', false, 'running', true, 'Run...',
      function(vm) entry({ text = 'Run command in <b>' .. vm .. '</b>', first_button = 'Run', command = function(text) awful.util.spawn('qrexec-client -d ' .. vm .. ' -e user:"' .. text .. '"') end }) end }, -- execute command
    { '.*', true, 'running', true, 'Poweroff',
      function(vm) confirm({ text = 'Shutdown <b>' .. vm .. '</b>?', command = function() awful.util.spawn('qvm-shutdown --quiet ' .. vm) end }) end }, -- shutdown
    { 'core%-', true, 'running', true, 'Restart',
      function(vm) confirm({ text = 'Restart <b>' .. vm .. '</b>?', command = function() awful.util.spawn(config.home .. "scripts/vm-restart.sh " .. vm .. " &") end }) end }, -- restart
    { 'fw%-', true, 'running', true, 'Restart',
      function(vm) confirm({ text = 'Restart <b>' .. vm .. '</b>?', command = function() awful.util.spawn(config.home .. 'scripts/vm-restart.sh ' .. vm .. ' &') end }) end }, -- restart
    { 'debian%-', true, '.*', true, 'Revert root',
      function(vm) confirm({ text = 'Revert root volume of <b>' .. vm .. '</b>?', command = function() awful.util.spawn("qvm-volume revert " .. vm .. ':root') end }) end }, -- revert
    { 'win%-base', true, '.*', true, 'Revert root',
      function(vm) confirm({ text = 'Revert root volume of <b>' .. vm .. '</b>?', command = function() awful.util.spawn('qvm-volume revert ' .. vm .. ':root') end }) end }, -- revert
    { '.*', true, '.*', true, 'Settings',
      function(vm) awful.util.spawn('qubes-vm-settings ' .. vm) end }, -- options
}


-- show vms menu
function vms_menu2()
    local sections = {
        ['Running'] = { color = 'red', vms = {} },
        ['Personal VMs'] = { color = 'green', replace = 'my%-', vms = {} },
        ['Disposable VMs'] = { color = 'orange', replace = 'dvm%-', vms = {} },
        ['Service VMs'] = { color = 'grey', replace = 'core%-', vms = {} },
        ['Firewalls'] = { color = 'grey', replace = 'fw%-', vms = {} },
        ['Templates'] = { color = 'black', vms = {} },
        ['Other'] = { color = 'red', vms = {} },
    }

    for _,vm in pairs(vms_list()) do
        local group = vm_group_fallback
        if vm.state == 'running' then
            group = 'Running'
        else
            for _,rule in pairs(vm_groups) do
                if string.find(vm.name, rule[1]) then
                    group = rule[2]
                    break
                end
            end
        end
        local index = length(sections[group].vms) + 1
        for i, list_vm in ipairs(sections[group].vms) do
            if vm.name < list_vm.name then
                index = i
                break
            end
        end
        table.insert(sections[group].vms, index, vm)
    end

    local function vm_actions_menu(vm)
        local structure = {}
        for _, action in ipairs(vm_commands) do
            if (string.find(vm, action[1]) ~= nil) == action[2] and (string.find(vm_state(vm), action[3]) ~= nil) == action[4] then
                table.insert(structure, { label = action[5], action = function() action[6](vm) end })
            end
        end
        local menu = loadsafe('mod-menu-small')
        menu.init({ title = vm })
        local timer = gears.timer({ timeout = 0.1 })
        timer:connect_signal("timeout", function()
            timer:stop()
            menu.show(structure)
        end)
        timer:start()
    end

    local function add_section(name, menu_structure)
        if length(sections[name].vms) > 0 then
            local section = {}
            for _,vm in ipairs(sections[name].vms) do
                local label = vm.name
                if sections[name].replace then
                    label = label:gsub(sections[name].replace, '', 1)
                end
                local icon = vm_icon_fallback
                if vm_icons[vm.name] ~= nil then
                    icon = vm_icons[vm.name]
                end
                table.insert(section, { label = label, icon = icon, action = function() vm_actions_menu(vm.name) end })
            end
            section.name = name
            section.color = sections[name].color
            table.insert(menu_structure, section)
        end
    end

    local menu_structure = {}
    add_section('Running', menu_structure)
    add_section('Personal VMs', menu_structure)
    add_section('Disposable VMs', menu_structure)
    add_section('Service VMs', menu_structure)
    add_section('Firewalls', menu_structure)
    add_section('Templates', menu_structure)
    add_section('Other', menu_structure)

    local menu = loadsafe('mod-menu-big')
    menu.init({title = 'Virtual Machines'})
    menu.show(menu_structure)
end
