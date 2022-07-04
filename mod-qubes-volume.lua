local awful = require("awful")
local gears = require("gears")


-- Initial state
widgets.volume = {
    name = 'Volume',
    enabled = false,

    -- private interface
    volume = -1,
    muted = -1,

    -- run on startup
    startup = function()
        awful.util.spawn('qvm-run --quiet --user user --autostart --no-gui --service core-sound liteqube.SoundVolume+NOOP')
    end,

    -- update widget based on internal state
    widget_update = function()
        if widgets.volume.muted == true then
            widgets.volume.enabled = true
            widgets.indicator.set_text(widgets.volume, '')
            widgets.indicator.set_icon(widgets.volume, '󰝛')
        else
            widgets.volume.enabled = true
            widgets.indicator.set_text(widgets.volume, widgets.volume.volume)
            widgets.indicator.set_icon(widgets.volume, '󰝚')
        end
        widgets.indicator.set_state(widgets.volume)
    end,
}
widgets.indicator.create(widgets.volume, "󰝚")


-- Callback for external script
sound_state = function(state)
    local muted = state:sub(1, 1) == 'M'
    local volume = state:sub(2, 3)
    if muted == false and (volume ~= widgets.volume.volume or muted ~= widgets.volume.muted) and widgets.volume.muted ~= -1 then
        if not widgets.volume.timer then
            widgets.volume.timer = gears.timer({ timeout = 30 })
            widgets.volume.timer:connect_signal("timeout", function()
                widgets.volume.timer:stop()
                widgets.volume.enabled = widgets.volume.muted
                widgets.indicator.set_state(widgets.volume)
            end)
        end
        if widgets.volume.timer.started then
            widgets.volume.timer:stop()
        end
        widgets.volume.timer:start()
    end
    if muted ~= widgets.volume.muted or volume ~= widgets.volume.volume then
        if widgets.volume.muted == -1 then
            widgets.volume.muted = muted
            widgets.volume.volume = volume
        else
            widgets.volume.muted = muted
            widgets.volume.volume = volume
        end
        widgets.volume.widget_update()
    end
end


-- Volume control functions for keybindings
volume = function(action)
    if action == "MUTE" then
        if widgets.volume.muted == true then
            awful.util.spawn('qvm-run --quiet --user user --autostart --no-gui --service core-sound liteqube.SoundVolume+UNMUTE')
        else
            awful.util.spawn('qvm-run --quiet --user user --autostart --no-gui --service core-sound liteqube.SoundVolume+MUTE')
        end
    elseif action == "UP" then
        awful.util.spawn('qvm-run --quiet --user user --autostart --no-gui --service core-sound liteqube.SoundVolume+UP')
    elseif action == "DOWN" then
        awful.util.spawn('qvm-run --quiet --user user --autostart --no-gui --service core-sound liteqube.SoundVolume+DOWN')
    end
end
