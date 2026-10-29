-- Directorio de clínicas, con datos de contacto, horarios y servicios.
create table if not exists public.clinics (
  id text primary key default gen_random_uuid()::text,
  name text not null,
  address text not null,
  phone text not null,
  email text,
  specialties text[] not null default '{}',
  hours jsonb not null default '{}',
  emergency_24h boolean not null default false,
  services text[] not null default '{}',
  latitude double precision,
  longitude double precision,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.clinics is
  'Directorio de clínicas veterinarias con contacto, ubicación, horarios, especialidades y servicios.';

create index if not exists clinics_specialties_idx
  on public.clinics using gin(specialties);
create index if not exists clinics_emergency_24h_idx
  on public.clinics(emergency_24h);
