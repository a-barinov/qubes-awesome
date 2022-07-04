local beautiful = require('beautiful')
local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')


local menu = {
    settings = {},
    runtime = {},
}


menu.init = function(args)
    menu.settings.title = args.title or nil
    menu.settings.title_font = args.title_font or beautiful.get_merged_font(beautiful.font, tostring(beautiful.get_font_height(beautiful.font)*1)):to_string()
    menu.settings.screen = args.screen or mouse.screen
    menu.settings.width = args.width or 45
    menu.settings.icon_font = args.icon_font or beautiful.icon_font or 'Material Design Icons Regular'
    menu.settings.margin = args.margin or math.floor(beautiful.get_font_height(beautiful.font)/3 + 0.5)

    menu.runtime.items = {}
    menu.runtime.row = -1
    menu.runtime.column = -1
end


menu.show = function(menu_structure)
    local width = screen[menu.settings.screen].geometry.width*menu.settings.width/100
    local height = 2 - menu.settings.margin*4

    local item_width = beautiful.get_font_height(beautiful.font)*4
    local glyph_font = beautiful.get_merged_font(beautiful.icon_font, tostring(beautiful.get_font_height(beautiful.icon_font)*1.5)):to_string()
    local label_font = beautiful.get_merged_font(beautiful.font, tostring(beautiful.get_font_height(beautiful.font)*0.55)):to_string()

    local close

    -- Main container
    local main_layout = wibox.widget {
        {
            id = "container",
            spacing = menu.settings.margin*2,
            layout = wibox.layout.fixed.vertical,
        },
        margins = menu.settings.margin*2,
        widget = wibox.container.margin,
    }
    local container = main_layout:get_children_by_id('container')[1]
    height = height + menu.settings.margin*4

    -- Title
    if menu.settings.title ~= nil then
        local header = wibox.widget{
            {
                id = 'label',
                markup = '<span font="' .. menu.settings.title_font .. '">' .. (menu.settings.title or '') .. '</span>',
                align = "center";
                color = beautiful.fg_normal,
                widget = wibox.widget.textbox,
            },
            margin_bottom = menu.settings.margin*2,
            widget = wibox.container.margin,
        }
        container:add(header)
        height = height + menu.settings.margin*2 + header:get_children_by_id('label')[1]:get_height_for_width(width, menu.settings.screen)
    end

    -- Sections
    local current_row = -1
    local max_width = -1
    for _, section in pairs(menu_structure) do
        local current_width = 2 + menu.settings.margin*4
        current_row = current_row + 1
        menu.runtime.items[current_row] = {}
        local section_layout = wibox.widget {
            {
                {
                    {
                        {
                            id = 'label',
                            markup = '<span font="' .. beautiful.font .. '">' .. (section.name or 'Section') .. '</span>',
                            align = "left",
                            color = beautiful.fg_normal,
                            widget = wibox.widget.textbox,
                        },
                        margins = menu.settings.margin,
                        widget = wibox.container.margin,
                    },
                    shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, menu.settings.margin/2) end,
                    bg = beautiful.colors[section.color] or section.color,
                    widget = wibox.container.background,
                },
                --{
                --    widget = wibox.widget.separator,
                --    orientation = "horizontal", span_ratio = 1.0,
                --    forced_height = menu.settings.margin,
                --    color = beautiful.bg_focus,
                --},
                id = "container",
                spacing = menu.settings.margin*2,
                layout = wibox.layout.fixed.vertical,
            },
            margins = menu.settings.margin,
            widget = wibox.container.margin,
        }
        local section_container = section_layout:get_children_by_id('container')[1]
        height = height + menu.settings.margin*7 + section_layout:get_children_by_id('label')[1]:get_height_for_width(width, menu.settings.screen)


        -- Items
        local row = wibox.widget {
            spacing = menu.settings.margin*2,
            layout = wibox.layout.fixed.horizontal,
        }
        section_container:add(row)
        local current_column = -1
        local max_height = -1
        for _, item in pairs(section) do
            current_column = current_column + 1
            if item.label then
                if current_width + item_width + menu.settings.margin*4 > width then
                    height = height + max_height + menu.settings.margin*2
                    max_height = -1
                    current_row = current_row + 1
                    menu.runtime.items[current_row] = {}
                    row = wibox.widget {
                        spacing = menu.settings.margin*2,
                        layout = wibox.layout.fixed.horizontal,
                    }
                    section_container:add(row)
                    current_column = 0
                    max_width = math.max(max_width, current_width)
                    current_width = 2 + menu.settings.margin*4
                end
                local button
                if item.icon:len() < 5 then
                    button = wibox.widget {
                        {
                            {
                                {
                                    {
                                        id = 'glyph',
                                        markup = '<span font="' .. glyph_font .. '">' .. item.icon .. '</span>',
                                        align = "center";
                                        widget = wibox.widget.textbox,
                                    },
                                    {
                                        id = 'label',
                                        markup = '<span font="' .. label_font .. '">' .. item.label .. '</span>',
                                        align = "center";
                                        color = beautiful.fg_normal,
                                        widget = wibox.widget.textbox,
                                    },
                                    spacing = menu.settings.margin,
                                    layout = wibox.layout.fixed.vertical,
                                },
                                width = item_width,
                                strategy = 'exact',
                                widget = wibox.container.constraint,
                            },
                            left = menu.settings.margin,
                            right = menu.settings.margin,
                            top = menu.settings.margin,
                            bottom = menu.settings.margin,
                            widget = wibox.container.margin,
                        },
                        id = 'bg',
                        shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, menu.settings.margin) end,
                        bg = beautiful.bg_normal,
                        widget = wibox.container.background,
                    }
                else
                    button = wibox.widget {
                        {
                            {
                                {
                                    {
                                        {
                                            id = 'glyph',
                                            image = item.icon,
                                            forced_height = item_width - 6*menu.settings.margin,
                                            forced_width = item_width - 0*menu.settings.margin,
                                            widget = wibox.widget.imagebox,
                                        },
                                        left = 3*menu.settings.margin,
                                        right = 3*menu.settings.margin,
                                        top = 0,
                                        bottom = 0,
                                        widget = wibox.container.margin,
                                    },
                                    {
                                        id = 'label',
                                        markup = '<span font="' .. label_font .. '">' .. item.label .. '</span>',
                                        align = "center";
                                        color = beautiful.fg_normal,
                                        widget = wibox.widget.textbox,
                                    },
                                    spacing = menu.settings.margin,
                                    layout = wibox.layout.fixed.vertical,
                                },
                                width = item_width,
                                strategy = 'exact',
                                widget = wibox.container.constraint,
                            },
                            left = menu.settings.margin,
                            right = menu.settings.margin,
                            top = menu.settings.margin,
                            bottom = menu.settings.margin,
                            widget = wibox.container.margin,
                        },
                        id = 'bg',
                        shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, menu.settings.margin) end,
                        bg = beautiful.bg_normal,
                        widget = wibox.container.background,
                    }
                end
                row:add(button)
                local glyph_height
                if item.icon:len() < 5 then
                    glyph_height = button:get_children_by_id('glyph')[1]:get_height_for_width(item_width, menu.settings.screen)
                else
                    glyph_height = item_width - menu.settings.margin*6
                end
                max_height = math.max(max_height, glyph_height + button:get_children_by_id('label')[1]:get_height_for_width(item_width, menu.settings.screen))
                menu.runtime.items[current_row][current_column] = { x = current_row, y = current_column, active = false, bg = button:get_children_by_id('bg')[1], action = item.action}
                local item = menu.runtime.items[current_row][current_column]
                button:connect_signal('mouse::enter', function() menu.set_active(item) end)
                button:connect_signal('button::release', function(_, _, _, button_pressed)
                    menu.set_active(item)
                    if button_pressed == 1 then
                        close(item)
                    end
                end)
                current_width = current_width + item_width + menu.settings.margin*4
            end
        end
        max_width = math.max(max_width, current_width)
        container:add(section_layout)
        height = height + max_height + menu.settings.margin*5
    end

    -- Window
    menu.runtime.window = wibox {
        type = 'menu',
        ontop = true,
        visible = true,
        screen = menu.settings.screen,
        x = (screen[menu.settings.screen].geometry.width - max_width)/2,
        y = (screen[menu.settings.screen].geometry.height - height)/2,
        width = max_width,
        height = height,
        shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 2*menu.settings.margin) end,
        border_width = 1,
        border_color = beautiful.fg_normal,
     }

    menu.runtime.window:set_widget(main_layout)
    menu.set_active(menu.runtime.items[0][0])
    local coords = mouse.coords()
    mouse.coords({ x = coords.x + 1, y = coords.y + 1})
    mouse.coords({ x = coords.x, y = coords.y})

    local function key_grabber(mod, key, event)
        if event ~= 'press' then return end
        if key == 'Escape' then
            close(nil)
        elseif key == 'Up' then
            local row = (menu.runtime.row - 1)%length(menu.runtime.items)
            local column = math.min(menu.runtime.column, length(menu.runtime.items[row]) - 1)
            menu.set_active(menu.runtime.items[row][column])
        elseif key == 'Down' then
            local row = (menu.runtime.row + 1)%length(menu.runtime.items)
            local column = math.min(menu.runtime.column, length(menu.runtime.items[row]) - 1)
            menu.set_active(menu.runtime.items[row][column])
        elseif key == 'Right' then
            local column = (menu.runtime.column + 1)%length(menu.runtime.items[menu.runtime.row])
            menu.set_active(menu.runtime.items[menu.runtime.row][column])
        elseif key == 'Left' then
            local column = (menu.runtime.column - 1)%length(menu.runtime.items[menu.runtime.row])
            menu.set_active(menu.runtime.items[menu.runtime.row][column])
        elseif key == 'Enter' or key == 'Return' then
            close(menu.runtime.items[menu.runtime.row][menu.runtime.column])
        end
    end

    close = function(item)
        keygrabber.stop(key_grabber)
        mousegrabber.stop()
        menu.runtime.window.visible = false
        main_layout:reset()
        if item ~= nil then
            local command = item.action
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
        local widgets = menu.runtime.window:find_widgets(mouse.x - menu.runtime.window.x, mouse.y - menu.runtime.window.y)
        if #widgets > 0 then return false end
        if ((mouse.buttons[1] and 1 or 0) + (mouse.buttons[2] and 1 or 0) + (mouse.buttons[3] and 1 or 0) > buttons_pressed) and #widgets == 0 then
            close(nil)
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
    menu.runtime.window:connect_signal('mouse::leave', function() grab_mouse() end)
    if #(menu.runtime.window:find_widgets(mouse.coords().x - menu.runtime.window.x, mouse.coords().y - menu.runtime.window.y)) == 0 then
        grab_mouse()
    end
end


menu.set_active = function(button)
    for _,row in pairs(menu.runtime.items) do
        for _,item in pairs(row) do
            if button.x == item.x and button.y == item.y then
                item.bg:set_bg(beautiful.bg_focus)
                item.active = true
                menu.runtime.row = item.x
                menu.runtime.column = item.y
            elseif item.active then
                item.bg:set_bg(beautiful.bg_normal)
                item.active = false
            end
        end
    end
end


return menu
