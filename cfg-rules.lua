local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local qubes = require("qubes")


awful.rules.rules = {

    -- everyone starts as normal window
    { rule = { },
    properties = {
        focus = true,
        fullscreen = false,
        border_color = beautiful.bg_focus,
        maximized = false,
        maximized_vertical = false,
        maximized_horizontal = false,
        size_hints_honor = false,
        screen = awful.screen.preferred,
        keys = config.keys.client,
        buttons = config.buttons.client,
        raise = true,
        above = false,
        skip_taskbar = false,
    nil}},

    -- fight outliers
    { rule_any = {
        class = {
            "Evince",
            "libreoffice",
            "xfreerdp",
            "Gedit",
            "Nautilus",
            "Qubes-backup",
            'Qubes Restore VMs',
            "Qubes Settings",
            "Qubes-qube-manager",
            "mednafen",
            "personal:mednafen",
            "regus-base",
            "regus-main",
            "win-base",
            "win-regus-base",
            "win-regus",
        nil},
        instance = {
            "libreoffice",
            "evince",
            'qubes-backup-restore',
            "qubes-vm-settings",
        },
    nil},
    except_any = {
        class = {
            "Qubes clone Qube",
            "Qube Removal Confirmation",
            "Warning!",
        nil},
    nil},
    properties = {
        floating = false,
        maximized = true,
        maximized_vertical = true,
        maximized_horizontal = true,
    nil}},

    -- floating windows
    { rule_any = {
        class = {
            "Qubes clone Qube",
            "Qube Removal Confirmation",
            "Warning!",
            "vault:keepassxc",
        nil},
    nil},
    properties = {
        floating = true,
        fullscreen = false,
        maximized_vertical = false,
        maximized_horizontal = false,
        size_hints_honor = true,
        above = true,
    nil}},

    -- no padding around terminal
    { rule_any = {
        class = { 'Roxterm', 'Sakura', ".*:Stterm" },
    nil},
    except_any = {
        class = { 'Roxterm-config' },
    nil},
    properties = {
        floating = false,
        maximized = false,
        maximized_vertical = false,
        maximized_horizontal = false,
    nil}},

nil}


client_setup = function(c)
    local floating = awful.client.floating.get(c)
    c.size_hints_honor = floating
    c.above = floating
    if floating then
        c:keys(config.keys.floating)
        c:buttons(config.buttons.floating)
        c.border_width = beautiful.border_width
        --TODO add close and maximise buttons
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        local layout = wibox.layout.align.horizontal()
        awful.button.ignore_modifiers = config.ignore_all_modifiers
        layout:buttons(awful.util.table.join(
            awful.button.new({ }, 1, function() awful.client.property.set(c, "moved", true); awful.mouse.client.move(c) end),
            awful.button.new({ }, 3, function() awful.mouse.client.resize(c) end),
        nil))
        layout:set_middle(title)
        local tb = awful.titlebar(c)
        tb:set_bg(qubes.get_colour_focus(c))
        tb:set_widget(layout)
        client_geometry(c)
    else
        c:keys(config.keys.client)
        c:buttons(config.buttons.client)
        c.border_width = 0
        awful.titlebar.hide(c)
    end
end

-- Add a titlebar if titlebars_enabled is set to true in the rules.
----client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
----    local buttons = gears.table.join(
----        awful.button({ }, 1, function()
----            c:emit_signal("request::activate", "titlebar", {raise = true})
----            awful.mouse.client.move(c)
----        end),
----        awful.button({ }, 3, function()
----            c:emit_signal("request::activate", "titlebar", {raise = true})
----            awful.mouse.client.resize(c)
----        end)
----    )

----    qubes.manage(c)
----    awful.titlebar(c, { bg_normal = qubes.get_colour(c),
----                        bg_focus = qubes.get_colour_focus(c) } ) : setup {
----        { -- Left
----            awful.titlebar.widget.iconwidget(c),
----            buttons = buttons,
----            layout  = wibox.layout.fixed.horizontal
----        },
----        { -- Middle
----            { -- Title
----                align  = "center",
----                widget = titlewidget(c)
----            },
----            buttons = buttons,
----            layout  = wibox.layout.flex.horizontal
----        },
----        { -- Right
----            awful.titlebar.widget.floatingbutton (c),
----            awful.titlebar.widget.maximizedbutton(c),
----            awful.titlebar.widget.stickybutton   (c),
----            awful.titlebar.widget.ontopbutton    (c),
----            awful.titlebar.widget.closebutton    (c),
----            layout = wibox.layout.fixed.horizontal()
----        },
----        layout = wibox.layout.align.horizontal
----    }
----end)

client_geometry = function(c)
    local cg = c:geometry()
    local sg = screen[c.screen].geometry
    if awful.client.floating.get(c) then
        if cg.width > 0.8*sg.width then cg.width = 0.8*sg.width end
        if cg.height > 0.8*sg.height then cg.height = 0.8*sg.height end
        c:geometry{width = cg.width, height = cg.height}
        if not awful.client.property.get(c, "moved") then
            c:geometry{x = sg.x + (sg.width - cg.width)/2, y = sg.y + (sg.height - cg.height)/2}
        else
            awful.placement.no_offscreen(c)
        end
    end
end

in_signal = false

client.connect_signal("manage", function (c, startup)
    if awful.client.property.get(c, "unmanaged") == true then return end
    if not startup then
        awful.client.setslave(c)
    end
    awful.client.property.set(c, "moved", false)
    awful.client.property.set(c, "closed", 0)
    client_setup(c)
    c:connect_signal("property::geometry", function(c)
        if in_signal then return end
        in_signal = true
        client_geometry(c)
        in_signal = false
    end)
end)
