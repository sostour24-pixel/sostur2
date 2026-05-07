-- =====================================================
-- SOS TUR — SCHEMA DO BANCO DE DADOS (Supabase)
-- Cole este SQL no Supabase > SQL Editor > Run
-- =====================================================

-- AGÊNCIAS CLIENTES
create table if not exists public.sos_agencies (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  resp        text not null,
  wpp         text not null,
  email       text not null,
  city        text not null,
  plan        text not null default 'Profissional',
  price       integer not null default 599,
  status      text not null default 'active',
  tickets     integer default 0,
  created_at  timestamptz default now()
);

-- CHAMADOS / TICKETS
create table if not exists public.sos_tickets (
  id           uuid primary key default gen_random_uuid(),
  num          text not null,
  type         text not null,
  priority     text not null default 'P2',
  pax          text not null,
  npax         integer default 1,
  flight       text not null,
  location     text,
  description  text not null,
  pax_phone    text,
  my_phone     text,
  agency_id    uuid references public.sos_agencies(id) on delete cascade,
  agency_name  text not null,
  status       text not null default 'open',
  assigned_to  text,
  sla_minutes  integer default 20,
  resolved_at  timestamptz,
  created_at   timestamptz default now()
);

-- EQUIPE DE PLANTÃO
create table if not exists public.sos_team (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  wpp         text not null,
  shift       text not null default 'Escala rotativa',
  spec        text not null default 'Geral',
  status      text not null default 'available',
  created_at  timestamptz default now()
);

-- MENSAGENS DE CHAT
create table if not exists public.sos_chat_messages (
  id          uuid primary key default gen_random_uuid(),
  ticket_id   uuid references public.sos_tickets(id) on delete cascade,
  from_type   text not null,
  sender_name text,
  message     text not null,
  created_at  timestamptz default now()
);

-- USUÁRIOS DO SISTEMA
create table if not exists public.sos_users (
  id          uuid primary key default gen_random_uuid(),
  email       text not null unique,
  name        text not null,
  role        text not null default 'agency',
  agency_id   uuid references public.sos_agencies(id) on delete set null,
  agency_name text,
  active      boolean default true,
  created_at  timestamptz default now()
);

-- ── ÍNDICES PARA PERFORMANCE ──────────────────
create index if not exists idx_tickets_agency   on public.sos_tickets(agency_id);
create index if not exists idx_tickets_status   on public.sos_tickets(status);
create index if not exists idx_tickets_priority on public.sos_tickets(priority);
create index if not exists idx_team_status      on public.sos_team(status);
create index if not exists idx_users_email      on public.sos_users(email);
create index if not exists idx_users_role       on public.sos_users(role);

-- ── FUNÇÕES AUXILIARES PARA RLS ───────────────
-- Retorna o role do usuário autenticado (security definer para bypassar RLS recursivo)
create or replace function public.get_my_role()
returns text language sql security definer stable as $$
  select role from public.sos_users
  where email = (auth.jwt() ->> 'email')
  limit 1;
$$;

-- Retorna o agency_id do usuário autenticado
create or replace function public.get_my_agency_id()
returns uuid language sql security definer stable as $$
  select agency_id from public.sos_users
  where email = (auth.jwt() ->> 'email')
  limit 1;
$$;

-- ── HABILITAR RLS ─────────────────────────────
alter table public.sos_agencies      enable row level security;
alter table public.sos_tickets       enable row level security;
alter table public.sos_team          enable row level security;
alter table public.sos_chat_messages enable row level security;
alter table public.sos_users         enable row level security;

-- ── REMOVER POLÍTICAS ANTIGAS (se existirem) ──
drop policy if exists "allow all sos_agencies"      on public.sos_agencies;
drop policy if exists "allow all sos_tickets"       on public.sos_tickets;
drop policy if exists "allow all sos_team"          on public.sos_team;
drop policy if exists "allow all sos_chat_messages" on public.sos_chat_messages;
drop policy if exists "allow all sos_users"         on public.sos_users;

-- ── POLÍTICAS: sos_agencies ───────────────────
-- Ops veem e gerenciam tudo
create policy "ops gerencia agencias"
  on public.sos_agencies for all
  using (public.get_my_role() = 'ops')
  with check (public.get_my_role() = 'ops');

-- Agências veem apenas sua própria agência
create policy "agencia ve a propria"
  on public.sos_agencies for select
  using (id = public.get_my_agency_id());

-- Usuários anônimos podem inserir apenas leads (formulário de contato da landing)
create policy "anon insere lead"
  on public.sos_agencies for insert
  to anon
  with check (status = 'lead');

-- Usuários anônimos podem contar agências (contador da landing page)
create policy "anon ve contagem agencias"
  on public.sos_agencies for select
  to anon
  using (true);

-- ── POLÍTICAS: sos_tickets ────────────────────
-- Ops gerenciam todos os tickets
create policy "ops gerencia tickets"
  on public.sos_tickets for all
  using (public.get_my_role() = 'ops')
  with check (public.get_my_role() = 'ops');

-- Agências gerenciam apenas os próprios tickets
create policy "agencia gerencia proprios tickets"
  on public.sos_tickets for all
  using (agency_id = public.get_my_agency_id())
  with check (agency_id = public.get_my_agency_id());

-- Anônimos podem ver contagem de tickets (landing page)
create policy "anon ve contagem tickets"
  on public.sos_tickets for select
  to anon
  using (true);

-- ── POLÍTICAS: sos_team ───────────────────────
-- Apenas ops gerenciam a equipe
create policy "ops gerencia equipe"
  on public.sos_team for all
  using (public.get_my_role() = 'ops')
  with check (public.get_my_role() = 'ops');

-- ── POLÍTICAS: sos_chat_messages ──────────────
-- Ops gerenciam todas as mensagens
create policy "ops gerencia chat"
  on public.sos_chat_messages for all
  using (public.get_my_role() = 'ops')
  with check (public.get_my_role() = 'ops');

-- Agências gerenciam mensagens dos próprios tickets
create policy "agencia gerencia proprio chat"
  on public.sos_chat_messages for all
  using (
    ticket_id in (
      select id from public.sos_tickets
      where agency_id = public.get_my_agency_id()
    )
  )
  with check (
    ticket_id in (
      select id from public.sos_tickets
      where agency_id = public.get_my_agency_id()
    )
  );

-- ── POLÍTICAS: sos_users ──────────────────────
-- Ops gerenciam todos os usuários
create policy "ops gerencia usuarios"
  on public.sos_users for all
  using (public.get_my_role() = 'ops')
  with check (public.get_my_role() = 'ops');

-- Cada usuário vê apenas seu próprio perfil
create policy "usuario ve proprio perfil"
  on public.sos_users for select
  using (email = (auth.jwt() ->> 'email'));

-- ── USUÁRIOS DE DEMONSTRAÇÃO ──────────────────
-- Para criar via Supabase: Authentication > Users > Add user
-- Email: agencia@demo.com / Senha: defina no painel do Supabase Auth
-- Email: ops@demo.com     / Senha: defina no painel do Supabase Auth
-- Depois vincule na tabela sos_users:
insert into public.sos_users (email, name, role) values
  ('agencia@demo.com', 'Agência Demo',  'agency'),
  ('ops@demo.com',     'Operador Demo', 'ops')
on conflict (email) do nothing;
