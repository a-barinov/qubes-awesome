local gears = require("gears")
local awful = require("awful")
local autofocus = require("awful.autofocus")
local beautiful = require("beautiful")
local naughty = require("naughty")
local qubes = require("qubes")


----------------------
--- Error handling ---
----------------------

-- startup error notifications
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical, title = "Startup error", text = awesome.startup_errors })
end
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true
        naughty.notify({ preset = naughty.config.presets.critical, title = "Startup error",  text = err })
        in_error = false
    end)
end


-- worryless module loading
function loadsafe(name)
    success, result = pcall(function() return dofile(config.home .. name .. ".lua") end)
    if success then
        return result
    else
        naughty.notify({ preset = naughty.config.presets.critical, title = "Script Loading Error: " .. name .. ".lua", text = result })
        return nil
    end
end


--------------------
--- Local config ---
--------------------
config = {
    home = os.getenv("HOME") .. "/.config/awesome/",
    icons = os.getenv("HOME") .. "/.config/awesome/icons/apps/",
nil}

widgets = { menu = {}, tasklist = {}, statusbar = { layouts = {} } }


-------------
--- Setup ---
-------------

-- local configs
loadsafe("utils")
loadsafe("cfg-id")
loadsafe("cfg-keys")
loadsafe("cfg-rules")

-- load theme
beautiful.init(config.home .. "cfg-theme.lua")

-- set wallpaper
local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.tiled(wallpaper, s)
    end
end
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)
    awful.tag({ "1" }, s, awful.layout.suit.max)
end)

-- disable startup notification globally
local oldspawn = awful.util.spawn
awful.util.spawn = function (s)
    oldspawn(s, false)
end


---------------
-- Statusbar --
---------------
loadsafe("mod-confirm")
loadsafe("mod-entry")
loadsafe("mod-notifications")
loadsafe("mod-statusbar")
loadsafe("mod-qubes-vm-state")
loadsafe("mod-qubes-vm-shutdown")
loadsafe("mod-statusbar-usermenu")
loadsafe("mod-tasklist")
loadsafe("mod-brightness")
loadsafe("mod-qubes-volume")
loadsafe('mod-thermal')
loadsafe('mod-qubes-cpu')
loadsafe('mod-qubes-memory')
--loadsafe("mod-qubes-printer")
--loadsafe("mod-qubes-media")
--loadsafe("mod-qubes-mail")
loadsafe("mod-qubes-vpn")
loadsafe("mod-qubes-tor")
loadsafe("mod-qubes-wifi")
loadsafe("mod-qubes-storage")
--loadsafe("mod-qubes-usb")
loadsafe("mod-statusbar-battery")
loadsafe("mod-statusbar-language")
loadsafe("mod-statusbar-clock")
loadsafe("mod-qubes-vm-menu")
loadsafe("mod-usermenu")
loadsafe("mod-statusbar-systemmenu")


--------------------------
--- Garbage collection ---
--------------------------
_gc_timer = gears.timer({ timeout = 10 })
_gc_timer:start()
_gc_timer:connect_signal("timeout", function() collectgarbage("step", 20000) end)
