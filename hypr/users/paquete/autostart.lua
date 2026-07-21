-- paquete's autostart: services launched on hyprland.start

hl.on("hyprland.start", function()
    -- Core services
    hl.exec_cmd("hypridle")

    -- Portals and agents
    hl.exec_cmd("/usr/lib/xdg-desktop-portal-hyprland")
    hl.exec_cmd("/usr/bin/gnome-keyring-daemon --daemonize --replace --components=secrets")

    -- Noctalia (paquete's instance)
    hl.exec_cmd("NOCTALIA_CONFIG_HOME=~/.config/noctalia/paquete/conf NOCTALIA_STATE_HOME=~/.config/noctalia/paquete/state noctalia")
end)
