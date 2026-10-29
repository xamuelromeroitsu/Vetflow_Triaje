create extension if not exists pgcrypto;

create table if not exists public.user_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  role text not null default 'dueno' check (role in ('dueno', 'personal')),
  owner_id uuid,
  company_id text,
  created_at timestamptz not null default now()
);

create table if not exists public.owners (
  id text primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  phone text not null,
  email text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

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

create index if not exists pets_owner_id_idx on public.pets(owner_id);
create index if not exists visits_owner_status_created_idx
  on public.visits(owner_id, status, created_at);
create index if not exists visits_company_status_created_idx
  on public.visits(company_id, status, created_at);
create index if not exists clinics_specialties_idx
  on public.clinics using gin(specialties);
create index if not exists clinics_emergency_24h_idx
  on public.clinics(emergency_24h);

create or replace function public.user_is_personal_for_company(target_company text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.user_profiles profile
    where profile.id = auth.uid()
      and profile.role = 'personal'
      and profile.company_id = target_company
  );
$$;

create or replace function public.set_visit_owner()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.owner_id is null then
    select pet.owner_id
      into new.owner_id
      from public.pets pet
      where pet.id = new.pet_id;
  end if;
  return new;
end;
$$;

create or replace function public.staff_can_access_pet(target_pet_id text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.visits visit
    where visit.pet_id = target_pet_id
      and public.user_is_personal_for_company(visit.company_id)
  );
$$;

create or replace function public.create_user_profile()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.user_profiles (id, email, role, owner_id)
  values (new.id, coalesce(new.email, ''), 'dueno', new.id)
  on conflict (id) do nothing;
  return new;
end;
$$;

create or replace function public.prevent_profile_role_change()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if coalesce(auth.role(), '') <> 'service_role'
    and (
      new.role is distinct from old.role
      or new.owner_id is distinct from old.owner_id
      or new.company_id is distinct from old.company_id
    ) then
    raise exception 'Profile authorization fields cannot be changed by the client';
  end if;
  return new;
end;
$$;

create or replace function public.user_owns_pet(target_pet_id text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.pets pet
    where pet.id = target_pet_id
      and pet.owner_id = auth.uid()
  );
$$;

create or replace function public.protect_visit_updates()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  old_level integer;
  new_level integer;
begin
  if coalesce(auth.role(), '') <> 'service_role' then
    if new.pet_id is distinct from old.pet_id
      or new.owner_id is distinct from old.owner_id
      or new.company_id is distinct from old.company_id then
      raise exception 'Visit ownership and clinic cannot be changed by the client';
    end if;

    if auth.uid() = old.owner_id
      and (
        new.triage is distinct from old.triage
        or new.status is distinct from old.status
        or new.assigned_room is distinct from old.assigned_room
        or new.assigned_veterinarian is distinct from old.assigned_veterinarian
        or new.position is distinct from old.position
      ) then
      raise exception 'Only clinic staff can update triage or queue fields';
    end if;

    if public.user_is_personal_for_company(old.company_id) then
      old_level := case old.triage->>'suggested'
        when 'consulta' then 1
        when 'urgencia' then 2
        when 'emergencia' then 3
        else 0
      end;
      new_level := case new.triage->>'suggested'
        when 'consulta' then 1
        when 'urgencia' then 2
        when 'emergencia' then 3
        else 0
      end;
      if new_level < old_level then
        raise exception 'Suggested triage level cannot be lowered';
      end if;
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists set_visit_owner_before_write on public.visits;
create trigger set_visit_owner_before_write
  before insert or update of pet_id on public.visits
  for each row execute function public.set_visit_owner();

drop trigger if exists on_auth_user_created_profile on auth.users;
create trigger on_auth_user_created_profile
  after insert on auth.users
  for each row execute function public.create_user_profile();

drop trigger if exists prevent_profile_role_change on public.user_profiles;
create trigger prevent_profile_role_change
  before update on public.user_profiles
  for each row execute function public.prevent_profile_role_change();

drop trigger if exists protect_visit_updates on public.visits;
create trigger protect_visit_updates
  before update on public.visits
  for each row execute function public.protect_visit_updates();

alter table public.user_profiles enable row level security;
alter table public.owners enable row level security;
alter table public.pets enable row level security;
alter table public.visits enable row level security;
alter table public.clinics enable row level security;

drop policy if exists "read own profile" on public.user_profiles;
create policy "read own profile"
  on public.user_profiles for select to authenticated
  using (id = auth.uid());
drop policy if exists "insert own owner profile" on public.user_profiles;
create policy "insert own owner profile"
  on public.user_profiles for insert to authenticated
  with check (id = auth.uid() and role = 'dueno');
drop policy if exists "update own profile" on public.user_profiles;
create policy "update own profile"
  on public.user_profiles for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

drop policy if exists "owner reads own owner record" on public.owners;
create policy "owner reads own owner record"
  on public.owners for select to authenticated
  using (owner_id = auth.uid());
drop policy if exists "owner creates own owner record" on public.owners;
create policy "owner creates own owner record"
  on public.owners for insert to authenticated
  with check (owner_id = auth.uid() and id = auth.uid()::text);
drop policy if exists "owner updates own owner record" on public.owners;
create policy "owner updates own owner record"
  on public.owners for update to authenticated
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid() and id = auth.uid()::text);

drop policy if exists "owners and assigned staff read pets" on public.pets;
create policy "owners and assigned staff read pets"
  on public.pets for select to authenticated
  using (
    owner_id = auth.uid()
    or public.staff_can_access_pet(id)
  );
drop policy if exists "owners create own pets" on public.pets;
create policy "owners create own pets"
  on public.pets for insert to authenticated
  with check (owner_id = auth.uid());
drop policy if exists "owners update own pets" on public.pets;
create policy "owners update own pets"
  on public.pets for update to authenticated
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());

drop policy if exists "owners and clinic staff read visits" on public.visits;
create policy "owners and clinic staff read visits"
  on public.visits for select to authenticated
  using (
    owner_id = auth.uid()
    or public.user_is_personal_for_company(company_id)
  );
drop policy if exists "owners create own visits" on public.visits;
create policy "owners create own visits"
  on public.visits for insert to authenticated
  with check (
    owner_id = auth.uid()
    and public.user_owns_pet(pet_id)
  );
drop policy if exists "owners and clinic staff update visits" on public.visits;
create policy "owners and clinic staff update visits"
  on public.visits for update to authenticated
  using (
    owner_id = auth.uid()
    or public.user_is_personal_for_company(company_id)
  )
  with check (
    owner_id = auth.uid()
    or public.user_is_personal_for_company(company_id)
  );

drop trigger if exists prevent_owner_triage_confirmation on public.visits;

drop policy if exists "authenticated users read clinics" on public.clinics;
create policy "authenticated users read clinics"
  on public.clinics for select to authenticated
  using (true);
drop policy if exists "clinic staff manage own clinic" on public.clinics;
create policy "clinic staff manage own clinic"
  on public.clinics for all to authenticated
  using (public.user_is_personal_for_company(id))
  with check (public.user_is_personal_for_company(id));

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('pet-photos', 'pet-photos', false, 5242880, array['image/jpeg', 'image/png'])
on conflict (id) do update
set public = false,
    file_size_limit = 5242880,
    allowed_mime_types = array['image/jpeg', 'image/png'];

drop policy if exists "owners read own pet photos" on storage.objects;
create policy "owners read own pet photos"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'pet-photos'
    and (storage.foldername(name))[1] = 'mascotas'
    and (
      public.user_owns_pet((storage.foldername(name))[2])
      or public.staff_can_access_pet((storage.foldername(name))[2])
    )
  );
drop policy if exists "owners upload own pet photos" on storage.objects;
create policy "owners upload own pet photos"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'pet-photos'
    and (storage.foldername(name))[1] = 'mascotas'
    and (storage.foldername(name))[3] = 'fotos'
    and public.user_owns_pet((storage.foldername(name))[2])
    and metadata->>'mimetype' in ('image/jpeg', 'image/png')
    and coalesce((metadata->>'size')::bigint, 0) <= 5242880
  );
drop policy if exists "owners delete own pet photos" on storage.objects;
create policy "owners delete own pet photos"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'pet-photos'
    and (storage.foldername(name))[1] = 'mascotas'
    and public.user_owns_pet((storage.foldername(name))[2])
  );

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'visits'
  ) then
    alter publication supabase_realtime add table public.visits;
  end if;
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'user_profiles'
  ) then
    alter publication supabase_realtime add table public.user_profiles;
  end if;
end;
$$;
