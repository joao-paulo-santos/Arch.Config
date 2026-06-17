-- Autostart: runs on hyprland.start event
hl.on("hyprland.start", function()
    -- Core services
    hl.exec_cmd("hypridle")
    hl.exec_cmd("swaync")

    -- Waybar with per-user profile
    local user = os.getenv("USER") or "ecila"
    hl.exec_cmd("~/.config/waybar/scripts/waybar-profile.sh " .. user)

    hl.exec_cmd("awww-daemon")

    -- Portals and agents
    hl.exec_cmd("/usr/lib/xdg-desktop-portal-hyprland")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("/usr/bin/gnome-keyring-daemon --daemonize --replace --components=secrets")

    -- Wallpaper
    hl.exec_cmd("awww img ~/.config/hypr/wallpapers/mount.jpg")
    hl.exec_cmd("hypr-bg-manager -d ~/.config/hypr/wallpapers -i global -t timer --interval 600 -s awww -o all")
end)
