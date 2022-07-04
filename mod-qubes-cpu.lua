local awful = require('awful')
local math = require("math")


widgets.xen_cpu = {
    -- plugin configuration
    threshold = 100,

    -- plugin description
    name = 'XEN CPU',
    enabled = false,

    -- callback for external script
    set_status = function(cpus, usage)
        if usage >= widgets.xen_cpu.threshold then
            widgets.xen_cpu.enabled = true
            widgets.indicator.set_text(widgets.xen_cpu, tostring(usage) .. '%')
        else
            widgets.xen_cpu.enabled = false
        end
        widgets.indicator.set_state(widgets.xen_cpu)
    end,
}
widgets.indicator.create(widgets.xen_cpu, '󰭄')
