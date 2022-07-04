local beautiful = require('beautiful')
local wibox = require("wibox")
local gears = require("gears")


local menu = {
    settings = {},
    runtime = {},
}


menu.init = function(args)
    menu.settings.title = args.title or nil
    menu.settings.screen = args.screen or mouse.screen
    menu.settings.margin = args.margin or math.floor(beautiful.get_font_height(beautiful.font)/3 + 0.5)

    menu.runtime.items = {}
    menu.runtime.row = -1
end


menu.show = function(menu_structure)
    local height = 2 - menu.settings.margin*2
    local width = menu.settings.margin*4

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
                markup = '<span font_size="larger"><b>' .. (menu.settings.title or 'Title') .. '</b></span>',
                align = "center";
                color = beautiful.fg_normal,
                widget = wibox.widget.textbox,
            },
            margins = menu.settings.margin,
            widget = wibox.container.margin,
        }
        container:add(header)
        local label = header:get_children_by_id('label')[1]
        width = math.max(width, label:get_preferred_size_at_dpi(screen[menu.settings.screen].dpi) + menu.settings.margin*6)
        height = height + menu.settings.margin*4 + label:get_height_for_width(screen[menu.settings.screen].geometry.width, menu.settings.screen)
    end

    -- Buttons
    local current_row = -1
    local max_width = -1
    for _, item in pairs(menu_structure) do
        if item.label then
            current_row = current_row + 1
            local button = wibox.widget {
                {
                    {
                        {
                            id = 'label',
                            text = item.label,
                            align = "center",
                            color = beautiful.fg_normal,
                            widget = wibox.widget.textbox,
                        },
                        margins = menu.settings.margin*2,
                        widget = wibox.container.margin,
                    },
                    margins = 1,
                    color = beautiful.bg_focus,
                    widget = wibox.container.margin,
                },
                id = 'bg',
                --shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, menu.settings.margin) end,
                bg = beautiful.bg_normal,
                widget = wibox.container.background,
            }
            width = math.max(width, button:get_children_by_id('label')[1]:get_preferred_size_at_dpi(screen[menu.settings.screen].dpi) + menu.settings.margin*8 + 2)
            height = height + button:get_children_by_id('label')[1]:get_height_for_width(screen[menu.settings.screen].geometry.width, menu.settings.screen) + menu.settings.margin*6
            menu.runtime.items[current_row] = { position = current_row, active = false, bg = button:get_children_by_id('bg')[1], action = item.action}
            local item = menu.runtime.items[current_row]
            button:connect_signal('mouse::enter', function() menu.set_active(item) end)
            button:connect_signal('button::release', function(_, _, _, button_pressed)
                menu.set_active(item)
                if button_pressed == 1 then
                    close(item)
                end
            end)
            --max_width = math.max(max_width, current_width)
            container:add(button)
        end
    end

    -- Window
    width = math.max(width, height*0.8)
    menu.runtime.window = wibox {
        type = 'menu',
        ontop = true,
        visible = true,
        screen = menu.settings.screen,
        x = (screen[menu.settings.screen].geometry.width - width)/2,
        y = (screen[menu.settings.screen].geometry.height - height)/2,
        width = width,
        height = height,
        shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 2*menu.settings.margin) end,
        border_width = 1,
        border_color = beautiful.fg_normal,
     }

    menu.runtime.window:set_widget(main_layout)
    menu.set_active(menu.runtime.items[0])
    local coords = mouse.coords()
    mouse.coords({ x = coords.x + 1, y = coords.y + 1})
    mouse.coords({ x = coords.x, y = coords.y})


    local function key_grabber(mod, key, event)
        if event ~= 'press' then return end
        if key == 'Escape' then
            close(nil)
        elseif key == 'Up' then
            local row = (menu.runtime.row - 1)%length(menu.runtime.items)
            menu.set_active(menu.runtime.items[row])
        elseif key == 'Down' then
            local row = (menu.runtime.row + 1)%length(menu.runtime.items)
            menu.set_active(menu.runtime.items[row])
        elseif key == 'Enter' or key == 'Return' then
            close(menu.runtime.items[menu.runtime.row])
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
    for _,item in pairs(menu.runtime.items) do
        if button.position == item.position then
            item.bg:set_bg(beautiful.bg_focus)
            item.active = true
            menu.runtime.row = item.position
        elseif item.active then
            item.bg:set_bg(beautiful.bg_normal)
            item.active = false
        end
    end
end


return menu
