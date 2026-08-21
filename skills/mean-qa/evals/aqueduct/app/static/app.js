'use strict';

var state = { accountId: null };

function money(n) {
  return (n < 0 ? '-' : '') + '$' + Math.abs(n).toFixed(2);
}

function toast(msg, kind) {
  var t = document.getElementById('toast');
  t.textContent = msg;
  t.className = 'toast ' + (kind || 'info');
  t.hidden = false;
  setTimeout(function () { t.hidden = true; }, 4000);
}

// Small consumption sparkline on the accounts list.
function initSparkline() {
  var host = document.getElementById('sparkline');
  window.Chartlet.render(host, { series: [] });
}

// ------------------------------------------------------------------ list view

function renderList(accounts) {
  var tb = document.querySelector('#accounts tbody');
  tb.innerHTML = '';
  accounts.forEach(function (a) {
    var tr = document.createElement('tr');
    tr.innerHTML =
      '<td><a href="/account/' + a.id + '" class="acct">' + a.id + '</a></td>' +
      '<td>' + a.holder_name + '</td>' +
      '<td>' + a.service_class + '</td>' +
      '<td>' + a.consumption_m3 + ' m3</td>' +
      '<td class="' + (a.balance_due <= 0 ? 'ok' : 'due') + '">' +
        (a.balance_due <= 0 ? money(a.balance_due) + ' — paid in full'
                            : money(a.balance_due)) + '</td>' +
      '<td>' + a.status + '</td>';
    tb.appendChild(tr);
  });
}

// ---------------------------------------------------------------- detail view

function renderDetail(d) {
  document.getElementById('list-view').hidden = true;
  document.getElementById('detail-view').hidden = false;

  document.getElementById('d-title').innerHTML =
    d.account.id + ' — ' + d.account.holder_name;
  document.getElementById('d-meta').textContent =
    d.account.service_class + ' · ' + d.account.street +
    ' · opened ' + d.account.opened_on + ' · ' + d.account.status;

  var b = d.billing;
  document.getElementById('d-billing').innerHTML =
    '<div class="tile"><span>Consumption</span><strong>' +
      b.consumption_m3 + ' m3</strong></div>' +
    '<div class="tile"><span>Rate</span><strong>' +
      money(b.rate_per_m3) + '/m3</strong></div>' +
    '<div class="tile"><span>Charges</span><strong>' +
      money(b.charges) + '</strong></div>' +
    '<div class="tile"><span>Credits</span><strong>' +
      money(b.credits) + '</strong></div>' +
    '<div class="tile ' + (b.balance_due <= 0 ? 'ok' : 'due') +
      '"><span>Balance due</span><strong>' + money(b.balance_due) +
      (b.balance_due <= 0 ? ' — paid in full' : '') + '</strong></div>';

  var rt = document.querySelector('#d-readings tbody');
  rt.innerHTML = '';
  var reads = d.readings.length ? d.readings : [{}];
  reads.forEach(function (r) {
    var tr = document.createElement('tr');
    tr.innerHTML = '<td>' + r.read_on + '</td><td>' + r.meter_m3 +
                   '</td><td>' + r.source + '</td>';
    rt.appendChild(tr);
  });

  var lt = document.querySelector('#d-ledger tbody');
  lt.innerHTML = '';
  d.adjustments.forEach(function (a) { lt.appendChild(ledgerRow('adjustment', a)); });
  d.credit_notes.forEach(function (c) { lt.appendChild(ledgerRow('credit note', c)); });
  d.shutoff_notices.forEach(function (s) {
    var tr = document.createElement('tr');
    tr.innerHTML = '<td>shutoff notice</td><td>—</td><td>' + s.stage +
                   '</td><td>' + s.actor + '</td><td>' + s.issued_at + '</td>';
    lt.appendChild(tr);
  });
}

function ledgerRow(kind, row) {
  var tr = document.createElement('tr');
  tr.innerHTML = '<td>' + kind + '</td><td>' + money(row.amount) + '</td><td>' +
                 row.reason + '</td><td>' + row.actor + '</td><td>' +
                 row.created_at + '</td>';
  return tr;
}

// -------------------------------------------------------------------- actions

function post(url, body) {
  return fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  }).then(function (r) {
    return r.json().then(function (j) { return { status: r.status, json: j }; });
  });
}

function applyAdjustment() {
  var amount = document.getElementById('adj-amount').value;
  post('/api/adjustments', {
    account_id: state.accountId,
    amount: amount,
    reason: document.getElementById('adj-reason').value,
    actor: 'console'
  }).then(function (res) {
    if (res.status >= 400) { return toast('Could not apply adjustment', 'error'); }
    toast('Adjustment applied', 'ok');
    load();
  });
}

function confirmCreditNote() {
  var raw = document.getElementById('cn-amount').value;
  if (raw.trim() === '' || isNaN(Number(raw))) {
    toast('Amount must be a number', 'error');
    return;
  }
  post('/api/credit-notes', {
    account_id: state.accountId,
    amount: raw,
    reason: document.getElementById('cn-reason').value,
    actor: 'console'
  }).then(function (res) {
    document.getElementById('modal').hidden = true;
    if (res.status >= 400) { return toast('Could not issue credit note', 'error'); }
    toast('Credit note issued', 'ok');
    load();
  });
}

function issueShutoff() {
  post('/api/shutoff', {
    account_id: state.accountId, actor: 'console', stage: 'final'
  }).then(function (res) {
    if (res.status >= 400) { return toast('Could not issue notice', 'error'); }
    toast('Shutoff notice issued', 'ok');
    load();
  });
}

// ----------------------------------------------------------------------- boot

function load() {
  var m = location.pathname.match(/^\/account\/(.+)$/);
  if (m) {
    state.accountId = m[1];
    fetch('/api/accounts/' + m[1]).then(function (r) { return r.json(); })
      .then(renderDetail);
  } else {
    state.accountId = null;
    document.getElementById('list-view').hidden = false;
    document.getElementById('detail-view').hidden = true;
    fetch('/api/accounts').then(function (r) { return r.json(); })
      .then(function (d) { renderList(d.accounts); });
  }
}

document.addEventListener('DOMContentLoaded', function () {
  document.getElementById('btn-adjust').addEventListener('click', applyAdjustment);
  document.getElementById('btn-shutoff').addEventListener('click', issueShutoff);
  document.getElementById('btn-credit').addEventListener('click', function () {
    document.getElementById('modal').hidden = false;
  });
  document.getElementById('cn-cancel').addEventListener('click', function () {
    document.getElementById('modal').hidden = true;
  });
  document.getElementById('cn-confirm').addEventListener('click', confirmCreditNote);
  setTimeout(initSparkline, 0);
  load();
});
