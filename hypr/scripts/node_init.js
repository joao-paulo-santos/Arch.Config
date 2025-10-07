#!/usr/bin/env node
// node_init.js

const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const net = require('net');

// Log level configuration
const LOG_LEVELS = {
  DEBUG: 0,
  INFO: 1,
  WARN: 2,
  ERROR: 3
};

// Set log level from environment variable or default to ERROR
const CURRENT_LOG_LEVEL = LOG_LEVELS[process.env.LOG_LEVEL] !== undefined 
  ? LOG_LEVELS[process.env.LOG_LEVEL] 
  : LOG_LEVELS.ERROR;

const SCRIPTS_DIR = path.join(process.env.HOME, '.config', 'hypr', 'scripts');
const LOG_DIR = path.join(SCRIPTS_DIR, 'logs');
const STATE_DIR = path.join(SCRIPTS_DIR, 'state');
if (!fs.existsSync(LOG_DIR)) fs.mkdirSync(LOG_DIR, { recursive: true });
if (!fs.existsSync(STATE_DIR)) fs.mkdirSync(STATE_DIR, { recursive: true });

const PID_FILE = path.join(SCRIPTS_DIR, 'node_init.pid');
const MONITOR_STATE_FILE = path.join(STATE_DIR, 'current_monitor.json');

fs.writeFileSync(PID_FILE, String(process.pid), { flag: 'w' });

// Monitor state management
let currentMonitorState = {
  name: null,
  ddcutilIndex: null
};

// simple logger that writes to rotating files (overwrite per run)
function makeLogger(name) {
  const out = fs.createWriteStream(path.join(LOG_DIR, `${name}.log`), { flags: 'a' });
  return (type, msg) => {
    const level = LOG_LEVELS[type] || LOG_LEVELS.INFO;
    if (level >= CURRENT_LOG_LEVEL) {
      const ts = new Date().toISOString();
      out.write(`${ts} [${type}] ${msg}\n`);
      
      // Also output to console for errors and warnings
      if (level >= LOG_LEVELS.WARN) {
        console.error(`${ts} [${type}] ${msg}`);
      }
    }
  };
}

const logMain = makeLogger('node_init');

// Function to save monitor state to file
function saveMonitorState(monitorName) {
  currentMonitorState.name = monitorName;
  
  // Find ddcutil index for this monitor
  findDdcutilIndex(monitorName).then(index => {
    if (index) {
      currentMonitorState.ddcutilIndex = index;
      try {
        const stateJson = JSON.stringify(currentMonitorState, null, 2);
        fs.writeFileSync(MONITOR_STATE_FILE, stateJson);
        logMain('INFO', `saved monitor state: ${monitorName} -> ddcutil index ${index}`);
      } catch (err) {
        logMain('ERROR', `failed to save monitor state: ${err.message}`);
      }
    } else {
      logMain('WARN', `no ddcutil index found for monitor: ${monitorName}`);
    }
  }).catch(err => {
    logMain('ERROR', `failed to find ddcutil index: ${err.message}`);
  });
}

// Function to find ddcutil index for a monitor name
function findDdcutilIndex(monitorName) {
  return new Promise((resolve, reject) => {
    const ddcProcess = spawn('ddcutil', ['detect', '--brief'], { stdio: ['ignore', 'pipe', 'pipe'] });
    let output = '';
    
    ddcProcess.stdout.on('data', (data) => {
      output += data.toString();
    });
    
    ddcProcess.on('close', (code) => {
      if (code !== 0) {
        reject(new Error(`ddcutil detect failed with code ${code}`));
        return;
      }
      
      const lines = output.split('\n');
      for (const line of lines) {
        // Look for DRM connector that ends with the monitor name
        // e.g., "card2-DP-3" should match monitor name "DP-3"
        if (line.includes('DRM connector') && line.includes(monitorName)) {
          // Find the corresponding Display number by looking backwards
          for (let i = lines.indexOf(line); i >= 0; i--) {
            const displayMatch = lines[i].match(/^Display\s+(\d+)/);
            if (displayMatch) {
              resolve(parseInt(displayMatch[1]));
              return;
            }
          }
        }
      }
      resolve(null);
    });
    
    ddcProcess.on('error', (err) => {
      reject(err);
    });
  });
}

// Load existing monitor state on startup
function loadMonitorState() {
  try {
    if (fs.existsSync(MONITOR_STATE_FILE)) {
      const data = fs.readFileSync(MONITOR_STATE_FILE, 'utf8');
      currentMonitorState = JSON.parse(data);
      logMain('INFO', `loaded monitor state: ${currentMonitorState.name} (ddcutil index: ${currentMonitorState.ddcutilIndex})`);
    }
  } catch (err) {
    logMain('ERROR', `failed to load monitor state: ${err.message}`);
  }
}

// helper: run a command as a supervised child with restart/backoff
function supervise(name, cmd, args = [], opts = {}) {
  const log = makeLogger(name);
  let child = null;
  let restarts = 0;
  let backoff = 500;

  function start() {
    log('INFO', `starting: ${cmd} ${args.join(' ')}`);
    child = spawn(cmd, args, Object.assign({ stdio: ['ignore', 'pipe', 'pipe'] }, opts));

    child.stdout.on('data', d => log('OUT', d.toString().trim()));
    child.stderr.on('data', d => log('ERR', d.toString().trim()));

    child.on('exit', (code, sig) => {
      log('INFO', `exited code=${code} sig=${sig}`);
      child = null;
      restarts++;
      backoff = Math.min(5000, 500 * Math.pow(1.5, restarts));
      setTimeout(start, backoff);
    });

    child.on('error', err => {
      log('ERR', `spawn error: ${err.message}`);
      child = null;
      restarts++;
      backoff = Math.min(5000, backoff * 2);
      setTimeout(start, backoff);
    });
  }

  start();

  return {
    stop: () => {
      if (child) {
        child.removeAllListeners('exit');
        child.kill('SIGTERM');
        child = null;
      }
    }
  };
}

// send a libnotify notification using notify-send so users see it's running
function notify(summary, body) {
  try {
    const s = spawn('notify-send', [summary, body], { stdio: 'ignore' });
    s.on('error', e => logMain('ERR', `notify-send failed: ${e.message}`));
  } catch (e) {
    logMain('ERR', `notify failed: ${e.message}`);
  }
}

// Function to get Hyprland instance and connect to event socket
function connectToHyprlandSocket() {
  const hyprlandInstance = process.env.HYPRLAND_INSTANCE_SIGNATURE;
  if (!hyprlandInstance) {
    logMain('ERROR', 'HYPRLAND_INSTANCE_SIGNATURE not found');
    return null;
  }

  const socketPath = path.join(
    process.env.XDG_RUNTIME_DIR || '/tmp',
    'hypr',
    hyprlandInstance,
    '.socket2.sock'
  );

  logMain('INFO', `connecting to Hyprland socket: ${socketPath}`);

  const client = net.createConnection(socketPath);
  let buffer = '';

  client.on('connect', () => {
    logMain('INFO', 'connected to Hyprland event socket');
    notify('Hyprland Monitor', 'Connected to monitor events');
  });

  client.on('data', (data) => {
    buffer += data.toString();
    const lines = buffer.split('\n');
    buffer = lines.pop(); // keep incomplete line in buffer

    for (const line of lines) {
      if (line.trim()) {
        handleHyprlandEvent(line.trim());
      }
    }
  });

  client.on('error', (err) => {
    logMain('ERROR', `Hyprland socket error: ${err.message}`);
    // Retry connection after delay
    setTimeout(() => connectToHyprlandSocket(), 2000);
  });

  client.on('close', () => {
    logMain('INFO', 'Hyprland socket connection closed, retrying...');
    setTimeout(() => connectToHyprlandSocket(), 1000);
  });

  return client;
}

// Handle Hyprland events
function handleHyprlandEvent(eventLine) {
  logMain('DEBUG', `event: ${eventLine}`);
  
  // Parse event format: EVENT>>DATA
  const [eventType, ...dataParts] = eventLine.split('>>');
  const eventData = dataParts.join('>>');

  switch (eventType) {
    case 'focusedmon':
      // focusedmon event format: focusedmon>>MONITOR_NAME,WORKSPACE_NAME
      const [monitorName, workspaceName] = eventData.split(',');
      logMain('INFO', `focused monitor changed: ${monitorName} (workspace: ${workspaceName})`);
      
      // Save monitor state for brightness script
      saveMonitorState(monitorName);
      
      notify('Monitor Focus Changed', `Now on monitor: ${monitorName}\nWorkspace: ${workspaceName}`);
      break;
    
    // You can add more event types here if needed
    case 'workspace':
      logMain('INFO', `workspace changed: ${eventData}`);
      break;
    
    case 'activewindow':
      logMain('DEBUG', `active window changed: ${eventData}`);
      break;
    
    default:
      // Uncomment to log all other events
      // logMain('DEBUG', `unhandled event: ${eventType} -> ${eventData}`);
      break;
  }
}

// --- Start of main logic ---
logMain('INFO', 'node_init starting');
logMain('INFO', 'Set LOG_LEVEL environment variable to DEBUG, INFO, WARN, or ERROR to change log level');

// Load existing monitor state
loadMonitorState();

notify('Hyprland Monitor Script', 'Starting monitor change detection');

// Connect to Hyprland event socket
connectToHyprlandSocket();

// graceful shutdown
process.on('SIGINT', () => {
  logMain('INFO', 'received SIGINT, exiting');
  process.exit(0);
});
process.on('SIGTERM', () => {
  logMain('INFO', 'received SIGTERM, exiting');
  process.exit(0);
});

process.on('exit', () => { try { fs.unlinkSync(PID_FILE); } catch (e) {} });