local gears = require("gears")
local awful = require("awful")
local math = require("math")


-- Initial state
widgets.brightness = { name = "Brightness", enabled = false }
widgets.indicator.create(widgets.brightness, "󰃠")


-- Get brightness level
widgets.brightness.read = function()
    local file = io.open("/sys/class/backlight/intel_backlight/max_brightness")
    if not file then return end
    local step = math.floor(tonumber(file:read())/10)
    file:close()
    local file = io.open("/sys/class/backlight/intel_backlight/brightness")
    if not file then return end
    local level = tonumber(file:read())/step
    file:close()
    return { level = level, step = step }
end


-- Regular updates
widgets.brightness.update = function(level)
    local cur = level or widgets.brightness.read()
    if cur.level == widgets.brightness.current then return end
    widgets.brightness.enabled = true
    widgets.indicator.set_text(widgets.brightness, tostring(math.floor(cur.level*10)))
    if not widgets.brightness.timer then
        widgets.brightness.timer = gears.timer({ timeout = 30 })
        widgets.brightness.timer:connect_signal("timeout", function()
            widgets.brightness.timer:stop()
            widgets.brightness.enabled = false
            widgets.indicator.set_state(widgets.brightness)
        end)
    end
    if widgets.brightness.timer.started then
        widgets.brightness.timer:stop()
    end
    widgets.brightness.timer:start()
    widgets.indicator.set_state(widgets.brightness)
    widgets.brightness.current = cur.level
end


-- Brightness functions for keybindings
brightness = function(direction)
    local cur = widgets.brightness.read()
    local level_tail = cur.level - math.floor(cur.level)
    local level_head = cur.level - level_tail
    local target = cur.level
    if direction == "UP" and level_head < 10 then
        target = level_head + 1
    end
    if direction == "DOWN" and level_head > 0 then
        if level_tail == 0 then
            if level_head > 1 then
                target = level_head - 1
            end
        else
            target = level_head
        end
    end
    widgets.brightness.update({ level = target, step = cur.step })
    awful.util.spawn("sudo bash -c \"echo " .. math.floor(target*cur.step) .. " > /sys/class/backlight/intel_backlight/brightness\"")
end


-- Avoid showing up on first update
widgets.brightness.current = widgets.brightness.read().level
