-- Casos de atención y triaje: signos, fotos, nivel sugerido y estado de cola.
create table if not exists public.visits (
  id text primary key default gen_random_uuid()::text,
  pet_id text not null references public.pets(id) on delete restrict,
  owner_id uuid references auth.users(id) on delete restrict,
  company_id text,
  red_flags jsonb,
  symptoms jsonb,
  vitals jsonb,
  photos text[] not null default '{}',
  triage jsonb not null default '{}' check (
    coalesce(triage->>'suggested', 'consulta')
      in ('consulta', 'urgencia', 'emergencia')
  ),
  status text not null default 'pendiente' check (
    status in ('pendiente', 'en_atencion', 'atendido', 'cancelado')
  ),
  assigned_room text,
  assigned_veterinarian text,
  position integer,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.visits is
  'Casos de atención y triaje de una mascota, incluidos sus datos clínicos, nivel sugerido y estado de atención.';

create index if not exists visits_owner_status_created_idx
  on public.visits(owner_id, status, created_at);
create index if not exists visits_company_status_created_idx
  on public.visits(company_id, status, created_at);
