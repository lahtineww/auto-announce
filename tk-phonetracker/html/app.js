'use strict';

// ── State ─────────────────────────────────────────────────────────
const tracks    = {};   // { [number]: TrackState }
const cooldowns = {};   // { [number]: { remaining: seconds } }

// ── Helpers ───────────────────────────────────────────────────────

function fmtTime(sec) {
    sec = Math.max(0, Math.floor(sec));
    const m = Math.floor(sec / 60);
    const s = sec % 60;
    return `${m}:${String(s).padStart(2, '0')}`;
}

function fmtCooldown(sec) {
    sec = Math.max(0, Math.floor(sec));
    const h = Math.floor(sec / 3600);
    const m = Math.floor((sec % 3600) / 60);
    if (h > 0) return `${h}h ${m}m`;
    return `${m}m`;
}

function statusLabel(status, found) {
    if (found)               return 'Signal Found';
    if (status === 'offline')  return 'Target Offline';
    if (status === 'no_phone') return 'No Phone';
    if (status === 'no_signal')return 'No Signal';
    if (status === 'syncing')  return 'Syncing…';
    return 'Unknown';
}

function showAlert(msg, type) {
    const el = document.getElementById('statusMsg');
    el.className = `alert ${type}`;
    el.textContent = msg;
    clearTimeout(el._timer);
    el._timer = setTimeout(() => el.className = 'alert hidden', 4000);
}

// ── Render ────────────────────────────────────────────────────────

function renderTracks() {
    const list    = document.getElementById('trackList');
    const entries = Object.entries(tracks);

    document.getElementById('trackCount').textContent = entries.length;

    if (entries.length === 0) {
        list.innerHTML = '<div class="empty-row">No active tracks</div>';
        return;
    }

    list.innerHTML = '';

    for (const [number, t] of entries) {
        const statusKey = t.found ? 'found' : (t.status || 'no_signal');
        const label     = statusLabel(t.status, t.found);
        const pct       = t.totalDuration
            ? Math.max(0, (t.remaining / t.totalDuration) * 100)
            : 100;

        const item = document.createElement('div');
        item.className = 'track-item';
        item.innerHTML = `
            <div class="track-row">
                <span class="track-number">${escHtml(number)}</span>
                <div style="display:flex;align-items:center;gap:7px;">
                    <div class="status-pill ${statusKey}">
                        <div class="dot"></div>
                        ${label}
                    </div>
                    <button class="btn-stop" onclick="stopTrack('${escHtml(number)}')">Stop</button>
                </div>
            </div>
            <div class="track-meta">
                <span class="track-time">Time left: <b>${fmtTime(t.remaining)}</b></span>
                <span class="track-update">Update #${t.updateNum || 0}</span>
            </div>
            <div class="progress">
                <div class="progress-fill" style="width:${pct}%"></div>
            </div>`;
        list.appendChild(item);
    }
}

function renderCooldowns() {
    const list    = document.getElementById('cooldownList');
    const entries = Object.entries(cooldowns).filter(([, v]) => v.remaining > 0);

    if (entries.length === 0) {
        list.innerHTML = '<div class="empty-row">No cooldowns</div>';
        return;
    }

    list.innerHTML = '';
    for (const [number, cd] of entries) {
        const item = document.createElement('div');
        item.className = 'cd-item';
        item.innerHTML = `
            <span class="cd-number">${escHtml(number)}</span>
            <span class="cd-time">${fmtCooldown(cd.remaining)}</span>`;
        list.appendChild(item);
    }
}

function escHtml(str) {
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
}

// ── Actions ───────────────────────────────────────────────────────

function startTracking() {
    const input  = document.getElementById('phoneInput');
    const number = input.value.trim();

    if (!number || number.length < 3) {
        showAlert('Enter a valid phone number', 'error');
        return;
    }

    nuiPost('startTracking', { number });
    input.value = '';
    showAlert('Tracking request sent…', 'info');
}

function stopTrack(number) {
    nuiPost('stopTracking', { number });
}

function closeUI() {
    nuiPost('closeUI', {});
}

function nuiPost(endpoint, data) {
    fetch(`https://${GetParentResourceName()}/${endpoint}`, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify(data),
    }).catch(() => {});
}

// ── NUI message handler ───────────────────────────────────────────

window.addEventListener('message', function (event) {
    const d = event.data;
    if (!d || !d.action) return;

    switch (d.action) {

        case 'show':
            document.getElementById('app').classList.remove('hidden');
            document.getElementById('phoneInput').focus();
            nuiPost('requestTracks', {});
            break;

        case 'hide':
            document.getElementById('app').classList.add('hidden');
            break;

        case 'trackUpdate':
            tracks[d.number] = {
                found:         d.found,
                status:        d.status,
                remaining:     d.remaining,
                totalDuration: d.totalDuration || 300,
                updateNum:     d.updateNum || 1,
            };
            renderTracks();
            break;

        case 'trackStopped': {
            delete tracks[d.number];
            if (d.cooldownEnds) {
                const secs = d.cooldownEnds - Math.floor(Date.now() / 1000);
                if (secs > 0) cooldowns[d.number] = { remaining: secs };
            }
            renderTracks();
            renderCooldowns();
            break;
        }

        case 'syncTracks': {
            // Replace entire state
            Object.keys(tracks).forEach(k => delete tracks[k]);
            Object.keys(cooldowns).forEach(k => delete cooldowns[k]);

            for (const t of (d.tracks || [])) {
                tracks[t.number] = {
                    found:         false,
                    status:        'syncing',
                    remaining:     Math.max(0, t.remaining),
                    totalDuration: 300,
                    updateNum:     0,
                };
            }
            for (const cd of (d.cooldowns || [])) {
                cooldowns[cd.number] = { remaining: cd.remaining };
            }

            renderTracks();
            renderCooldowns();
            break;
        }
    }
});

// ── Input events ──────────────────────────────────────────────────

document.getElementById('phoneInput').addEventListener('keydown', function (e) {
    if (e.key === 'Enter')  startTracking();
    if (e.key === 'Escape') closeUI();
});

document.getElementById('btnTrack').addEventListener('click', startTracking);
document.getElementById('btnSearch').addEventListener('click', startTracking);
document.getElementById('btnClose').addEventListener('click', closeUI);

// ── Countdown tick (every second) ────────────────────────────────

setInterval(function () {
    let changed = false;

    for (const t of Object.values(tracks)) {
        if (t.remaining > 0) { t.remaining -= 1; changed = true; }
    }
    for (const [num, cd] of Object.entries(cooldowns)) {
        if (cd.remaining > 0) { cd.remaining -= 1; changed = true; }
        else { delete cooldowns[num]; changed = true; }
    }

    if (changed) {
        renderTracks();
        renderCooldowns();
    }
}, 1000);
