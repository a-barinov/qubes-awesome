local awful = require("awful")


-- Initial state
widgets.language = {
    -- user-defined configuration
    languages = { "us", "ru" },

    -- plugin description
    name = "Language",
    enabled = false,
}
widgets.indicator.create(widgets.language, "")


-- Cycle through languages
next_language = function()
    local layout = read_command("setxkbmap -query | grep layout | cut -c13-14"):sub(1, 2)
    if layout == widgets.language.languages[1] then
        set_language(widgets.language.languages[2])
        widgets.language.enabled = true
    else
        set_language(widgets.language.languages[1])
        widgets.language.enabled = false
    end
    widgets.indicator.set_state(widgets.language)
end


set_language = function(lang)
    read_command("setxkbmap " .. lang)
    if config.id == "L380" then
        read_command("xmodmap -e 'keycode 66 = XF86TouchpadOn' -e 'clear Lock'")
    end
    for _,vm in pairs(vms_list()) do
        if vm.state == 'running' then
            if vm.name == "core-xorg" or vm.name == "core-rdp" or (vm.name:sub(1, 5) ~= "core-" and vm.name:sub(1, 6) ~= "regus-" and vm.name:sub(1, 3) ~= "fw-") then
                --TODO replace with service calls
                awful.util.spawn("qrexec-client -d " .. vm.name .. " user:'setxkbmap " .. lang .. "'")
                if config.id == "L380" then
                    awful.util.spawn("qrexec-client -d " .. vm.name .. " user:'xmodmap -e \"keycode 66 = XF86TouchpadOn\" -e \"clear Lock\"'")
                end
            end
        end
    end
end


-- Set language back to original if xscreensaver deployed
widgets.language.update = function()
    awful.util.spawn(config.home .. "scripts/screensaver.sh")
end


-- Initialize the widget
widgets.indicator.set_text(widgets.language, string.upper(widgets.language.languages[2]))
set_language(widgets.language.languages[1])
