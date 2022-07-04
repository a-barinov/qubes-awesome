local awful = require("awful")
local naughty = require("naughty")

-- Callback for external script
storage_state = function(action, vm, device, fs, size)
    if action == 'A' then
        naughty.notify({ title = "New device", text = vm .. ":" .. device .. "\n" .. fs .. " " .. size })
    end
    if action == 'R' and not widgets.storage.disconnecting == false then
        naughty.notify({ title = "Device removed", text = vm .. ":" .. device })
    end
end
