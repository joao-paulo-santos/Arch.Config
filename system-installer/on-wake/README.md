# Wake Scripts

This directory contains scripts that run **after** the system resumes from sleep/suspend.

## Current Scripts

- `01-restart-user-services.sh` - Restarts user services
- `02-refresh-system.sh` - Refreshes NetworkManager and clears stale files

## Documentation

See the main [Sleep/Wake Scripts documentation](../run-on-wake-README.md) for:
- Complete setup instructions
- How to add custom scripts
- Testing and debugging
- Script templates
- Common use cases

## Quick Test

```bash
# Test this wake script
./01-restart-user-services.sh

# Test all wake scripts through the system
sudo ../run-on-wake.sh post suspend
```