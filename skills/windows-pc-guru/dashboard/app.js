(function (root) {
  'use strict';

  function asArray(value) {
    if (value === null || value === undefined) return [];
    return Array.isArray(value) ? value : [value];
  }

  function firstAvailable(value) {
    return asArray(value).find(function (item) { return item && !item.Unavailable; }) || null;
  }

  function numberOrNull(value) {
    var n = Number(value);
    return Number.isFinite(n) ? n : null;
  }

  function systemVolume(snapshot) {
    var volumes = asArray(snapshot && snapshot.Storage && snapshot.Storage.Volumes);
    return volumes.find(function (v) { return v && String(v.DriveLetter || '').toUpperCase() === 'C'; }) || volumes.find(function (v) { return v && !v.Unavailable; }) || null;
  }

  function getStartupCount(snapshot) {
    var summary = firstAvailable(snapshot && snapshot.Startup && snapshot.Startup.Summary);
    return summary ? numberOrNull(summary.StartupCommandCount) : null;
  }

  function getRebootPending(snapshot) {
    var reboot = firstAvailable(snapshot && snapshot.Updates && snapshot.Updates.Reboot);
    return reboot && typeof reboot.RebootPending === 'boolean' ? reboot.RebootPending : null;
  }

  function getMemory(snapshot) {
    var memory = snapshot && snapshot.Performance && snapshot.Performance.Memory;
    return memory && !memory.Unavailable ? memory : null;
  }

  function getCpu(snapshot) {
    var processor = firstAvailable(snapshot && snapshot.Performance && snapshot.Performance.Processor);
    return processor ? numberOrNull(processor.PercentProcessorTime) : null;
  }

  function getProblemDeviceCount(snapshot) {
    return asArray(snapshot && snapshot.ProblemDevices).filter(function (d) { return d && !d.Unavailable; }).length;
  }

  function severityRank(value) {
    var v = String(value || '').toLowerCase();
    if (v === 'critical' || v === 'high') return 3;
    if (v === 'warning' || v === 'medium') return 2;
    if (v === 'low' || v === 'info') return 1;
    return 0;
  }

  function normalizeFindings(input) {
    if (!input) return [];
    if (Array.isArray(input)) return input;
    if (Array.isArray(input.Findings)) return input.Findings;
    if (input.Findings) return [input.Findings];
    return [];
  }

  function summarizeSnapshot(snapshot, findingsInput) {
    var os = firstAvailable(snapshot && snapshot.OperatingSystem);
    var computer = firstAvailable(snapshot && snapshot.Hardware && snapshot.Hardware.ComputerSystem);
    var cpu = firstAvailable(snapshot && snapshot.Hardware && snapshot.Hardware.Processors);
    var bios = firstAvailable(snapshot && snapshot.Hardware && snapshot.Hardware.Bios);
    var memory = getMemory(snapshot);
    var volume = systemVolume(snapshot);
    var startupCount = getStartupCount(snapshot);
    var problemCount = getProblemDeviceCount(snapshot);
    var rebootPending = getRebootPending(snapshot);
    var cpuPercent = getCpu(snapshot);
    var findings = normalizeFindings(findingsInput);

    var warnings = 0;
    var criticals = 0;
    if (volume && numberOrNull(volume.FreePercent) !== null) {
      if (Number(volume.FreePercent) < 10) criticals += 1;
      else if (Number(volume.FreePercent) < 20) warnings += 1;
    }
    if (memory && numberOrNull(memory.FreePhysicalMemoryPercent) !== null && Number(memory.FreePhysicalMemoryPercent) < 15) warnings += 1;
    if (problemCount > 0) warnings += 1;
    if (rebootPending === true) warnings += 1;
    findings.forEach(function (f) {
      var rank = severityRank(f.Severity);
      if (rank >= 3) criticals += 1;
      else if (rank === 2) warnings += 1;
    });

    var overall = criticals > 0 ? 'bad' : warnings > 0 ? 'warn' : 'good';
    return {
      os: os,
      computer: computer,
      cpu: cpu,
      bios: bios,
      memory: memory,
      systemVolume: volume,
      startupCount: startupCount,
      problemDeviceCount: problemCount,
      rebootPending: rebootPending,
      cpuPercent: cpuPercent,
      findings: findings,
      overall: overall,
      warnings: warnings,
      criticals: criticals
    };
  }

  var api = {
    asArray: asArray,
    firstAvailable: firstAvailable,
    normalizeFindings: normalizeFindings,
    summarizeSnapshot: summarizeSnapshot
  };

  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  root.WindowsPcGuruDashboard = api;

  if (typeof document === 'undefined') return;

  var state = { snapshot: null, findings: null };
  var $ = function (id) { return document.getElementById(id); };

  function text(id, value) { $(id).textContent = value === null || value === undefined || value === '' ? '–' : String(value); }
  function formatPercent(value) { return value === null || value === undefined ? '–' : Number(value).toLocaleString('de-DE', { maximumFractionDigits: 1 }) + ' %'; }
  function formatNumber(value, digits) { return value === null || value === undefined ? '–' : Number(value).toLocaleString('de-DE', { maximumFractionDigits: digits || 0 }); }
  function escapeHtml(value) { return String(value === null || value === undefined ? '' : value).replace(/[&<>'\"]/g, function (c) { return ({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','\"':'&quot;'})[c]; }); }
  function statusClass(ok, warn) { if (ok === null || ok === undefined) return 'neutral'; return ok ? 'good' : (warn ? 'warn' : 'bad'); }
  function boolLabel(value, goodText, badText) { if (value === null || value === undefined) return 'Unbekannt'; return value ? goodText : badText; }

  function detailRow(label, value) { return '<dt>' + escapeHtml(label) + '</dt><dd>' + escapeHtml(value || '–') + '</dd>'; }
  function statusRow(label, value, cls) { return '<div class="status-row"><span>' + escapeHtml(label) + '</span><span class="status-value ' + cls + '">' + escapeHtml(value) + '</span></div>'; }

  function render() {
    if (!state.snapshot) return;
    var s = summarizeSnapshot(state.snapshot, state.findings);
    $('emptyState').hidden = true;
    $('dashboard').hidden = false;

    var badge = $('overallBadge');
    badge.className = 'badge ' + s.overall;
    badge.textContent = s.overall === 'bad' ? 'Kritische Punkte erkannt' : s.overall === 'warn' ? 'Prüfung empfohlen' : 'Keine offensichtliche Warnung';

    text('kpiWindows', s.os && s.os.Caption);
    text('kpiBuild', s.os ? 'Build ' + (s.os.BuildNumber || '–') + ' · ' + (s.os.OSArchitecture || '–') : '–');
    text('kpiMemory', s.memory ? formatPercent(s.memory.FreePhysicalMemoryPercent) : '–');
    text('kpiMemoryDetail', s.memory ? formatNumber(s.memory.FreePhysicalMemoryMiB / 1024, 1) + ' GiB frei' : '–');
    text('kpiStorage', s.systemVolume ? formatPercent(s.systemVolume.FreePercent) : '–');
    text('kpiStorageDetail', s.systemVolume ? formatNumber(s.systemVolume.FreeGiB, 1) + ' GiB frei auf ' + s.systemVolume.DriveLetter + ':' : '–');
    text('kpiStartup', s.startupCount);
    text('kpiDevices', s.problemDeviceCount);
    text('kpiReboot', s.rebootPending === null ? 'Unbekannt' : (s.rebootPending ? 'Ausstehend' : 'Nein'));
    text('collectedAt', state.snapshot.CollectedAtUtc ? 'Erfasst: ' + new Date(state.snapshot.CollectedAtUtc).toLocaleString('de-DE') : '');

    var systemHtml = '';
    systemHtml += detailRow('Windows', s.os && s.os.Caption);
    systemHtml += detailRow('Version / Build', s.os ? (s.os.Version || '–') + ' / ' + (s.os.BuildNumber || '–') : '–');
    systemHtml += detailRow('Architektur', s.os && s.os.OSArchitecture);
    systemHtml += detailRow('Hersteller / Modell', s.computer ? (s.computer.Manufacturer || '–') + ' / ' + (s.computer.Model || '–') : '–');
    systemHtml += detailRow('Arbeitsspeicher', s.computer && s.computer.TotalPhysicalMemoryGiB !== undefined ? formatNumber(s.computer.TotalPhysicalMemoryGiB, 1) + ' GiB' : '–');
    systemHtml += detailRow('Prozessor', s.cpu && s.cpu.Name);
    systemHtml += detailRow('Kerne / Threads', s.cpu ? (s.cpu.NumberOfCores || '–') + ' / ' + (s.cpu.NumberOfLogicalProcessors || '–') : '–');
    systemHtml += detailRow('BIOS', s.bios && s.bios.SMBIOSBIOSVersion);
    $('systemDetails').innerHTML = systemHtml;

    var defender = firstAvailable(state.snapshot.Security && state.snapshot.Security.Defender);
    var firewalls = asArray(state.snapshot.Security && state.snapshot.Security.FirewallProfiles).filter(function (f) { return f && !f.Unavailable; });
    var securityHtml = '';
    securityHtml += statusRow('Virenschutz', defender ? boolLabel(defender.AntivirusEnabled, 'Aktiv', 'Deaktiviert') : 'Nicht verfügbar', defender ? statusClass(defender.AntivirusEnabled, false) : 'neutral');
    securityHtml += statusRow('Echtzeitschutz', defender ? boolLabel(defender.RealTimeProtectionEnabled, 'Aktiv', 'Deaktiviert') : 'Nicht verfügbar', defender ? statusClass(defender.RealTimeProtectionEnabled, false) : 'neutral');
    firewalls.forEach(function (f) { securityHtml += statusRow('Firewall ' + (f.Name || ''), boolLabel(f.Enabled, 'Aktiv', 'Deaktiviert'), statusClass(f.Enabled, false)); });
    if (!securityHtml) securityHtml = statusRow('Sicherheitsstatus', 'Nicht verfügbar', 'neutral');
    $('securityList').innerHTML = securityHtml;

    var volumes = asArray(state.snapshot.Storage && state.snapshot.Storage.Volumes).filter(function (v) { return v && !v.Unavailable; });
    $('storageList').innerHTML = volumes.length ? volumes.map(function (v) {
      var free = numberOrNull(v.FreePercent);
      var cls = free === null ? 'neutral' : free < 10 ? 'bad' : free < 20 ? 'warn' : 'good';
      var used = free === null ? 0 : Math.max(0, Math.min(100, 100 - free));
      return '<div class="storage-item"><strong>' + escapeHtml(v.DriveLetter || '?') + ':</strong><div><div class="storage-meter"><span style="width:' + used + '%"></span></div><small class="muted">' + escapeHtml(formatNumber(v.FreeGiB, 1)) + ' GiB frei von ' + escapeHtml(formatNumber(v.SizeGiB, 1)) + ' GiB</small></div><strong class="' + cls + '">' + escapeHtml(formatPercent(free)) + ' frei</strong></div>';
    }).join('') : '<p class="muted">Keine Laufwerksdaten verfügbar.</p>';

    var perf = '';
    perf += statusRow('CPU Momentaufnahme', s.cpuPercent === null ? 'Nicht verfügbar' : formatPercent(s.cpuPercent), s.cpuPercent !== null && s.cpuPercent > 85 ? 'warn' : 'neutral');
    perf += statusRow('Freier Arbeitsspeicher', s.memory ? formatPercent(s.memory.FreePhysicalMemoryPercent) : 'Nicht verfügbar', s.memory && Number(s.memory.FreePhysicalMemoryPercent) < 15 ? 'warn' : 'good');
    perf += statusRow('Autostart-Einträge', s.startupCount === null ? 'Nicht verfügbar' : String(s.startupCount), s.startupCount !== null && s.startupCount > 20 ? 'warn' : 'neutral');
    $('performanceList').innerHTML = perf;

    var reliability = state.snapshot.Reliability || {};
    var rel = '';
    rel += statusRow('Geräte mit Fehlercode', String(s.problemDeviceCount), s.problemDeviceCount > 0 ? 'warn' : 'good');
    rel += statusRow('Neustart ausstehend', s.rebootPending === null ? 'Unbekannt' : (s.rebootPending ? 'Ja' : 'Nein'), s.rebootPending ? 'warn' : 'good');
    rel += statusRow('Kritische/Fehler-Ereignisse', reliability.CriticalOrErrorCount === null || reliability.CriticalOrErrorCount === undefined ? 'Nicht erhoben' : String(reliability.CriticalOrErrorCount), reliability.CriticalOrErrorCount > 0 ? 'warn' : 'neutral');
    $('reliabilityList').innerHTML = rel;

    text('findingCount', s.findings.length ? s.findings.length + ' Findings' : 'keine Findings-Datei geladen');
    $('findingsList').innerHTML = s.findings.length ? s.findings.map(function (f) {
      var sev = String(f.Severity || 'Low').toLowerCase();
      var cls = sev === 'critical' || sev === 'high' ? 'high' : sev === 'warning' || sev === 'medium' ? 'medium' : 'low';
      var title = f.Title || f.Id || 'Finding';
      var evidence = f.Evidence || f.Description || '';
      var confidence = f.Confidence ? 'Confidence: ' + f.Confidence : '';
      return '<article class="finding ' + cls + '"><h3>' + escapeHtml(title) + '</h3><p>' + escapeHtml(evidence) + '</p><p class="muted">' + escapeHtml(confidence) + '</p></article>';
    }).join('') : '<p class="muted">Optional kannst du zusätzlich das JSON-Ergebnis der Findings Engine laden.</p>';

    text('privacyNotice', state.snapshot.PrivacyNotice || 'Keine Datenschutzerklärung im Snapshot enthalten.');
  }

  async function readJson(file) {
    var textValue = await file.text();
    return JSON.parse(textValue.replace(/^\uFEFF/, ''));
  }

  $('snapshotInput').addEventListener('change', async function (event) {
    try {
      var file = event.target.files[0];
      if (!file) return;
      var data = await readJson(file);
      if (String(data.SchemaVersion || '') !== '2.0') throw new Error('Erwartet wird Snapshot-Schema 2.0.');
      state.snapshot = data;
      $('message').textContent = '';
      render();
    } catch (error) {
      $('message').textContent = 'Snapshot konnte nicht geladen werden: ' + error.message;
    }
  });

  $('findingsInput').addEventListener('change', async function (event) {
    try {
      var file = event.target.files[0];
      if (!file) return;
      state.findings = await readJson(file);
      $('message').textContent = '';
      if (state.snapshot) render();
    } catch (error) {
      $('message').textContent = 'Findings konnten nicht geladen werden: ' + error.message;
    }
  });

  $('resetButton').addEventListener('click', function () {
    state.snapshot = null;
    state.findings = null;
    $('snapshotInput').value = '';
    $('findingsInput').value = '';
    $('dashboard').hidden = true;
    $('emptyState').hidden = false;
    $('message').textContent = '';
    $('overallBadge').className = 'badge neutral';
    $('overallBadge').textContent = 'Noch keine Daten';
  });
})(typeof window !== 'undefined' ? window : globalThis);
