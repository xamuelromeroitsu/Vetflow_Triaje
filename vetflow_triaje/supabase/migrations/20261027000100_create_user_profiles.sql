-- Perfil de la aplicación asociado a una cuenta de Supabase Auth.
create table if not exists public.user_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  role text not null default 'dueno' check (role in ('dueno', 'personal')),
  owner_id uuid,
  company_id text,
  created_at timestamptz not null default now()
);

comment on table public.user_profiles is
  'Perfil de la aplicación para una cuenta de Supabase Auth; guarda el rol y las asociaciones de dueño o clínica.';
