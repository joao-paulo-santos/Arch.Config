#!/usr/bin/env node
/**
 * rofi-tmuxdrun.js
 *
 * Minimal, robust script to:
 *  - list live tmux sessions (freeze / attach)
 *  - list frozen snapshots (unfreeze)
 *  - freeze a live session (non-interactive, detached)
 *  - unfreeze (load) a snapshot and delete the YAML after load
 *  - attach to a live session (spawn terminal detached and exit immediately)
 *
 * Places workspace files under XDG_CONFIG_HOME or ~/.config/tmux/tmux-workspaces
 *
 * Drop this file into ~/.config/rofi/scripts/ and make executable:
 * chmod +x ~/.config/rofi/scripts/rofi-tmuxdrun.js
 */

const fs = require('fs');
const fsp = fs.promises;
const path = require('path');
const { spawn, execFile } = require('child_process');
const util = require('util');
const execFileP = util.promisify(execFile);

// --- configuration (respects XDG) ---
const WORKDIR = path.join(
    process.env.XDG_CONFIG_HOME || path.join(process.env.HOME || '', '.config'),
    'tmux',
    'tmux-workspaces'
);
const FROZENDIR = path.join(WORKDIR, 'frozen');

// --- small helpers ---
function stdoutWrite(s) {
    try { process.stdout.write(s + '\n'); } catch (e) { }
}

async function ensureDirs() {
    try { await fsp.mkdir(WORKDIR, { recursive: true }); } catch (e) { }
    try { await fsp.mkdir(FROZENDIR, { recursive: true }); } catch (e) { }
    // ensure log exists
    try { await fsp.writeFile(path.join(WORKDIR, 'debug.log'), '', { flag: 'a' }); } catch (e) { }
    try { await fsp.writeFile(path.join(WORKDIR, 'tmuxp.log'), '', { flag: 'a' }); } catch (e) { }
}

async function runCmd(cmd, args = [], opts = {}) {
    try {
        const { stdout, stderr } = await execFileP(cmd, args, opts);
        return { ok: true, out: String(stdout || ''), err: String(stderr || '') };
    } catch (e) {
        // execFile throws on non-zero exit; capture stdout/stderr if present
        return {
            ok: false,
            out: (e.stdout !== undefined) ? String(e.stdout) : '',
            err: (e.stderr !== undefined) ? String(e.stderr) : String(e)
        };
    }
}

async function resolveBinary(name, fallbacks = []) {
    try {
        const r = await runCmd('which', [name]);
        if (r.ok && r.out) return r.out.trim().split('\n')[0];
    } catch (e) { }
    for (const p of fallbacks) {
        try { if (fs.existsSync(p)) return p; } catch (e) { }
    }
    return null;
}

function spawnDetached(cmd, args, logPath) {
    try {
        try { fs.mkdirSync(path.dirname(logPath), { recursive: true }); } catch { }
        const out = fs.openSync(logPath, 'a');
        const err = fs.openSync(logPath, 'a');
        const p = spawn(cmd, args, {
            stdio: ['ignore', out, err],
            detached: true
        });
        p.unref();
        return { ok: true, pid: p.pid };
    } catch (e) {
        return { ok: false, err: String(e) };
    }
}

function printRow(label, info, extra = {}) {
    let out = label + '\x00info\x1f' + info;
    if (extra.icon) out += '\x1ficon\x1f' + extra.icon;
    stdoutWrite(out + '\n');
}

// --- tmux / workspace helpers ---
async function getLiveSessionSet() {
    const set = new Set();
    const tmuxBin = await resolveBinary('tmux', ['/usr/bin/tmux', '/bin/tmux', '/usr/local/bin/tmux']);
    if (!tmuxBin) return set;
    const r = await runCmd(tmuxBin, ['list-sessions', '-F', '#{session_name}']);
    if (!r.ok || !r.out) return set;
    for (const raw of r.out.trim().split('\n')) {
        const s = raw.trim().replace(/:$/, '');
        if (s) set.add(s);
    }
    return set;
}

async function listTmuxSessions() {
    const debugPath = path.join(WORKDIR, 'debug.log');
    try { await fsp.appendFile(debugPath, `listTmuxSessions ${new Date().toISOString()}\n`); } catch (e) { }

    const liveSet = await getLiveSessionSet();
    if (liveSet.size === 0) {
        printRow('sessions › (no tmux sessions)', 'NO_SESSIONS');
        return;
    }

    for (const s of Array.from(liveSet)) {
        // show both actions as separate selectable rows
        printRow(`freeze › ${s}`, `FREEZE:${s}`);
        printRow(`attach › ${s}`, `ATTACH:${s}`);
    }

    try { await fsp.appendFile(debugPath, `listed ${liveSet.size} live sessions (freeze+attach)\n`); } catch (e) { }
}




async function listFrozenWorkspaces() {
    try {
        const files = await fsp.readdir(FROZENDIR, { withFileTypes: true });
        for (const f of files) {
            if (!f.isFile()) continue;
            const m = f.name.match(/^(.+?)\.(ya?ml|json)$/i);
            if (!m) continue;
            const name = m[1];
            printRow(`Unfreeze> ${name}`, `UNFREEZE:${path.join(FROZENDIR, f.name)}`);
        }
    } catch (e) {
        // ignore
    }
}

async function listAll() {
    await ensureDirs();
    await listTmuxSessions();
    await listFrozenWorkspaces();
}

// --- freeze / load / unfreeze implementations ---
async function freezeSession(sessionName) {
    if (!sessionName) return { ok: false, err: 'no session' };
    const tmuxpBin = await resolveBinary('tmuxp', ['/usr/bin/tmuxp', '/usr/local/bin/tmuxp']);
    const tmuxBin = await resolveBinary('tmux', ['/usr/bin/tmux', '/bin/tmux', '/usr/local/bin/tmux']);
    if (!tmuxpBin) return { ok: false, err: 'tmuxp not found' };
    if (!tmuxBin) return { ok: false, err: 'tmux not found' };

    const outPath = path.join(FROZENDIR, `${sessionName}.yaml`);
    const log = path.join(WORKDIR, 'tmuxp.log');

    // Chain: freeze -> wait -> kill session
    const cmd = `printf 'y\\n' | ${tmuxpBin} freeze --workspace-format yaml --yes -o ${outPath} ${sessionName} && sleep 0.3 && ${tmuxBin} kill-session -t ${sessionName}`;
    return spawnDetached('sh', ['-c', cmd], log);
}

async function loadWorkspace(filePath) {
    if (!filePath) return { ok: false, err: 'no file' };
    const tmuxpBin = await resolveBinary('tmuxp', ['/usr/bin/tmuxp', '/usr/local/bin/tmuxp']);
    if (!tmuxpBin) return { ok: false, err: 'tmuxp not found' };
    const log = path.join(WORKDIR, 'tmuxp.log');
    return spawnDetached(tmuxpBin, ['load', filePath], log);
}

async function unfreezeAndLoad(srcPath) {
    if (!srcPath) return { ok: false, err: 'no src' };
    const base = path.basename(srcPath);
    const dst = path.join(WORKDIR, base);

    try {
        // Move snapshot into WORKDIR for loading (avoid path issues)
        let loadPath = dst;
        if (fs.existsSync(dst)) {
            const ts = Date.now();
            loadPath = path.join(WORKDIR, base.replace(/(\.[^.]+)$/, `_${ts}$1`));
            await fsp.rename(srcPath, loadPath);
        } else {
            await fsp.rename(srcPath, dst);
            loadPath = dst;
        }

        // Start loading the workspace (detached)
        const r = await loadWorkspace(loadPath);

        // Spawn detached helper to delete the YAML after a short delay
        const log = path.join(WORKDIR, 'debug.log');
        const shCmd = [
            'sh',
            '-c',
            `sleep 0.6 && if [ -f '${loadPath}' ]; then rm -f '${loadPath}' && printf '%s\\n' "removed frozen file ${loadPath}" >> '${log}'; else printf '%s\\n' "no frozen file to remove at ${loadPath}" >> '${log}'; fi`
        ];
        try {
            const out = fs.openSync(log, 'a');
            const err = fs.openSync(log, 'a');
            const p = spawn(shCmd[0], shCmd.slice(1), { stdio: ['ignore', out, err], detached: true });
            p.unref();
        } catch (e) {
            try { await fsp.appendFile(log, `failed to spawn remover: ${String(e)}\n`); } catch (e2) { }
        }

        return r;
    } catch (err) {
        return { ok: false, err: String(err) };
    }
}

// --- attach helper (spawn terminal detached and exit immediately) ---
async function attachTmuxSession(sessionName) {
    if (!sessionName) return { ok: false, err: 'no session' };

    const terminals = [
        { cmd: 'kitty', args: ['tmux', 'attach-session', '-t', sessionName] },
        { cmd: 'alacritty', args: ['-e', 'tmux', 'attach-session', '-t', sessionName] },
        { cmd: 'gnome-terminal', args: ['--', 'tmux', 'attach-session', '-t', sessionName] },
        { cmd: 'xterm', args: ['-e', 'tmux', 'attach-session', '-t', sessionName] }
    ];

    for (const t of terminals) {
        const bin = await resolveBinary(t.cmd, [`/usr/bin/${t.cmd}`, `/bin/${t.cmd}`]);
        if (!bin) continue;
        try {
            const p = spawn(bin, t.args, { stdio: 'ignore', detached: true });
            p.unref();
            return { ok: true, pid: p.pid, term: bin };
        } catch (e) {
            // try next
        }
    }
    return { ok: false, err: 'no terminal found' };
}

// --- main: handle rofi script-mode env vars ---
async function main() {
    await ensureDirs();

    const ROFI_RETV = process.env.ROFI_RETV || '0';
    const ROFI_INFO = process.env.ROFI_INFO || '';

    // If rofi is asking for the list
    if (ROFI_RETV === '0') {
        await listAll();
        process.exit(0);
    }

    // If rofi returned a selection (user chose an action)
    if (ROFI_RETV === '1') {
        if (ROFI_INFO.startsWith('FREEZE:')) {
            const session = ROFI_INFO.slice('FREEZE:'.length);
            await freezeSession(session);
            process.exit(0);
        } else if (ROFI_INFO.startsWith('ATTACH:')) {
            const session = ROFI_INFO.slice('ATTACH:'.length);
            // spawn terminal detached and exit immediately so rofi closes
            await attachTmuxSession(session);
            process.exit(0);
        } else if (ROFI_INFO.startsWith('UNFREEZE:')) {
            const src = ROFI_INFO.slice('UNFREEZE:'.length);
            // Extract session name from filename (e.g., "session.yaml" -> "session")
            const sessionName = path.basename(src).replace(/\.(ya?ml|json)$/i, '');
            await unfreezeAndLoad(src);
            // Wait for tmuxp to create the session, then attach
            await new Promise(r => setTimeout(r, 800));
            await attachTmuxSession(sessionName);
            process.exit(0);
        } else if (ROFI_INFO.startsWith('OPENFILE:')) {
            const file = ROFI_INFO.slice('OPENFILE:'.length);
            const r = await loadWorkspace(file);
            if (!r.ok) {
                stdoutWrite(`open> error: ${r.err || 'failed'}`);
                process.exit(0);
            }
            stdoutWrite(`open> started (pid ${r.pid || 'n/a'})`);
            process.exit(0);
        } else {
            // unknown action
            process.exit(0);
        }
    }

    // default: list
    await listAll();
    process.exit(0);
}

main().catch(async (err) => {
    try { await fsp.appendFile(path.join(WORKDIR, 'debug.log'), `fatal error: ${String(err)}\n`); } catch (e) { }
    process.exit(1);
});
