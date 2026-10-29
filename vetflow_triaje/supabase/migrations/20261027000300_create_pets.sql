-- Mascotas registradas por sus dueños y sus antecedentes básicos.
create table if not exists public.pets (
  id text primary key default gen_random_uuid()::text,
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  species text not null check (
    species in ('perro', 'gato', 'huron', 'conejo', 'ave', 'roedor', 'reptil')
  ),
  breed text not null,
  age_months integer not null check (age_months >= 0),
  sex text,
  neutered boolean,
  weight_kg double precision,
  history text,
  allergies text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.pets is
  'Mascotas registradas por los dueños, con especie, datos básicos y antecedentes relevantes.';

create index if not exists pets_owner_id_idx on public.pets(owner_id);
