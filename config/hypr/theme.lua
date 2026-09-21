-- 主题设置：移植自 dotfiles 的 config/hypr/theme.lua（hyprconf2lua v1.4.0 生成）
-- 原文件里 col.* 是 Arch 侧 matugen 的 $outline / $outline_variant 占位，
-- 这里按本仓库静态深色配色（同 waybar/colors.css）填实。

---@module 'hl'

hl.config({
    general = {
        -- See https://wiki.hyprland.org/Configuring/Variables/ for more
        gaps_in = 3,
        gaps_out = 6,
        border_size = 2,
        col = {
            active_border   = "rgb(edb1ff)", -- $outline         → primary #edb1ff
            inactive_border = "rgb(4d444e)", -- $outline_variant → #4d444e
        },
        layout = "dwindle",
        -- Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
        allow_tearing = false,
    },
})

hl.config({
    decoration = {
        -- See https://wiki.hyprland.org/Configuring/Variables/ for more
        rounding = 12,
        active_opacity = 1.0,
        inactive_opacity = 0.9,
        shadow = {
            enabled = true,
            range = 30,
            render_power = 5,
            offset = "0 5",
            color = "rgba(00000070)",
        },
        -- dotfiles 这份没有模糊；仓库旧主题曾开启，需要的话取消注释
        -- blur = { enabled = true, size = 3, passes = 1 },
    },
})
