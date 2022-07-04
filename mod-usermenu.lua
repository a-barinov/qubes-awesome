local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")


local simplify = {
    ["Chromium Web Browser"] = "Chromium",
    ["mpv Media Player"] = "MPV",
    ["GNU Image Manipulation Program"] = "GIMP",
}

local commands = {
    ['Thunderbird'] = '/home/user/mail/thunderbird.sh',
}

local icons = {
    ['Sakura'] = config.icons .. 'gksu-root-terminal.svg',
    ['KeePassXC'] = config.icons .. 'keepassxc.svg',
}

local default_icon = '/home/user/.config/awesome/icons/apps/abiword.svg'


--- Create and show menu
menu_user = function()

    local menu_section = function(menu, name, color)
        for _,section in pairs(menu) do
            if section.name == name then
                return
            end
        end
        table.insert(menu, { name = name, color = color })
    end

    local add_to_section = function(menu, name, item)
        for _, section in pairs(menu) do
            if section.name == name then
                table.insert(section, item)
                return
            end
        end
    end

    local add_app = function(vm, filename, menu)
        file = io.open(filename)
        local name, icon, exec
        for line in file:lines() do
            if line:sub(1, 5) == "Name=" then
                name = line:sub(6 + vm:len() + 2)
                if simplify[name] then
                    name = simplify[name]
                end
            end
            if line:sub(1, 5) == "Exec=" then
                if commands[name] then
                    exec = 'qvm-run -q -a ' .. vm .. ' -- "/etc/qubes-rpc/liteqube.Run ' .. commands[name] .. '"'
                else
                    exec = line:sub(6)
                end
            end
        end
        file:close()
        if icons[name] then
            icon = icons[name]
        else
            icon = default_icon
        end
        return { label = name, icon = icon, action = exec }
    end

    local vm_menu = function(menu, name, label, color)
        menu_section(menu, label, color)
        dir = io.popen("ls /home/user/.local/share/qubes-appmenus/" .. name .. "/apps/")
        for filename in dir:lines() do
            if filename ~= name .. "-vm.directory" and filename ~= name .. "-qubes-vm-settings.desktop" then
                local item = add_app(name, "/home/user/.local/share/qubes-appmenus/" .. name .. "/apps/" .. filename, menu)
                if item.label ~= 'Qube Settings' and item.action ~= nil then
                    add_to_section(menu, label, item)
                end
            end
        end
        dir:close()
    end

    local add_to_section = function(menu, name, item)
        for _, section in pairs(menu) do
            if section.name == name then
                table.insert(section, item)
                return
            end
        end
    end

    local menu_structure = {}

    if vm_state('core-iscsi') == 'running' and vm_state('dvm-archive') == 'running' then
        menu_section(menu_structure, 'Dom0', 'black')
        add_to_section(menu_structure, 'Dom0', { label = 'Backup', icon = config.icons .. 'preferences-system-sharing.svg', action = 'qubes-backup' })
        add_to_section(menu_structure, 'Dom0', { label = 'Restore', icon = 'A', action = 'qubes-backup-restore' })
    end

    if vm_state('dvm-torbrowser') ~= nil then
        menu_section(menu_structure, 'Connected', 'orange')
        add_to_section(menu_structure, 'Connected', { label = 'Tor Browser', icon = config.icons .. 'firefox.svg', action = 'qvm-run -q -a dvm-torbrowser /home/user/torbrowser.sh' })
    end

    if vm_state("dvm-chrome-tor") ~= nil then
        menu_section(menu_structure, 'Connected', 'orange')
        add_to_section(menu_structure, 'Connected', { label = 'Chrome over Tor', icon = config.icons .. 'chromium-browser.svg', action = 'qvm-run -q -a dvm-chrome-tor /home/user/chromium.sh' })
    end

    if vm_state('dvm-chrome') ~= nil then
        menu_section(menu_structure, 'Connected', 'orange')
        add_to_section(menu_structure, 'Connected', { label = 'Chrome', icon = config.icons .. 'chromium-browser.svg', action = 'qvm-run -q -a dvm-chrome /home/user/chromium.sh' })
    end

    if vm_state("my-liferea") ~= nil then
        menu_section(menu_structure, 'Connected', 'orange')
        add_to_section(menu_structure, 'Connected', { label = 'Liferea', icon = config.icons .. 'internet-news-reader.svg', action = 'qvm-run -q -a my-liferea /etc/qubes-rpc/liteqube.Run /usr/bin/liferea' })
    end

    if vm_state("win-regus") ~= nil then
        menu_section(menu_structure, 'Connected', 'orange')
        add_to_section(menu_structure, 'Connected', { label = 'Regus', icon = config.icons .. 'gnome-remote-desktop.svg', action = config.home .. 'scripts/start-win.sh rdp win-regus' })
    end

    if vm_state('core-rdp') ~= nil then
        menu_section(menu_structure, 'Connected', 'orange')
        add_to_section(menu_structure, 'Connected', { label = 'Saturn', icon = config.icons .. 'gnome-remote-desktop.svg',
            action = function()
                if widgets.wifi.state.ap == '67' then
                    naughty.notify({ title = 'RDP', text = 'Connecting to <b>Home</b>' })
                    awful.util.spawn('/home/user/bin/lq-remote rdp "SATRUN:Alex Barinov@192.168.1.40"')
                elseif widgets.wifi.state.ap ~= '' then
                    naughty.notify({ title = 'RDP', text = 'Connecting <b>over SSH</b>' })
                    awful.util.spawn('/home/user/bin/lq-remote rdp-ssh "root@alte.myds.me:443" "SATRUN:Alex Barinov@192.168.1.40"')
                else
                    naughty.notify({ title = 'RDP', text = 'Cannot connect' })
                end
            end
        })
    end

    if vm_state('my-personal') ~= nil then
        vm_menu(menu_structure, 'my-personal', 'Personal', 'green')
        add_to_section(menu_structure, 'Personal', { label = "Rocks'n'Diamonds", icon = '', action = 'qvm-run -q -a my-personal rocksndiamonds' })
        add_to_section(menu_structure, 'Personal', { label = 'Wing IDE', icon = '', action = 'qvm-run -q -a my-personal wing8.1' })
    end

    if vm_state('my-photo') ~= nil then
        vm_menu(menu_structure, 'my-photo', 'Photo', 'green')
        add_to_section(menu_structure, 'Photo', { label = 'GIMP', icon = '', action = 'qvm-run -q -a my-photo /home/user/gimp/gimp.sh' })
        add_to_section(menu_structure, 'Photo', { label = 'Planetary Stacker', icon = '', action = 'qvm-run -q -a my-photo /home/user/pss/planetary_system_stacker' })
    end

    if vm_state('my-devel') ~= nil then
        vm_menu(menu_structure, 'my-devel', 'Development', 'green')
        add_to_section(menu_structure, 'Development', { label = 'Sublime', icon = config.icons .. 'sublime.svg', action = 'qvm-run -q -a my-devel /etc/qubes-rpc/liteqube.Run /home/user/opt/sublime_text/sublime_text' })
    end

    if vm_state('dvm-archive') == 'running' then
        vm_menu(menu_structure, 'dvm-archive', 'Archive', 'orange')
    end

    if vm_state('my-vault') ~= nil then
        vm_menu(menu_structure, 'my-vault', 'Vault', 'blue')
    end

    local menu = loadsafe('mod-menu-big')
    menu.init({title = 'Applications'})
    menu.show(menu_structure)
end
