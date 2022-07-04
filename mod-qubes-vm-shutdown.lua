local gears = require("gears")
local awful = require("awful")


vm_shutdown_rules = {
    { name = "debian-core", timeout = 10 },
    { name = "debian-core1", timeout = 10 },
    { name = "debian-full", timeout = 10 },
    { name = "core-xorg", timeout = 10 },
    { name = "core-rdp", timeout = 30 },
    { name = "dvm-base", timeout = 10 },
    { name = "dvm-chrome", timeout = 30 },
    { name = "dvm-chrome-tor", timeout = 30 },
    { name = "dvm-anbox", timeout = 10 },
    { name = "dvm-torbrowser", timeout = 10 },
    { name = "dvm-github", timeout = 60 },
    { name = "my-liferea", timeout = 10 },
    { name = "my-personal", timeout = 60 },
    { name = "my-devel", timeout = 60 },
    { name = "my-photo", timeout = 60 },
    { name = "vault", timeout = 10 },
nil}


client.connect_signal("manage", function (c, startup)
    local domain = awful.client.property.get(c, "qubes_vmname")
    for _, rule in pairs(vm_shutdown_rules) do
        if rule.name == domain then
            if rule.timer and rule.timer.started then
                rule.timer:stop()
            end
            return
        end
    end
end)

client.connect_signal("unmanage", function (c)
    local domain = awful.client.property.get(c, "qubes_vmname")
    for _, rule in pairs(vm_shutdown_rules) do
        if rule.name == domain then
            for _, window in pairs(client.get()) do
                if awful.client.property.get(window, "qubes_vmname") == domain then
                    return
                end
            end
            if rule.timeout == 0 then
                awful.spawn("qvm-shutdown --quiet " .. domain)
            else
                rule.timer = gears.timer({ timeout = rule.timeout })
                rule.timer:connect_signal("timeout", function()
                    awful.spawn("qvm-shutdown --quiet " .. domain)
                    rule.timer:stop()
                end)
                rule.timer:start()
            end
            return
        end
    end
end)
