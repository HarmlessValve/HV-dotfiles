-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
local programs = require("programs")

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
hl.on("hyprland.start", function()
        -- D-Bus & Wayland Environment Integration (Pencegah Delay 10 Detik)
        hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
        hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

        -- App Daemons
        hl.exec_cmd("mako") -- Notification daemon (blackturq theme)
        hl.exec_cmd("waybar") -- Status bar (blackturq theme)
        hl.exec_cmd("swayosd") -- Volume/brightness OSD (blackturq theme)
        hl.exec_cmd("walker --gapplication-service") -- Walker daemon (required for Super)
        hl.exec_cmd("awww-daemon") -- Wallpaper daemon (swww fork)
        hl.exec_cmd(
                "sleep 1 && awww img --transition-type fade --transition-duration 2 "
                        .. os.getenv("HOME")
                        .. "/Pictures/backgrounds/mech.jpg"
        )
end)
