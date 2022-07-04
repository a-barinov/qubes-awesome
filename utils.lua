local beautiful = require("beautiful")
local awful = require("awful")
local naughty = require("naughty")


-- Split string into table
split = function(string, separator)
    local tokens = { }
    for match in string:gmatch("[^" .. separator .. "]+") do
        table.insert(tokens, match)
    end
    return tokens
end


-- Read command output
read_command = function(command)
    local f = io.popen(command)
    local result = f:read("*all")
    f:close()
    return result
end


-- Read file
read_file = function(filename)
    local file = io.open(filename)
    if not file then return nil end
    local result = file:read()
    file:close()
    return result
end


-- Debug to notifications
debug_msg = function(message)
    naughty.notify({ text = tostring(message) })
end


-- Calculate table length
length = function(table)
    local count = 0
    for _,item in pairs(table) do
        if item ~= nil then
            count = count + 1
        end
    end
    return count
end

-- Enrure we don't run several grabs simultaneously
unique_popup = function(callback)
    if unique_popup_registered ~= nil then
        unique_popup_registered()
    end
    unique_popup_registered = callback
end
