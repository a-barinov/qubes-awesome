local gears = require("gears")
local awful = require("awful")


-- Pseudo-widget 1
widgets.qubesmenu = {
    enabled = false,
    priority = 0,
    menu_category = "qubes",
    menu = {
        [1] = {
            glyph = '󰧛',
            label = 'Terminal',
            first_action = 'sakura -t Dom0',
            second_action = 'sakura -t Dom0 -e sudo bash',
        },
        [2] = {
            glyph = '󰆧',
            label = function()
                local count = 0
                for _,vm in ipairs(widgets.vmstate.vms) do
                    if vm.state == 'running' then
                        count = count + 1
                    end
                end
                return 'Running: ' .. tostring(count)
            end,
            first_action = function() local timer = gears.timer({ timeout = 0.1 }); timer:connect_signal("timeout", function() timer:stop(); vms_menu2({ }) end); timer:start() end,
            second_action = 'qubes-qube-manager',
        },
    },
}


-- Pseudo-widget 2
widgets.systemmenu = {
    enabled = false,
    priority = 0,
    menu_category = "system",
    menu = {
        [1] = {
            glyph = '󰐥',
            label = 'Power off',
            first_action = function() confirm({text = "<b>POWER OFF</b> system?", command = function() awful.util.spawn("systemctl poweroff") end}) end,
            second_action = function()
                local menu_structure = {
                    { label = 'Power Off', action = function() confirm({text = "<b>POWER OFF</b> system?", command = function() awful.util.spawn("systemctl poweroff") end}) end },
                    { label = 'Restart', action = function() confirm({text = "<b>RESTART</b> system?", command = function() awful.util.spawn("systemctl reboot") end}) end },
                }
                if config.id == 'L380' or config.id == 'OneMix4' then
                    table.insert(menu_structure, { label = 'Suspend', action = function() confirm({ text = '<b>SUSPEND</b> system?', command =
                    function() awful.util.spawn('xscreensaver-command -lock'); awful.util.spawn('systemctl suspend') end }) end })
                end
                local menu = loadsafe('mod-menu-small')
                menu.init({ title = 'System' })
                local timer = gears.timer({ timeout = 0.1 })
                timer:connect_signal("timeout", function()
                    timer:stop()
                    menu.show(menu_structure)
                end)
                timer:start()
            end,
        },
    },
}
