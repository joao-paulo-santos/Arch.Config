# Pre-Sleep Scripts

This directory contains scripts that run **before** the system goes to sleep/suspend.

## Current Scripts

- `stop-services.sh` - stops media players and development servers

## Purpose

Pre-sleep scripts help ensure a clean sleep transition by:
- Saving current session state
- Stopping services 
- Syncing important data to prevent loss
- Preparing the system for sleep

## Documentation

See the main [Sleep/Wake Scripts documentation](../sleep-wake-README.md) for:
- Complete setup instructions
- How to add custom scripts
- Testing and debugging
- Script templates and examples
- Common use cases

## Quick Test

```bash
# Test this pre-sleep script
./stop-services.sh

# Test all pre-sleep scripts through the system
sudo ../run-on-wake.sh pre suspend
```

## Script Guidelines

- Keep scripts fast - they run during sleep transition
- Handle errors gracefully (use `|| true` for non-critical commands) 
- Remember: scripts run as your user, not root