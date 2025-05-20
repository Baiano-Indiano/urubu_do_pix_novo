-- Tabela de contas para saldo
create table if not exists accounts (
  user_id uuid references auth.users(id) primary key,
  balance float8 not null default 30000.0
);

-- Tabela de transferências (histórico)
create table if not exists transfers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id),
  destinatario text not null,
  valor float8 not null,
  moeda text,
  valor_original float8,
  data timestamp with time zone default now()
);
