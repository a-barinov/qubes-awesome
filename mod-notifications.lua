local naughty = require("naughty")
local wibox = require("wibox")
local beautiful = require("beautiful")


notifications_history = ""

naughty.config.notify_callback = function(args)
    local notification = ""
    if args.title then
        notification = "<b>" .. tostring(args.title) .. "</b>  <small>(" .. os.date("%R") .. ")</small>\n"
    else
        notification = "<small>(" .. os.date("%R") .. ")</small>\n"
    end
    notification = notification .. tostring(args.text) .. "<small><small>\n\n</small></small>"
    if args.preset == naughty.config.presets.critical then
        notification = '<span foreground="#FFAAAA">' .. notification .. "</span>"
    end
    notifications_history = notification .. notifications_history
    if notifications_history_widget then
        notifications_history_textbox:set_markup(notifications_history)
    end
    return args
end


notifications_history_widget = nil
notifications_history_textbox = nil

show_notifications = function()
    if notifications_history_widget then
        notifications_history_widget.visible = not notifications_history_widget.visible
    else
        local layout = wibox.layout.align.vertical()
        notifications_history_textbox = wibox.widget.textbox(notifications_history, false)
        notifications_history_textbox:set_valign("top")
        layout:set_first(notifications_history_textbox)
        local margins = wibox.container.margin()
        margins:set_widget(layout)
        margins:set_margins(4)
        notifications_history_widget = wibox({ type = "normal", ontop = true, visible = true, screen = 1 })
        notifications_history_widget:set_widget(margins)
    end
    local area = screen[1].workarea
    notifications_history_widget.width = area.width/6
    notifications_history_widget.height = area.height
    notifications_history_widget.x = area.x + area.width - notifications_history_widget.width
    notifications_history_widget.y = area.y
end
