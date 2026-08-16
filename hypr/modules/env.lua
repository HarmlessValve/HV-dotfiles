-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- Existing config
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_THEME", "Adwaita")
hl.env("HYPRCURSOR_SIZE", "20")
hl.env("GDK_SCALE", "1")

-- Environment Variables untuk DBus / Wayland
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- NVIDIA Hardware Acceleration & Driver Setup
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
