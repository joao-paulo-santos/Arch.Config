# Sleep/Wake Scripts

This directory contains scripts that automatically run when the system goes to sleep and wakes up from sleep/suspend.

## How it works

1. `run-on-wake.sh` - Main script that gets symlinked to `/lib/systemd/system-sleep/`
2. `on-wake/` - Directory containing wake scripts
3. `on-sleep/` - Directory containing pre-sleep scripts  
4. When system goes to sleep or wakes up, systemd calls the main script
5. The main script runs all executable scripts in the appropriate directory as your user

## Script Directories

### on-wake/ (Post-Sleep Scripts)
Scripts that run **after** the system resumes from sleep:
- Refreshing wallpapers
- Restarting services that might hang after suspend
- Updating system time and network connections
- Clearing stale lock files

### on-sleep/ (Pre-Sleep Scripts)  
Scripts that run **before** the system goes to sleep:
- Saving session state and open applications
- Stopping services gracefully
- Syncing important data and history
- Preparing the system for sleep

## Installation

The installer automatically sets this up, but you can also do it manually:

```bash
sudo ln -sf ~/.config/system-installer/run-on-wake.sh /lib/systemd/system-sleep/run-on-wake.sh
```

## Adding your own scripts

1. Create a script in either `on-wake/` or `on-sleep/` directory
2. Make it executable: `chmod +x on-wake/your-script.sh` or `chmod +x on-sleep/your-script.sh`
3. Use a numbered prefix for execution order: `01-`, `02-`, etc.

## Example scripts included

### Wake Scripts (on-wake/)
- `01-refresh-wallpaper.sh` - Changes wallpaper to a random one from current workspace
- `02-restart-user-services.sh` - Restarts specified user systemd services  
- `03-refresh-system.sh` - Refreshes network, waybar, and system time

### Pre-Sleep Scripts (on-sleep/)
- `save-session.sh` - Saves current wallpaper, open windows, and workspace state
- `stop-services.sh` - Gracefully stops media players and development servers
- `sync-data.sh` - Syncs filesystem, saves shell history, and backs up tmux sessions

## Logs

Script execution is logged to `/var/log/run-on-wake.log`

```bash
# View script logs
sudo tail -f /var/log/run-on-wake.log

# View recent sleep/wake activity
sudo tail -20 /var/log/run-on-wake.log
```

## Common use cases

### Wake Scripts
- Refresh wallpapers
- Restart user services that might hang after suspend
- Reconnect to network services
- Update system time
- Clear stale lock files
- Refresh status bars
- Re-initialize hardware that doesn't resume properly

### Pre-Sleep Scripts
- Save current application state
- Stop media playback
- Gracefully shutdown development servers
- Sync filesystem buffers
- Save shell history
- Backup tmux sessions
- Stop resource-intensive processes

## Script templates

### Wake Script Template
```bash
#!/bin/bash

# Wake script description
# This script runs when the system wakes from sleep

echo "Running my wake script..."

# Your code here
# Remember: this runs as your user, not as root

echo "Wake script completed"
```

### Pre-Sleep Script Template
```bash
#!/bin/bash

# Pre-sleep script description  
# This script runs before the system goes to sleep

echo "Preparing for sleep..."

# Your code here
# Good for saving state, stopping services, syncing data

echo "Ready for sleep"
```

## Testing

You can test your scripts by running them manually:

```bash
# Test individual wake script
./on-wake/01-refresh-wallpaper.sh

# Test individual pre-sleep script
./on-sleep/save-session.sh

# Test all pre-sleep scripts (as they would run before sleep)
sudo ./run-on-wake.sh pre suspend

# Test all wake scripts (as they would run on wake)
sudo ./run-on-wake.sh post suspend
```

## Debugging

1. Check the log file: `/var/log/run-on-wake.log`
2. Make sure scripts are executable: `ls -la on-wake/`
3. Test scripts manually to ensure they work
4. Check systemd sleep hooks: `ls -la /lib/systemd/system-sleep/`