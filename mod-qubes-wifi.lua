local awful = require("awful")
local naughty = require("naughty")


widgets.wifi = {
    -- plugin description
    name = "WiFi",
    enabled = false,
    priority = 0,
    menu_category = "connection",
    menu = {
        [1] = {
            glyph = function()
                if widgets.wifi.state.enabled == false or widgets.wifi.state.ap == '' then
                    return '󰖪'
                else
                    return '󰖩'
                end
            end,
            label = function()
                if widgets.wifi.state.enabled == false then
                    return 'WiFi Off'
                else
                    if widgets.wifi.state.ap == '' then
                        return 'WiFi On'
                    else
                        return widgets.wifi.state.ap
                    end
                end
            end,
            first_action = function()
                if widgets.wifi.state.enabled == false then
                    awful.spawn('qvm-run --no-autostart --no-gui --user root --service core-net liteqube.WifiSetState+on')
                else
                    awful.spawn('qvm-run --no-autostart --no-gui --user root --service core-net liteqube.Xterm+nmtui')
                end
            end,
            second_action = function()
                if widgets.wifi.state.enabled == true then
                    awful.spawn('qvm-run --no-autostart --no-gui --user root --service core-net liteqube.WifiSetState+off')
                else
                    awful.spawn('qvm-run --no-autostart --no-gui --user root --service core-net liteqube.WifiSetState+on')
                end
            end,
        },
    },

    -- private interface
    state = { ap = nil, state = nil, enabled = nil, signal = nil },

    -- run on startup
    startup = function()
        awful.util.spawn('qvm-run --autostart --no-gui --user root --service core-net liteqube.WifiMonitor')
        vm_state_change("core-net", function(state)
            if state ~= "domain-start" then
                widgets.wifi.state.enabled = false
            end
            widgets.wifi.widget_update()
        end)
    end,

    -- update widget
    widget_update = function()
        widgets.wifi.enabled = widgets.wifi.state.enabled
        if widgets.wifi.state.enabled then
            if widgets.wifi.state.ap == "" then
                widgets.indicator.set_text(widgets.wifi, "On")
                widgets.wifi.alttext = "Disconnected"
                widgets.indicator.set_icon(widgets.wifi, "󰢿")
            else
                if widgets.wifi.state.state ~= 100 then
                    widgets.indicator.set_text(widgets.wifi, "--")
                    if widgets.wifi.state.ap ~= nil then
                        widgets.wifi.alttext = "Connecting to <b>" .. widgets.wifi.state.ap .. "</b>"
                    end
                    widgets.indicator.set_icon(widgets.wifi, "󰢿")
                else
                    widgets.indicator.set_text(widgets.wifi, tostring(widgets.wifi.state.signal))
                    widgets.wifi.alttext = "Connected to <b>" .. widgets.wifi.state.ap .. "</b>"
                    if widgets.wifi.state.signal ~= nil then
                        if tonumber(widgets.wifi.state.signal) > 66 then
                            widgets.indicator.set_icon(widgets.wifi, "󰢾")
                        elseif tonumber(widgets.wifi.state.signal) > 33 then
                            widgets.indicator.set_icon(widgets.wifi, "󰢽")
                        else
                            widgets.indicator.set_icon(widgets.wifi, "󰢼")
                        end
                    end
                end
            end
        end
        widgets.indicator.set_state(widgets.wifi)
    end,
}
widgets.indicator.create(widgets.wifi, "󰢾")


-- Callback for external script
wifi_state = function(item, value)
    if item == "Signal" then
        widgets.wifi.state.signal = value
    elseif item == "AccessPoint" then
        if value ~= "" then
            naughty.notify({ title = "WiFi", text = "Connecting to <b>" .. value .. "</b>" })
        else
            if widgets.wifi.state.ap ~= nil then
                naughty.notify({ title = "WiFi", text = "Disconnected" })
            end
        end
        widgets.wifi.state.ap = value
        tor_widget_update()
    elseif item == "State" then
        widgets.wifi.state.state = value
        if value == 100 and widgets.wifi.state.ap ~= nil then
            naughty.notify({ title = "WiFi", text = "Connected to <b>" .. widgets.wifi.state.ap .. "</b>" })
        end
    elseif item == "Enabled" then
        widgets.wifi.state.enabled = (value == 1)
        tor_widget_update()
    end
    widgets.wifi.widget_update()
end


-- Get current AP
wifi_ap = function()
    if widgets.wifi.state.enabled and widgets.wifi.state.state == 100 then
        return widgets.wifi.state.ap
    else
        return nil
    end
end
