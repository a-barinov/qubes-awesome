widgets.clock = {
    -- plugin description
    name = "Clock",
    enabled = true,

    -- update on startup
    startup = function()
        widgets.clock.update()
    end,

    -- update every minute
    update = function()
        widgets.indicator.set_text(widgets.clock, os.date("%R"))
        widgets.clock.alttext = os.date("%a, %b %d, %Y")
    end,

    -- show widgets menu
    on_click = function()
        menu_statusbar()
    end,
}
widgets.indicator.create(widgets.clock, " ")
