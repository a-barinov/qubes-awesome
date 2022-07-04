theme = {}

if config.id == "GPDWIN2" then
    theme.font      = "Sans Regular 10"
    theme.icon_font = "Material Design Icons Regular 10"
    theme.menu_divider_font = "Sans Bold 10"
    theme.menu_width        = 200
    theme.menu_height       = 24
    theme.statusbar_height  = 22
    theme.tasklist_width    = 250
end
if config.id == "L380" then
    theme.font      = "Sans Regular 10"
    theme.icon_font = "Material Design Icons Regular 10"
    theme.menu_divider_font = "Sans Bold 10"
    theme.menu_width        = 200
    theme.menu_height       = 24
    theme.statusbar_height  = 22
    theme.tasklist_width    = 250
end
if config.id == "OneMix4" then
    theme.font      = "Sans Regular 16"
    theme.icon_font = "Material Design Icons Regular 16"
    theme.menu_divider_font = "Sans Bold 16"
    theme.menu_width        = 300
    theme.menu_height       = 38
    theme.statusbar_height  = 38
    theme.tasklist_width    = 350
end

theme.fg_normal = "#CCCCCC"
theme.fg_focus  = "#EEEEEE"
theme.fg_urgent = "#FFCCCC"
theme.bg_normal = "#222222"
theme.bg_focus  = "#444444"
theme.bg_urgent = "#664444"

theme.border_width  = 2
theme.border_normal = theme.bg_normal
theme.border_focus  = theme.bg_normal
theme.border_marked = theme.bg_normal

theme.titlebar_bg_focus  = theme.bg_normal
theme.titlebar_bg_normal = theme.bg_normal
theme.titlebar_fg_focus  = theme.fg_normal
theme.titlebar_fg_normal = theme.fg_normal

theme.menu_divider_bg   = "#000000"
theme.menu_submenu      = ">"
theme.menu_border_color = theme.bg_focus
theme.menu_border_width = 0

theme.tasklist_disable_icon = true

theme.tasklist_sticky = ""
theme.tasklist_ontop = ""
theme.tasklist_floating = ""
theme.tasklist_maximized_horizontal = ""
theme.tasklist_maximized_vertical = ""

theme.wallpaper = config.home .. "wallpaper.png"

theme.colors = {
    ['green'] = '#226622',
    ['orange'] = '#886622',
    ['grey'] = '#666666',
    ['red'] = '#662222',
    ['blue'] = '#222266',
}


return theme
