-- Keybindings (migrated from keybindings.conf)
-- This file is required by hyprland.lua. It runs in its own scope, so a mistake
-- here will not abort the core config.

local mainMod    = "SUPER" -- Sets "Windows" key as main modifier
local terminal    = "kitty"
local fileManager = "thunar"
local browser     = "google-chrome-stable"
local code        = "code"
local menu        = "fuzzel"
local locking     = "swaylock -f -c 000000 --show-failed-attempts --fade-in 0.2 --grace 5 --grace-no-mouse --effect-vignette 0.5:0.5 --effect-blur 7x5 --ignore-empty-password --screenshots --clock"

-------------------
---- SUBMAPS ------
-------------------

-- Power menu: SUPER + SHIFT + E
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.submap(" (l)锁定 (e)注销 (r)重启 (u)睡眠 (s)关机"))
hl.define_submap(" (l)锁定 (e)注销 (r)重启 (u)睡眠 (s)关机", function()
    hl.bind("L", hl.dsp.exec_cmd(locking))
    hl.bind("L", hl.dsp.submap("reset"))
    hl.bind("E", hl.dsp.exit())
    hl.bind("R", hl.dsp.exec_cmd("systemctl reboot"))
    hl.bind("U", hl.dsp.exec_cmd("systemctl suspend"))
    hl.bind("U", hl.dsp.submap("reset"))
    hl.bind("S", hl.dsp.exec_cmd("systemctl poweroff"))
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Screenshot picker: Print
hl.bind("print", hl.dsp.submap("󰄄 Pick (p) Output (o)+ Shift for "))
hl.define_submap("󰄄 Pick (p) Output (o)+ Shift for ", function()
    hl.bind("P", hl.dsp.exec_cmd([=[grimblast save area - | swappy -f - && [[ $(wl-paste -l) == "image/png" ]] && notify-send "Screenshot copied to clipboard"]=]))
    hl.bind("P", hl.dsp.submap("reset"))
    hl.bind("O", hl.dsp.exec_cmd([=[grimblast save output - | swappy -f - && [[ $(wl-paste -l) == "image/png" ]] && notify-send "Screenshot copied to clipboard"]=]))
    hl.bind("O", hl.dsp.submap("reset"))
    hl.bind("SHIFT + P", hl.dsp.exec_cmd([[bash -c 'grimblast save area - | curl -s -F "file=@-;filename=.png" https://x0.at/ | tee >(wl-copy) >(xargs notify-send)']]))
    hl.bind("SHIFT + P", hl.dsp.submap("reset"))
    hl.bind("SHIFT + O", hl.dsp.exec_cmd([[bash -c 'grimblast save output - | curl -s -F "file=@-;filename=.png" https://x0.at/ | tee >(wl-copy) >(xargs notify-send)']]))
    hl.bind("SHIFT + O", hl.dsp.submap("reset"))
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Recording: SUPER + SHIFT + R
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.submap(" Record (r)+ [Shift for 󰍮]"))
hl.define_submap(" Record (r)+ [Shift for 󰍮]", function()
    hl.bind("R", hl.dsp.exec_cmd("$HOME/.config/waybar/scripts/recorder.sh"))
    hl.bind("R", hl.dsp.submap("reset"))
    hl.bind("SHIFT + R", hl.dsp.exec_cmd("$HOME/.config/waybar/scripts/recorder.sh -a"))
    hl.bind("SHIFT + R", hl.dsp.submap("reset"))
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-------------------
---- GLOBAL BINDS ----
-------------------

-- Stop wf-recorder
hl.bind(mainMod .. " + escape", hl.dsp.exec_cmd("killall -s SIGINT wf-recorder"))

-- Clipboard history
hl.bind("SUPER + V", hl.dsp.exec_cmd([[cliphist list | rofi -dmenu -p "Select item to copy" | cliphist decode | wl-copy]]))

-- Launch apps
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.kill())
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(code))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("$HOME/.config/waybar/scripts/launcher.sh"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("$HOME/.config/waybar/scripts/powermenu.sh"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Restart waybar (original used an undefined $CONTROL var -> interpreted as bare ESC;
-- fixed to CTRL + ESC, which was the obvious intent)
hl.bind("CTRL + ESCAPE", hl.dsp.exec_cmd("killall waybar || waybar"))

hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("waypaper"))

-- Non-consuming: close floating_shell windows on escape without swallowing the key
hl.bind("escape", hl.dsp.exec_cmd([[hyprctl dispatch closewindow "title:^floating_shell$"]]), { non_consuming = true })

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(i) }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),  { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-------------------
---- VOLUME / MEDIA ----
-------------------
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),       { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),     { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl pause"))
hl.bind("XF86AudioStop",  hl.dsp.exec_cmd("playerctl stop"))
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"))
hl.bind("ALT + space",  hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("ALT + return", hl.dsp.exec_cmd("playerctl stop"))
hl.bind("ALT + left",   hl.dsp.exec_cmd("playerctl previous"))
hl.bind("ALT + right",  hl.dsp.exec_cmd("playerctl next"))
hl.bind("ALT + up",     hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("ALT + down",   hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))

-------------------
---- BRIGHTNESS ----
-------------------
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s +5%"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"))
