-- ecila's autostart: services launched on hyprland.start
-- Combines shared services + ecila's user-specific session.

hl.on("hyprland.start", function()
    -- Core services
    hl.exec_cmd("hypridle")
    -- hl.exec_cmd("swaync")
    -- hl.exec_cmd("awww-daemon")

    -- Portals and agents
    hl.exec_cmd("/usr/lib/xdg-desktop-portal-hyprland")
    -- hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("/usr/bin/gnome-keyring-daemon --daemonize --replace --components=secrets")

    -- Wallpaper (disabled — testing noctalia wallpaper switcher)
    -- hl.exec_cmd("awww img ~/.config/hypr/wallpapers/mount.jpg")
    -- hl.exec_cmd("hypr-bgmanager -d ~/.config/hypr/wallpapers -i global -t timer --interval 600 -s awww -o all")

    -- Noctalia (ecila's instance)
    hl.exec_cmd("NOCTALIA_CONFIG_HOME=~/.config/noctalia/ecila/conf NOCTALIA_STATE_HOME=~/.config/noctalia/ecila/state noctalia")
end)
