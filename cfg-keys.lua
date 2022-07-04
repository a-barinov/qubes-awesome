local gears = require("gears")
local awful = require('awful')
local naughty = require('naughty')


-- Config
local modkey = 'Mod4'
config.ignore_modifiers = { 'Shift', 'Lock', 'Mod2', 'Mod5' }
config.ignore_all_modifiers = { 'Control', 'Shift', 'Lock', 'Mod2', 'Mod4', 'Mod5' }


-- Some syntaxic sugar
config.keys = {}
config.buttons = {}


-- Core modifier keys
awful.key.ignore_modifiers = config.ignore_modifiers
awful.button.ignore_modifiers = config.ignore_modifiers


-- Global keys
config.keys.global = gears.table.join(
    awful.key.new({ modkey }, "t", function() awful.spawn("sakura -t Dom0") end),
    awful.key.new({ modkey, "Control" }, "t", function() awful.spawn('sakura -t Dom0 -e sudo /bin/sh -c "\\"sleep 0.1 ; exec bash\\""') end),
    awful.key.new({ modkey }, "l", function() awful.spawn("xscreensaver-command -lock") end),
    awful.key.new({ modkey }, "h", function() show_notifications() end),
    awful.key.new({ modkey, "Control" }, "r", awesome.restart),
    awful.key.new({ modkey, "Control" }, "q", awesome.quit),
    awful.key.new({ modkey, "Control" }, "Return", function() statusbar_toggle() end),
    awful.key.new({}, "XF86AudioRaiseVolume", function() volume("UP") end),
    awful.key.new({}, "XF86AudioLowerVolume", function() volume("DOWN") end),
    awful.key.new({}, "XF86AudioMute", function() volume("MUTE") end),
    awful.key.new({}, "XF86AudioMicMute", function() toggle_mic_mute() end),
    awful.key.new({}, "XF86MonBrightnessUp", function() brightness("UP") end),
    awful.key.new({}, "XF86MonBrightnessDown", function() brightness("DOWN") end),
nil)
if config.id == "GPDWIN2" then
    config.keys.global = gears.table.join(
        awful.key.new({}, "XF86TouchpadOff", function() menu_user() end),
        awful.key.new({}, "XF86Launch5", function() menu_statusbar() end),
        awful.key.new({}, "XF86Launch8", function() inject({ "Control_R", "Prior" }) end),
        awful.key.new({}, "XF86Launch9", function() inject({ "Control_R", "Next" }) end),
        awful.key.new({}, "XF86Copy", function() inject({ "Control_R", "c" }) end),
        awful.key.new({}, "XF86Paste", function() inject({ "Control_R", "v" }) end),
        awful.key.new({}, "XF86Launch1", function() inject({ "Control_R", "Shift_R", "c" }) end),
        awful.key.new({}, "XF86Launch2", function() inject({ "Control_R", "Shift_R", "v" }) end),
        awful.key.new({}, "XF86TouchpadOn", function() next_language() end),
    config.keys.global)
end
if config.id == "L380" then
    config.keys.global = gears.table.join(
        awful.key.new({}, "Insert", function() next_language() end),
        awful.key.new({}, "Print", function() menu_user() end),
        awful.key.new({ "Control" }, "Print", function() menu_statusbar() end),
        awful.key.new({ modkey }, "Home", function() menu_user() end),
        awful.key.new({ modkey }, "End", function() menu_statusbar() end),
        awful.key.new({ modkey, "Control" }, "s", function() awful.spawn(config.home .. "scripts/hdmi.sh") end),
    config.keys.global)
end
if config.id == "OneMix4" then
    config.keys.global = gears.table.join(
        awful.key.new({ modkey }, '\\', function() next_language() end),
        awful.key.new({ modkey }, "Escape", function() menu_user() end),
        awful.key.new({ modkey }, "Delete", function() menu_statusbar() end),
        awful.key.new({ modkey, "Control" }, "s", function() awful.spawn(config.home .. "scripts/hdmi.sh") end),
        awful.key.new({ modkey, "Control" }, "Right", function() awful.client.swap.byidx(1) end),
        awful.key.new({ modkey, "Control" }, "Left", function() awful.client.swap.byidx(-1) end),
    config.keys.global)
end
config.buttons.global = gears.table.join(
    awful.button.new({ }, 1, function() if menu_user_widget then menu_user_widget:hide() end; if menu_statusbar_widget then menu_statusbar_widget:hide() end end),
nil)


-- Client windows
config.keys.client = gears.table.join(
    awful.key.new({ modkey }, "f", function(c) awful.client.floating.toggle(c); client_setup(c) end),
    awful.key.new({ modkey }, "i", function(c) info(c) end),
    awful.key.new({ modkey }, "BackSpace", function(c) c:kill() end),
nil)
if config.id == "GPDWIN2" then
    config.keys.client = gears.table.join(
        awful.key.new({ }, "XF86Launch6", function() c = awful.client.next(1); client.focus = c; c:raise() end),
        awful.key.new({ }, "XF86Launch7", function() c = awful.client.next(-1); client.focus = c; c:raise() end),
    config.keys.client)
end
if config.id == "L380" then
    config.keys.client = gears.table.join(
        awful.key.new({ modkey }, "Right", function() c = awful.client.next(1); client.focus = c; c:raise() end),
        awful.key.new({ modkey }, "Left", function() c = awful.client.next(-1); client.focus = c; c:raise() end),
    config.keys.client)
end
if config.id == "OneMix4" then
    config.keys.client = gears.table.join(
        awful.key.new({ modkey }, "Right", function() c = awful.client.next(1); client.focus = c; c:raise() end),
        awful.key.new({ modkey }, "Left", function() c = awful.client.next(-1); client.focus = c; c:raise() end),
    config.keys.client)
end
config.buttons.client = gears.table.join(
    awful.button.new({ }, 1, function(c) if menu_user_widget then menu_user_widget:hide() end; if menu_statusbar_widget then menu_statusbar_widget:hide() end; if c then client.focus = c; c:raise() end end),
nil)


-- Floating windows
config.keys.floating = gears.table.join(config.keys.client,
    --awful.key.new({ modkey }, "BackSpace", function(c) c:kill() end),
nil)
config.buttons.floating = gears.table.join( config.buttons.client,
    awful.button.new({ modkey }, 1, awful.mouse.client.move),
    awful.button.new({ modkey }, 3, awful.mouse.client.resize),
nil)


-- Key remapper
inject = function(keys)
    keygrabber.stop()
    for i = 1, #keys, 1 do
        root.fake_input("key_press", keys[i])
    end
    for i = #keys, 1, -1 do
        root.fake_input("key_release", keys[i])
    end
end


-- Current window info
info = function(c)
    naughty.notify({ preset = naughty.config.presets.critical, title = "Window Information",  text =
        "Name: " .. tostring(c.name) .. "\n" ..
        "Class: " .. tostring(c.class) .. "\n" ..
        "Role: " .. tostring(c.role) .. "\n" ..
        "Instance: " .. tostring(c.instance)
    })
end


-- Set key bindings
if config.keys.global then
    root.keys(config.keys.global)
end
if config.buttons.global then
    root.buttons(config.buttons.global)
end
