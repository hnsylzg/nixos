-- Hyprland Lua config (0.55+)
-- Migrated from the old hyprlang config. The legacy .conf files
-- (hyprland.conf, keybindings.conf, windowrules.conf, config.d/* theme/userprefs,
-- nvidia.conf, theme-matcha.conf) are removed -- everything now lives in these .lua files.
-- Binds / window rules live in keybindings.lua / windowrules.lua (separate scopes,
-- so a runtime error there will not abort this core file).

-------------------
---- MONITOR ------
-------------------
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

---------------------------
---- ENVIRONMENT VARS ------
---------------------------
hl.env("EDITOR", "nvim")
hl.env("TERMINAL", "foot")
hl.env("SHELL", "fish")
hl.env("MOZ_DBUS_REMOTE", "1")
hl.env("GTK_CSD", "0")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

-- NOTE: config.d/userprefs.conf forced software GL. Kept as-is for behavior parity,
-- but on an NVIDIA machine this is almost certainly unintended — see migration notes.
hl.env("LIBGL_ALWAYS_SOFTWARE", "true")

-------------------
---- INPUT --------
-------------------
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

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

-------------------
---- ANIMATIONS ----
-------------------
hl.config({ animations = { enabled = true } })

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("liner",    { type = "bezier", points = { { 1, 1 }, { 1, 1 } } })

hl.animation({ leaf = "windows",     enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7,  bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6,  bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 75, bezier = "liner", loop = true })

-------------------
---- LAYOUTS ------
-------------------
hl.config({
    dwindle = {
        -- NOTE: dwindle.pseudotile was removed in Hyprland 0.55; pseudotiling
        -- is now a runtime toggle via the `window.pseudo` dispatcher (bound to SUPER+P).
        preserve_split = true, -- you probably want this
    },
    master = {
        new_status = "master",
    },
})

-------------------
---- MISC ----------
-------------------
hl.config({
    misc = {
        disable_hyprland_logo   = true,
        force_default_wallpaper = -1, -- Set to 0 to disable the anime mascot wallpapers
    },
})

hl.config({
    xwayland = {
        force_zero_scaling = true,
    },
})

-------------------
---- AUTOSTART (replaces exec-once) ----
-------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("fcitx5 -d")
    hl.exec_cmd("waypaper --restore")
    hl.exec_cmd("waybar")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("nice -n 15 thunar --daemon")
    hl.exec_cmd("ionice -c 3 playerctld daemon")
    hl.exec_cmd([[wl-clip-persist --clipboard regular --all-mime-type-regex '(?i)^(?!image/x-inkscape-svg).+']])
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd([[until pgrep -x waybar >/dev/null; do sleep 0.3; done; sleep 2; wl-paste --watch pkill -RTMIN+9 waybar]])
    hl.exec_cmd([[swayidle -w timeout 300 'swaylock -f -c 000000 --show-failed-attempts --fade-in 0.2 --grace 5 --grace-no-mouse --effect-vignette 0.5:0.5 --effect-blur 7x5 --ignore-empty-password --screenshots --clock' timeout 600 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' timeout 900 'systemctl suspend']])
end)

-------------------
---- MODULAR CONFIGS ----
-------------------
require("keybindings")
require("windowrules")
