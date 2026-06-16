# hypr-greet custom greeter

Custom Wayland greeter using greetd + Hyprland + WebKit2 (HTML/CSS/JS).

## ⚠️ Manual setup required

This greeter is **not auto-installed** because:
- The source code lives in a private GitHub repo
- It references paths on mounted drives that won't exist on another machine
- It requires manual configuration (monitors, NVIDIA env vars, user paths)

## What it does

A login screen with:
- Video wallpaper backgrounds (per-user folders)
- User profile photos
- Session picker (Hyprland, etc.)
- Guest ephemeral sessions
- Mute/volume control
- Power buttons (shutdown, reboot, suspend)

## Dependencies

```
greetd hyprland python-gobject webkit2gtk-4.1
```

## Manual setup

1. Clone the repo:
   ```bash
   git clone git@github.com:joao-paulo-santos/hypr-greet.git ~/Dev/Repos/hypr-greet
   ```

2. Create greeter user:
   ```bash
   sudo useradd -r -s /sbin/nologin greeter
   ```

3. Copy and edit the greetd config — update the paths to match your system:
   ```bash
   sudo mkdir -p /etc/greetd
   sudo cp greetd.toml /etc/greetd/config.toml
   # Edit the command path to point to your hypr-greet location
   ```

4. Edit `hyprland-greeter.conf` — update monitor names and paths for your hardware

5. Set up wallpapers:
   ```bash
   sudo mkdir -p /usr/share/backgrounds/greeter/$USER
   ```

6. Enable greetd:
   ```bash
   sudo systemctl enable greetd
   ```

See the repo's README.md for full documentation.
