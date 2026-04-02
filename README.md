# 🚨 SOS Tur — Sistema de Plantão 24h para Agências de Viagens

Sistema completo com 3 módulos:
1. **Site de vendas** — para vender para agências
2. **Portal da agência** — agência abre chamados 24/7
3. **Central de operações** — sua equipe atende e resolve

---

## ⚡ COMO PUBLICAR (passo a passo)

### PASSO 1 — Criar conta no Supabase (banco de dados)

1. Acesse **supabase.com** e clique em **"Start your project"**
2. Faça login com o Google
3. Clique em **"New project"**
4. Dê um nome (ex: `sostur`) e escolha uma senha
5. Aguarde 2 minutos enquanto cria o projeto

### PASSO 2 — Criar as tabelas do banco

1. No painel do Supabase, clique em **"SQL Editor"** (menu esquerdo)
2. Clique em **"New query"**
3. Abra o arquivo `supabase-schema.sql` deste projeto
4. Copie todo o conteúdo e cole no editor
5. Clique em **"Run"** (botão verde)
6. Deve aparecer "Success. No rows returned."

### PASSO 3 — Pegar as credenciais do Supabase

1. No painel do Supabase, vá em **"Project Settings"** (ícone de engrenagem)
2. Clique em **"API"**
3. Você vai ver:
   - **Project URL** — algo como `https://xyzxyz.supabase.co`
   - **anon public** — uma chave longa
4. Copie os dois valores

### PASSO 4 — Colocar as credenciais no sistema

1. Abra o arquivo `index.html` no Bloco de Notas (ou VS Code)
2. Encontre estas duas linhas (lá no começo do `<script>`):

```javascript
const SUPABASE_URL = window.SUPABASE_URL || 'https://SEU_PROJETO.supabase.co';
const SUPABASE_KEY = window.SUPABASE_ANON_KEY || 'SUA_ANON_KEY_AQUI';
```

3. Substitua:
   - `https://SEU_PROJETO.supabase.co` → pelo seu **Project URL**
   - `SUA_ANON_KEY_AQUI` → pela sua **anon public key**

4. Salve o arquivo

### PASSO 5 — Publicar no Vercel

1. Acesse **vercel.com** e faça login com o Google
2. Clique em **"Add New Project"**
3. Escolha **"Deploy from your computer"** ou arraste a pasta inteira
4. Clique em **Deploy**
5. Aguarde 1-2 minutos
6. Pronto! Você terá um link como `sostur-abc123.vercel.app`

---

## ✅ Testando se funcionou

1. Abra o link do Vercel
2. No **Site de vendas**, preencha o formulário e clique em "Cadastrar agência"
3. Vá para **Portal da agência** e abra um chamado
4. Vá para **Central de operações** — o chamado deve aparecer lá
5. Clique em "Assumir chamado" e depois "Marcar resolvido"

Se tudo aparecer, o banco está funcionando! 🎉

---

## 🌐 Usar domínio próprio (opcional)

1. No painel do Vercel, acesse seu projeto
2. Clique em **"Settings"** → **"Domains"**
3. Digite seu domínio (ex: `sostur.com.br`)
4. Siga as instruções para apontar o DNS
5. Seu site ficará em `sostur.com.br`

Domínio `.com.br` no Registro.br custa ~R$40/ano.

---

## 💰 Custo total para funcionar

| Serviço | Plano | Custo |
|---------|-------|-------|
| Supabase | Free (até 500MB) | R$ 0/mês |
| Vercel | Hobby (grátis) | R$ 0/mês |
| Domínio .com.br | — | R$ 40/ano |
| **Total para começar** | | **R$ 0/mês** |

Só paga quando escalar (muitos usuários).

---

## 📁 Arquivos do projeto

```
sostur-deploy/
├── index.html          ← Sistema completo (abra no navegador para testar)
├── vercel.json         ← Configuração do Vercel
├── supabase-schema.sql ← SQL para criar as tabelas
└── README.md           ← Este arquivo
```

---

## 🆘 Precisa de ajuda?

Se travar em algum passo, você pode:
1. Testar o `index.html` direto no navegador (sem banco, como demo)
2. Voltar ao Claude e descrever onde travou
