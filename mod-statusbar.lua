local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local common = require("awful.widget.common")
local naughty = require("naughty")


-- Statusbar
widgets.statusbar.padding = awful.wibar({ position = "top", screen = 1 })
widgets.statusbar.widget = wibox( { screen = 1, x = 0, y = 0, width = screen[1].geometry.width, height = beautiful.statusbar_height, visible = true, type = 'normal', ontop = true, bg = '#000000' } )
widgets.statusbar.trigger = wibox( { screen = 1, x = 0, y = 0, width = screen[1].geometry.width, height = 1, visible = false, type = 'normal', ontop = true, bg = '#000000' } )
widgets.statusbar.hidden = false
widgets.statusbar.layouts.left = wibox.layout.fixed.horizontal()
widgets.statusbar.layouts.right = wibox.layout.fixed.horizontal()
widgets.statusbar.layouts.main = wibox.layout.align.horizontal()
widgets.statusbar.layouts.main:set_left(widgets.statusbar.layouts.left)
widgets.statusbar.layouts.main:set_right(widgets.statusbar.layouts.right)
widgets.statusbar.widget:set_widget(widgets.statusbar.layouts.main)


-- Autohide
widgets.statusbar.trigger:connect_signal("button::release", function(w)
    if widgets.statusbar.hidden then
        widgets.statusbar.widget.visible = true
        widgets.statusbar.trigger.visible = false
    end
end)

widgets.statusbar.widget:connect_signal("mouse::leave", function(w)
    if widgets.statusbar.hidden then
        widgets.statusbar.widget.visible = false
        widgets.statusbar.trigger.visible = true
    end
end)

statusbar_toggle = function()
    widgets.statusbar.padding.visible = widgets.statusbar.hidden
    widgets.statusbar.widget.visible = widgets.statusbar.hidden
    widgets.statusbar.trigger.visible = not widgets.statusbar.hidden
    widgets.statusbar.hidden = not widgets.statusbar.hidden
    local geom = screen[1].workarea
    for _, window in pairs(client.get()) do
        if not window.floating then
            window:geometry(geom)
        end
    end
end


-- Indicators API
widgets.indicator = {
    create = function(object, icon)
        object.layout = wibox.layout.fixed.horizontal()
        if icon ~= "" then
            object.icon = wibox.widget.textbox()
            object.icon:set_markup('<span font_desc="' .. beautiful.icon_font .. '">' .. icon ..  '</span>')
            object.icon_holder = wibox.container.margin(object.icon, 2, 2, 1, 2)
            object.layout:add(object.icon_holder)
        end
        object.percent = wibox.widget.textbox()
        object.percent:set_font(beautiful.font)
        object.layout:add(object.percent)
        object.holder = wibox.container.margin(object.layout, 4, 4, 2, 2)
        if not object.enalbed then
            object.holder:set_widget(nil)
            object.holder:set_margins(0)
        end
        object.holder:connect_signal("button::release", function(_, _, _, button)
            if button == 1 and object.on_click then
                object.on_click()
            end
            if button == 3 and object.alttext then
                naughty.notify({ title = object.name, text = object.alttext })
            end
        end)
        widgets.statusbar.layouts.right:add(object.holder)
        widgets.indicator.set_state(object)
    end,

    set_state = function(object)
        if object.enabled then
            if object.holder.widget == nil then
                object.holder:set_widget(object.layout)
                object.holder:set_top(2)
                object.holder:set_bottom(2)
                object.holder:set_left(4)
                object.holder:set_right(4)
            end
        else
            if object.holder.widget ~= nil then
                object.holder:set_widget(nil)
                object.holder:set_margins(0)
            end
        end
    end,

    set_icon = function(object, icon)
        if icon ~= "" and object.icon ~= nil then
            object.icon:set_markup('<span font_desc="' .. beautiful.icon_font .. '">' .. icon ..  '</span>')
        end
    end,

    set_text = function(object, text)
        if object.percent and object._text ~= text then
            object.percent:set_markup(text)
            object._text = text
        end
    end
}


-- Initial update
-- TODO find signal for this?
widgets.indicator.startup_timer = gears.timer({ timeout = 1 })
widgets.indicator.startup_timer:start()
widgets.indicator.startup_timer:connect_signal("timeout", function()
    for _,w in pairs(widgets) do
        if w.startup then w.startup() end
    end
    widgets.indicator.startup_timer:stop()
end)


-- Periodic updates
widgets.indicator.timer = gears.timer({ timeout = 60 })
widgets.indicator.timer:start()
widgets.indicator.timer:connect_signal("timeout", function()
    for _,w in pairs(widgets) do
        if w.update then w.update() end
    end
end)


-- Show menu defined by indicators
menu_statusbar_old = function()
    local section = function(menu, name)
        local menu_part = {}
        for _,w in pairs(widgets) do
            if w.menu_category == name then
                for num, i in ipairs(w.menu) do
                    menu_part[w.priority + num] = i
                end
            end
        end
        if length(menu_part) > 0 then
            table.insert(menu, { string.upper(name), nil, theme = { font = beautiful.menu_divider_font, bg_normal = beautiful.menu_divider_bg } })
            for i = 0, 32 do
                if menu_part[i] ~= nil then
                    table.insert(menu, menu_part[i])
                end
            end
        end
    end

    local menu = {}
    section(menu, "connection")
    section(menu, "sharing")
    section(menu, "system")

    if #menu > 0 then
        menu_statusbar_widget = awful.menu({ items = menu, theme = { width = beautiful.menu_width } })
        menu_statusbar_widget:show({ coords = { x = screen[1].geometry.width, y = 0 } })
    end

    unique_popup(function() menu_statusbar_widget:hide() end)
end

menu_statusbar = function(args)
    args = args or {}
    local margin = args.margin or math.floor(beautiful.get_font_height(beautiful.font)/3 + 0.5)
    local width = args.width or beautiful.get_font_height(beautiful.font)*6
    screen_num = args.screen or mouse.screen

    local glyph_font = args.glyph_font or beautiful.get_merged_font(beautiful.icon_font, tostring(beautiful.get_font_height(beautiful.icon_font)*1.5)):to_string()
    local label_font = args.label_font or beautiful.get_merged_font(beautiful.font, tostring(beautiful.get_font_height(beautiful.font)*0.55)):to_string()
    local height = 2 + 4*margin - 2*margin
    local buttons = {}
    local current_button = -1
    local close

    local set_active = function(position)
        if current_button ~= position then
            for i = 0, #buttons  do
                if i == position then
                    buttons[i].bg_widget:set_bg(beautiful.bg_focus)
                else
                    buttons[i].bg_widget:set_bg(beautiful.bg_normal)
                end
            end
            current_button = position
        end
    end

    local button  = function(glyph, text, first_action, second_action)
        local button = wibox.widget {
            {
                {
                    {
                        id = "glyph",
                        markup = '<span font="' .. glyph_font .. '">' .. glyph .. '</span>',
                        force_width = width/2,
                        align = "center";
                        widget = wibox.widget.textbox,
                    },
                    {
                        id = "label",
                        markup = '<span font="' .. label_font .. '">' .. (text or '') .. '</span>',
                        align = "center";
                        force_width = width - 2 - 6*margin,
                        color = beautiful.fg_normal,
                        widget = wibox.widget.textbox,
                    },
                    spacing = margin,
                    layout = wibox.layout.fixed.vertical,
                },
                left = 0,
                right = 0,
                top = margin,
                bottom = margin,
                widget = wibox.container.margin,
            },
            id = 'bg',
            shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, margin) end,
            bg = beautiful.bg_normal,
            widget = wibox.container.background,
        }
        button.bg_widget = button:get_children_by_id('bg')[1]
        button.button_position = length(buttons)
        button.first_action = first_action
        button.second_action = second_action
        buttons[button.button_position] = button
        button.bg_widget:connect_signal('mouse::enter', function() set_active(button.button_position) end)
        button.bg_widget:connect_signal('button::release', function(_, _, _, button_pressed)
            set_active(button.button_position)
            if button_pressed == 1 then
                close("first")
            elseif button_pressed == 3 then
                close("second")
            end
        end)
        height = height + button:get_children_by_id('glyph')[1]:get_height_for_width(width/2, screen_num) + button:get_children_by_id('label')[1]:get_height_for_width(width - 2 - 4*margin, screen_num) + margin*5
        return button
    end

    local separator = function()
        height = height + margin*3
        return wibox.widget{ widget = wibox.widget.separator, orientation = "horizontal", span_ratio = 0.8, forced_height = margin }
    end

    local main_layout = wibox.widget {
        {
            id = "container",
            spacing = margin*2,
            layout = wibox.layout.fixed.vertical,
        },
        margins = margin*2,
        widget = wibox.container.margin,
    }
    local container = main_layout:get_children_by_id('container')[1]

    local section = function(name, count_only)
        local count = 0
        for priority = 0, 10 do
            for _,w in pairs(widgets) do
                if w.priority == priority then
                    if w.menu_category == name then
                        for num, item in ipairs(w.menu) do
                            if not count_only then
                                local glyph = item.glyph
                                if type(glyph) == 'function' then
                                    glyph = item.glyph()
                                end
                                local label = item.label
                                if type(label) == 'function' then
                                    label = item.label()
                                end
                                container:add(button(glyph, label, item.first_action, item.second_action)) --󰫝
                            end
                            count = count + 1
                        end
                    end
                end
            end
        end
        return count
    end

    -- check if there are items in the list

    section('connection')
    if section('qubes', true) > 0 then
        container:add(separator())
    end
    section('qubes')
    if section('system', true) > 0 then
        container:add(separator())
    end
    section('system')

    local window = wibox {
        type = 'menu',
        ontop = true,
        visible = true,
        screen = screen_num,
        x = screen[screen_num].geometry.width - width - 2*margin,
        y = (screen[screen_num].geometry.height - height)/2,
        width = width,
        height = height,
        shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 2*margin) end,
        border_width = 1,
        border_color = beautiful.fg_normal,
    }
    window:set_widget(main_layout)
    window:connect_signal('mouse::move', function(_, x, y)
        for _, widget in ipairs(window:find_widgets(x, y)) do
            if widget.widget.button_position ~= nil then
                set_active(widget.widget.button_position)
            end
        end
    end)

    local function key_grabber(mod, key, event)
        if event ~= 'press' then return end
        if key == 'Escape' then
            close(false)
        elseif key == 'Up' then
            if current_button == -1 then current_button = 0 end
            set_active((current_button - 1)%length(buttons))
        elseif key == 'Down' then
            set_active((current_button + 1)%length(buttons))
        elseif key == ' ' then
            close('second')
        elseif key == 'Enter' or key == 'Return' then
            close('first')
        end
    end

    close = function(action)
        keygrabber.stop(key_grabber)
        mousegrabber.stop()
        main_layout:reset()
        window.visible = false
        local command
        if current_button ~= -1 then
            if action == "first" then
                command = buttons[current_button].first_action
            elseif action == "second" then
                command = buttons[current_button].second_action
            end
            if type(command) == "string" then
                awful.spawn(command)
            elseif type(command) == "function" then
                command()
            end
        end
    end

    unique_popup(function() close(nil) end)

    local buttons_pressed
    local function mouse_grabber(mouse)
        local widgets = window:find_widgets(mouse.x - window.x, mouse.y - window.y)
        if #widgets > 0 then return false end
        if ((mouse.buttons[1] and 1 or 0) + (mouse.buttons[2] and 1 or 0) + (mouse.buttons[3] and 1 or 0) > buttons_pressed) and #widgets == 0 then
            close()
        end
        buttons_pressed = (mouse.buttons[1] and 1 or 0) + (mouse.buttons[2] and 1 or 0) + (mouse.buttons[3] and 1 or 0)
        return true
    end
    local function grab_mouse()
        if mousegrabber.isrunning() then return end
        buttons_pressed = (mouse.coords().buttons[1] and 1 or 0) + (mouse.coords().buttons[2] and 1 or 0) + (mouse.coords().buttons[3] and 1 or 0)
        mousegrabber.run(mouse_grabber, 'arrow')
    end

    keygrabber.run(key_grabber)
    window:connect_signal('mouse::leave', function() grab_mouse() end)
    if #(window:find_widgets(mouse.coords().x - window.x, mouse.coords().y - window.y)) == 0 then
        grab_mouse()
    end

end
