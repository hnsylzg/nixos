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

hl.env("XCURSOR_SIZE", "24")

hl.env("QT_QPA_PLATFORM", "wayland;xcb")

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

hl.env("QT_QPA_PLATFORMTHEME", "gtk3")

hl.env("QT_QPA_PLATFORMTHEME_QT6", "gtk3")

hl.env("TERMINAL", "kitty")


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
	hl.exec_cmd("dbus-update-activation-environment --systemd --all")
	hl.exec_cmd("systemctl --user start hyprland-session.target")
	-- polkit 认证代理不在 hypr 内启动：NixOS 没有 /usr/lib，且本文件是纯部署（非 nix 模板），
	-- 无法写 ${pkgs.polkit_gnome} 的 store 路径。改由 home.nix 的 systemd 用户单元
	-- polkit-gnome-auth-agent 拉起（与 waybar/mpd/dunst 同一套路）。
	hl.exec_cmd("waypaper --restore")
	hl.exec_cmd("fcitx5 -d")
	hl.exec_cmd("nm-applet")
	hl.exec_cmd("wl-clip-persist --clipboard regular --all-mime-type-regex '(?i)^(?!image/x-inkscape-svg).+'")
	hl.exec_cmd("wl-paste --watch cliphist store")
	hl.exec_cmd("wl-paste --watch pkill -RTMIN+9 waybar")
	hl.exec_cmd(
		"swayidle -w timeout 300 'swaylock -f -c 000000 --show-failed-attempts --fade-in 0.2 --grace 5 --grace-no-mouse --effect-vignette 0.5:0.5 --effect-blur 7x5 --ignore-empty-password --screenshots --clock' timeout 600 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' timeout 900 'systemctl suspend'"
	)
	hl.exec_cmd("playerctld daemon")
end)

-------------------
---- MODULAR CONFIGS ----
-------------------
require("theme")
require("keybindings")
require("windowrules")
