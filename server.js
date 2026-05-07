const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

const SUPABASE_URL = process.env.SUPABASE_URL || '';
const SUPABASE_KEY = process.env.SUPABASE_KEY || '';
const SENTRY_DSN   = process.env.SENTRY_DSN   || '';

if (!SUPABASE_URL || !SUPABASE_KEY) {
  console.warn('AVISO: SUPABASE_URL ou SUPABASE_KEY não configurados nas variáveis de ambiente do Railway.');
}

const htmlTemplate = fs.readFileSync(path.join(__dirname, 'index.html'), 'utf8');

app.get('/', (req, res) => {
  const html = htmlTemplate
    .replace("'__SUPABASE_URL__'", `'${SUPABASE_URL}'`)
    .replace("'__SUPABASE_KEY__'", `'${SUPABASE_KEY}'`)
    .replace("'__SENTRY_DSN__'",   `'${SENTRY_DSN}'`);
  res.type('html').send(html);
});

app.use(express.static(__dirname));

app.listen(PORT, () => {
  console.log(`SOS Tur rodando na porta ${PORT}`);
});
