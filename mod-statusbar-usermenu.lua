local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")


-- Launcher
widgets.menu.launcher = wibox.widget.textbox()
widgets.menu.launcher:set_font(beautiful.font)
widgets.menu.launcher:set_text("≡")
widgets.menu.holder = wibox.container.margin(widgets.menu.launcher, 4, 4, 1, 2)
widgets.menu.holder:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then
        menu_user()
    end
end)
widgets.statusbar.layouts.left:add(widgets.menu.holder)
