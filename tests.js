// Rodar com: npm test
const assert = require('assert').strict;

// ── Funções puras copiadas do index.html ─────────────────────
function esc(s) {
  return String(s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
}
const cur = n => 'R$ ' + Math.round(n || 0).toLocaleString('pt-BR');
function renderPagination(page, total, perPage, prevFn, nextFn) {
  const totalPages = Math.ceil(total / perPage) || 1;
  if (totalPages <= 1 && total <= perPage) return '';
  return `<div class="pg-nav"><span>${page} de ${totalPages} (${total} registros)</span><button ${page<=1?'disabled':''} onclick="${prevFn}()">← Ant.</button><button ${page>=totalPages?'disabled':''} onclick="${nextFn}()">Próx. →</button></div>`;
}
function fmtDate(d) {
  return d ? new Date(d).toLocaleString('pt-BR', {
    timeZone: 'America/Sao_Paulo', day:'2-digit', month:'2-digit',
    year:'numeric', hour:'2-digit', minute:'2-digit'
  }) : '—';
}

// ── Runner ───────────────────────────────────────────────────
let passed = 0, failed = 0;
function test(name, fn) {
  try { fn(); console.log('  ✅', name); passed++; }
  catch (e) { console.error('  ❌', name, '\n    ', e.message); failed++; }
}

// ── esc() — prevenção de XSS ─────────────────────────────────
console.log('\n🔒 esc()');
test('escapa tags HTML', () => assert.equal(esc('<script>alert(1)</script>'), '&lt;script&gt;alert(1)&lt;/script&gt;'));
test('escapa &', () => assert.equal(esc('SOS & TOUR'), 'SOS &amp; TOUR'));
test('escapa aspas duplas', () => assert.equal(esc('"ola"'), '&quot;ola&quot;'));
test('escapa aspas simples', () => assert.equal(esc("it's ok"), 'it&#39;s ok'));
test('null retorna string vazia', () => assert.equal(esc(null), ''));
test('undefined retorna string vazia', () => assert.equal(esc(undefined), ''));
test('número é convertido', () => assert.equal(esc(42), '42'));
test('string limpa não é alterada', () => assert.equal(esc('Olá Mundo'), 'Olá Mundo'));

// ── cur() — formatação de moeda ──────────────────────────────
console.log('\n💰 cur()');
test('zero retorna R$ 0', () => assert.equal(cur(0), 'R$ 0'));
test('null retorna R$ 0', () => assert.equal(cur(null), 'R$ 0'));
test('começa com R$', () => assert.ok(cur(1999.99).startsWith('R$')));
test('arredonda para inteiro (sem centavos)', () => assert.ok(!cur(599.6).includes('.')));
test('undefined retorna R$ 0', () => assert.equal(cur(undefined), 'R$ 0'));

// ── renderPagination() ───────────────────────────────────────
console.log('\n📄 renderPagination()');
test('página única (total <= perPage) retorna vazio', () => assert.equal(renderPagination(1, 10, 15, 'p', 'n'), ''));
test('zero itens retorna vazio', () => assert.equal(renderPagination(1, 0, 15, 'p', 'n'), ''));
test('múltiplas páginas retorna HTML', () => assert.ok(renderPagination(1, 20, 15, 'p', 'n').includes('pg-nav')));
test('mostra total correto', () => assert.ok(renderPagination(1, 42, 15, 'p', 'n').includes('42 registros')));
test('página 1 desabilita botão anterior', () => assert.ok(renderPagination(1, 30, 15, 'p', 'n').includes('disabled')));
test('última página desabilita próximo', () => assert.match(renderPagination(2, 30, 15, 'p', 'n'), /disabled[^>]*>Próx/));
test('página intermediária não desabilita nenhum', () => {
  const html = renderPagination(2, 45, 15, 'p', 'n');
  const disabled = (html.match(/disabled/g) || []).length;
  assert.equal(disabled, 0);
});

// ── fmtDate() — timezone Brasil ──────────────────────────────
console.log('\n🕐 fmtDate()');
test('null retorna —', () => assert.equal(fmtDate(null), '—'));
test('undefined retorna —', () => assert.equal(fmtDate(undefined), '—'));
test('string vazia retorna —', () => assert.equal(fmtDate(''), '—'));
test('retorna string com o ano', () => assert.ok(fmtDate('2025-01-15T12:00:00Z').includes('2025')));
test('formato dd/mm/aaaa hh:mm', () => assert.match(fmtDate('2025-06-01T10:00:00Z'), /\d{2}\/\d{2}\/\d{4}/));

// ── Resultado ─────────────────────────────────────────────────
const total = passed + failed;
console.log(`\n${'─'.repeat(44)}`);
console.log(`${total} testes: ${passed} ✅  ${failed} ❌`);
if (failed > 0) { console.error('\nFALHOU\n'); process.exit(1); }
else console.log('\nOK\n');
