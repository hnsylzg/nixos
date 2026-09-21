-- 主题配置（从 hyprland.lua 拆出，对应 dotfiles 的 config/hypr/theme.lua）

-------------------
---- THEME: Catppuccin (config.d/theme-catppuccin.conf) ----
-------------------
hl.config({
    general = {
        gaps_in     = 3,
        gaps_out    = 6,
        border_size = 3,

        col = {
            inactive_border = "0xff414868", -- Inactive gray
            active_border   = {
                colors = { "rgb(8839EF)", "rgb(7CB6F5)", "rgb(FD807E)" },
                angle  = 45,
            },
        },

        layout        = "dwindle",
        allow_tearing = false,
    },

    group = {
        col = {
            border_active           = { colors = { "rgba(ca9ee6ff)", "rgba(f2d5cfff)" }, angle = 45 },
            border_inactive         = { colors = { "rgba(b4befecc)", "rgba(6c7086cc)" }, angle = 45 },
            border_locked_active    = { colors = { "rgba(ca9ee6ff)", "rgba(f2d5cfff)" }, angle = 45 },
            border_locked_inactive  = { colors = { "rgba(b4befecc)", "rgba(6c7086cc)" }, angle = 45 },
        },
    },

    decoration = {
        rounding = 10,

        blur = {
            enabled = true,
            size    = 3,
            passes  = 1,
        },

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },
    },

    render = {
        cm_enabled = false,
    },
})
