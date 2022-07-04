local awful = require('awful')
local math = require("math")


widgets.thermal = {
    -- plugin configuration
    threshold = 60,

    -- plugin description
    name = 'Thermal',
    enabled = false,

    -- run on startup
    startup = function()
        widgets.thermal.update()
    end,

    -- update every minute
    update = function()
        local temperature = -1
        for i = 0,10 do
            local zone_temp = read_file('/sys/class/thermal/thermal_zone' .. tostring(i) .. '/temp')
            if zone_temp ~= nil then
                zone_temp = math.floor(tonumber(zone_temp)/1000)
            else
                break
            end
            temperature = math.max(temperature, zone_temp)
        end
        if temperature >= widgets.thermal.threshold then
            widgets.thermal.enabled = true
            widgets.indicator.set_text(widgets.thermal, tostring(temperature) .. '°C')
        else
            widgets.thermal.enabled = false
        end
        widgets.indicator.set_state(widgets.thermal)
    end,
}
widgets.indicator.create(widgets.thermal, '󰔐')
