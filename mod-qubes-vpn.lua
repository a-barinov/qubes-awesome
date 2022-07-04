local awful = require("awful")

-- Initial state
widgets.vpn = {
    name = 'VPN',
    enabled = false,
    priority = 2,
    menu_category = 'connection',
    menu = {
        [1] = {
            glyph = function()
                if widgets.vpn.state == 'connected' then
                    return '󰯄'
                else
                    return '󰯅'
                end
            end,
            label = function()
                if widgets.vpn.state == 'connected' then
                    return 'VPN: On'
                elseif widgets.vpn.state == 'connecting' then
                    return 'Connecting'
                else
                    return 'VPN: Off'
                end
            end,
            first_action = function()
                if vm_state("core-vpn-ssh") == 'running' then
                    awful.spawn('qvm-shutdown --quiet --force core-vpn-ssh')
                else
                    awful.spawn('qvm-start --quiet --skip-if-running core-vpn-ssh')
                end
            end,
        },
    },

    -- private interface
    state = '',

    -- run on startup
    startup = function()
        if vm_state("core-vpn-ssh") == 'running' then
            widgets.vpn.state = 'connetced'
        else
            widgets.vpn.state = ''
        end
        vm_state_change('core-vpn-ssh', function(state)
            if state == 'domain-start' then
                widgets.vpn.state = 'disconnetced'
            else
                widgets.vpn.state = ''
            end
            widgets.vpn.widget_update()
        end)
    end,

    -- update widget based on internal state
    widget_update = function()
        if widgets.vpn.state == '' then
            widgets.vpn.enabled = false
            widgets.indicator.set_text(widgets.vpn, 'Off')
        else
            widgets.vpn.enabled = true
            if widgets.vpn.state == 'connected' then
                widgets.indicator.set_text(widgets.vpn, '')
                widgets.indicator.set_icon(widgets.vpn, '󰯄')
            elseif widgets.vpn.state == 'connecting' then
                widgets.indicator.set_text(widgets.vpn, '--')
                widgets.indicator.set_icon(widgets.vpn, '󰯅')
            else
                widgets.indicator.set_text(widgets.vpn, 'Off')
                widgets.indicator.set_icon(widgets.vpn, '󰯅')
            end
        end
        widgets.indicator.set_state(widgets.vpn)
    end,
}
widgets.indicator.create(widgets.vpn, '󰯅')


-- Callback for external script
vpn_state = function(state)
    widgets.vpn.state = state
    widgets.vpn.widget_update()
end
