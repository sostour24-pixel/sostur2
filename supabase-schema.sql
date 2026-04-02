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

-- MENSAGENS DE CHAT (opcional, para persistir o chat)
create table if not exists public.sos_chat_messages (
  id          uuid primary key default gen_random_uuid(),
  ticket_id   uuid references public.sos_tickets(id) on delete cascade,
  from_type   text not null, -- 'agency' ou 'ops'
  sender_name text,
  message     text not null,
  created_at  timestamptz default now()
);

-- ── HABILITAR RLS (Row Level Security) ────────
-- Por enquanto deixamos aberto para facilitar o desenvolvimento.
-- Em produção, adicione políticas por usuário autenticado.

alter table public.sos_agencies      enable row level security;
alter table public.sos_tickets       enable row level security;
alter table public.sos_team          enable row level security;
alter table public.sos_chat_messages enable row level security;

-- Política temporária: acesso total (troque por políticas reais em produção)
create policy "allow all sos_agencies"      on public.sos_agencies      for all using (true) with check (true);
create policy "allow all sos_tickets"       on public.sos_tickets       for all using (true) with check (true);
create policy "allow all sos_team"          on public.sos_team          for all using (true) with check (true);
create policy "allow all sos_chat_messages" on public.sos_chat_messages for all using (true) with check (true);

-- ── ÍNDICES PARA PERFORMANCE ──────────────────
create index if not exists idx_tickets_agency   on public.sos_tickets(agency_id);
create index if not exists idx_tickets_status   on public.sos_tickets(status);
create index if not exists idx_tickets_priority on public.sos_tickets(priority);
create index if not exists idx_team_status      on public.sos_team(status);

-- ── USUÁRIOS DO SISTEMA (login e controle de acesso) ──────
create table if not exists public.sos_users (
  id          uuid primary key default gen_random_uuid(),
  email       text not null unique,
  name        text not null,
  role        text not null default 'agency', -- 'agency' ou 'ops'
  agency_id   uuid references public.sos_agencies(id) on delete set null,
  agency_name text,
  active      boolean default true,
  created_at  timestamptz default now()
);

alter table public.sos_users enable row level security;
create policy "allow all sos_users" on public.sos_users for all using (true) with check (true);
create index if not exists idx_users_email on public.sos_users(email);
create index if not exists idx_users_role  on public.sos_users(role);

-- Inserir usuários de demonstração (senha gerenciada pelo Supabase Auth)
-- Para criar via Supabase: Authentication > Users > Add user
-- Email: agencia@demo.com / Senha: demo123
-- Email: ops@demo.com     / Senha: demo123
-- Depois vincule na tabela sos_users:
insert into public.sos_users (email, name, role) values
  ('agencia@demo.com', 'Agência Demo',  'agency'),
  ('ops@demo.com',     'Operador Demo', 'ops')
on conflict (email) do nothing;
