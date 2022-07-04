local awful = require('awful')
local wibox = require('wibox')
local beautiful = require('beautiful')
local keygrabber = require("awful.keygrabber")


confirm = function(args)
    local screen_num = args.screen or 1
    local width = args.width or screen[screen_num].workarea.width/6
    local message_text = args.text or 'ERROR: Message not defined'
    local first_button_text = args.first_button or 'Yes'
    local second_button_text = args.second_button or 'No'
    local margin = args.margin or 8
    local command = args.command or function() debug_msg('ERROR: No command specified') end

    local main_layout = wibox.widget {
        {
            {
                markup = '<span font_size="larger">' .. message_text .. '</span>',
                align = "center";
                widget = wibox.widget.textbox,
                id = 'header',
            },
            {
                {
                    {
                        {
                            {
                                text = first_button_text,
                                align = "center";
                                widget = wibox.widget.textbox,
                                id = 'first-button',
                            },
                            id = 'first-bg',
                            bg = beautiful.bg_focus,
                            widget = wibox.container.background,
                        },
                        id = 'first-padding',
                        margins = margin,
                        color = beautiful.bg_focus,
                        widget = wibox.container.margin,
                    },
                    id = 'first-border',
                    margins = 1,
                    color = beautiful.fg_focus,
                    widget = wibox.container.margin,
                },
                {
                    {
                        {
                            {
                                text = second_button_text,
                                align = "center";
                                widget = wibox.widget.textbox,
                                id = 'second-button',
                            },
                            id = 'second-bg',
                            bg = beautiful.bg_normal,
                            widget = wibox.container.background,
                        },
                        id = 'second-padding',
                        margins = margin,
                        color = beautiful.bg_normal,
                        widget = wibox.container.margin,
                    },
                    id = 'second-border',
                    margins = 1,
                    color = beautiful.bg_focus,
                    widget = wibox.container.margin,
                },
                spacing = margin*3,
                layout = wibox.layout.flex.horizontal,
            },
            spacing = margin*3,
            layout = wibox.layout.fixed.vertical,
        },
        margins = margin*3,
        widget = wibox.container.margin,
    }
    local first_bg = main_layout:get_children_by_id('first-bg')[1]
    local first_padding = main_layout:get_children_by_id('first-padding')[1]
    local first_border = main_layout:get_children_by_id('first-border')[1]
    local second_bg = main_layout:get_children_by_id('second-bg')[1]
    local second_padding = main_layout:get_children_by_id('second-padding')[1]
    local second_border = main_layout:get_children_by_id('second-border')[1]
    local height = margin*11 + 4 + main_layout:get_children_by_id('first-button')[1]:get_height_for_width(8192, screen_num) + main_layout:get_children_by_id('header')[1]:get_height_for_width(width - margin*6, screen_num)

    local window = wibox {
        type = 'menu',
        ontop = true,
        visible = true,
        screen = screen_num,
        x = (screen[screen_num].workarea.width - width)/2,
        y = (screen[screen_num].workarea.height - height)/2,
        width = width,
        height = height,
        border_width = 1,
        border_color = beautiful.fg_normal,
    }
    window:set_widget(main_layout)

    local active_button = 0
    local function set_active(button)
        if button == 1 then
            active_button = 1
            first_bg:set_bg(beautiful.bg_normal)
            first_padding:set_color(beautiful.bg_normal)
            first_border:set_color(beautiful.bg_focus)
            second_bg:set_bg(beautiful.bg_focus)
            second_padding:set_color(beautiful.bg_focus)
            second_border:set_color(beautiful.fg_focus)
        else
            active_button = 0
            first_bg:set_bg(beautiful.bg_focus)
            first_padding:set_color(beautiful.bg_focus)
            first_border:set_color(beautiful.fg_focus)
            second_bg:set_bg(beautiful.bg_normal)
            second_padding:set_color(beautiful.bg_normal)
            second_border:set_color(beautiful.bg_focus)
        end
    end

    local close
    local function key_grabber(mod, key, event)
        if event ~= 'press' then return end
        if key == 'Escape' then
            close(false)
        elseif key == 'Left' or key == 'Right' or key == 'Tab' then
            set_active((active_button + 1)%2)
        elseif key == 'Enter' or key == 'Return' then
            close(active_button == 0)
        end
    end

    close = function(action)
        keygrabber.stop(key_grabber)
        mousegrabber.stop()
        main_layout:reset()
        window.visible = false
        if action then
            command()
        end
    end

    unique_popup(function() close(false) end)

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

    first_border:connect_signal('button::release', function() close(true) end)
    first_border:connect_signal('mouse::enter', function() set_active(0) end)
    second_border:connect_signal('button::release', function() close(false) end)
    second_border:connect_signal('mouse::enter', function() set_active(1) end)
    keygrabber.run(key_grabber)
    window:connect_signal('mouse::leave', function() grab_mouse() end)
    if #(window:find_widgets(mouse.coords().x - window.x, mouse.coords().y - window.y)) == 0 then
        grab_mouse()
    end

end
