local awful = require("awful")
local math = require("math")


widgets.battery = {
    -- plugin description
    name = "Battery",
    enabled = false,

    -- private interface
    current = {},

    -- run on startup
    startup = function()
        widgets.battery.update()
    end,

    -- update every minute
    update = function()
        local cur = widgets.battery.read()
        local percent = math.max(0, math.min(math.ceil(100*cur.level/widgets.battery.capacity), 100))
        if cur.charging and percent >= 97 then
            widgets.battery.enabled = false
        else
            widgets.battery.enabled = true
            widgets.indicator.set_text(widgets.battery, tostring(percent))
            if cur.charging then
                if cur.charging == widgets.battery.current.charging and cur.level ~= widgets.battery.current.level then
                    local left = math.floor((widgets.battery.capacity - cur.level)/(cur.level - widgets.battery.current.level)) or 0
                    widgets.battery.alttext = "Time until full: " .. math.floor(left/60) .. ":" .. string.format('%02d', left%60)
                else
                    widgets.battery.alttext = nil
                end
                if percent>66 then
                    widgets.indicator.set_icon(widgets.battery, "󱄇")
                elseif percent>33 then
                    widgets.indicator.set_icon(widgets.battery, "󱄇")
                elseif percent>33 then
                    widgets.indicator.set_icon(widgets.battery, "󱄇")
                end
            else
                if cur.charging == widgets.battery.current.charging and cur.level ~= widgets.battery.current.level then
                    local left = math.floor(cur.level/(widgets.battery.current.level - cur.level)) or 0
                    widgets.battery.alttext = "Time until empty: " .. math.floor(left/60) .. ":" .. string.format('%02d', left%60)
                else
                    widgets.battery.alttext = nil
                end
                if percent>66 then
                    widgets.indicator.set_icon(widgets.battery, "󱊣")
                elseif percent>33 then
                    widgets.indicator.set_icon(widgets.battery, "󱊢")
                elseif percent>33 then
                    widgets.indicator.set_icon(widgets.battery, "󱊡")
                end
            end
        end
        widgets.indicator.set_state(widgets.battery)
        widgets.battery.current = cur
    end,

    -- get battery level
    read = function()
        if not widgets.battery.capacity then
            widgets.battery.capacity = tonumber(read_file("/sys/class/power_supply/BAT0/energy_full"))
        end
        return {
            level = tonumber(read_file("/sys/class/power_supply/BAT0/energy_now")),
            charging = read_file("/sys/class/power_supply/BAT0/status") ~= "Discharging",
        }
    end,
}
widgets.indicator.create(widgets.battery, "󱊣")
