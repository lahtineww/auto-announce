'use strict';

// ── State ─────────────────────────────────────────────────────────
const tracks    = {};   // { [number]: TrackState }
const cooldowns = {};   // { [number]: { remaining: seconds } }

// Locale strings – täytetään Luasta tulevalla datalla
let L = {
    ui_title:           'Phone Tracker',
    ui_tab:             'Phone Tracker',
    ui_dept:            'Police Department',
    ui_close_title:     'Close',
    ui_card_track:      'Track Phone Number',
    ui_phone_label:     'Phone Number',
    ui_placeholder:     'e.g. 555-1234',
    ui_search_title:    'Search',
    ui_btn_start:       'Start Tracking',
    ui_card_cooldowns:  'Cooldowns',
    ui_no_cooldowns:    'No cooldowns',
    ui_card_active:     'Active Tracks',
    ui_no_tracks:       'No active tracks',
    ui_status_found:    'Signal Found',
    ui_status_offline:  'Target Offline',
    ui_status_no_phone: 'No Phone',
    ui_status_no_signal:'No Signal',
    ui_status_syncing:  'Syncing…',
    ui_status_unknown:  'Unknown',
    ui_btn_stop:        'Stop',
    ui_time_left:       'Time left:',
    ui_update_label:    'Update #',
    ui_alert_invalid:   'Enter a valid phone number',
    ui_alert_sent:      'Tracking request sent…',
};

// ── Locale – aseta UI-tekstit ────────────────────────────────────

function applyLocale(locale) {
    if (!locale) return;
    // Yhdistetään saapuva locale defaulteihin
    L = Object.assign({}, L, locale);

    // Staattinen HTML
    setText('lTabTitle',      L.ui_tab);
    setText('officerName',    L.ui_dept);
    setAttr('btnClose',       'title', L.ui_close_title);
    setText('lCardTrack',     L.ui_card_track);
    setText('lPhoneLabel',    L.ui_phone_label);
    setAttr('phoneInput',     'placeholder', L.ui_placeholder);
    setAttr('btnSearch',      'title', L.ui_search_title);
    setText('btnTrack',       L.ui_btn_start);
    setText('lCardCooldowns', L.ui_card_cooldowns);
    setText('lNoCooldowns',   L.ui_no_cooldowns);
    setText('lCardActive',    L.ui_card_active);
    setText('lNoTracks',      L.ui_no_tracks);

    // Päivitetään dynaamiset listat uusilla käännöksillä
    renderTracks();
    renderCooldowns();
}

function setText(id, val) {
    const el = document.getElementById(id);
    if (el) el.textContent = val;
}

function setAttr(id, attr, val) {
    const el = document.getElementById(id);
    if (el) el.setAttribute(attr, val);
}

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
    if (found)                  return L.ui_status_found;
    if (status === 'offline')   return L.ui_status_offline;
    if (status === 'no_phone')  return L.ui_status_no_phone;
    if (status === 'no_signal') return L.ui_status_no_signal;
    if (status === 'syncing')   return L.ui_status_syncing;
    return L.ui_status_unknown;
}

function showAlert(msg, type) {
    const el = document.getElementById('statusMsg');
    el.className = `alert ${type}`;
    el.textContent = msg;
    clearTimeout(el._timer);
    el._timer = setTimeout(() => el.className = 'alert hidden', 4000);
}

function escHtml(str) {
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
}

// ── Render ────────────────────────────────────────────────────────

function renderTracks() {
    const list    = document.getElementById('trackList');
    const entries = Object.entries(tracks);

    document.getElementById('trackCount').textContent = entries.length;

    if (entries.length === 0) {
        list.innerHTML = `<div class="empty-row">${escHtml(L.ui_no_tracks)}</div>`;
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
                        ${escHtml(label)}
                    </div>
                    <button class="btn-stop" onclick="stopTrack('${escHtml(number)}')">${escHtml(L.ui_btn_stop)}</button>
                </div>
            </div>
            <div class="track-meta">
                <span class="track-time">${escHtml(L.ui_time_left)} <b>${fmtTime(t.remaining)}</b></span>
                <span class="track-update">${escHtml(L.ui_update_label)}${t.updateNum || 0}</span>
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
        list.innerHTML = `<div class="empty-row">${escHtml(L.ui_no_cooldowns)}</div>`;
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

// ── Actions ───────────────────────────────────────────────────────

function startTracking() {
    const input  = document.getElementById('phoneInput');
    const number = input.value.trim();

    if (!number || number.length < 3) {
        showAlert(L.ui_alert_invalid, 'error');
        return;
    }

    nuiPost('startTracking', { number });
    input.value = '';
    showAlert(L.ui_alert_sent, 'info');
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
            applyLocale(d.locale);
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

// ── Countdown tick (every second) ─────────────────────────────────

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
