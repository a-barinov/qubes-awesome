local awful = require('awful')
local wibox = require('wibox')
local beautiful = require('beautiful')
local keygrabber = require("awful.keygrabber")


entry = function(args)
    local screen_num = args.screen or 1
    local width = args.width or screen[screen_num].workarea.width/3
    local message_text = args.text or 'ERROR: Message not defined'
    local first_button_text = args.first_button or 'OK'
    local second_button_text = args.second_button or 'Cancel'
    local margin = args.margin or 8
    local command = args.command or function() debug_msg('ERROR: No command specified') end

    local message = wibox.widget.textbox('<span font_size="larger">' .. message_text .. '</span>', false)
    message:set_align('left') -- or 'center'
    local margin_message = wibox.container.margin(message, margin*2, margin*2, margin*2, margin*2)

    local entry_text = ' '
    local entry_position = 0
    local markup_with_cursor = function(inverse)
        local result = '<tt>' .. entry_text:sub(0, entry_position)
        if inverse then
            result = result .. '<span foreground="' .. beautiful.bg_focus .. '" background="' .. beautiful.fg_focus .. '">'
        else
            result = result .. '<u>'
        end
        result = result .. entry_text:sub(entry_position + 1, entry_position + 1)
        if inverse then
            result = result .. '</span>'
        else
            result = result .. '</u>'
        end
        result = result .. entry_text:sub(entry_position + 2, entry_text:len()) .. '</tt>'
        return result
    end

    local insert_char = function(char)
        entry_text = entry_text:sub(0, entry_position) .. char .. entry_text:sub(entry_position + 1, entry_text:len())
        entry_position = entry_position + 1
    end

    local entry = wibox.widget.textbox(markup_with_cursor(false), false)
    entry:set_align('left')
    local entry_background = wibox.widget.background(entry, beautiful.bg_focus)
    local entry_margin_inner = wibox.container.margin(entry_background, margin, margin, margin, margin, beautiful.bg_focus)
    local entry_margin = wibox.container.margin(entry_margin_inner, margin*2, margin*2, 0, margin*2)

    local first_button = wibox.widget.textbox(first_button_text, false)
    first_button:set_align('center')
    local first_background = wibox.widget.background(first_button, beautiful.bg_focus)
    local first_margin_inner = wibox.container.margin(first_background, margin, margin, margin, margin, beautiful.bg_focus)
    local first_border = wibox.container.margin(first_margin_inner, 1, 1, 1, 1, beautiful.fg_focus)
    local first_margin_outer = wibox.container.margin(first_border, margin*2, margin, 0, margin*2)

    local second_button = wibox.widget.textbox(second_button_text, false)
    second_button:set_align('center')
    local second_background = wibox.widget.background(second_button, beautiful.bg_normal)
    local second_margin_inner = wibox.container.margin(second_background, margin, margin, margin, margin, beautiful.bg_normal)
    local second_border = wibox.container.margin(second_margin_inner, 1, 1, 1, 1, beautiful.bg_focus)
    local second_margin_outer = wibox.container.margin(second_border, margin, margin*2, 0, margin*2)

    local buttons_layout = wibox.layout.flex.horizontal()
    buttons_layout:add(first_margin_outer)
    buttons_layout:add(second_margin_outer)

    local main_layout = wibox.layout.fixed.vertical()
    main_layout:add(margin_message)
    main_layout:add(entry_margin)
    main_layout:add(buttons_layout)
    --TOOD fix
    local height = 180

    local window = wibox({
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
    })
    window:set_widget(main_layout)

    local active_button = 0
    local function set_active(button)
        if button == 0 then
            active_button = 0
            first_background:set_bg(beautiful.bg_focus)
            first_margin_inner:set_color(beautiful.bg_focus)
            first_border:set_color(beautiful.fg_focus)
            second_background:set_bg(beautiful.bg_normal)
            second_margin_inner:set_color(beautiful.bg_normal)
            second_border:set_color(beautiful.bg_focus)
        elseif button == 1 then
            active_button = 1
            first_background:set_bg(beautiful.bg_normal)
            first_margin_inner:set_color(beautiful.bg_normal)
            first_border:set_color(beautiful.bg_focus)
            second_background:set_bg(beautiful.bg_focus)
            second_margin_inner:set_color(beautiful.bg_focus)
            second_border:set_color(beautiful.fg_focus)
        end
    end

    local close
    local function key_grabber(mod, key, event)
        if event ~= 'press' then return end
        if key == 'Escape' then
            close(false)
        elseif key == 'Tab' then
            set_active((active_button + 1)%2)
        elseif key == 'Right' and entry_position < (entry_text:len() - 1) then
            entry_position = entry_position + 1
            entry:set_markup(markup_with_cursor(false))
        elseif key == 'Left' and entry_position > 0 then
            entry_position = entry_position - 1
            entry:set_markup(markup_with_cursor(false))
        elseif key == 'Delete' and entry_position < (entry_text:len() - 1) then
            entry_text = entry_text:sub(0, entry_position) .. entry_text:sub(entry_position + 2, entry_text:len())
            entry:set_markup(markup_with_cursor(false))
        elseif key == 'BackSpace' and entry_position > 0 then
            entry_text = entry_text:sub(0, entry_position - 1) .. entry_text:sub(entry_position + 1, entry_text:len())
            entry_position = entry_position - 1
            entry:set_markup(markup_with_cursor(false))
        elseif key == 'Enter' or key == 'Return' then
            close(active_button == 0)
        elseif key:len() == 1 then
            insert_char(key)
            entry:set_markup(markup_with_cursor(false))
        end
    end

    close = function(action)
        keygrabber.stop(key_grabber)
        mousegrabber.stop()
        main_layout:reset()
        window.visible = false
        if action then
            command(entry_text:sub(0, entry_text:len() - 1))
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
