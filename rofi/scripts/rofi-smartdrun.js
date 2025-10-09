#!/usr/bin/env node
/* Rofi Script Mode in Node.js: Apps + Calc + Hyprland windows/workspaces */
const { execFile, spawn } = require('child_process');
const fs = require('fs');
const fsp = require('fs/promises');
const path = require('path');

const stdoutWrite = (s) => { try { fs.writeSync(1, s); } catch (_) {} };
process.stdout.on('error', () => { try { process.exit(0); } catch (_) {} });

const ROFI_RETV = process.env.ROFI_RETV || '0';
const ROFI_INFO = process.env.ROFI_INFO || '';
const INPUT = process.argv.slice(2).join(' ').trim();

const appDirs = (() => {
  const dirs = [
    path.join(process.env.HOME || '', '.local/share/applications'),
    '/usr/share/applications',
    '/usr/local/share/applications',
    path.join(process.env.HOME || '', '.local/share/flatpak/exports/share/applications'),
    '/var/lib/flatpak/exports/share/applications',
    '/var/lib/snapd/desktop/applications',
  ];
  const xdg = process.env.XDG_DATA_DIRS || '';
  if (xdg) xdg.split(':').forEach(d => dirs.push(path.join(d, 'applications')));
  return dirs;
})();

function printRow(label, info, extra = {}) {
  let out = label + '\x00info\x1f' + info;
  if (extra.icon) out += '\x1ficon\x1f' + extra.icon;
  stdoutWrite(out + '\n');
}

function runCmd(cmd, args, opts={}) {
  return new Promise((resolve, reject) => {
    execFile(cmd, args, { maxBuffer: 1024*1024, ...opts }, (err, stdout) => {
      if (err) return resolve(null);
      resolve(stdout.toString());
    });
  });
}

   function deferHypr(cmd){
     try {
       const p = spawn('sh', ['-c', `sleep 0.15; ${cmd}`], { stdio: 'ignore', detached: true });
       p.unref();
     } catch {}
   }

async function qalc(expr) {
  if (!expr) return null;
  const out = await runCmd('qalc', ['-t', '--', expr]);
  const s = (out||'').trim();
  return s ? s : null;
}

async function listWorkspaces() {
  const out = await runCmd('hyprctl', ['-j','workspaces']);
  if (!out) return;
  let data; try { data = JSON.parse(out); } catch { return; }
  for (const ws of [...data].sort((a,b)=>(a.id||0)-(b.id||0))) {
    if (typeof ws !== 'object') continue;
    const wid = ws.id;
    const name = ws.name || String(wid);
    printRow(`w > ${name}`, `WS:${wid}:${name}`);
  }
}

async function listWindows() {
  const out = await runCmd('hyprctl', ['-j','clients']);
  if (!out) return;
  let data; try { data = JSON.parse(out); } catch { return; }
  for (const c of data) {
    if (typeof c !== 'object') continue;
    const title = c.title || c.class || 'Unnamed';
    const addr = c.address || '';
    printRow(`show > ${title}`, `WIN:${addr}`);
  }
}

async function readDesktopFile(p) {
  try {
    const txt = await fsp.readFile(p, 'utf8');
    const id = path.basename(p);
    const lang = process.env.LC_ALL || process.env.LC_MESSAGES || process.env.LANG || '';
    const mlang = lang.split('.')[0];
    let name = '';
    const nameLoc = new RegExp('^Name\\[' + mlang.replace(/[-]/g,'\\$&') + '\\]=(.+)$','mi');
    const m1 = txt.match(nameLoc);
    if (m1) name = m1[1].trim();
    if (!name) {
      const m2 = txt.match(/^Name=(.+)$/mi);
      if (m2) name = m2[1].trim();
    }
    if (!name) return null;
    const icon = (txt.match(/^Icon=(.+)$/mi) || [,''])[1].trim();
    const noDisplay = /^NoDisplay=\s*true$/mi.test(txt);
    if (noDisplay) return null; // follow drun behavior
    return { id, name, icon };
  } catch { return null; }
}

async function listApps() {
  const seen = new Set();
  const results = [];
  for (const d of appDirs) {
    try {
      const entries = await fsp.readdir(d, { withFileTypes: true });
      for (const ent of entries) {
        if (!ent.isFile() && !ent.isSymbolicLink()) continue;
        if (!ent.name.endsWith('.desktop')) continue;
        const full = path.join(d, ent.name);
        let stat;
        try { stat = await fsp.lstat(full); } catch { continue; }
        let real = full;
        if (stat.isSymbolicLink()) {
          try { real = await fsp.realpath(full); } catch {}
        }
        const item = await readDesktopFile(real);
        if (!item) continue;
        if (seen.has(item.id)) continue;
        seen.add(item.id);
        results.push(item);
      }
    } catch {}
  }
  for (const it of results) {
    printRow(`launch > ${it.name}`, `APP:${it.id}`, { icon: it.icon });
  }
}

async function copyToClipboard(text) {
  if (!text) return;
  try {
    const p = spawn('wl-copy', [], { stdio: ['pipe','ignore','ignore'], detached: true });
    if (p.stdin) { try { p.stdin.end(text); } catch {} }
    p.unref();
  } catch {}
}

async function launchApp(desktopId) {
  if (!desktopId) return;
  const id = desktopId.replace(/\.desktop$/,'');
  try {
    const p = spawn('gtk-launch', [id], { stdio: 'ignore', detached: true });
    p.unref();
  } catch {}
}

async function switchWorkspace(info) {
  // info: WS:<id>:<name>
  const rest = info.slice(3);
  const id = rest.split(':')[0];
  const name = rest.split(':').slice(1).join(':');
  const cmd = `hyprctl dispatch workspace ${name}`;
  deferHypr(cmd);
}

async function launchAppFallback(desktopId) {
  try {
    const p = spawn('dex', [desktopId], { stdio: 'ignore', detached: true });
    p.unref();
  } catch {}
}


async function focusWindow(addr) {
  const cmd = `hyprctl dispatch focuswindow address:${addr}`;
  deferHypr(cmd);
}

async function listAll() {
  // Calc row first if applicable
  if (INPUT) {
    const res = await qalc(INPUT);
    if (res) printRow(`calc > ${INPUT} = ${res}`, `CALC:${res}`);
  }
  await listWindows();
  await listApps();
  await listWorkspaces();
}

(async () => {
  if (ROFI_RETV === '0') {
    await listAll();
    process.exit(0);
  } else if (ROFI_RETV === '1') {
    if (ROFI_INFO.startsWith('CALC:')) {
      await copyToClipboard(ROFI_INFO.slice(5));
      stdoutWrite('\0input\x1f\n');
      await listAll();
      process.exit(0);
    } else if (ROFI_INFO.startsWith('APP:')) {
      await launchApp(ROFI_INFO.slice(4));
      // Also try fallback in case gtk-launch not available
      await launchAppFallback(ROFI_INFO.slice(4));
      process.exit(0);
    } else if (ROFI_INFO.startsWith('WS:')) {
      await switchWorkspace(ROFI_INFO);
      process.exit(0);
    } else if (ROFI_INFO.startsWith('WIN:')) {
      await focusWindow(ROFI_INFO.slice(4));
      process.exit(0);
    } else {
      process.exit(0);
    }
  } else if (ROFI_RETV === '2') {
    // Custom accept: compute once
    const res = await qalc(INPUT);
    if (res) printRow(`calc > ${INPUT} = ${res}`, `CALC:${res}`);
    process.exit(0);
  } else {
    process.exit(0);
  }
})();
