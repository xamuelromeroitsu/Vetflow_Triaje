-- Datos de contacto del dueño vinculados a su cuenta.
create table if not exists public.owners (
  id text primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  phone text not null,
  email text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.owners is
  'Datos de contacto del dueño de mascotas, vinculados a su cuenta de Supabase Auth.';
