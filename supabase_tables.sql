-- Tabela de usuários
create table if not exists users (
  user_id uuid references auth.users(id) primary key,
  nome text not null,
  email text unique not null,
  cpf text unique not null,
  telefone text,
  tipo_pessoa text default 'fisica',
  foto text,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

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

-- Função para atualizar o timestamp de updated_at
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Trigger para atualizar o updated_at automaticamente
create trigger update_users_updated_at
  before update on users
  for each row
  execute function update_updated_at_column();
