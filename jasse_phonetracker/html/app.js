'use strict';

// ── State ─────────────────────────────────────────────────────────
const tracks    = {};
const cooldowns = {};

// ── Default locale (overwritten by Lua on show) ───────────────────
let L = {
    ui_brand:           'Poliisi',
    ui_tab:             'Puhelinträkkeri',
    ui_dept:            'Poliisilaitos',
    ui_close_title:     'Sulje',
    ui_nav_main:        'Seuranta',
    ui_nav_history:     'Historia',
    ui_nav_cooldowns:   'Cooldownit',
    ui_nav_settings:    'Asetukset',
    ui_col_search:      'Hae numeroa',
    ui_col_tracks:      'Aktiiviset seurannat',
    ui_col_cooldowns:   'Cooldownit',
    ui_placeholder:     'Kirjoita numero…',
    ui_search_hint:     'Kirjoita puhelinnumero alle ja paina lähetä',
    ui_no_tracks:       'Ei aktiivisia seurantoja',
    ui_no_cooldowns:    'Ei cooldowneja',
    ui_status_found:    'Signaali löydetty',
    ui_status_offline:  'Kohde offline',
    ui_status_no_phone: 'Ei puhelinta',
    ui_status_no_signal:'Ei signaalia',
    ui_status_syncing:  'Synkronoidaan…',
    ui_status_unknown:  'Tuntematon',
    ui_btn_stop:        'Lopeta',
    ui_time_left:       'Aikaa jäljellä:',
    ui_update_label:    'Päivitys #',
    ui_alert_invalid:   'Syötä kelvollinen puhelinnumero',
    ui_alert_sent:      'Seurantapyyntö lähetetty…',
};

// ── Locale application ────────────────────────────────────────────

function applyLocale(locale) {
    if (locale) L = Object.assign({}, L, locale);

    setText('lBrand',        L.ui_brand);
    setText('lTabTitle',     L.ui_tab);
    setText('officerName',   L.ui_dept);
    setText('lNavMain',      L.ui_nav_main);
    setText('lNavHistory',   L.ui_nav_history);
    setText('lNavCooldowns', L.ui_nav_cooldowns);
    setText('lNavSettings',  L.ui_nav_settings);
    setText('lColSearch',    L.ui_col_search);
    setText('lColTracks',    L.ui_col_tracks);
    setText('lColCooldowns', L.ui_col_cooldowns);
    setText('searchHint',    L.ui_search_hint);
    setText('lNoTracks',     L.ui_no_tracks);
    setText('lNoCooldowns',  L.ui_no_cooldowns);
    setAttr('phoneInput',    'placeholder', L.ui_placeholder);

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

// ── Live clock ────────────────────────────────────────────────────

function updateClock() {
    const now = new Date();
    const d   = String(now.getDate()).padStart(2,'0');
    const mo  = String(now.getMonth()+1).padStart(2,'0');
    const y   = now.getFullYear();
    const h   = String(now.getHours()).padStart(2,'0');
    const mi  = String(now.getMinutes()).padStart(2,'0');
    setText('liveTime', `${d}/${mo}/${y}, ${h}:${mi}`);
}
updateClock();
setInterval(updateClock, 10000);

// ── Helpers ───────────────────────────────────────────────────────

function fmtTime(sec) {
    sec = Math.max(0, Math.floor(sec));
    const m = Math.floor(sec / 60);
    const s = sec % 60;
    return `${m}:${String(s).padStart(2,'0')}`;
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

function escHtml(str) {
    return String(str)
        .replace(/&/g,'&amp;').replace(/</g,'&lt;')
        .replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

// ── Alert in left column body ─────────────────────────────────────

let alertTimer = null;

function showAlert(msg, type) {
    const body = document.getElementById('searchBody');
    // Remove existing alert if any
    const old = body.querySelector('.alert-row');
    if (old) old.remove();

    const el = document.createElement('div');
    el.className = `alert-row ${type}`;
    el.textContent = msg;
    body.insertBefore(el, body.firstChild);

    clearTimeout(alertTimer);
    alertTimer = setTimeout(() => el.remove(), 5000);
}

// ── Render ────────────────────────────────────────────────────────

function renderTracks() {
    const list    = document.getElementById('trackList');
    const entries = Object.entries(tracks);

    document.getElementById('trackCount').textContent = entries.length;

    if (entries.length === 0) {
        list.innerHTML = `<div class="empty-state">${escHtml(L.ui_no_tracks)}</div>`;
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
            <div class="track-top">
                <span class="track-number">${escHtml(number)}</span>
                <div class="track-right">
                    <div class="status-pill ${statusKey}">
                        <div class="dot"></div>
                        ${escHtml(label)}
                    </div>
                    <button class="btn-stop" onclick="stopTrack('${escHtml(number)}')">${escHtml(L.ui_btn_stop)}</button>
                </div>
            </div>
            <div class="track-meta">
                <span class="track-time">${escHtml(L.ui_time_left)} <b>${fmtTime(t.remaining)}</b></span>
                <span class="track-upd">${escHtml(L.ui_update_label)}${t.updateNum || 0}</span>
            </div>
            <div class="progress">
                <div class="progress-fill" style="width:${pct}%"></div>
            </div>`;
        list.appendChild(item);
    }
}

function renderCooldowns() {
    const list    = document.getElementById('cooldownList');
    const entries = Object.entries(cooldowns).filter(([,v]) => v.remaining > 0);

    if (entries.length === 0) {
        list.innerHTML = `<div class="empty-state">${escHtml(L.ui_no_cooldowns)}</div>`;
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

window.addEventListener('message', function(event) {
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

document.getElementById('phoneInput').addEventListener('keydown', function(e) {
    if (e.key === 'Enter')  startTracking();
    if (e.key === 'Escape') closeUI();
});

document.getElementById('btnTrack').addEventListener('click', startTracking);
document.getElementById('btnClose').addEventListener('click', closeUI);

// ── Countdown tick ────────────────────────────────────────────────

setInterval(function() {
    let changed = false;

    for (const t of Object.values(tracks)) {
        if (t.remaining > 0) { t.remaining -= 1; changed = true; }
    }
    for (const [num, cd] of Object.entries(cooldowns)) {
        if (cd.remaining > 0) { cd.remaining -= 1; changed = true; }
        else { delete cooldowns[num]; changed = true; }
    }

    if (changed) { renderTracks(); renderCooldowns(); }
}, 1000);
