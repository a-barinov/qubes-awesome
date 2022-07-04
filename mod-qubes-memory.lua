local awful = require('awful')
local math = require("math")


widgets.xen_memory = {
    -- plugin configuration
    threshold = 0.75,

    -- plugin description
    name = 'XEN Memory',
    enabled = false,

    -- callback for external script
    set_status = function(total, used)
        if used/total >= widgets.xen_memory.threshold then
            widgets.xen_memory.enabled = true
            widgets.indicator.set_text(widgets.xen_memory, tostring(math.floor(used/total*100)) .. '%')
        else
            widgets.xen_memory.enabled = false
        end
        widgets.indicator.set_state(widgets.xen_memory)
    end,
}
widgets.indicator.create(widgets.xen_memory, '󰆪')
