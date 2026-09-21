-- Window rules (migrated from windowrules.conf)
-- Runs in its own scope (required by hyprland.lua).

-------------------
---- FLOAT DIALOGS / FILE PICKERS ----
-------------------
hl.window_rule({ name = "float-open-file",    match = { title = "^(Open File)(.*)$" },            float = true })
hl.window_rule({ name = "float-select-file",  match = { title = "^(Select a File)(.*)$" },        float = true })
hl.window_rule({ name = "float-choose-wp",    match = { title = "^(Choose wallpaper)(.*)$" },      float = true })
hl.window_rule({ name = "float-open-folder",  match = { title = "^(Open Folder)(.*)$" },          float = true })
hl.window_rule({ name = "float-save-as",      match = { title = "^(Save As)(.*)$" },              float = true })
hl.window_rule({ name = "float-library",      match = { title = "^(Library)(.*)$" },              float = true })
hl.window_rule({ name = "float-open-file-cn", match = { title = "^(打开文件)(.*)$" },        float = true })
hl.window_rule({ name = "float-open-folder-cn",match = { title = "^(打开文件夹)(.*)$" },      float = true })
hl.window_rule({ name = "float-confirm-replace", match = { title = "^(确认文件替换)(.*)$" }, float = true })
hl.window_rule({ name = "float-waypaper",     match = { class = "^(waypaper)$" },                 float = true })
hl.window_rule({ name = "float-polkit",       match = { class = "^(org.kde.polkit-kde-authentication-agent-1)$" }, float = true })

-------------------
---- xdg-desktop-portal FILE PICKERS ----
-------------------
hl.window_rule({ name = "float-portal-open",     match = { class = "^(xdg-desktop-portal-gtk)$", title = "^(Open File)$" },     float = true })
hl.window_rule({ name = "float-portal-folder",   match = { class = "^(xdg-desktop-portal-gtk)$", title = "^(Open Folder)$" },   float = true })
hl.window_rule({ name = "float-portal-of-cn",    match = { class = "^(xdg-desktop-portal-gtk)$", title = "^(打开文件)$" }, float = true })
hl.window_rule({ name = "float-portal-fd-cn",    match = { class = "^(xdg-desktop-portal-gtk)$", title = "^(打开文件夹)$" }, float = true })
hl.window_rule({ name = "float-portal-ws-open",  match = { class = "^(xdg-desktop-portal-gtk)$", title = "^(从文件打开工作区)$" }, float = true })
hl.window_rule({ name = "float-portal-saveas",   match = { class = "^(xdg-desktop-portal-gtk)$", title = "^(另存为)$" },  float = true })
hl.window_rule({ name = "float-portal-savews",   match = { class = "^(xdg-desktop-portal-gtk)$", title = "^(保存工作区)$" }, float = true })
hl.window_rule({ name = "float-portal-addfolder",match = { class = "^(xdg-desktop-portal-gtk)$", title = "^(将文件夹添加到工作区)$" }, float = true })

-------------------
---- OPACITY: FILE MANAGERS ----
-------------------
local fm_classes = {
    "pcmanfm-qt", "nemo", "org.gnome.Nautilus", "org.kde.dolphin",
    "thunar", "Thunar", "file-roller", "xarchiver", "mousepad",
}
for _, c in ipairs(fm_classes) do
    hl.window_rule({ name = "opacity-fm-" .. c, match = { class = "^(" .. c .. ")$" }, opacity = "0.8" })
end

-------------------
---- OPACITY: MISC ----
-------------------
hl.window_rule({ name = "opacity-code-url",     match = { class = "^(code-url-handler)$" },               opacity = "0.9" })
hl.window_rule({ name = "opacity-pamac",        match = { class = "^(org.manjaro.pamac.manager)$" },      opacity = "0.8" })
hl.window_rule({ name = "opacity-waypaper",     match = { class = "^(waypaper)$" },                        opacity = "0.95" })
hl.window_rule({ name = "opacity-spotify",      match = { class = "^(Spotify)$" },                         opacity = "0.8" })
hl.window_rule({ name = "opacity-octopi",       match = { class = "^(octopi)$" },                          opacity = "0.8" })
hl.window_rule({ name = "opacity-partition",    match = { class = "^(org.kde.partitionmanager)$" },        opacity = "0.8" })

-------------------
---- TRAY APPS: FLOAT + OPACITY ----
-------------------
hl.window_rule({ name = "float-opacity-nm-applet",  match = { class = "^(nm-applet)$" },   float = true, opacity = "0.9" })
hl.window_rule({ name = "float-opacity-nm-editor",  match = { class = "^(nm-connection-editor)$" }, float = true, opacity = "0.9" })
hl.window_rule({ name = "float-opacity-qq",         match = { class = "^(QQ)$" },          float = true, opacity = "0.9" })
hl.window_rule({ name = "float-opacity-wechat",     match = { class = "^(wechat)$" },      float = true, opacity = "0.9" })

-------------------
---- floating_shell ----
-------------------
hl.window_rule({ name = "float-shell",  match = { class = "floating_shell" }, float = true })
hl.window_rule({ name = "center-shell", match = { class = "floating_shell" }, center = true })
