local awful = require("awful")

--TODO setting to disable obfs4

widgets.tor = {
    -- plugin description
    name = "Tor",
    enabled = false,
    priority = 1,
    menu_category = "connection",
    menu = {
        [1] = {
            glyph = function()
                if widgets.tor.state.enabled == true and widgets.tor.state.state == 100 then
                    return '󰞀'
                else
                    return '󰫝'
                end
            end,
            label = function()
                if widgets.tor.state.enabled == true and widgets.tor.state.state == 100 then
                    return 'Tor: On'
                else
                    return 'Tor: Off'
                end
            end,
            first_action = function()
                awful.spawn('qvm-run --no-autostart --no-gui --user root --service core-tor liteqube.TorRestart')
            end,
        },
    },

    -- menu templates
    obfs_on = { "Obfs4 On", "qvm-run --no-autostart --no-gui --user root --service core-tor liteqube.TorToggleObfs4", "/usr/share/icons/Adwaita/16x16/apps/preferences-system-privacy.png" },
    obfs_off = { "Obfs4 Off", "qvm-run --no-autostart --no-gui --user root --service core-tor liteqube.TorToggleObfs4", "/usr/share/icons/Adwaita/16x16/apps/preferences-system-privacy.png" },
    restart = { "Restart Tor", 'qvm-run --no-autostart --no-gui --user root --service core-tor liteqube.TorRestart', "/usr/share/icons/Adwaita/16x16/actions/view-refresh.png" },

    -- private interface
    state = { enabled = nil, state = nil, obfs = nil },

    -- run on startup
    startup = function()
        awful.util.spawn('qvm-run --no-autostart --no-gui --user root --service core-tor liteqube.TorMonitor')
        if vm_state("core-tor") == 'running' then
            widgets.tor.state.enabled = true
        end
        vm_state_change("core-tor", function(state)
            if state == "domain-start" then
                widgets.tor.state.enabled = true
                widgets.tor.state.state = 0
                widgets.tor.state.obfs4 = nil
                local ap = wifi_ap()
            else
                widgets.tor.state.enabled = false
                widgets.tor.state.state = 0
                widgets.tor.state.obfs4 = nil
            end
            widgets.tor.widget_update()
        end)
    end,

    -- update widget based on internal state
    widget_update = function()
        --widgets.tor.menu = {}
        if wifi_ap() == nil then
            if widgets.tor.state.enabled == true then
                widgets.indicator.set_text(widgets.tor, "On")
                widgets.tor.enabled = true
            else
                widgets.tor.enabled = false
            end
        else
            widgets.tor.enabled = true
            --if widgets.tor.state.obfs == true then
            --    widgets.tor.menu = { [1] = widgets.tor.restart, [2] = widgets.tor.obfs_off }
            --elseif widgets.tor.state.obfs == false then
            --else
            --    widgets.tor.menu = { [1] = widgets.tor.restart, [2] = widgets.tor.obfs_on }
            --end
            if widgets.tor.state.enabled == true then
                if widgets.tor.state.state == 100 then
                    widgets.tor.enabled = false
                else
                    widgets.indicator.set_text(widgets.tor, tostring(widgets.tor.state.state))
                end
            else
                --widgets.tor.menu = {}
                widgets.indicator.set_text(widgets.tor, "Off")
            end
        end
        widgets.indicator.set_state(widgets.tor)
    end,
}
widgets.indicator.create(widgets.tor, "󰒙")


-- Callback for external script
tor_state = function(state)
    local level = tonumber(state)
    if level == 999 then
        widgets.tor.state.state = 0
    elseif level == 200 then
        widgets.tor.state.enabled = true
        widgets.tor.state.state = 0
    elseif level <= 100 and level >= 0 then
        widgets.tor.state.enabled = true
        widgets.tor.state.state = level
    elseif level == 500 then
        widgets.tor.state.obfs = false
    elseif level == 501 then
        widgets.tor.state.obfs = true
    end
    widgets.tor.widget_update()
end


-- Allow anyone to check tor state
tor_running = function()
    return (widgets.tor.state.enabled == true and widgets.tor.state.state == 100)
end


-- Refresh widget
tor_widget_update = function()
    widgets.tor.widget_update()
end
