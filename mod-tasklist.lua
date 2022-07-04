local awful = require("awful")
local wibox = require("wibox")
local qubes = require("qubes")
local beautiful = require("beautiful")
local common = require("awful.widget.common")


-- Tasklist
widgets.tasklist.widget = awful.widget.tasklist(
    1,
    awful.widget.tasklist.filter.allscreen,
    awful.util.table.join(awful.button({ }, 1, function (c) client.focus = c; c:raise() end), nil),
    nil,
    function(w, buttons, label, data, object)
        local new_label = function(c, args)
            local text, bg, bg_image, icon = label(c, args)
            if client.focus == c then
                bg = awful.client.property.get(c, "qubes_label_color_focus")
            else
                bg = nil
            end
            icon = nil
            return text:gsub("%[.-%] ", ""), bg, bg_image, icon
        end
        common.list_update(w, buttons, new_label, data, object)
        w:set_max_widget_size(beautiful.tasklist_width)
    end
)
--widgets.tasklist.layout = wibox.layout.align.horizontal()
--widgets.tasklist.layout:set_left(widgets.tasklist.widget)
widgets.statusbar.layouts.main:set_middle(widgets.tasklist.widget)


-- Change statusbar color based on client's cube
client.connect_signal("focus", function(c)
    if awful.client.property.get(c, "qubes_label_color_unfocus") == nil then
        qubes.manage(c)
    end
    if awful.client.floating.get(c) then
        c.border_color = awful.client.property.get(c, "qubes_label_color_focus") or beautiful.bg_focus
        awful.titlebar(c):set_bg(c.border_color)
    end
    widgets.statusbar.widget:set_bg(awful.client.property.get(c, "qubes_label_color_unfocus"))
    c:raise()
end)

client.connect_signal("unfocus", function(c)
    if awful.client.floating.get(c) then
        c.border_color = awful.client.property.get(c, "qubes_label_color_unfocus")
        awful.titlebar(c):set_bg(c.border_color)
    end
    widgets.statusbar.widget:set_bg(beautiful.bg_normal)
end)
